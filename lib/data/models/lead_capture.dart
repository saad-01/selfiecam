// lib/features/upload/models/lead_capture.dart
//
// Mirrors the leadCapture payload documented in the SelfieCam Mobile Upload API
// reference (section 4 – Lead Capture).  All fields are nullable / optional;
// which fields are actually required is determined server-side by the event's
// lead-capture config.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:hive/hive.dart';

part 'lead_capture.g.dart';

@HiveType(typeId: 51)
class LeadCapture extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  String? email;

  @HiveField(2)
  String? phone;

  @HiveField(3)
  String? company;

  /// Instagram handle, e.g. "@janesmith"
  @HiveField(4)
  String? instagram;

  /// TikTok handle, e.g. "@janesmith"
  @HiveField(5)
  String? tiktok;

  /// Marketing / data-processing consent flag.
  @HiveField(6)
  bool consentGiven;

  LeadCapture({
    this.name,
    this.email,
    this.phone,
    this.company,
    this.instagram,
    this.tiktok,
    this.consentGiven = true,
  });

  // ── Serialisation helpers ────────────────────────────────────────────────

  /// Produces the JSON object expected by the server's `leadCapture` field.
  /// Null / empty values are omitted so the payload stays clean.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'consentGiven': consentGiven};
    if (name != null && name!.isNotEmpty) map['name'] = name;
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (phone != null && phone!.isNotEmpty) map['phone'] = phone;
    if (company != null && company!.isNotEmpty) map['company'] = company;
    if (instagram != null && instagram!.isNotEmpty) map['instagram'] = instagram;
    if (tiktok != null && tiktok!.isNotEmpty) map['tiktok'] = tiktok;
    return map;
  }

  /// Returns `true` when at least one identifying field is present.
  bool get hasContent =>
      (name?.isNotEmpty ?? false) ||
      (email?.isNotEmpty ?? false) ||
      (phone?.isNotEmpty ?? false) ||
      (company?.isNotEmpty ?? false) ||
      (instagram?.isNotEmpty ?? false) ||
      (tiktok?.isNotEmpty ?? false);

  @override
  String toString() => 'LeadCapture(name: $name, email: $email)';
}
