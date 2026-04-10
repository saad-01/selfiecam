// lib/features/upload/services/internet_service_adapter.dart
//
// Bridges the existing GetX-based InternetService to the ConnectivityService
// interface expected by UploadQueueService.
//
// ─── What each side provides ────────────────────────────────────────────────
//
//  InternetService (yours)          ConnectivityService (upload interface)
//  ──────────────────────────────   ────────────────────────────────────────
//  RxBool isConnected               bool get isOnline
//  onConnectivityChanged (RxBool)   Stream<bool> get onConnectivityChanged
//
// ─── Usage ──────────────────────────────────────────────────────────────────
//
//   // Wherever you build UploadQueueService (e.g. a GetX binding or main.dart):
//
//   final uploadQueue = UploadQueueService(
//     repository:   UploadRepository(),
//     connectivity: InternetServiceAdapter(Get.find<InternetService>()),
//     credentials:  MyCredentialsProvider(),
//   );
//   await uploadQueue.init();
//
// ────────────────────────────────────────────────────────────────────────────

import 'package:get/get.dart';
import 'package:selfiecam1/data/services/internet_service.dart';

import 'connectivity_service.dart';


class InternetServiceAdapter implements ConnectivityService {
  final InternetService _service;

  InternetServiceAdapter(this._service);

  // ── ConnectivityService contract ──────────────────────────────────────────

  /// Reads the current value of the RxBool directly – always up to date because
  /// InternetService keeps it synchronised via its connectivity listener.
  @override
  bool get isOnline => _service.isConnected.value;

  /// Converts the RxBool's change stream into a plain Dart Stream<bool>.
  ///
  /// RxBool extends Stream<bool> in GetX, so this is zero-overhead – no extra
  /// StreamController is created.  The stream is already a broadcast stream,
  /// matching what UploadQueueService expects.
  @override
  Stream<bool> get onConnectivityChanged => _service.isConnected.stream;
}
