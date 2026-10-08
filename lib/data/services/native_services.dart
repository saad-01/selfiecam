import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class NativeVideoOverlay {
  static const _channel = MethodChannel('com.yourapp/video_overlay');

  /// Burns overlay image into video natively.
  /// [videoPath] — path to the recorded video
  /// [overlayAsset] — flutter asset path e.g. AppAssets.demoFilter
  static Future<String> apply({
    required String videoPath,
    required String overlayAsset,
    bool mirror = false,
  }) async {
    // Write asset to temp file so native side can read it
    final dir = await getTemporaryDirectory();
    final overlayPath = '${dir.path}/overlay_${DateTime.now().millisecondsSinceEpoch}.png';
    final byteData = await rootBundle.load(overlayAsset);
    await File(overlayPath).writeAsBytes(byteData.buffer.asUint8List());

    final result = await _channel.invokeMethod<String>('applyOverlay', {
      'videoPath': videoPath,
      'overlayPath': overlayPath,
      'mirror': mirror ? 'true' : 'false',
    });

    if (result == null) throw Exception('Native overlay returned null');
    return result;
  }
}