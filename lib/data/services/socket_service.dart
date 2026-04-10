import 'dart:io';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/controller/settings_controller.dart';
import 'package:selfiecam1/data/models/branding_model.dart';
import 'package:selfiecam1/data/models/experiences_model.dart';
import 'package:selfiecam1/data/models/lead_model.dart';
import 'package:selfiecam1/data/services/branding_service.dart';
import 'package:selfiecam1/data/services/experience_service.dart';
import 'package:selfiecam1/data/services/lead_capture_service.dart';
import 'package:selfiecam1/data/services/settings_service.dart';
import 'package:selfiecam1/infrastructure/constants/api_endpoints.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../infrastructure/utils/logger.dart';

class SocketService extends GetxService {
  static late io.Socket socket;
  static RxInt connectedId = 0.obs;
  static RxBool initializedSocket = false.obs;
  static RxBool callEvents = false.obs;
  static RxInt conversationId = 0.obs;
  static RxInt currentRoomId = 0.obs;
  static List<int> tempIdList = [];
  static Future<void> init() async {
    Logger.log("Socket Service Initialized");
    // var id = MainHomeController.to.profileData['user']['id'];
    socket = io.io(
      ApiUrls.socketUrl,
      io.OptionBuilder()
          .setPath('/socket.io') // ✅ add this line
          .setTransports(['websocket']) // optional
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setTimeout(20000)
          .setAuth({'token': PrefUtils().getUserToken()})
          .setQuery({'deviceId': PrefUtils().getString("deviceId")})
          .build(),
    );
    try {
      // socket.
      socket.connect();
      Logger.log("Connection Established ${{"authorization": 'Bearer ${PrefUtils().getUserToken()}'}.toString()}");
    } catch (e) {
      Logger.log(e.toString());
      Logger.log("Error Connecting To Server");
    }
    socket.onConnect((data) {
      initializedSocket.value = true;
      Logger.log("@@@@@@@@@@@@@@@@@@@Connection established");
      Logger.log(socket.connected.toString());
      socket.emit('getUserDetails', {});
      if (connectedId.value != 0) {}
    });
    socket.onAny((event, payload) => {Logger.log("EVENT: $event payload: $payload")});
    socket.onConnectError((data) {
      Logger.log("Error while connecting $data");
      // MyToast.error("msg_something_wrong");
    });
    socket.onDisconnect((data) {
      initializedSocket.value = false;
      SocketService.socket.emit("event:leave", {"eventId": PrefUtils().getString("eventId")});
      Logger.log("@@@Diconnected from the server: $data");
    });
    socket.on('device:removed', (data) async {
      DeviceController.to.clearSession();
      await PrefUtils().clearPreferencesData();

      /// 1️⃣ Clear Hive boxes
      if (Hive.isBoxOpen("brandingBox")) {
        await Hive.box("brandingBox").clear();
      }

      if (Hive.isBoxOpen("experiencesBox")) {
        await Hive.box("experiencesBox").clear();
      }
      SettingsController.to.resetAllSettings();

      /// 2️⃣ Delete downloaded media folder
      final dir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory("${dir.path}/event_media");

      if (await mediaDir.exists()) {
        await mediaDir.delete(recursive: true);
      }
      Get.offAllNamed(Routes.SIGNIN);
    });
    socket.on('event:branding-updated', (data) async {
      Logger.log("Received branding update from server");
      Logger.log("Received ${data['branding']['homeNoActivityVideo']}");
      final BrandingLocalRepository brandingRepo = BrandingLocalRepository();
      final processedBranding = await brandingRepo.processAndStore(Branding.fromJson(data['branding']));

      DeviceController.to.branding.value = processedBranding;
      DeviceController.to.update();
      if (DeviceController.to.branding.value!.homeVideo != null && DeviceController.to.branding.value!.homeVideo!.isNotEmpty) {
        await DeviceController.to.initVideoPreviewForOverlay(DeviceController.to.branding.value!.homeVideo!);
      } else {
        DeviceController.to.videoControllerForOverlay.value?.pause();
        DeviceController.to.videoControllerForOverlay.value?.seekTo(Duration.zero);
        DeviceController.to.videoControllerForOverlay.value = null;
      }
      if (DeviceController.to.branding.value!.homeNoActivityVideo != null &&
          DeviceController.to.branding.value!.homeNoActivityVideo!.isNotEmpty) {
        DeviceController.to.resetIdleTimer();
        await DeviceController.to.initVideoPreviewForActivity(DeviceController.to.branding.value!.homeNoActivityVideo!);
        DeviceController.to.startIdleTimer();
      } else {
        DeviceController.to.isIdle.value = false;
        DeviceController.to.videoControllerForActivity.value?.pause();
        DeviceController.to.videoControllerForActivity.value?.seekTo(Duration.zero);
        DeviceController.to.videoControllerForActivity.value = null;
        DeviceController.to.clearTimer();
      }
    });
    socket.on('event:experiences-updated', (data) async {
      Logger.log("Received experiences update from server");
      final ExperiencesLocalRepository experiencesRepo = ExperiencesLocalRepository();
      final processedExperiences = await experiencesRepo.processAndStore(Experiences.fromJson(data['experiences']));

      DeviceController.to.experiences.value = processedExperiences;
      DeviceController.to.update();
    });
    socket.on('leadCapture:config-updated', (data) async {
      Logger.log("Received lead capture config update from server");
      final LeadCaptureLocalRepository configRepo = LeadCaptureLocalRepository();
      final processedConfig = await configRepo.processAndStore(LeadCaptureConfig.fromJson(data['config']));

      DeviceController.to.leadCaptureConfig.value = processedConfig;
      DeviceController.to.update();
    });
    socket.on('settings:disclaimers-updated', (data) async {
      Logger.log("Received disclaimers update from server");
      final disclaimersRepo = SettingsLocalRepository();
      final processedDisclaimers = await disclaimersRepo.processAndStore(SettingsModel.fromJson(data['disclaimers']));

      DeviceController.to.settings.value = processedDisclaimers;
      DeviceController.to.update();
    });
  }
}
