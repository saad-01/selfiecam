class BrandingEmail {
  final String subject;
  final String heading;
  final String? body;

  BrandingEmail({
    required this.subject,
    required this.heading,
    this.body,
  });

  factory BrandingEmail.fromJson(Map<String, dynamic> json) {
    return BrandingEmail(
      subject: json['subject'] ?? '',
      heading: json['heading'] ?? '',
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'heading': heading,
      'body': body,
    };
  }
}
