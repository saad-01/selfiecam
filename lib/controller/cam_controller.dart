import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selfiecam1/controller/animation_controller.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/infrastructure/constants/api_endpoints.dart';
import 'package:selfiecam1/infrastructure/utils/api_client.dart';
import 'package:selfiecam1/infrastructure/utils/custom_snackbar.dart';
import 'package:selfiecam1/infrastructure/utils/loader.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:selfiecam1/infrastructure/utils/video_utils.dart';
import 'package:selfiecam1/presentation/component/progress_bar.dart';
import 'package:selfiecam1/presentation/home/preview_approve_screen.dart';
import 'package:video_player/video_player.dart';

import '../infrastructure/utils/logger.dart';

class CameraControllerX extends GetxController with GetTickerProviderStateMixin {
  static CameraControllerX get to => Get.find();
  final loader = Get.find<LoaderService>();
  late CameraController cameraController;
  Rx<XFile>? capturedFile;
  RxInt counter = 6.obs;
  RxBool isCounting = true.obs;
  Timer? timer;
  Timer? timer2;

  List<CameraDescription> cameras = [];
  var isReady = false.obs;
  void startCountdown() {
    counter.value = 6;
    isCounting.value = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (counter.value > 1) {
        counter--;
      } else {
        isCounting.value = false;
        timer.cancel();
        // await takePhoto();
        // Get.toNamed(Routes.PREVIEW);
        // Get.to(() => PreviewApproveScreen(capturedFile: capturedFile!.value));
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
    cameraController = CameraController(frontCamera, ResolutionPreset.max, enableAudio: true);

    await cameraController.initialize();
    isReady.value = true;
  }

  @override
  void onClose() {
    cameraController.dispose();
    videoController.value?.dispose();
    animationController.dispose();
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

  Future<void> saveVideo() async {
    if (capturedFile == null) return;

    try {
      final filePath = capturedFile!.value.path;

      final result = await ImageGallerySaver.saveFile(filePath, name: "VideoBooth_${DateTime.now().millisecondsSinceEpoch}");

      if (result['isSuccess'] == true || result['success'] == true) {
        // CustomSnackbar.showSuccess('Video saved to gallery!');
      } else {
        // CustomSnackbar.showError('Failed to save video.');
      }

      capturedFile = null;
    } catch (e) {
      CustomSnackbar.showError('Something went wrong while saving.');
    }
  }

  Rx<XFile>? capturedFile1;
  Rx<XFile>? capturedFile2;
  Rx<XFile>? capturedFile3;
  Rx<XFile>? capturedFile4;
  Future<void> recordGif() async {
    try {
      await cameraController.setFlashMode(FlashMode.always);
      final file = await cameraController.takePicture();
      final File originalFile = File(file.path);

      // Read captured image
      final capturedBytes = await originalFile.readAsBytes();
      img.Image capturedImg = img.decodeImage(capturedBytes)!;

      // Mirror for front camera
      capturedImg = img.flipHorizontal(capturedImg);
      final dir = await getTemporaryDirectory();
      final output = File('${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.png');

      await output.writeAsBytes(img.encodePng(capturedImg));

      capturedFile1 = XFile(output.path).obs;
      // await Future.delayed(const Duration(milliseconds: 1000));
      // await AnimationControllerX.to.startFlowGif(0);

      // print("Captured file 2 path: ${capturedFile2?.value.path}");
      for (var i = 0; i < 3; i++) {
        await Future.delayed(const Duration(milliseconds: 1000));
        await AnimationControllerX.to.startFlowGif(i);
        await Future.delayed(const Duration(seconds: 4));
      }
      await Future.delayed(const Duration(seconds: 1));
      final photos = [
        File(capturedFile1!.value.path),
        File(capturedFile2!.value.path),
        File(capturedFile3!.value.path),
        File(capturedFile4!.value.path),
      ];

      loader.show();
      final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;
      if (overlayUrl != null && overlayUrl.isNotEmpty) {
        // capturedFile = XFile(videoFile.path).obs;
        // saveVideo();
        final response = await http.get(Uri.parse(overlayUrl));
        if (response.statusCode == 200) {
          final overlayImg = img.decodeImage(response.bodyBytes);
          for (int i = 0; i < photos.length; i++) {
            // 1️⃣ Read each photo separately
            final bytes = await photos[i].readAsBytes();
            img.Image baseImg = img.decodeImage(bytes)!;

            // 2️⃣ Resize overlay to match THIS photo
            final resizedOverlay = img.copyResize(overlayImg!, width: baseImg.width, height: baseImg.height);

            // 3️⃣ Apply overlay to THIS image
            img.compositeImage(baseImg, resizedOverlay);

            // 4️⃣ Save processed file
            final dir = await getTemporaryDirectory();
            final processedPath = '${dir.path}/processed_${DateTime.now().millisecondsSinceEpoch}_$i.png';

            await File(processedPath).writeAsBytes(img.encodePng(baseImg));

            // 5️⃣ Update list
            photos[i] = File(processedPath);
          }
        }
      }
      final videoPath = await VideoUtils.createGif(photos: photos);
      capturedFile = XFile(videoPath).obs;
      await initVideoPreview(videoPath);
      loader.hide();
    } catch (e, stackTrace) {
      Logger.log('Error recording GIF: $e');
      Logger.log('Stack trace: $stackTrace');
    }
  }

  Future<void> subrecordGif(int index) async {
    try {
      final file = await cameraController.takePicture();
      final File originalFile = File(file.path);

      // Read captured image
      final capturedBytes = await originalFile.readAsBytes();
      img.Image capturedImg = img.decodeImage(capturedBytes)!;

      // Mirror for front camera
      capturedImg = img.flipHorizontal(capturedImg);
      final dir = await getTemporaryDirectory();
      final output = File('${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.png');

      await output.writeAsBytes(img.encodePng(capturedImg));
      if (index == 0) {
        capturedFile2 = XFile(output.path).obs;
      } else if (index == 1) {
        capturedFile3 = XFile(output.path).obs;
      } else if (index == 2) {
        capturedFile4 = XFile(output.path).obs;
        Logger.log("Captured file 4 path: ${capturedFile4?.value.path}");
        capturedFile4!.refresh();
      }
      refresh();
    } catch (e) {
      Logger.log('Error recording GIF: $e');
    }
  }

  Future<void> takePhoto() async {
    try {
      await cameraController.setFlashMode(FlashMode.always);
      loader.show();

      final file = await cameraController.takePicture();
      final File originalFile = File(file.path);

      // Read captured image
      final capturedBytes = await originalFile.readAsBytes();
      img.Image capturedImg = img.decodeImage(capturedBytes)!;

      // Mirror for front camera
      capturedImg = img.flipHorizontal(capturedImg);

      final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;

      // 👉 Apply overlay ONLY if available
      if (overlayUrl != null && overlayUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(overlayUrl));

        if (response.statusCode == 200) {
          final overlayImg = img.decodeImage(response.bodyBytes);
          if (overlayImg != null) {
            final resizedOverlay = img.copyResize(overlayImg, width: capturedImg.width, height: capturedImg.height);

            img.compositeImage(capturedImg, resizedOverlay);
          }
        } else {
          Logger.log('Overlay skipped: HTTP ${response.statusCode}');
        }
      }

      // Save final image
      final dir = await getTemporaryDirectory();
      final output = File('${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.png');

      await output.writeAsBytes(img.encodePng(capturedImg));

      capturedFile = XFile(output.path).obs;
    } catch (e) {
      Logger.log('Error taking photo: $e');
    } finally {
      loader.hide();
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
        if (videoController.value != null && videoController.value!.value.isPlaying) {
          videoController.value!.pause();
          videoController.value!.seekTo(Duration.zero);
          videoController.value = null;
        }
        CustomSnackbar.showSuccess("Uploaded successfully and saved to gallery.");
      } else {
        CustomSnackbar.showError(response.statusMessage ?? 'Failed to upload image.');
      }
    } catch (e) {
      loader.hide();
      Logger.log('Error uploading image: $e');
      CustomSnackbar.showError('Error uploading image.');
    }
  }

  Future<void> uploadAiToApi() async {
    loader.show();
    var data = {"aiStyleImageId": generatedImageId, 'eventName': PrefUtils().getString("eventName")};

    try {
      var response = await ApiCalls.postAPICall(
        url: ApiUrls.imageUploadAiStyle,
        bodyParams: data,
        isAuth: true,
        eventJoined: true,
      );

      loader.hide();
      Logger.log("Upload API Response: ${response.statusCode} ${response.data}");
      if (response.statusCode == 200) {
        Get.back();
        Get.back();
        Get.back();
        CustomSnackbar.showSuccess("Uploaded successfully and saved to gallery.");
      } else {
        CustomSnackbar.showError(response.data['message'] ?? 'Failed to upload image.');
      }
    } catch (e) {
      loader.hide();
      Logger.log('Error uploading image: $e');
      CustomSnackbar.showError('Error uploading image.');
    }
  }

  String generatedImageId = "";
  String generatedImageUrl = "";
  Future<void> generateAiStyle() async {
    await cameraController.setFlashMode(FlashMode.always);
    loader.show();

    final file = await cameraController.takePicture();
    var data = Dio.FormData.fromMap({
      'image': [await Dio.MultipartFile.fromFile(file.path, filename: file.name)],
      'styleId': DeviceController.to.styleId,
    });
    try {
      var response = await ApiCalls.dioClient.request(
        "${ApiUrls.baseUrl}${ApiUrls.aiGenerateStyle}",
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
      if (response.statusCode == 200) {
        Logger.log("AI Generation API Response: ${response.statusCode} ${response.data}");
        generatedImageUrl = response.data['data']['mediaUrl'];
        var file = await VideoUtils.applyOverlayOnNetworkImage(generatedImageUrl);
        capturedFile = XFile(file!.path).obs;
        Get.to(() => PreviewApproveScreen(capturedFile: capturedFile!.value, type: 'Ai'));
        CustomSnackbar.showSuccess("AI Style generated successfully");
      } else {
        CustomSnackbar.showError(response.statusMessage ?? 'Failed to generate image.');
      }
    } catch (e, stackTrace) {
      loader.hide();
      Logger.log('Error generating image: $e $stackTrace');
      CustomSnackbar.showError('Error generating image.');
    }
  }

  RxBool isBoomerangRecording = false.obs;
  Rx<VideoPlayerController?> videoController = Rx<VideoPlayerController?>(null);

  RxBool isVideoInitialized = false.obs;
  final RxBool isFlashing = false.obs;
  final RxBool _blinkActive = false.obs;

  Future<void> startBlinkingFlash({required int durationSeconds}) async {
    _blinkActive.value = true;

    final endTime = DateTime.now().add(Duration(seconds: durationSeconds));

    while (DateTime.now().isBefore(endTime) && _blinkActive.value) {
      isFlashing.value = true;
      await Future.delayed(const Duration(milliseconds: 69));

      isFlashing.value = false;
      await Future.delayed(const Duration(milliseconds: 60));
    }

    isFlashing.value = false;
  }

  void stopBlinkingFlash() {
    _blinkActive.value = false;
    isFlashing.value = false;
  }

  late AnimationController animationController;

  RxBool isRecording = false.obs;
  int totalSeconds = 10;

  void init(int seconds) {
    totalSeconds = seconds;

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalSeconds),
    );
    start();
  }

  void start() {
    isRecording.value = true;
    animationController.forward(from: 0);
  }

  void stop() {
    animationController.stop();
    isRecording.value = false;
  }

  void reset() {
    animationController.reset();
    isRecording.value = false;
  }

  Future<void> recordSlomo({int seconds = 5}) async {
    await cameraController.startVideoRecording();
    init(seconds); // 10 seconds recording

    await Future.delayed(Duration(seconds: seconds));
    stop();
    reset();
    final XFile videoFile = await cameraController.stopVideoRecording();
    loader.show();

    var noAudioFile = await VideoUtils.removeAudio(videoFile.path);
    var reversedFile = await VideoUtils.reverseVideo(noAudioFile);
    String? slomo = '';
    // /// 🔹 Download overlay if exists
    final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;

    if (overlayUrl != null && overlayUrl.isNotEmpty) {
      // capturedFile = XFile(videoFile.path).obs;
      // saveVideo();
      final response = await http.get(Uri.parse(overlayUrl));
      if (response.statusCode == 200) {
        final overlayImg = img.decodeImage(response.bodyBytes);
        final processedPath = await VideoUtils.applyOverlayFromImagePackage(videoPath: reversedFile, overlayImage: overlayImg!);
        final processedPathForward = await VideoUtils.applyOverlayFromImagePackage(
          videoPath: noAudioFile,
          overlayImage: overlayImg!,
        );
        slomo = await VideoUtils.concatenateVideosLocal(localVideoPath: processedPathForward, remoteVideoUrl: processedPath);
        capturedFile = XFile(slomo!).obs;
        loader.hide();
        await initVideoPreview(slomo);
      }
    } else {
      loader.hide();
      slomo = await VideoUtils.concatenateVideosLocal(localVideoPath: noAudioFile, remoteVideoUrl: reversedFile);
      capturedFile = XFile(slomo!).obs;
      await initVideoPreview(slomo);
    }
  }

  Future<void> recordShoutout({int seconds = 10}) async {
    await cameraController.startVideoRecording();
    init(seconds); // 10 seconds recording

    await Future.delayed(Duration(seconds: seconds));
    stop();
    reset();

    final XFile videoFile = await cameraController.stopVideoRecording();

    loader.show();
    // /// 🔹 Download overlay if exists
    final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;

    if (overlayUrl != null && overlayUrl.isNotEmpty) {
      // capturedFile = XFile(videoFile.path).obs;
      // saveVideo();
      final response = await http.get(Uri.parse(overlayUrl));
      if (response.statusCode == 200) {
        final overlayImg = img.decodeImage(response.bodyBytes);
        final processedPath = await VideoUtils.applyOverlayFromImagePackage(videoPath: videoFile.path, overlayImage: overlayImg!);
        capturedFile = XFile(processedPath).obs;
        await initVideoPreview(processedPath);
      }
    } else {
      capturedFile = XFile(videoFile.path).obs;
      await initVideoPreview(videoFile.path);
    }
  }

  Future<void> recordBoomerang({int seconds = 1}) async {
    if (isBoomerangRecording.value) return;

    try {
      isBoomerangRecording.value = true;
      // loader.show();

      startBlinkingFlash(durationSeconds: seconds);

      await cameraController.startVideoRecording();

      await Future.delayed(Duration(seconds: seconds));

      final XFile videoFile = await cameraController.stopVideoRecording();

      stopBlinkingFlash();

      // _startFlashBlinking();
      loader.show();

      final forwardPath = videoFile.path;

      final inputFile = File(forwardPath);
      if (!await inputFile.exists()) {
        throw Exception("Recorded file not found");
      }

      /// 1️⃣ Remove audio from recorded video
      final noAudioVideoPath = await VideoUtils.removeAudio(forwardPath);
      final result = await VideoUtils.generateBoomerang(noAudioVideoPath);

      final boomerangVideoPath = result;

      // /// 🔹 Download overlay if exists
      final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;

      if (overlayUrl != null && overlayUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(overlayUrl));
        if (response.statusCode == 200) {
          final overlayImg = img.decodeImage(response.bodyBytes);
          final processedPath = await VideoUtils.applyOverlayFromImagePackage(
            videoPath: boomerangVideoPath!,
            overlayImage: overlayImg!,
          );
          capturedFile = XFile(processedPath).obs;
          await initVideoPreview(processedPath);
        }
      } else {
        capturedFile = XFile(boomerangVideoPath!).obs;
        await initVideoPreview(boomerangVideoPath);
      }
    } catch (e) {
      Logger.log('Boomerang error: $e');
    } finally {
      isBoomerangRecording.value = false;
      loader.hide();
    }
  }

  Future<void> initVideoPreview(String path) async {
    videoController.value?.dispose();

    final controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    await controller.setLooping(true);
    await controller.play();

    videoController.value = controller;
    isVideoInitialized.value = true;
  }
}
