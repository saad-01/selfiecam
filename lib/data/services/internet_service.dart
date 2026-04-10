import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/data/services/connectivity_service.dart';

class InternetService extends GetxService {
  final Connectivity _connectivity = Connectivity();

  /// true = internet available
  /// false = no internet
  final RxBool isConnected = true.obs;

  dynamic _subscription;

  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) async {
      final hasInternet = await _checkRealInternet(result.first);
      isConnected.value = hasInternet;
    });
  }

  /// Manual check (can be used on app start)
  Future<bool> checkInternetOnce() async {
    final result = await _connectivity.checkConnectivity();
    final hasInternet = await _checkRealInternet(result.first);
    isConnected.value = hasInternet;
    return hasInternet;
  }

  Future<bool> _checkRealInternet(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) return false;

    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
