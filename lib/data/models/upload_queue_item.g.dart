// lib/features/upload/models/upload_queue_item.g.dart
//
// Hand-written Hive TypeAdapter for UploadQueueItem (typeId = 52).
// Functionally identical to what `hive_generator` would produce.
// Ready to use without running build_runner.
//
// Field registry (do not renumber existing fields – Hive is index-based):
//   0  id               String
//   1  filePath         String
//   2  fileName         String
//   3  fileSize         int
//   4  mimeType         String
//   5  eventName        String
//   6  compress         bool
//   7  leadCapture      LeadCapture?
//   8  status           UploadStatus
//   9  retryCount       int
//  10  createdAt        DateTime
//  11  updatedAt        DateTime?
//  12  serverMediaId    String?
//  13  mediaUrl         String?
//  14  imageLink        String?
//  15  errorMessage     String?
//  16  listOnGallery    bool          ← previously absent; added here
//  17  chunkUploadId    String?
//  18  nextChunkIndex   int
//  19  chunkSize        int
//  20  totalChunks      int?
//  21  uploadProgress   double
// ─────────────────────────────────────────────────────────────────────────────
// ignore_for_file: type=lint

part of 'upload_queue_item.dart';

class UploadQueueItemAdapter extends TypeAdapter<UploadQueueItem> {
  @override
  final int typeId = 52;

  @override
  UploadQueueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return UploadQueueItem(
      id: fields[0] as String,
      filePath: fields[1] as String,
      fileName: fields[2] as String,
      fileSize: fields[3] as int,
      mimeType: fields[4] as String,
      eventName: fields[5] as String,
      compress: fields[6] as bool? ?? true,
      leadCapture: fields[7] as dynamic,
      status: fields[8] as UploadStatus? ?? UploadStatus.pending,
      retryCount: fields[9] as int? ?? 0,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime?,
      serverMediaId: fields[12] as String?,
      mediaUrl: fields[13] as String?,
      imageLink: fields[14] as String?,
      errorMessage: fields[15] as String?,
      // Field 16 may be absent in boxes written before this field was added;
      // default to true so existing items remain visible in the gallery.
      listOnGallery: fields[16] as bool? ?? true,
      chunkUploadId: fields[17] as String?,
      nextChunkIndex: fields[18] as int? ?? 0,
      chunkSize: fields[19] as int? ?? (5 * 1024 * 1024),
      totalChunks: fields[20] as int?,
      uploadProgress: fields[21] as double? ?? 0.0,
    );
  }

  @override
  void write(BinaryWriter writer, UploadQueueItem obj) {
    writer
      ..writeByte(22) // total field count
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.fileSize)
      ..writeByte(4)
      ..write(obj.mimeType)
      ..writeByte(5)
      ..write(obj.eventName)
      ..writeByte(6)
      ..write(obj.compress)
      ..writeByte(7)
      ..write(obj.leadCapture)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.retryCount)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.serverMediaId)
      ..writeByte(13)
      ..write(obj.mediaUrl)
      ..writeByte(14)
      ..write(obj.imageLink)
      ..writeByte(15)
      ..write(obj.errorMessage)
      ..writeByte(16)
      ..write(obj.listOnGallery)
      ..writeByte(17)
      ..write(obj.chunkUploadId)
      ..writeByte(18)
      ..write(obj.nextChunkIndex)
      ..writeByte(19)
      ..write(obj.chunkSize)
      ..writeByte(20)
      ..write(obj.totalChunks)
      ..writeByte(21)
      ..write(obj.uploadProgress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadQueueItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
