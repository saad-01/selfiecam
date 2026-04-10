// lib/features/upload/models/upload_status.dart
//
// Enum representing every stage an UploadQueueItem can be in.
// Includes a hand-written Hive TypeAdapter (typeId = 50) so no build_runner
// run is required.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:hive/hive.dart';

// ── Enum ─────────────────────────────────────────────────────────────────────

enum UploadStatus {
  /// Waiting in the queue – not yet attempted.
  pending,

  /// Currently being sent to the server.
  uploading,

  /// Server confirmed success.
  completed,

  /// Exhausted all retry attempts; requires manual intervention.
  failed,

  /// User explicitly cancelled before completion.
  cancelled,
}

// ── Hand-written Hive TypeAdapter (typeId = 50) ───────────────────────────────

class UploadStatusAdapter extends TypeAdapter<UploadStatus> {
  @override
  final int typeId = 50;

  @override
  UploadStatus read(BinaryReader reader) {
    final index = reader.readByte();
    switch (index) {
      case 0:
        return UploadStatus.pending;
      case 1:
        return UploadStatus.uploading;
      case 2:
        return UploadStatus.completed;
      case 3:
        return UploadStatus.failed;
      case 4:
        return UploadStatus.cancelled;
      default:
        // Defensive default – treat unknown values as pending so the queue
        // processor will retry rather than silently drop the item.
        return UploadStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, UploadStatus obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
