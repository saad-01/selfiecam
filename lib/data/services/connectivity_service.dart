// lib/features/upload/services/connectivity_service.dart
//
// Abstract interface for your existing connectivity service.
//
// Wire up your concrete implementation (connectivity_plus, custom BLoC, etc.)
// and inject it into UploadQueueService.  The upload system only depends on
// this interface – nothing is imported from connectivity_plus here.
// ─────────────────────────────────────────────────────────────────────────────

/// Minimum contract the upload system requires from your connectivity service.
abstract class ConnectivityService {
  /// Current connection status.  `true` = online, `false` = offline.
  bool get isOnline;

  /// Broadcast stream that emits:
  ///   • `true`  when the device gains internet access
  ///   • `false` when internet access is lost
  Stream<bool> get onConnectivityChanged;
}

// ─────────────────────────────────────────────────────────────────────────────
// UploadCredentials & CredentialsProvider
// ─────────────────────────────────────────────────────────────────────────────
//
// Wrap the three auth values the API requires:
//   • deviceToken  → Authorization: Bearer <token>
//   • eventToken   → x-auth-event: <token>
//   • baseUrl      → e.g. "https://hub.selfiecam.ai"
//
// Implement CredentialsProvider in your auth / session layer and inject it into
// UploadQueueService.

class UploadCredentials {
  final String deviceToken;
  final String eventToken;

  /// API base URL – no trailing slash.
  /// e.g. "https://hub.selfiecam.ai"
  final String baseUrl;

  const UploadCredentials({
    required this.deviceToken,
    required this.eventToken,
    required this.baseUrl,
  });

  /// Full path prefix for image upload endpoints.
  String get imageBase => '$baseUrl/api/image';
}

/// Provides credentials to the upload service on demand.
/// Return `null` if the user is not authenticated.
abstract class CredentialsProvider {
  Future<UploadCredentials?> getCredentials();
}
