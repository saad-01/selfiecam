import 'package:hive/hive.dart';
import 'package:selfiecam1/data/models/branding_model.dart';

class SettingsLocalRepository {

  Future<SettingsModel> processAndStore(SettingsModel settings) async {
    final updatedSettings = SettingsModel(
      privacyPolicyUrl: settings.privacyPolicyUrl,
      photoReleaseAgreementUrl: settings.photoReleaseAgreementUrl,
      termsUrl: settings.termsUrl,
      explicitDisclaimerEnabled: settings.explicitDisclaimerEnabled,
    );

    final box = await Hive.openBox('settingsBox');
    await box.put('settings', updatedSettings.toJson());

    return updatedSettings;
  }
}
