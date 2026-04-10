// lib/features/upload/models/upload_queue_item.dart
//
// Persistent Hive record for a single pending / in-progress / completed upload.
//
// Design notes
// ────────────
// • `id` doubles as the client-side `media_id` sent in every API request so the
//   server can echo it back and you can correlate queue items with DB records.
// • Chunked-upload resume state (chunkUploadId, nextChunkIndex, chunkSize,
//   totalChunks) is persisted after every chunk so the queue processor can pick
//   up exactly where it left off after an app restart or connectivity loss.
// • `listOnGallery` – previously absent from the model; added here at
//   @HiveField(16) so existing boxes without this field read a safe default
//   (false → will be treated as true by the adapter's null-coerce logic).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:hive/hive.dart';

import 'lead_capture.dart';
import 'upload_status.dart';

part 'upload_queue_item.g.dart';

@HiveType(typeId: 52)
class UploadQueueItem extends HiveObject {
  // ── Identity ──────────────────────────────────────────────────────────────

  /// UUID generated client-side.  Sent to the server as `media_id` and echoed
  /// back in the response so we can match the server record to this queue item.
  @HiveField(0)
  String id;

  // ── File metadata ─────────────────────────────────────────────────────────

  /// Absolute path to the local file (e.g. from image_picker or camera).
  @HiveField(1)
  String filePath;

  /// Original filename, e.g. "wedding-video.mp4".
  @HiveField(2)
  String fileName;

  /// Total byte size.  Drives the single-vs-chunked routing decision.
  @HiveField(3)
  int fileSize;

  /// MIME type, e.g. "image/jpeg", "video/mp4".
  @HiveField(4)
  String mimeType;

  // ── Upload parameters (sent verbatim to API) ──────────────────────────────

  /// Event name used for server-side folder structure.
  @HiveField(5)
  String eventName;

  /// Whether to run Sharp compression on the server (sent as 'true'/'false').
  @HiveField(6)
  bool compress;

  /// Optional lead-capture payload attached to this upload.
  @HiveField(7)
  dynamic leadCapture;

  // ── Queue state ───────────────────────────────────────────────────────────

  @HiveField(8)
  UploadStatus status;

  /// Number of times this item has been attempted and failed.
  @HiveField(9)
  int retryCount;

  /// When the item was added to the queue (used for FIFO ordering).
  @HiveField(10)
  DateTime createdAt;

  /// Last time status / progress changed.
  @HiveField(11)
  DateTime? updatedAt;

  // ── Server response (populated on success) ────────────────────────────────

  /// MongoDB `_id` returned by the server after a successful upload.
  @HiveField(12)
  String? serverMediaId;

  /// CDN URL, e.g. "https://cdn.example.com/images/...".
  @HiveField(13)
  String? mediaUrl;

  /// Shareable link, e.g. "https://selfiecam.ai/social/<_id>".
  @HiveField(14)
  String? imageLink;

  // ── Error tracking ────────────────────────────────────────────────────────

  @HiveField(15)
  String? errorMessage;

  // ── Gallery visibility ────────────────────────────────────────────────────

  /// Controls whether this upload appears in the in-app gallery.
  /// Previously absent from the model – added at @HiveField(16).
  /// Existing Hive boxes that lack this field will default to `true`
  /// via the adapter's null-coerce.
  @HiveField(16)
  bool listOnGallery;

  // ── Chunked-upload resume state ───────────────────────────────────────────

  /// The `uploadId` returned by `/api/image/chunk/init`.
  /// Non-null only for large files routed through the chunked path.
  @HiveField(17)
  String? chunkUploadId;

  /// 0-based index of the next chunk to send.
  /// 0 means no chunks have been uploaded yet.
  /// Persisted after every successful chunk so uploads are resumable.
  @HiveField(18)
  int nextChunkIndex;

  /// Server-dictated chunk size in bytes (from `data.chunkSize` in init
  /// response).  Falls back to 5 MB if the server does not return it.
  @HiveField(19)
  int chunkSize;

  /// Total number of chunks (from `data.totalChunks` in init response).
  @HiveField(20)
  int? totalChunks;

  // ── Progress ──────────────────────────────────────────────────────────────

  /// Upload progress in the range [0.0, 1.0].
  @HiveField(21)
  double uploadProgress;

  // ── Constructor ───────────────────────────────────────────────────────────

  UploadQueueItem({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.eventName,
    this.compress = true,
    this.leadCapture,
    this.status = UploadStatus.pending,
    this.retryCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.serverMediaId,
    this.mediaUrl,
    this.imageLink,
    this.errorMessage,
    this.listOnGallery = true,
    this.chunkUploadId,
    this.nextChunkIndex = 0,
    this.chunkSize = 5 * 1024 * 1024, // 5 MB default
    this.totalChunks,
    this.uploadProgress = 0.0,
  });

  // ── Routing helper ────────────────────────────────────────────────────────

  /// Files ≥ 20 MB are routed through the chunked upload path.
  static const int chunkThresholdBytes = 20 * 1024 * 1024; // 20 MB

  bool get requiresChunkedUpload => fileSize >= chunkThresholdBytes;

  /// True when a chunked upload has been initialised but not yet completed.
  bool get isChunkResumable =>
      requiresChunkedUpload &&
      chunkUploadId != null &&
      nextChunkIndex > 0 &&
      totalChunks != null &&
      nextChunkIndex < totalChunks!;

  // ── Convenience ───────────────────────────────────────────────────────────

  bool get isPending => status == UploadStatus.pending;
  bool get isUploading => status == UploadStatus.uploading;
  bool get isCompleted => status == UploadStatus.completed;
  bool get isFailed => status == UploadStatus.failed;
  bool get isCancelled => status == UploadStatus.cancelled;

  @override
  String toString() =>
      'UploadQueueItem(id: $id, file: $fileName, status: $status, '
      'progress: ${(uploadProgress * 100).toStringAsFixed(1)}%)';
}
