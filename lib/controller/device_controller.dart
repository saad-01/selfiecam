import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_device_info_plus/flutter_device_info_plus.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/controller/settings_controller.dart';
import 'package:selfiecam1/data/models/branding_model.dart';
import 'package:selfiecam1/data/models/experiences_model.dart';
import 'package:selfiecam1/data/models/lead_model.dart';
import 'package:selfiecam1/data/services/branding_service.dart';
import 'package:selfiecam1/data/services/experience_service.dart';
import 'package:selfiecam1/data/services/internet_service.dart';
import 'package:selfiecam1/data/services/settings_service.dart';
import 'package:selfiecam1/data/services/socket_service.dart';
import 'package:selfiecam1/infrastructure/constants/api_endpoints.dart';
import 'package:selfiecam1/infrastructure/constants/app_assets.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/infrastructure/utils/api_client.dart';
import 'package:selfiecam1/infrastructure/utils/custom_snackbar.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:selfiecam1/presentation/home/ai_style_preview.dart';
import 'package:selfiecam1/presentation/home/countdown_screen.dart';
import 'package:video_player/video_player.dart';

import '../infrastructure/utils/logger.dart';

class DeviceController extends GetxController {
  static DeviceController get to => Get.find();
  final RxBool disclaimerAccepted = false.obs;
  final FlutterDeviceInfoPlus _deviceInfo = const FlutterDeviceInfoPlus();
  final BrandingLocalRepository _brandingRepo = BrandingLocalRepository();
  final SettingsLocalRepository _settingsRepo = SettingsLocalRepository();
  final ExperiencesLocalRepository repo = ExperiencesLocalRepository();
  DeviceInformation? deviceInformation;
  final branding = Rxn<Branding>();
  final experiences = Rxn<Experiences>();
  final leadCaptureConfig = Rxn<LeadCaptureConfig>();
  final settings = Rxn<SettingsModel>();
  BatteryInfo? batteryInfo;
  String? pkgVersion;
  dynamic iosDeviceInfo;
  NetworkInfo? _networkInfo;
  Timer? heartbeatTimer;
  Future<void> loadAllInfo() async {
    try {
      final pkg = await PackageInfo.fromPlatform();
      pkgVersion = pkg.version;
      // Demonstrate all available methods
      final platform = _deviceInfo.getCurrentPlatform();
      final deviceInfo = await _deviceInfo.getDeviceInfo();
      final _batteryInfo = await _deviceInfo.getBatteryInfo();
      final sensorInfo = await _deviceInfo.getSensorInfo();
      final networkInfo = await _deviceInfo.getNetworkInfo();
      debugPrint('========== DEVICE INFO DEBUG START ==========');
      debugPrint('Platform: $platform');

      debugPrint('--- Device Info ---');
      debugPrint('Name: ${deviceInfo.deviceName}');
      debugPrint('Manufacturer: ${deviceInfo.manufacturer}');
      debugPrint('Model: ${deviceInfo.model}');
      debugPrint('Brand: ${deviceInfo.brand}');
      debugPrint('OS: ${deviceInfo.operatingSystem} ${deviceInfo.systemVersion}');
      debugPrint('Build: ${deviceInfo.buildNumber}');
      debugPrint('Kernel: ${deviceInfo.kernelVersion}');

      debugPrint('--- Processor ---');
      debugPrint('Arch: ${deviceInfo.processorInfo.architecture}');
      debugPrint('Cores: ${deviceInfo.processorInfo.coreCount}');
      debugPrint('Max Freq: ${deviceInfo.processorInfo.maxFrequency}');
      debugPrint('Name: ${deviceInfo.processorInfo.processorName}');
      debugPrint('Features: ${deviceInfo.processorInfo.features}');

      debugPrint('--- Memory ---');
      debugPrint('Total RAM: ${deviceInfo.memoryInfo.totalPhysicalMemory}');
      debugPrint('Avail RAM: ${deviceInfo.memoryInfo.availablePhysicalMemory}');
      debugPrint('Total Storage: ${deviceInfo.memoryInfo.totalStorageSpace}');
      debugPrint('Avail Storage: ${deviceInfo.memoryInfo.availableStorageSpace}');

      debugPrint('--- Display ---');
      debugPrint(
        'Screen: ${deviceInfo.displayInfo.screenWidth}x'
        '${deviceInfo.displayInfo.screenHeight}',
      );
      debugPrint('Pixel Ratio: ${deviceInfo.displayInfo.pixelDensity}');
      debugPrint('Refresh Rate: ${deviceInfo.displayInfo.refreshRate}');

      debugPrint('--- Battery ---');
      if (_batteryInfo != null) {
        debugPrint('Level: ${_batteryInfo.batteryLevel}%');
        debugPrint('Status: ${_batteryInfo.chargingStatus}');
        debugPrint('Health: ${_batteryInfo.batteryHealth}');
      } else {
        debugPrint('Battery Info: null');
      }

      debugPrint('--- Sensors ---');
      if (sensorInfo.availableSensors.isEmpty) {
        debugPrint('No sensors available (or empty list returned)');
      } else {
        debugPrint('Sensors: ${sensorInfo.availableSensors}');
      }

      debugPrint('--- Network ---');
      debugPrint('Type: ${networkInfo.connectionType}');
      debugPrint('Speed: ${networkInfo.networkSpeed}');
      debugPrint('Connected: ${networkInfo.isConnected}');
      debugPrint('IP: ${networkInfo.ipAddress}');
      debugPrint('MAC: ${networkInfo.macAddress}');

      debugPrint('========== DEVICE INFO DEBUG END ==========');
      deviceInformation = deviceInfo;
      batteryInfo = _batteryInfo;
      sendHeartbeat(
        batteryLevel: batteryInfo!.batteryLevel,
        batteryCharging: batteryInfo!.isCharging,
        storageTotal: deviceInformation?.memoryInfo.totalStorageSpace,
        storageUsed: deviceInformation?.memoryInfo.usedStorageSpace,
        storageFree: deviceInformation?.memoryInfo.availableStorageSpace,
        wifiConnected: _networkInfo?.isConnected,
        wifiStrength: 92,
        cameraReady: true,
        cameraError: null,
      );
      SocketService.socket.emit("event:join", {"eventId": PrefUtils().getString("eventId")});
      heartbeatTimer = Timer.periodic(Duration(minutes: 1), (timer) {
        sendHeartbeat(
          batteryLevel: batteryInfo!.batteryLevel,
          batteryCharging: batteryInfo!.isCharging,
          storageTotal: deviceInformation?.memoryInfo.totalStorageSpace,
          storageUsed: deviceInformation?.memoryInfo.usedStorageSpace,
          storageFree: deviceInformation?.memoryInfo.availableStorageSpace,
          wifiConnected: _networkInfo?.isConnected,
          wifiStrength: 92,
          cameraReady: true,
          cameraError: null,
        );
      });
    } on Object catch (e, stackTrace) {
      debugPrint('Error fetching device info: $e');
      debugPrint('Stack Trace: $stackTrace');
    }
  }

  void sendHeartbeat({
    required int batteryLevel,
    required bool batteryCharging,
    required int? storageTotal,
    required int? storageUsed,
    required int? storageFree,
    required bool? wifiConnected,
    required int wifiStrength,
    required bool cameraReady,
    String? cameraError,
  }) {
    Logger.log("Sending Heartbeat to server");
    SocketService.socket.emit('device:heartbeat', {
      'batteryLevel': batteryLevel,
      'batteryCharging': batteryCharging,
      'storageTotal': storageTotal,
      'storageUsed': storageUsed,
      'storageFree': storageFree,
      'wifiConnected': wifiConnected,
      'wifiStrength': wifiStrength,
      'cameraReady': cameraReady,
      'cameraError': cameraError ?? '',
    });
  }

  String referenceImageUrl = "";
  String styleId = "";
  dynamic experienceData = {}.obs;
  Future<void> getJoinedEvent() async {
    var response = await ApiCalls.getAPICall(url: ApiUrls.joinEventDetails);
    if (response.statusCode == 200) {
      final processedBranding = await _brandingRepo.processAndStore(
        Branding.fromJson(response.data['data']['lastEventId']['branding']),
      );

      branding.value = processedBranding;
      // experiences.value = Experiences.fromJson(response.data['data']['lastEventId']['experiences']);

      experiences.value = await repo.processAndStore(Experiences.fromJson(response.data['data']['lastEventId']['experiences']));

      experienceData = response.data['data']['lastEventId']['experiences'];
      if (response.data['data']['leadCaptureConfig'] != null) {
        leadCaptureConfig.value = LeadCaptureConfig.fromJson(response.data['data']['leadCaptureConfig']);
      }
      Logger.log("Branding loaded: ${response.data['data']['lastEventId']['branding']['homeNoActivityVideo'] ?? ''}");
    } else {
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
    }
  }

  dynamic settingsData = {}.obs;
  Future<void> getSettingsDisclaimers() async {
    var response = await ApiCalls.getAPICall(url: ApiUrls.settingsDisclaimers);
    if (response.statusCode == 200) {
      settingsData = response.data['data'];
      final updatedSettings = await _settingsRepo.processAndStore(SettingsModel.fromJson(response.data['data']));
      settings.value = updatedSettings;
      Logger.log("Settings loaded: $settingsData");
    } else {}
  }

  List<ExperienceItem> getEnabledExperiencesForSettings(Experiences exp) {
    return [
      if (exp.photo.enabled)
        ExperienceItem(
          key: 'photo',
          label: 'Photo',
          icon: AppAssets.selfie,
          onTap: () => Get.to(() => CountdownScreen(type: 'Photo')),
        ),

      if (exp.boomerang.enabled)
        ExperienceItem(
          key: 'boomerang',
          label: 'Boomerang',
          icon: AppAssets.boomerang,
          onTap: () => Get.to(() => CountdownScreen(type: 'Boomerang')),
        ),

      if (exp.gif.enabled)
        ExperienceItem(
          key: 'gif',
          label: 'GIF',
          icon: AppAssets.gif,
          onTap: () {
            CameraControllerX.to.capturedFile1 = null;
            CameraControllerX.to.capturedFile2 = null;
            CameraControllerX.to.capturedFile3 = null;
            CameraControllerX.to.capturedFile4 = null;
            Get.to(() => CountdownScreen(type: 'Gif'));
          },
        ),

      if (exp.shoutout.enabled)
        ExperienceItem(
          key: 'shoutout',
          label: 'Shoutout',
          icon: AppAssets.shoutout,
          onTap: () => Get.to(() => CountdownScreen(type: 'Shoutout')),
        ),

      if (exp.slowMotion.enabled)
        ExperienceItem(
          key: 'slowmo',
          label: 'Slowmo',
          icon: AppAssets.slowmo,
          onTap: () => Get.to(() => CountdownScreen(type: 'Slomo')),
        ),

      if (exp.aiStyles.enabled)
        ExperienceItem(
          key: 'ai',
          label: 'AI Photo',
          icon: AppAssets.aiPhoto,
          onTap: () {
            if (experiences.value?.aiStyles != null && experiences.value!.aiStyles.styles.isNotEmpty) {
              var enabledStyles = experiences.value!.aiStyles.styles.where((style) => style['enabled'] == true).toList();
              Get.to(() => AiStylePreview(list: enabledStyles));
            } else {
              CustomSnackbar.showInfo("No AI styles are currently configured for this event.");
            }
          },
        ),
    ];
  }

  List<ExperienceItem> getEnabledExperiences(Experiences exp) {
    final settings = Get.find<SettingsController>();

    return [
      if (settings.isEnabled('photo', exp.photo.enabled) && exp.photo.enabled)
        ExperienceItem(
          key: 'photo',
          label: 'Photo',
          icon: AppAssets.selfie,
          onTap: () => Get.to(() => CountdownScreen(type: 'Photo')),
        ),

      if (settings.isEnabled('boomerang', exp.boomerang.enabled) && exp.boomerang.enabled)
        ExperienceItem(
          key: 'boomerang',
          label: 'Boomerang',
          icon: AppAssets.boomerang,
          onTap: () => Get.to(() => CountdownScreen(type: 'Boomerang')),
        ),

      if (settings.isEnabled('gif', exp.gif.enabled) && exp.gif.enabled)
        ExperienceItem(
          key: 'gif',
          label: 'GIF',
          icon: AppAssets.gif,
          onTap: () {
            CameraControllerX.to.capturedFile1 = null;
            CameraControllerX.to.capturedFile2 = null;
            CameraControllerX.to.capturedFile3 = null;
            CameraControllerX.to.capturedFile4 = null;
            Get.to(() => CountdownScreen(type: 'Gif'));
          },
        ),

      if (settings.isEnabled('shoutout', exp.shoutout.enabled) && exp.shoutout.enabled)
        ExperienceItem(
          key: 'shoutout',
          label: 'Shoutout',
          icon: AppAssets.shoutout,
          onTap: () => Get.to(() => CountdownScreen(type: 'Shoutout')),
        ),

      if (settings.isEnabled('slowmo', exp.slowMotion.enabled) && exp.slowMotion.enabled)
        ExperienceItem(
          key: 'slowmo',
          label: 'Slowmo',
          icon: AppAssets.slowmo,
          onTap: () => Get.to(() => CountdownScreen(type: 'Slomo')),
        ),

      if (settings.isEnabled('ai', exp.aiStyles.enabled) && exp.aiStyles.enabled && Get.find<InternetService>().isConnected.value)
        ExperienceItem(
          key: 'ai',
          label: 'AI Photo',
          icon: AppAssets.aiPhoto,
          onTap: () {
            if (exp.aiStyles.styles.isNotEmpty) {
              var enabledStyles = exp.aiStyles.styles.where((style) => style['enabled'] == true).toList();

              Get.to(() => AiStylePreview(list: enabledStyles));
            } else {
              CustomSnackbar.showInfo("No AI styles are currently configured for this event.");
            }
          },
        ),
    ];
  }

  Future<void> loadLocalData() async {
    final box = await Hive.openBox('brandingBox');
    final data = box.get('branding');

    if (data != null) {
      branding.value = Branding.fromJson(Map<String, dynamic>.from(data));
    }
    final boxSecond = await Hive.openBox("experiencesBox");
    final dataSecond = boxSecond.get("experiences");
    if (dataSecond != null) {
      experiences.value = Experiences.fromJson(Map<String, dynamic>.from(dataSecond));
    }
    final boxThird = await Hive.openBox("leadCaptureBox");
    final dataThird = boxThird.get("leadCapture");
    if (dataThird != null) {
      leadCaptureConfig.value = LeadCaptureConfig.fromJson(dataThird);
    }
  }

  Rx<VideoPlayerController?> videoControllerForOverlay = Rx<VideoPlayerController?>(null);
  Rx<VideoPlayerController?> videoControllerForActivity = Rx<VideoPlayerController?>(null);
  RxBool isVideoInitializedOverlay = false.obs;
  RxBool isVideoInitializedActivity = false.obs;
  final RxBool isIdle = false.obs;
  Timer? _idleTimer;
  void startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 30), _onIdle);
  }

  void resetIdleTimer() {
    if (branding.value?.homeNoActivityVideo != null && branding.value!.homeNoActivityVideo!.isNotEmpty) {
      if (isIdle.value) {
        isIdle.value = false;
        videoControllerForActivity.value?.pause();
        videoControllerForActivity.value?.seekTo(Duration.zero);
        videoControllerForOverlay.value?.play();
      }
      startIdleTimer();
    } else {
      clearTimer();
      isIdle.value = false;
    }
  }

  void _onIdle() {
    isIdle.value = true;
    videoControllerForActivity.value?.play();
    videoControllerForOverlay.value?.pause();
    videoControllerForOverlay.value?.seekTo(Duration.zero);
  }

  Future<void> initVideoPreviewForOverlay(String path) async {
    // videoControllerForOverlay.value?.dispose();
    DeviceController.to.videoControllerForOverlay.value?.pause();
    DeviceController.to.videoControllerForOverlay.value?.seekTo(Duration.zero);

    final controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    await controller.setLooping(true);
    await controller.play();

    videoControllerForOverlay.value = controller;
    isVideoInitializedOverlay.value = true;
  }
  bool firstIdle = false;
  Future<void> initVideoPreviewForActivity(String path) async {
    // videoControllerForActivity.value?.dispose();
    DeviceController.to.videoControllerForActivity.value?.pause();
    DeviceController.to.videoControllerForActivity.value?.seekTo(Duration.zero);

    final controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    await controller.setLooping(true);
    // await controller.play();

    videoControllerForActivity.value = controller;
    isVideoInitializedActivity.value = true;
  }

  @override
  void onClose() {
    _idleTimer?.cancel();
    videoControllerForActivity.value?.dispose();
    videoControllerForOverlay.value?.dispose();
    super.onClose();
  }

  void clearSession() {
    // cancel timer
    _idleTimer?.cancel();
    _idleTimer = null;

    // pause instead of dispose
    if (videoControllerForActivity.value != null) {
      videoControllerForActivity.value?.pause();
    }
    if (videoControllerForOverlay.value != null) {
      videoControllerForOverlay.value?.pause();
    }

    // reset values (important)
    videoControllerForActivity.value = null;
    videoControllerForOverlay.value = null;
  }

  void clearTimer() {
    
    _idleTimer?.cancel();
    _idleTimer = null;
  }
}
