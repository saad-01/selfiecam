// lib/features/upload/services/upload_repository.dart
//
// Handles all HTTP communication with the SelfieCam upload API.
//
// Endpoints implemented (mirroring the Mobile Upload API reference exactly):
//   POST /api/image/upload            – single file < 20 MB
//   POST /api/image/chunk/init        – start a chunked session
//   POST /api/image/chunk/upload      – send one 5–10 MB slice
//   POST /api/image/chunk/complete    – finalise and assemble
//
// Auth headers sent on every request:
//   Authorization : Bearer <deviceToken>
//   x-auth-event  : <eventToken>
//   x-app-secret  : <static constant>
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/web.dart';
import 'package:selfiecam1/controller/cam_controller.dart';

import '../models/lead_capture.dart';
import '../models/upload_queue_item.dart';
import 'connectivity_service.dart';

// ── Result types ─────────────────────────────────────────────────────────────

class UploadResult {
  /// MongoDB `_id` of the created EventImage record.
  final String id;

  /// CDN URL, e.g. "https://cdn.example.com/images/..."
  final String? mediaUrl;

  /// Shareable link, e.g. "https://selfiecam.ai/social/<id>"
  final String? imageLink;

  const UploadResult({required this.id, this.mediaUrl, this.imageLink});
}

class ChunkInitResult {
  /// Server-issued session token used for all subsequent chunk calls.
  final String uploadId;

  /// Server-dictated slice size in bytes (typically 5 MB or 10 MB).
  final int chunkSize;

  /// Total number of slices the server expects.
  final int totalChunks;

  const ChunkInitResult({required this.uploadId, required this.chunkSize, required this.totalChunks});
}

// ── Repository ────────────────────────────────────────────────────────────────

class UploadRepository {
  // Hardcoded app secret – matches the value in the API reference.
  static const String _appSecret = 'e7053b3b07076b7e9949faa0c6978697721b0995';

  final Dio _dio;

  UploadRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(minutes: 5),
              sendTimeout: const Duration(minutes: 5),
            ),
          );

  // ── Private helpers ───────────────────────────────────────────────────────

  Map<String, String> _authHeaders(UploadCredentials creds) => {
    'Authorization': 'Bearer ${creds.deviceToken}',
    'x-auth-event': creds.eventToken,
    'x-app-secret': _appSecret,
  };

  /// Throws a [UploadApiException] if the response body signals failure.
  void _assertSuccess(Response response) {
    final body = response.data;
    if (body is Map && body['success'] == true) return;

    final msg = body is Map
        ? (body['message'] ?? body['error'] ?? 'Unknown API error').toString()
        : 'HTTP ${response.statusCode}';
    throw UploadApiException(msg, statusCode: response.statusCode);
  }

  // ── 1. Single upload ──────────────────────────────────────────────────────
  //
  // POST /api/image/upload
  // Content-Type: multipart/form-data
  //
  // Fields: media, eventName, compress, media_id, [leadCapture]

  Future<UploadResult> singleUpload(
    UploadQueueItem item,
    UploadCredentials creds, {
    void Function(double progress)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'media': await MultipartFile.fromFile(item.filePath, filename: item.fileName),
      'eventName': item.eventName,
      'compress': item.compress ? 'true' : 'false',
      'media_id': item.id, // client-side UUID echoed back as media_id
      'leadCapture': jsonEncode(item.leadCapture),
      'captureType': CameraControllerX.to.captureType.value,
      'listOnGallery': item.listOnGallery,
    });
    print("FormData: ${formData.fields}, Files: ${formData.files}");
    print("LeadCapture JSON: ${jsonEncode(item.leadCapture)}");

    final response = await _dio.post(
      '${creds.imageBase}/upload',
      data: formData,
      options: Options(headers: _authHeaders(creds)),
      onSendProgress: onProgress != null
          ? (sent, total) {
              if (total > 0) onProgress(sent / total);
            }
          : null,
    );

    _assertSuccess(response);

    final data = response.data['data'] as Map<String, dynamic>;
    return UploadResult(id: data['id'] as String, mediaUrl: data['mediaUrl'] as String?, imageLink: data['imageLink'] as String?);
  }

  // ── 2. Chunk init ─────────────────────────────────────────────────────────
  //
  // POST /api/image/chunk/init
  // Content-Type: application/json
  //
  // Body: filename, fileSize, mimeType, eventName, [media_id]

  Future<ChunkInitResult> chunkInit(UploadQueueItem item, UploadCredentials creds) async {
    final response = await _dio.post(
      '${creds.imageBase}/chunk/init',
      data: {
        'filename': item.fileName,
        'fileSize': item.fileSize,
        'mimeType': item.mimeType,
        'eventName': item.eventName,
        'media_id': item.id,
      },
      options: Options(headers: {..._authHeaders(creds), 'Content-Type': 'application/json'}),
    );

    _assertSuccess(response);

    final data = response.data['data'] as Map<String, dynamic>;
    return ChunkInitResult(
      uploadId: data['uploadId'] as String,
      // Honour the server's dictated chunk size; fall back to 5 MB.
      chunkSize: (data['chunkSize'] as int?) ?? (5 * 1024 * 1024),
      totalChunks: data['totalChunks'] as int,
    );
  }

  // ── 3. Upload one chunk ───────────────────────────────────────────────────
  //
  // POST /api/image/chunk/upload
  // Content-Type: multipart/form-data
  //
  // Fields: chunk (binary slice), uploadId, chunkIndex

  Future<void> uploadChunk({
    required String filePath,
    required String uploadId,
    required int chunkIndex,
    required int chunkSize,
    required int fileSize,
    required UploadCredentials creds,
    void Function(double progress)? onProgress,
  }) async {
    final start = chunkIndex * chunkSize;
    final end = (start + chunkSize).clamp(0, fileSize);
    final length = end - start;

    // Read only the bytes for this slice – avoids loading the whole file.
    final file = File(filePath);
    final raf = await file.open();
    await raf.setPosition(start);
    final bytes = await raf.read(length);
    await raf.close();

    final formData = FormData.fromMap({
      'chunk': MultipartFile.fromBytes(bytes, filename: 'chunk-$chunkIndex'),
      'uploadId': uploadId,
      'chunkIndex': chunkIndex.toString(),
    });

    final response = await _dio.post(
      '${creds.imageBase}/chunk/upload',
      data: formData,
      options: Options(headers: _authHeaders(creds)),
      onSendProgress: onProgress != null
          ? (sent, total) {
              if (total > 0) onProgress(sent / total);
            }
          : null,
    );

    _assertSuccess(response);
  }

  // ── 4. Complete chunked upload ────────────────────────────────────────────
  //
  // POST /api/image/chunk/complete
  // Content-Type: application/json
  //
  // Body: uploadId, eventName, compress, [leadCapture]

  Future<UploadResult> chunkComplete({
    required String uploadId,
    required String eventName,
    required UploadCredentials creds,
    LeadCapture? leadCapture,
  }) async {
    final body = <String, dynamic>{
      'uploadId': uploadId,
      'eventName': eventName,
      'compress': 'false', // Server reassembles; compression is handled there
      'leadCapture': leadCapture,
      'captureType': CameraControllerX.to.captureType.value,
      'listOnGallery': CameraControllerX.to.publishToPublic.value, // Chunked uploads are not listed in gallery
    };

    final response = await _dio.post(
      '${creds.imageBase}/chunk/complete',
      data: body,
      options: Options(headers: {..._authHeaders(creds), 'Content-Type': 'application/json'}),
    );

    _assertSuccess(response);

    final data = response.data['data'] as Map<String, dynamic>;
    return UploadResult(id: data['id'] as String, mediaUrl: data['mediaUrl'] as String?, imageLink: data['imageLink'] as String?);
  }

  // ── Utility ───────────────────────────────────────────────────────────────

  MediaType _mediaType(String mimeType) {
    try {
      return MediaType.parse(mimeType);
    } catch (_) {
      return MediaType('application', 'octet-stream');
    }
  }
}

// ── Exception ─────────────────────────────────────────────────────────────────

class UploadApiException implements Exception {
  final String message;
  final int? statusCode;

  const UploadApiException(this.message, {this.statusCode});

  @override
  String toString() => 'UploadApiException(${statusCode != null ? '$statusCode ' : ''}$message)';
}
