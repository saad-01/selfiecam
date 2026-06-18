import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_info_plus/flutter_device_info_plus.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/data/services/credentials.dart';
import 'package:selfiecam1/data/services/device_id_service.dart';
import 'package:selfiecam1/data/services/internet_service.dart';
import 'package:selfiecam1/data/services/internet_service_adapter.dart';
import 'package:selfiecam1/data/services/socket_service.dart';
import 'package:selfiecam1/data/services/upload_queue_service.dart';
import 'package:selfiecam1/data/services/upload_repository.dart';
import 'package:selfiecam1/infrastructure/constants/api_endpoints.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/infrastructure/utils/api_client.dart';
import 'package:selfiecam1/infrastructure/utils/custom_snackbar.dart';
import 'package:selfiecam1/infrastructure/utils/loader.dart';
import 'package:selfiecam1/infrastructure/utils/logger.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';

class SignInController extends GetxController {
  // final emailcontroller = TextEditingController(text: "m.saadashraf186@gmail.com");
  // final passwordcontroller = TextEditingController(text: "Succe\$\$26");
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final loader = Get.find<LoaderService>();
  final FlutterDeviceInfoPlus _deviceInfo = const FlutterDeviceInfoPlus();
  DeviceInformation? _deviceInformation;
  BatteryInfo? _batteryInfo;
  String? pkgVersion;
  dynamic iosDeviceInfo;
  NetworkInfo? _networkInfo;

  Future<void> loadAllInfo() async {
    try {
      var deviceInfo2 = DeviceInfoPlugin();
      final pkg = await PackageInfo.fromPlatform();
      pkgVersion = pkg.version;
      iosDeviceInfo = await deviceInfo2.iosInfo;
      // Demonstrate all available methods
      final platform = _deviceInfo.getCurrentPlatform();
      final deviceInfo = await _deviceInfo.getDeviceInfo();
      final batteryInfo = await _deviceInfo.getBatteryInfo();
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
      if (batteryInfo != null) {
        debugPrint('Level: ${batteryInfo.batteryLevel}%');
        debugPrint('Status: ${batteryInfo.chargingStatus}');
        debugPrint('Health: ${batteryInfo.batteryHealth}');
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
      _deviceInformation = deviceInfo;
      _batteryInfo = batteryInfo;
    } on Object catch (e) {
      debugPrint('Error fetching device info: $e');
    }
  }

  Future<void> loginApi() async {
    if (emailcontroller.text.trim().isNotEmpty && passwordcontroller.text.trim().isNotEmpty) {
      try {
        loader.show();
        final deviceId = await DeviceIdService.getDeviceId();
        var response = await ApiCalls.postAPICall(
          url: ApiUrls.login,
          bodyParams: {
            "deviceId": deviceId,
            "email": emailcontroller.text.trim(),
            "password": passwordcontroller.text.trim(),
            "deviceName": _deviceInformation?.deviceName,
            "deviceType": "ipad",
            "deviceInfo": {
              "model": _deviceInformation?.model,
              "osVersion": _deviceInformation?.operatingSystem,
              "appVersion": pkgVersion,
              "screenResolution": _deviceInformation?.displayInfo.resolutionString ?? 'Unknown',
            },
            "deviceHealth": {
              "batteryLevel": _batteryInfo!.batteryLevel,
              // "batteryLevel": 100,
              "batteryCharging": _batteryInfo!.isCharging,
              // "batteryCharging":false,
              "storageTotal": _deviceInformation?.memoryInfo.totalStorageSpace,
              "storageUsed": _deviceInformation?.memoryInfo.usedStorageSpace,
              "storageFree": _deviceInformation?.memoryInfo.availableStorageSpace,
              "wifiConnected": _networkInfo?.isConnected,
              "wifiStrength": 92,
              "cameraReady": true,
              "cameraError": null,
            },
          },
        );

        Logger.log("Login API Response: ${response.data} ${response.statusCode}");
        if (response.statusCode == 200) {
          var data = response.data['data'];
          await PrefUtils().clearPreferencesData();
          PrefUtils().saveString("deviceToken", data['deviceToken']);
          PrefUtils().saveString("deviceId", data['device']['deviceId']);
          PrefUtils().saveString("password", passwordcontroller.text.trim());
          PrefUtils().saveString("email", emailcontroller.text.trim());
          await getDeviceById();
          loader.hide();
          // Get.offAllNamed(Routes.JOINEVENT);
        } else {
          CustomSnackbar.showError("${response.data ?? 'Login failed'}");
        }
      } catch (e, stackTrace) {
        CustomSnackbar.showError("$e");
        Logger.log("Login API Error: $e $stackTrace");
      }
    } else {
      CustomSnackbar.showError("Please enter email and password");
    }
  }

  Future<void> getDeviceById() async {
    var response = await ApiCalls.getAPICall(url: "${ApiUrls.joinEvent}/${PrefUtils().getString("deviceId")}", isAuth: true);
    if (response.statusCode == 200) {
      var data = response.data['data']['lastEventId'];
      if (data != null && data.isNotEmpty) {
        PrefUtils().saveString("eventJoined", "true");
        PrefUtils().saveString("eventToken", data['eventToken']);
        PrefUtils().saveString("eventId", data['_id']);
        PrefUtils().saveString("eventName", data['eventName']);
        await DeviceController.to.getJoinedEvent();
        await DeviceController.to.getSettingsDisclaimers();
        SocketService.init();
        unawaited(DeviceController.to.loadAllInfo());
        await Get.putAsync(() async {
          final service = UploadQueueService(
            repository: UploadRepository(),
            connectivity: InternetServiceAdapter(Get.find<InternetService>()),
            credentials: MyCredentialsProvider(),
          );
          await service.init();
          return service;
        }, permanent: true);
        if (DeviceController.to.branding.value!.homeVideo != null && DeviceController.to.branding.value!.homeVideo!.isNotEmpty) {
          await DeviceController.to.initVideoPreviewForOverlay(DeviceController.to.branding.value!.homeVideo!);
        }
        if (DeviceController.to.branding.value!.homeNoActivityVideo != null &&
            DeviceController.to.branding.value!.homeNoActivityVideo!.isNotEmpty) {
          await DeviceController.to.initVideoPreviewForActivity(DeviceController.to.branding.value!.homeNoActivityVideo!);
        }
        Get.offAllNamed(Routes.EXPERIENCESELECTION2);
        CustomSnackbar.showSuccess("Login Successful");
      } else {
        Get.offAllNamed(Routes.JOINEVENT);
        CustomSnackbar.showSuccess("Login Successful");
      }
    } else {
      CustomSnackbar.showError("${response.data ?? 'Failed to fetch device info'}");
    }
  }
}
