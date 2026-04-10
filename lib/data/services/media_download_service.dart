import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class MediaDownloadService {
  final Dio _dio = Dio();

  Future<String?> downloadFile(String? url, String fileName) async {
    if (url == null || url.isEmpty) return null;

    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${dir.path}/media');

    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final filePath = '${mediaDir.path}/$fileName';

    final file = File(filePath);

    if (await file.exists()) {
      return filePath; // already downloaded
    }

    await _dio.download(url, filePath);
    return filePath;
  }
}