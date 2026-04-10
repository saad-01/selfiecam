class ApiUrls {
  /// STAGING
  // static const String baseUrl = 'https://gettogether.staging.pegasync.com/api/';

  /// LIVE
  static const String baseUrl = 'https://hub.selfiecam.ai/api/';
  static const String socketUrl = 'https://hub.selfiecam.ai';

  static const String login = 'devices/login';
  static const String getEvents = 'events/dropdown';
  static const String joinEvent = 'devices';
  static const String joinEventDetails = 'devices/joined/event';
  static const String uploadImage = 'image/upload';
  static const String aiGenerateStyle = 'ai/generate-style';
  static const String imageUploadAiStyle = 'image/upload/ai-style';
  static const String settingsDisclaimers = 'settings/disclaimers';
  static const String leadCaptureContacts = 'lead-capture/leads/contacts';
}
