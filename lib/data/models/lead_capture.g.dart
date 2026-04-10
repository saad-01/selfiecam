// lib/features/upload/models/lead_capture.g.dart
//
// Hand-written Hive TypeAdapter for LeadCapture (typeId = 51).
// This is functionally identical to what `hive_generator` would emit.
// You do NOT need to run build_runner to use this file.
// ─────────────────────────────────────────────────────────────────────────────
// ignore_for_file: type=lint

part of 'lead_capture.dart';

class LeadCaptureAdapter extends TypeAdapter<LeadCapture> {
  @override
  final int typeId = 51;

  @override
  LeadCapture read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeadCapture(
      name: fields[0] as String?,
      email: fields[1] as String?,
      phone: fields[2] as String?,
      company: fields[3] as String?,
      instagram: fields[4] as String?,
      tiktok: fields[5] as String?,
      consentGiven: fields[6] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, LeadCapture obj) {
    writer
      ..writeByte(7) // field count
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.company)
      ..writeByte(4)
      ..write(obj.instagram)
      ..writeByte(5)
      ..write(obj.tiktok)
      ..writeByte(6)
      ..write(obj.consentGiven);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeadCaptureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
