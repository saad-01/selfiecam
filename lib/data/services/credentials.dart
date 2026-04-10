import 'package:selfiecam1/data/services/connectivity_service.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';

class MyCredentialsProvider implements CredentialsProvider {
  MyCredentialsProvider();

  @override
  Future<UploadCredentials?> getCredentials() async {
    return UploadCredentials(
      deviceToken: PrefUtils().getString("deviceToken") ?? '',
      eventToken: PrefUtils().getString("eventToken") ?? '',
      baseUrl: 'https://hub.selfiecam.ai',
    );
  }
}
