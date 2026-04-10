import 'package:get/get.dart';
import 'package:hive/hive.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();
  late Box box;

  final RxMap<String, bool> settings = <String, bool>{}.obs;

  final keys = const ['photo', 'boomerang', 'gif', 'shoutout', 'slowmo', 'ai'];

  @override
  void onInit() {
    box = Hive.box('experience_settings');

    /// ✅ initialize all keys with default true if null
    for (var key in keys) {
      settings[key] = box.get(key, defaultValue: true) as bool;
    }

    super.onInit();
  }

  Future<void> resetAllSettings() async {
    final box = await Hive.openBox("experience_settings");
    await box.clear();

    // Optional: reset controller memory as well
    for (var key in keys) {
      settings[key] = true; // default ON
    }
  }

  bool isEnabled(String key, bool apiValue) {
    return settings[key] ?? apiValue;
  }

  void toggle(String key, bool value) {
    settings[key] = value;
    box.put(key, value);
  }
}
