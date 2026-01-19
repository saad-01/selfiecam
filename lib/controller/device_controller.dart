import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_info_plus/flutter_device_info_plus.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:selfiecam1/data/services/socket_service.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';

import '../infrastructure/utils/logger.dart';

class DeviceController extends GetxController {
  final FlutterDeviceInfoPlus _deviceInfo = const FlutterDeviceInfoPlus();
  DeviceInformation? _deviceInformation;
  BatteryInfo? _batteryInfo;
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
      sendHeartbeat(
        batteryLevel: _batteryInfo!.batteryLevel,
        batteryCharging: _batteryInfo!.isCharging,
        storageTotal: _deviceInformation?.memoryInfo.totalStorageSpace,
        storageUsed: _deviceInformation?.memoryInfo.usedStorageSpace,
        storageFree: _deviceInformation?.memoryInfo.availableStorageSpace,
        wifiConnected: _networkInfo?.isConnected,
        wifiStrength: 92,
        cameraReady: true,
        cameraError: null,
      );
      SocketService.socket.emit("event:join", {"eventId": PrefUtils().getString("eventId")});
      heartbeatTimer = Timer.periodic(Duration(minutes: 1), (timer) {
        sendHeartbeat(
          batteryLevel: _batteryInfo!.batteryLevel,
          batteryCharging: _batteryInfo!.isCharging,
          storageTotal: _deviceInformation?.memoryInfo.totalStorageSpace,
          storageUsed: _deviceInformation?.memoryInfo.usedStorageSpace,
          storageFree: _deviceInformation?.memoryInfo.availableStorageSpace,
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
}
