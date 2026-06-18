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
  final String? homeScreenMode;
  final String? homeVideo;
  final String? homeNoActivityVideo;
  final String? homeImage;

  final bool enablePromoBoomerang;
  final bool enablePromoShoutout;
  final bool enablePromoAnimatedGif;
  final bool enablePromoSlowmo;

  final String? backgroundAudio;
  final bool enableAudioBoomerang;
  final bool enableAudioGif;
  final bool enableAudioSlowmo;
  final double fontSize;

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
    this.homeScreenMode,
    this.homeVideo,
    this.homeImage,
    this.homeNoActivityVideo,
    required this.enablePromoBoomerang,
    required this.enablePromoShoutout,
    required this.enablePromoAnimatedGif,
    required this.enablePromoSlowmo,
    this.backgroundAudio,
    required this.enableAudioBoomerang,
    required this.enableAudioGif,
    required this.enableAudioSlowmo,
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
      homeVideo: json['homeVideo'],
      homeNoActivityVideo: json['homeNoActivityVideo'],
      homeImage: json['homeImage'],
      homeScreenMode: json['homeScreenMode'],
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
      'homeVideo': homeVideo,
      'homeNoActivityVideo': homeNoActivityVideo,
      'homeImage': homeImage,
      'homeScreenMode': homeScreenMode,
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
      'smsMessage': smsMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SettingsModel {
  final String privacyPolicyUrl;
  final String photoReleaseAgreementUrl;
  final String termsUrl;
  final bool explicitDisclaimerEnabled;

  SettingsModel({
    required this.privacyPolicyUrl,
    required this.photoReleaseAgreementUrl,
    required this.termsUrl,
    required this.explicitDisclaimerEnabled,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      termsUrl: json['termsUrl'] ?? '',
      privacyPolicyUrl: json['privacyPolicyUrl'] ?? '',
      photoReleaseAgreementUrl: json['photoAgreementURL'] ?? '',
      explicitDisclaimerEnabled: json['explicitDisclaimerEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "explicitDisclaimerEnabled": explicitDisclaimerEnabled,
      "privacyPolicyUrl": privacyPolicyUrl,
      "termsUrl": termsUrl,
      "photoAgreementURL": photoReleaseAgreementUrl,
    };
  }
}
