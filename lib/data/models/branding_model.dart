import 'package:selfiecam1/data/models/branding_email_model.dart';

class Branding {
  final String id;
  final String eventId;

  final String buttonColor;
  final String buttonTextColor;
  final String buttonStyle;

  final String fontFamily;
  final String fontColor;

  final String? homeOverlay;
  final String? photoVideoOverlay;
  final String? promoVideo;

  final bool enablePromoBoomerang;
  final bool enablePromoShoutout;
  final bool enablePromoAnimatedGif;
  final bool enablePromoSlowmo;

  final String? backgroundAudio;
  final bool enableAudioBoomerang;
  final bool enableAudioGif;
  final bool enableAudioSlowmo;
  final double fontSize;
  final BrandingEmail contentEmail;
  final BrandingEmail thankYouEmail;

  final String smsMessage;

  final DateTime createdAt;
  final DateTime updatedAt;

  Branding({
    required this.id,
    required this.eventId,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.buttonStyle,
    required this.fontFamily,
    required this.fontColor,
    this.homeOverlay,
    this.photoVideoOverlay,
    this.promoVideo,
    required this.enablePromoBoomerang,
    required this.enablePromoShoutout,
    required this.enablePromoAnimatedGif,
    required this.enablePromoSlowmo,
    this.backgroundAudio,
    required this.enableAudioBoomerang,
    required this.enableAudioGif,
    required this.enableAudioSlowmo,
    required this.contentEmail,
    required this.thankYouEmail,
    required this.smsMessage,
    required this.createdAt,
    required this.updatedAt,
    required this.fontSize,
  });

  factory Branding.fromJson(Map<String, dynamic> json) {
    return Branding(
      id: json['_id'] ?? '',
      eventId: json['eventId'] ?? '',
      buttonColor: json['buttonColor'] ?? '',
      buttonTextColor: json['buttonTextColor'] ?? '',
      buttonStyle: json['buttonStyle'] ?? '',
      fontFamily: json['fontFamily'] ?? '',
      fontColor: json['fontColor'] ?? '',
      fontSize: json['fontSize'] != null ? (json['fontSize'] as num).toDouble() : 18.0,
      homeOverlay: json['homeOverlay'],
      photoVideoOverlay: json['photoVideoOverlay'],
      promoVideo: json['promoVideo'],
      enablePromoBoomerang: json['enablePromoBoomerang'] ?? false,
      enablePromoShoutout: json['enablePromoShoutout'] ?? false,
      enablePromoAnimatedGif: json['enablePromoAnimatedGif'] ?? false,
      enablePromoSlowmo: json['enablePromoSlowmo'] ?? false,
      backgroundAudio: json['backgroundAudio'],
      enableAudioBoomerang: json['enableAudioBoomerang'] ?? false,
      enableAudioGif: json['enableAudioGif'] ?? false,
      enableAudioSlowmo: json['enableAudioSlowmo'] ?? false,
      contentEmail: BrandingEmail.fromJson(json['contentEmail'] ?? {}),
      thankYouEmail: BrandingEmail.fromJson(json['thankYouEmail'] ?? {}),
      smsMessage: json['smsMessage'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'eventId': eventId,
      'buttonColor': buttonColor,
      'buttonTextColor': buttonTextColor,
      'buttonStyle': buttonStyle,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'fontColor': fontColor,
      'homeOverlay': homeOverlay,
      'photoVideoOverlay': photoVideoOverlay,
      'promoVideo': promoVideo,
      'enablePromoBoomerang': enablePromoBoomerang,
      'enablePromoShoutout': enablePromoShoutout,
      'enablePromoAnimatedGif': enablePromoAnimatedGif,
      'enablePromoSlowmo': enablePromoSlowmo,
      'backgroundAudio': backgroundAudio,
      'enableAudioBoomerang': enableAudioBoomerang,
      'enableAudioGif': enableAudioGif,
      'enableAudioSlowmo': enableAudioSlowmo,
      'contentEmail': contentEmail.toJson(),
      'thankYouEmail': thankYouEmail.toJson(),
      'smsMessage': smsMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
