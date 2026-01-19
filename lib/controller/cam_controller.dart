import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart' as Dio;
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selfiecam1/infrastructure/constants/api_endpoints.dart';
import 'package:selfiecam1/infrastructure/constants/app_assets.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/infrastructure/utils/api_client.dart';
import 'package:selfiecam1/infrastructure/utils/custom_snackbar.dart';
import 'package:selfiecam1/infrastructure/utils/loader.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:selfiecam1/presentation/home/preview_approve_screen.dart';

import '../infrastructure/utils/logger.dart';

class CameraControllerX extends GetxController {
  final loader = Get.find<LoaderService>();
  late CameraController cameraController;
  Rx<XFile>? capturedFile;
  RxInt counter = 3.obs;
  RxBool isCounting = true.obs;
  Timer? timer;

  List<CameraDescription> cameras = [];
  var isReady = false.obs;
  void startCountdown() {
    counter.value = 3;
    isCounting.value = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (counter.value > 1) {
        counter--;
      } else {
        isCounting.value = false;
        timer?.cancel();
        await takePhoto();
        // Get.toNamed(Routes.PREVIEW);
        Get.to(() => PreviewApproveScreen(capturedFile: capturedFile!.value));
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    cameraController = CameraController(frontCamera, ResolutionPreset.max, enableAudio: false);

    await cameraController.initialize();
    isReady.value = true;
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

  Future<void> savePhoto() async {
    if (capturedFile == null) return;
    try {
      final bytes = await File(capturedFile!.value.path).readAsBytes();
      final result = await ImageGallerySaver.saveImage(
        bytes,
        name: "PhotoBooth_${DateTime.now().millisecondsSinceEpoch}",
        quality: 100,
      );

      if (result['isSuccess'] == true || result['success'] == true) {
        // CustomSnackbar.showSuccess('Photo saved to gallery!');
      } else {
        // CustomSnackbar.showError('Failed to save photo.');
      }

      capturedFile = null;
    } catch (e) {
      CustomSnackbar.showError('Something went wrong while saving.');
    }
  }

  Future<void> takePhoto() async {
    try {
      await cameraController.setFlashMode(FlashMode.off);

      final file = await cameraController.takePicture();
      final overlayPath = AppAssets.demoFilter; // static for now
      File finalFile = File(file.path);

      // Read images
      final capturedBytes = await finalFile.readAsBytes();
      final overlayBytes = await rootBundle.load(overlayPath);

      img.Image capturedImg = img.decodeImage(capturedBytes)!;
      capturedImg = img.flipHorizontal(capturedImg); // Mirror the image for front camera
      img.Image overlayImg = img.decodeImage(overlayBytes.buffer.asUint8List())!;

      // Resize overlay to match captured image size
      img.Image resizedOverlay = img.copyResize(overlayImg, width: capturedImg.width, height: capturedImg.height);

      // Draw overlay on captured image
      img.compositeImage(capturedImg, resizedOverlay);

      // Save final image
      final dir = await getTemporaryDirectory();
      final output = File('${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.png');

      await output.writeAsBytes(img.encodePng(capturedImg));

      capturedFile = XFile(output.path).obs;
    } catch (e) {
      Logger.log('Error taking photo: $e');
    }
  }

  Future<void> uploadToApi(XFile file) async {
    loader.show();
    var data = Dio.FormData.fromMap({
      'media': [await Dio.MultipartFile.fromFile(file.path, filename: file.name)],
      'eventName': PrefUtils().getString("eventName"),
      'compress': 'false',
    });
    final fileSize = await File(file.path).length();
    Logger.log(
      "Uploading image to API: ${PrefUtils().getString("eventName")} $data, File size: $fileSize bytes ${PrefUtils().getString("deviceToken")} ${PrefUtils().getString("eventToken")}",
    );
    try {
      var response = await ApiCalls.dioClient.request(
        "${ApiUrls.baseUrl}${ApiUrls.uploadImage}",
        options: Dio.Options(
          method: 'POST',
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer ${PrefUtils().getUserToken()}',
            'x-auth-event': '${PrefUtils().getString("eventToken")}',
            "x-app-secret": "e7053b3b07076b7e9949faa0c6978697721b0995",
          },
        ),
        data: data,
      );

      loader.hide();
      Logger.log("Upload API Response: ${response.statusCode} ${response.data}");
      if (response.statusCode == 200) {
        Get.back();
        Get.back();
        Get.back();
        CustomSnackbar.showSuccess("Image uploaded successfully and saved to gallery.");
      } else {
        CustomSnackbar.showError(response.statusMessage ?? 'Failed to upload image.');
      }
    } catch (e) {
      loader.hide();
      Logger.log('Error uploading image: $e');
      CustomSnackbar.showError('Error uploading image.');
    }
  }
}
