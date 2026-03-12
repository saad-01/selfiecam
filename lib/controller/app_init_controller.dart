import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/infrastructure/utils/api_client.dart';
import 'package:selfiecam1/infrastructure/utils/loader.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';

class AppInitController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _init();
  }

  Future<void> _init() async {
    // Yield first frame (critical for iOS debug)
    await Future.delayed(Duration.zero);

    await dotenv.load(fileName: "assets/config/.env");

    await PrefUtils().init();

    await ApiCalls.initialize();

    await Get.putAsync<LoaderService>(() async => LoaderService());

    await Get.putAsync<DeviceController>(() async => DeviceController());
  }
}
