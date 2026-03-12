import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_device_info_plus/flutter_device_info_plus.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/data/models/branding_model.dart';
import 'package:selfiecam1/data/models/experiences_model.dart';
import 'package:selfiecam1/data/services/socket_service.dart';
import 'package:selfiecam1/infrastructure/constants/api_endpoints.dart';
import 'package:selfiecam1/infrastructure/constants/app_assets.dart';
import 'package:selfiecam1/infrastructure/utils/api_client.dart';
import 'package:selfiecam1/infrastructure/utils/custom_snackbar.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:selfiecam1/presentation/home/ai_style_preview.dart';
import 'package:selfiecam1/presentation/home/countdown_screen.dart';

import '../infrastructure/utils/logger.dart';

class DeviceController extends GetxController {
  static DeviceController get to => Get.find();
  final FlutterDeviceInfoPlus _deviceInfo = const FlutterDeviceInfoPlus();
  DeviceInformation? deviceInformation;
  final branding = Rxn<Branding>();
  final experiences = Rxn<Experiences>();
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
    } on Object catch (e) {
      debugPrint('Error fetching device info: $e');
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
      branding.value = Branding.fromJson(response.data['data']['lastEventId']['branding']);
      experiences.value = Experiences.fromJson(response.data['data']['lastEventId']['experiences']);
      experienceData = response.data['data']['lastEventId']['experiences'];

      Logger.log("Branding loaded: ${branding.value?.homeOverlay ?? ''}");
    } else {}
  }

  List<ExperienceItem> getEnabledExperiences(Experiences exp) {
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
              var style = experiences.value!.aiStyles.styles[0];
              if (style['enabled'] == true) {
                referenceImageUrl = style['referenceImage'] ?? '';
                styleId = style['id'] ?? '';
              }
              Get.to(() => AiStylePreview(aiImageUrl: referenceImageUrl,));
            } else {
              CustomSnackbar.showInfo("No AI styles are currently configured for this event.");
            }
          },
        ),
    ];
  }
}
