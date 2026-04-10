class LeadCaptureConfig {
  final String id;
  final String eventId;
  final String status;
  final DateTime? deletedAt;

  final bool emailAutoPopulate;
  final LeadFields fields;

  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  LeadCaptureConfig({
    required this.id,
    required this.eventId,
    required this.status,
    this.deletedAt,
    required this.emailAutoPopulate,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory LeadCaptureConfig.fromJson(dynamic json) {
    return LeadCaptureConfig(
      id: json['_id'] ?? '',
      eventId: json['eventId'] ?? '',
      status: json['status'] ?? '',
      deletedAt:
          json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      emailAutoPopulate: json['emailAutoPopulate'] ?? false,
      fields: LeadFields.fromJson(json['fields'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'eventId': eventId,
      'status': status,
      'deletedAt': deletedAt?.toIso8601String(),
      'emailAutoPopulate': emailAutoPopulate,
      'fields': fields.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}
class LeadFields {
  final LeadField company;
  final LeadField consent;
  final LeadField email;
  final LeadField instagram;
  final LeadField name;
  final LeadField phone;
  final LeadField tiktok;

  LeadFields({
    required this.company,
    required this.consent,
    required this.email,
    required this.instagram,
    required this.name,
    required this.phone,
    required this.tiktok,
  });

  factory LeadFields.fromJson(dynamic json) {
    return LeadFields(
      company: LeadField.fromJson(json['company'] ?? {}),
      consent: LeadField.fromJson(json['consent'] ?? {}),
      email: LeadField.fromJson(json['email'] ?? {}),
      instagram: LeadField.fromJson(json['instagram'] ?? {}),
      name: LeadField.fromJson(json['name'] ?? {}),
      phone: LeadField.fromJson(json['phone'] ?? {}),
      tiktok: LeadField.fromJson(json['tiktok'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company': company.toJson(),
      'consent': consent.toJson(),
      'email': email.toJson(),
      'instagram': instagram.toJson(),
      'name': name.toJson(),
      'phone': phone.toJson(),
      'tiktok': tiktok.toJson(),
    };
  }
}
class LeadField {
  final bool enabled;
  final bool required;

  LeadField({
    required this.enabled,
    required this.required,
  });

  factory LeadField.fromJson(dynamic json) {
    return LeadField(
      enabled: json['enabled'] ?? false,
      required: json['required'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'required': required,
    };
  }
}