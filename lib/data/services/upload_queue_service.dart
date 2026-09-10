// lib/features/upload/services/upload_queue_service.dart
//
// UploadQueueService – offline-first upload queue backed by Hive.
//
// Responsibilities
// ────────────────
// • Persists every upload request to Hive so nothing is lost across restarts.
// • Listens to ConnectivityService; resumes processing the moment the device
//   goes online – no polling loop, no busy-waiting.
// • Processes up to [maxConcurrent] uploads simultaneously (fire-and-forget).
// • Routes by file size: < 20 MB → singleUpload, ≥ 20 MB → chunkUpload.
// • Persists chunked-upload progress after every slice so large files are
//   resumable mid-transfer.
// • Retries failed items up to [maxRetries] times before marking them FAILED.
// • Exposes a broadcast stream so the UI can react to status changes without
//   polling Hive directly.
//
// Usage
// ─────
//   final service = UploadQueueService(
//     repository: UploadRepository(),
//     connectivity: myConnectivityService,
//     credentials: myCredentialsProvider,
//   );
//   await service.init();                     // call once at app start
//
//   await service.enqueue(UploadEnqueueRequest(
//     filePath: '/path/to/photo.jpg',
//     fileName: 'photo.jpg',
//     fileSize: 1_024_000,
//     mimeType: 'image/jpeg',
//     eventName: 'Summer Party 2025',
//     compress: true,
//     listOnGallery: true,
//     leadCapture: LeadCapture(name: 'Jane', email: 'jane@example.com', consentGiven: true),
//   ));
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:hive/hive.dart';
import 'package:selfiecam1/infrastructure/utils/logger.dart';
import 'package:uuid/uuid.dart';

import '../models/lead_capture.dart';
import '../models/upload_queue_item.dart';
import '../models/upload_status.dart';
import 'connectivity_service.dart';
import 'upload_repository.dart';

// ── Enqueue request ───────────────────────────────────────────────────────────

/// All data needed to add a new upload to the persistent queue.
class UploadEnqueueRequest {
  final String filePath;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String eventName;
  final bool compress;
  final bool listOnGallery;
  final dynamic leadCapture;

  const UploadEnqueueRequest({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.eventName,
    this.compress = true,
    this.listOnGallery = true,
    this.leadCapture,
  });
}

// ── Service ───────────────────────────────────────────────────────────────────

class UploadQueueService {
  // ── Configuration ─────────────────────────────────────────────────────────

  static const String _boxName = 'sc_upload_queue';

  /// Maximum simultaneous uploads.
  final int maxConcurrent;

  /// Maximum number of retry attempts before a queue item is marked FAILED.
  final int maxRetries;

  // ── Dependencies ──────────────────────────────────────────────────────────

  final UploadRepository _repository;
  final ConnectivityService _connectivity;
  final CredentialsProvider _credentials;

  // ── Internal state ────────────────────────────────────────────────────────

  late Box<UploadQueueItem> _box;
  final _uuid = const Uuid();

  /// IDs of items currently being uploaded (prevents double-dispatching).
  final Set<String> _activeIds = {};

  StreamSubscription<bool>? _connectivitySub;

  // Broadcast so multiple UI widgets can subscribe without interference.
  final _statusController = StreamController<UploadQueueItem>.broadcast();

  // ── Public surface ────────────────────────────────────────────────────────

  /// Emits an [UploadQueueItem] every time its status or progress changes.
  Stream<UploadQueueItem> get onItemUpdated => _statusController.stream;

  /// Live read-only view of every item in the queue.
  Iterable<UploadQueueItem> get allItems => _box.values;

  /// Items that have not yet completed or failed.
  Iterable<UploadQueueItem> get pendingItems =>
      _box.values.where((i) => i.isPending || i.isUploading);

  /// Items that completed successfully.
  Iterable<UploadQueueItem> get completedItems =>
      _box.values.where((i) => i.isCompleted);

  /// Items that exhausted all retries.
  Iterable<UploadQueueItem> get failedItems =>
      _box.values.where((i) => i.isFailed);

  // ── Constructor ───────────────────────────────────────────────────────────

  UploadQueueService({
    required UploadRepository repository,
    required ConnectivityService connectivity,
    required CredentialsProvider credentials,
    this.maxConcurrent = 2,
    this.maxRetries = 5,
  })  : _repository = repository,
        _connectivity = connectivity,
        _credentials = credentials;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Must be called once before using the service, typically in main() or
  /// an app-level provider initialisation.
  Future<void> init() async {
    _box = await Hive.openBox<UploadQueueItem>(_boxName);
    _resetStaleItems();
    _subscribeToConnectivity();
    // Kick off any items that were pending before this session started.
    _processQueue();
  }

  /// Closes the Hive box and cancels the connectivity subscription.
  /// Call this only if you need to completely tear down the service.
  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    await _statusController.close();
    await _box.close();
  }

  // ── Enqueue ───────────────────────────────────────────────────────────────

  /// Persists [request] to Hive and immediately attempts to process the queue.
  /// Returns the generated client-side [UploadQueueItem.id] so callers can
  /// track this specific item via [onItemUpdated].
  Future<String> enqueue(UploadEnqueueRequest request) async {
    final id = _uuid.v4(); // becomes media_id sent to the server

    final item = UploadQueueItem(
      id: id,
      filePath: request.filePath,
      fileName: request.fileName,
      fileSize: request.fileSize,
      mimeType: request.mimeType,
      eventName: request.eventName,
      compress: request.compress,
      listOnGallery: request.listOnGallery,
      leadCapture: request.leadCapture,
      status: UploadStatus.pending,
      createdAt: DateTime.now(),
    );

    await _box.put(id, item);
    _statusController.add(item);

    // Fire-and-forget – the queue processor handles the rest.
    _processQueue();

    return id;
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  /// Marks a pending item as cancelled.  Items currently uploading will finish
  /// their current chunk / request before the cancellation takes effect.
  Future<void> cancel(String id) async {
    final item = _box.get(id);
    if (item == null || item.isCompleted) return;
    await _updateItem(item, status: UploadStatus.cancelled);
  }

  /// Moves a FAILED item back to PENDING and re-triggers the queue.
  Future<void> retry(String id) async {
    final item = _box.get(id);
    if (item == null || !item.isFailed) return;
    item.retryCount = 0;
    item.errorMessage = null;
    await _updateItem(item, status: UploadStatus.pending);
    _processQueue();
  }

  /// Removes completed and failed items from the persistent store.
  Future<void> clearFinished() async {
    final toDelete = _box.values
        .where((i) => i.isCompleted || i.isFailed || i.isCancelled)
        .map((i) => i.id)
        .toList();
    await _box.deleteAll(toDelete);
  }

  // ── Private – connectivity ────────────────────────────────────────────────

  void _subscribeToConnectivity() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        // Back online – resume immediately.
        _processQueue();
      }
      // Offline – active uploads will fail naturally; the retry mechanism
      // ensures they re-queue once connectivity returns.
    });
  }

  // ── Private – queue processor ─────────────────────────────────────────────

  /// Entry point for the queue processor.  Safe to call multiple times;
  /// internally serialised by the _activeIds guard.
  void _processQueue() {
    if (!_connectivity.isOnline) return;

    final available = maxConcurrent - _activeIds.length;
    if (available <= 0) return;

    final candidates = _box.values
        .where((i) => i.isPending && !_activeIds.contains(i.id))
        .toList()
      // FIFO: oldest items first.
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final item in candidates.take(available)) {
      // Mark as active synchronously to prevent double-dispatch before the
      // async upload function gets a chance to run.
      _activeIds.add(item.id);
      // Fire-and-forget – deliberate unawaited call.
      _uploadItem(item);
    }
  }

  // ── Private – upload dispatch ─────────────────────────────────────────────

  Future<void> _uploadItem(UploadQueueItem item) async {
    try {
      final creds = await _credentials.getCredentials();
      if (creds == null) {
        // Not authenticated – leave as pending; will retry on next process call.
        _activeIds.remove(item.id);
        return;
      }

      // Guard: item may have been cancelled while we were fetching credentials.
      final fresh = _box.get(item.id);
      if (fresh == null || fresh.isCancelled) {
        _activeIds.remove(item.id);
        return;
      }

      await _updateItem(item, status: UploadStatus.uploading);

      if (false) {
        Logger.log('Starting chunked upload for ${item.fileName} (${item.fileSize} bytes)');
        await _chunkUpload(item, creds);
      } else {
        Logger.log('Starting single upload for ${item.fileName} (${item.fileSize} bytes)');
        await _singleUpload(item, creds);
      }

      await _updateItem(
        item,
        status: UploadStatus.completed,
        uploadProgress: 1.0,
      );
    } catch (error, stackTrace) {
      print('Upload failed: $error');
      print('Stack trace: $stackTrace');
      await _handleFailure(item, error);
    } finally {
      _activeIds.remove(item.id);
      // Immediately check for more work.
      _processQueue();
    }
  }

  // ── Private – single upload ───────────────────────────────────────────────
  //
  // Used for files < 20 MB.
  // POST /api/image/upload

  Future<void> _singleUpload(
    UploadQueueItem item,
    UploadCredentials creds,
  ) async {
    final result = await _repository.singleUpload(
      item,
      creds,
      onProgress: (progress) {
        item.uploadProgress = progress;
        _statusController.add(item);
      },
    );

    item.serverMediaId = result.id;
    item.mediaUrl = result.mediaUrl;
    item.imageLink = result.imageLink;
    await item.save();
  }

  // ── Private – chunked upload ──────────────────────────────────────────────
  //
  // Used for files ≥ 20 MB.
  // 1. POST /api/image/chunk/init    (skipped if resuming a previous session)
  // 2. POST /api/image/chunk/upload  (repeated for each slice)
  // 3. POST /api/image/chunk/complete

  Future<void> _chunkUpload(
    UploadQueueItem item,
    UploadCredentials creds,
  ) async {
    // ── Step 1: init (only if we don't already have a server uploadId) ──────

    if (item.chunkUploadId == null) {
      final initResult = await _repository.chunkInit(item, creds);
      print('Chunked upload init: ${initResult.toString()}');
      item.chunkUploadId = initResult.uploadId;
      item.chunkSize = initResult.chunkSize;
      item.totalChunks = initResult.totalChunks;
      item.nextChunkIndex = 0;
      item.uploadProgress = 0.0;
      await item.save(); // Persist before any chunks fly so we can resume
    }

    final totalChunks = item.totalChunks!;

    // ── Step 2: upload each remaining chunk ──────────────────────────────────

    while (item.nextChunkIndex < totalChunks) {
      // Re-read from Hive to detect cancellation between chunks.
      final live = _box.get(item.id);
      if (live == null || live.isCancelled) return;

      final chunkIndex = item.nextChunkIndex;

      await _repository.uploadChunk(
        filePath: item.filePath,
        uploadId: item.chunkUploadId!,
        chunkIndex: chunkIndex,
        chunkSize: item.chunkSize,
        fileSize: item.fileSize,
        creds: creds,
        onProgress: (sliceProgress) {
          // Combine overall chunk position with within-chunk progress.
          final overall =
              (chunkIndex + sliceProgress) / totalChunks;
          item.uploadProgress = overall;
          _statusController.add(item);
        },
      );

      item.nextChunkIndex = chunkIndex + 1;
      item.uploadProgress = item.nextChunkIndex / totalChunks;
      // Persist after every chunk so a restart can resume here.
      await item.save();
      _statusController.add(item);
    }
    print('All chunks uploaded for ${item.chunkUploadId}');
    // ── Step 3: complete ─────────────────────────────────────────────────────
// jsonEncode(item.leadCapture),
    final result = await _repository.chunkComplete(
      uploadId: item.chunkUploadId!,
      eventName: item.eventName,
      creds: creds,
      leadCapture: item.leadCapture,
    );

    item.serverMediaId = result.id;
    item.mediaUrl = result.mediaUrl;
    item.imageLink = result.imageLink;
    await item.save();
  }

  // ── Private – failure handling ────────────────────────────────────────────

  Future<void> _handleFailure(UploadQueueItem item, Object error) async {
    item.retryCount++;
    item.errorMessage = error.toString();
    item.updatedAt = DateTime.now();
    if (item.retryCount >= maxRetries) {
      // Exhausted all retries – surface to the UI as FAILED.
      await _updateItem(item, status: UploadStatus.failed);
    } else {
      // Still have retries left – return to PENDING so the next processQueue()
      // call (triggered by the next connectivity event or enqueue) picks it up.
      await _updateItem(item, status: UploadStatus.pending);
    }
  }

  // ── Private – state mutation ──────────────────────────────────────────────

  Future<void> _updateItem(
    UploadQueueItem item, {
    UploadStatus? status,
    double? uploadProgress,
  }) async {
    if (status != null) item.status = status;
    if (uploadProgress != null) item.uploadProgress = uploadProgress;
    item.updatedAt = DateTime.now();
    await item.save(); // HiveObject.save() flushes to the open box
    _statusController.add(item);
  }

  // ── Private – startup cleanup ─────────────────────────────────────────────

  /// Any item that was marked UPLOADING when the app last exited was
  /// interrupted mid-flight.  Reset it to PENDING so the processor retries it.
  /// Chunked uploads retain their progress (chunkUploadId + nextChunkIndex) and
  /// will resume from the last persisted chunk.
  void _resetStaleItems() {
    for (final item in _box.values) {
      if (item.isUploading) {
        item.status = UploadStatus.pending;
        item.save(); // intentionally unawaited here – best-effort cleanup
      }
    }
  }
}
