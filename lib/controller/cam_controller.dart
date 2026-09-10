import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:selfiecam1/controller/animation_controller.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/data/models/lead_capture.dart';
import 'package:selfiecam1/data/models/upload_status.dart';
import 'package:selfiecam1/data/services/credentials.dart';
import 'package:selfiecam1/data/services/internet_service.dart';
import 'package:selfiecam1/data/services/internet_service_adapter.dart';
import 'package:selfiecam1/data/services/native_services.dart';
import 'package:selfiecam1/data/services/upload_queue_service.dart';
import 'package:selfiecam1/data/services/upload_repository.dart';
import 'package:selfiecam1/infrastructure/constants/api_endpoints.dart';
import 'package:selfiecam1/infrastructure/constants/app_assets.dart';
import 'package:selfiecam1/infrastructure/utils/api_client.dart';
import 'package:selfiecam1/infrastructure/utils/custom_snackbar.dart';
import 'package:selfiecam1/infrastructure/utils/loader.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:selfiecam1/infrastructure/utils/video_utils.dart';
import 'package:selfiecam1/presentation/component/progress_bar.dart';
import 'package:selfiecam1/presentation/home/preview_approve_screen.dart';
import 'package:selfiecam1/presentation/home/send_it_to_me_2_screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:video_player/video_player.dart';

import '../infrastructure/utils/logger.dart';

class CameraControllerX extends GetxController with GetTickerProviderStateMixin {
  static CameraControllerX get to => Get.find();
  final loader = Get.find<LoaderService>();
  late CameraController cameraController;
  RxBool publishToPublic = true.obs;
  Rx<XFile>? capturedFile;
  Rx<XFile>? capturedFileOriginal;
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

    await cameraController.initialize(); // initialize FIRST
    await cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp); // THEN lock

    isReady.value = true;
  }

  @override
  void onClose() {
    // cameraController.dispose();
    videoController.value?.dispose();
    videoControllerForOverlay.value?.dispose();
    videoControllerForActivity.value?.dispose();
    if (Get.isRegistered<AnimationControllerX>()) {
      animationController.dispose();
    }

    super.onClose();
  }

  Future<void> requestPhotoPermissionAfterLogin() async {
    final status = await Permission.photos.request();

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> savePhoto() async {
    if (capturedFileOriginal == null) return;
    try {
      final bytes = await File(capturedFileOriginal!.value.path).readAsBytes();
      final result = await ImageGallerySaver.saveImage(
        bytes,
        name: "PhotoBooth_${DateTime.now().millisecondsSinceEpoch}",
        quality: 100,
      );
      // final result = {};

      if (result['isSuccess'] == true || result['success'] == true) {
        // CustomSnackbar.showSuccess('Photo saved to gallery!');
      } else {
        // CustomSnackbar.showError('Failed to save photo.');
      }

      // capturedFile = null;
    } catch (e) {
      CustomSnackbar.showError('Something went wrong while saving.');
    }
  }

  Future<void> saveAIPhoto() async {
    if (capturedFile == null) return;
    try {
      final bytes = await File(capturedFile!.value.path).readAsBytes();
      final result = await ImageGallerySaver.saveImage(
        bytes,
        name: "PhotoBooth_${DateTime.now().millisecondsSinceEpoch}",
        quality: 100,
      );
      // final result = {};

      if (result['isSuccess'] == true || result['success'] == true) {
        // CustomSnackbar.showSuccess('Photo saved to gallery!');
      } else {
        // CustomSnackbar.showError('Failed to save photo.');
      }

      // capturedFile = null;
    } catch (e) {
      CustomSnackbar.showError('Something went wrong while saving.');
    }
  }

  // Future<void> saveVideo() async {
  //   if (capturedFile == null) return;

  //   try {
  //     final filePath = capturedFile!.value.path;

  //     final result = await ImageGallerySaver.saveFile(filePath, name: "VideoBooth_${DateTime.now().millisecondsSinceEpoch}");

  //     if (result['isSuccess'] == true || result['success'] == true) {
  //       // CustomSnackbar.showSuccess('Video saved to gallery!');
  //     } else {
  //       // CustomSnackbar.showError('Failed to save video.');
  //     }

  //     capturedFile = null;
  //   } catch (e) {
  //     CustomSnackbar.showError('Something went wrong while saving.');
  //   }
  // }

  Rx<XFile>? capturedFile1;
  Rx<XFile>? capturedFile2;
  Rx<XFile>? capturedFile3;
  Rx<XFile>? capturedFile4;
  Future<void> recordGif() async {
    try {
      try {
        await cameraController.setFlashMode(FlashMode.always);
      } on CameraException catch (e) {
        if (e.code == 'setFlashModeFailed') {
          // Device does not have flash — silently ignore.
        } else {
          rethrow;
        }
      }
      final file = await cameraController.takePicture();
      final File originalFile = File(file.path);

      // Read captured image
      final capturedBytes = await originalFile.readAsBytes();
      img.Image capturedImg = img.decodeImage(capturedBytes)!;

      // Mirror for front camera
      // capturedImg = img.flipHorizontal(capturedImg);
      final dir = await getTemporaryDirectory();
      final output = File('${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.png');

      await output.writeAsBytes(img.encodePng(capturedImg));

      capturedFile1 = XFile(output.path).obs;
      // await Future.delayed(const Duration(milliseconds: 1000));
      // await AnimationControllerX.to.startFlowGif(0);

      // print("Captured file 2 path: ${capturedFile2?.value.path}");
      for (var i = 0; i < 3; i++) {
        await Future.delayed(const Duration(milliseconds: 1000));
        _subCaptureCompleter = Completer<void>();
        await AnimationControllerX.to.startFlowGif(i);
        await _subCaptureCompleter!.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            Logger.log('subrecordGif[$i] timed out — hardware too slow?');
            throw TimeoutException('Sub-capture $i timed out after 10s');
          },
        );
      }
      await Future.delayed(const Duration(seconds: 1));
      if (capturedFile1 == null || capturedFile2 == null || capturedFile3 == null || capturedFile4 == null) {
        throw Exception('One or more captured files is null after all sub-records');
      }
      final photos = [
        File(capturedFile1!.value.path),
        File(capturedFile2!.value.path),
        File(capturedFile3!.value.path),
        File(capturedFile4!.value.path),
      ];

      loader.show();
      final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;
      Logger.log("Overlay URL: $overlayUrl");
      if (overlayUrl != null && overlayUrl.isNotEmpty) {
        // capturedFile = XFile(videoFile.path).obs;
        // saveVideo();
        final byteData = await rootBundle.load(overlayUrl);
        var data = byteData.buffer.asUint8List();
        final overlayImg = img.decodeImage(data);
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
      final videoPath = await VideoUtils.createGif(photos: photos);
      capturedFile = XFile(videoPath).obs;
      await initVideoPreview(videoPath);
      loader.hide();
    } catch (e, stackTrace) {
      Logger.log('Error recording GIF: $e');
      Logger.log('Stack trace: $stackTrace');
      loader.hide();
      throw Sentry.addBreadcrumb(Breadcrumb(message: "Error recording GIF: $e $stackTrace", level: SentryLevel.error));
    }
  }

  Completer<void>? _subCaptureCompleter;
  Future<void> subrecordGif(int index) async {
    try {
      final file = await cameraController.takePicture();
      final File originalFile = File(file.path);

      // Read captured image
      final capturedBytes = await originalFile.readAsBytes();
      img.Image capturedImg = img.decodeImage(capturedBytes)!;

      // Mirror for front camera
      // capturedImg = img.flipHorizontal(capturedImg);
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
      _subCaptureCompleter?.complete();
    } catch (e, stackTrace) {
      Logger.log('Error recording GIF: $e');
      throw Sentry.addBreadcrumb(Breadcrumb(message: "Error sub recording GIF: $e $stackTrace", level: SentryLevel.error));
    }
  }

  img.Image? unflippedImage;
  Future<void> takePhoto() async {
    try {
      try {
        await cameraController.setFlashMode(FlashMode.always);
      } on CameraException catch (e) {
        if (e.code == 'setFlashModeFailed') {
          // Device does not have flash — silently ignore.
        } else {
          rethrow;
        }
      }
      loader.show();

      final file = await cameraController.takePicture();
      final File originalFile = File(file.path);

      // Read captured image
      final capturedBytes = await originalFile.readAsBytes();
      img.Image capturedImg = img.decodeImage(capturedBytes)!;
      unflippedImage = img.decodeImage(capturedBytes)!;

      // Mirror for front camera
      // capturedImg = img.flipHorizontal(capturedImg);


      final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;

      // 👉 Apply overlay ONLY if available
      if (overlayUrl != null && overlayUrl.isNotEmpty) {
        // final response = await http.get(Uri.parse(overlayUrl));

        // if (response.statusCode == 200) {
        // final overlayImg = img.decodeImage(response.bodyBytes);
        final byteData = await rootBundle.load(overlayUrl);
        var data = byteData.buffer.asUint8List();
        final overlayImg = img.decodeImage(data);
        if (overlayImg != null) {
          final resizedOverlay = img.copyResize(overlayImg, width: capturedImg.width, height: capturedImg.height);

          img.compositeImage(capturedImg, resizedOverlay);
          img.compositeImage(unflippedImage!, resizedOverlay);
        }
        // } else {
        //   Logger.log('Overlay skipped: HTTP ${response.statusCode}');
        // }
      }

      // Save final image
      final dir = await getTemporaryDirectory();
      final output = File('${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.png');
      final output2 = File('${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}_original.png');

      await output.writeAsBytes(img.encodePng(capturedImg));
      await output2.writeAsBytes(img.encodePng(unflippedImage!));

      capturedFile = XFile(output.path).obs;
      capturedFileOriginal = XFile(output2.path).obs;
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
    try {
      await cameraController.setFlashMode(FlashMode.always);
    } on CameraException catch (e) {
      if (e.code == 'setFlashModeFailed') {
        // Device does not have flash — silently ignore.
      } else {
        rethrow;
      }
    }
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
        XFile? file;
        if (DeviceController.to.experiences.value?.aiStyles.overlayEnabled == true) {
          file = await VideoUtils.applyOverlayOnNetworkImage(generatedImageUrl);
        } else {
          final tempDir = await getTemporaryDirectory();
          final responseBytes = await http.get(Uri.parse(generatedImageUrl));
          final filePath = '${tempDir.path}/ai_style_${DateTime.now().millisecondsSinceEpoch}.png';
          await File(filePath).writeAsBytes(responseBytes.bodyBytes);
          file = XFile(filePath);
        }
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
  Rx<VideoPlayerController?> videoControllerForOverlay = Rx<VideoPlayerController?>(null);
  Rx<VideoPlayerController?> videoControllerForActivity = Rx<VideoPlayerController?>(null);

  RxBool isVideoInitialized = false.obs;
  RxBool isVideoInitializedOverlay = false.obs;
  RxBool isVideoInitializedActivity = false.obs;
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

  // Future<void> recordSlomo({int seconds = 5, double? speed}) async {
  //   await cameraController.startVideoRecording();
  //   init(seconds); // 10 seconds recording

  //   await Future.delayed(Duration(seconds: seconds));
  //   stop();
  //   reset();
  //   final XFile videoFile = await cameraController.stopVideoRecording();
  //   loader.show();

  //   var noAudioFile = await VideoUtils.removeAudio(videoFile.path);
  //   var slowSpeedFile = await VideoUtils.changeVideoSpeed(noAudioFile, speed: speed ?? 1);
  //   var reversedFile = await VideoUtils.reverseVideo(noAudioFile);
  //   String? slomo = '';
  //   // /// 🔹 Download overlay if exists
  //   final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;
  //   try {
  //     if (overlayUrl != null && overlayUrl.isNotEmpty) {
  //       Logger.log("Applying overlay to 1st slomo video with overlayUrl: $overlayUrl");
  //       final processedPath = await NativeVideoOverlay.apply(videoPath: reversedFile, overlayAsset: overlayUrl);
  //       Logger.log("Applying overlay to 2nd slomo video with overlayUrl: $overlayUrl");
  //       final processedPathForward = await NativeVideoOverlay.apply(videoPath: slowSpeedFile, overlayAsset: overlayUrl);
  //       Logger.log("concatenating videos with overlayUrl");
  //       slomo = await VideoUtils.concatenateVideosLocal(localVideoPath: processedPathForward, remoteVideoUrl: processedPath);
  //       capturedFile = XFile(slomo!).obs;
  //       await initVideoPreview(slomo);
  //       loader.hide();
  //     } else {
  //       slomo = await VideoUtils.concatenateVideosLocal(localVideoPath: slowSpeedFile, remoteVideoUrl: reversedFile);
  //       capturedFile = XFile(slomo!).obs;
  //       await initVideoPreview(slomo);
  //       loader.hide();
  //     }
  //   } catch (e) {
  //     loader.hide();
  //     throw Sentry.addBreadcrumb(Breadcrumb(message: "Error in recordSlomo: $e", level: SentryLevel.error));
  //   }
  // }
  Future<void> recordSlomo({int seconds = 5, double? speed}) async {
    final sw = Stopwatch()..start();
    void logTime(String label) => Logger.log('⏱ $label: ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');

    await cameraController.startVideoRecording();
    init(seconds);

    await Future.delayed(Duration(seconds: seconds));
    stop();
    reset();
    final XFile videoFile = await cameraController.stopVideoRecording();
    loader.show();

    try {
      // Step 1: single pass — slow + reversed at original resolution
      sw.reset();
      final mirroredPath = await VideoUtils().mirrorVideo(videoFile.path!);
      final slomoPath = await VideoUtils.processSlomoSinglePass(inputPath: mirroredPath!, speed: speed ?? 1.0);
      logTime('processSlomoSinglePass');

      if (slomoPath == null) {
        Logger.log('Error: processSlomoSinglePass returned null');
        loader.hide();
        return;
      }

      // Step 2: apply overlay once on full video at original resolution
      String finalPath = slomoPath;
      final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;
      if (overlayUrl != null && overlayUrl.isNotEmpty) {
        sw.reset();
        Logger.log("Applying overlay to slomo video");
        finalPath = await NativeVideoOverlay.apply(videoPath: slomoPath, overlayAsset: overlayUrl);
        logTime('overlay');
      }

      // Step 3: preview
      sw.reset();
      capturedFile = XFile(finalPath).obs;
      await initVideoPreview(finalPath);
      logTime('initVideoPreview');

      loader.hide();
    } catch (e, stackTrace) {
      Logger.log('Error in recordSlomo: $e, stackTrace: $stackTrace');
      loader.hide();
      throw Sentry.addBreadcrumb(Breadcrumb(message: "Error in recordSlomo: $e", level: SentryLevel.error));
    }
  }

  bool startShoutoutRecording = false;
  Future<void> recordShoutout(String type, {int seconds = 10}) async {
    Logger.log("Starting shoutout recording for $seconds seconds");
    startShoutoutRecording = true;
    await cameraController.startVideoRecording();
    init(seconds); // 10 seconds recording

    await Future.delayed(Duration(seconds: seconds));
    if (startShoutoutRecording == true) {
      startShoutoutRecording = false;

      stop();
      reset();

      final XFile videoFile = await cameraController.stopVideoRecording();

      loader.show();
      // /// 🔹 Download overlay if exists
      final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;
      if (overlayUrl != null && overlayUrl.isNotEmpty) {
        final mirroredPath = await VideoUtils().mirrorVideo(videoFile.path!);
        final processedPath = await NativeVideoOverlay.apply(videoPath: mirroredPath!, overlayAsset: overlayUrl);
        capturedFile = XFile(processedPath).obs;
        await initVideoPreview(processedPath);
      } else {
        capturedFile = XFile(videoFile.path).obs;
        await initVideoPreview(videoFile.path);
      }
      loader.hide();
      Get.to(() => PreviewApproveScreen(capturedFile: CameraControllerX.to.capturedFile!.value, type: type));
    }
  }

  Future<void> stopShoutout(String type) async {
    startShoutoutRecording = false;
    stop();
    reset();
    final XFile videoFile = await cameraController.stopVideoRecording();
    loader.show();
    // /// 🔹 Download overlay if exists
    final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;
    if (overlayUrl != null && overlayUrl.isNotEmpty) {
      final mirroredPath = await VideoUtils().mirrorVideo(videoFile.path!);
      final processedPath = await NativeVideoOverlay.apply(videoPath: mirroredPath!, overlayAsset: overlayUrl);
      capturedFile = XFile(processedPath).obs;
      await initVideoPreview(processedPath);
    } else {
      capturedFile = XFile(videoFile.path).obs;
      await initVideoPreview(videoFile.path);
    }
    loader.hide();
    Get.to(() => PreviewApproveScreen(capturedFile: CameraControllerX.to.capturedFile!.value, type: type));
  }

  Future<void> recordBoomerang({int seconds = 1}) async {
    if (isBoomerangRecording.value) return;

    try {
      isBoomerangRecording.value = true;
      startBlinkingFlash(durationSeconds: seconds);

      await cameraController.startVideoRecording();

      await Future.delayed(Duration(seconds: seconds));

      final XFile videoFile = await cameraController.stopVideoRecording();

      stopBlinkingFlash();
      loader.show();

      final noAudioPath = await VideoUtils.removeAudio(videoFile.path);
      final boomerangPath = await VideoUtils.generateBoomerang(noAudioPath);
      final mirroredPath = await VideoUtils().mirrorVideo(boomerangPath!);
      final overlayUrl = DeviceController.to.branding.value?.photoVideoOverlay;
      if (overlayUrl != null && overlayUrl.isNotEmpty) {
        final processedPath = await NativeVideoOverlay.apply(videoPath: mirroredPath!, overlayAsset: overlayUrl);
        // final processedPathFlipped = await NativeVideoOverlay.apply(videoPath: mirroredPath!, overlayAsset: overlayUrl);
        capturedFile = XFile(processedPath).obs;
        await initVideoPreview(processedPath);
      } else {
        capturedFile = XFile(mirroredPath!).obs;
        await initVideoPreview(mirroredPath);
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

  RxString captureType = ''.obs;
  Future<void> submitLead(String type) async {
    try {
      // Snapshot everything synchronously before any async work
      final String originalFilePath = capturedFile!.value.path;
      final String originalFileName = capturedFile!.value.name;
      final String originalMimeType = capturedFile!.value.mimeType ?? 'image/jpeg';
      final bool publishToPublic = CameraControllerX.to.publishToPublic.value;
      final String eventName = PrefUtils().getString("eventName") ?? "unknown_event";
      // await initVideoPreview(capturedFile!.value.path);
      // Navigate immediately — user doesn't wait for processing
      Get.to(() => SenItToMeScreen2(capturedFile: capturedFile!.value, type: type));

      // Fire processing + enqueue in background — no await
      unawaited(
        _processAndEnqueue(
          type: type,
          originalFilePath: originalFilePath,
          originalFileName: originalFileName,
          originalMimeType: originalMimeType,
          publishToPublic: publishToPublic,
          eventName: eventName,
          peopleList: [],
        ),
      );
    } catch (e, stackTrace) {
      CustomSnackbar.showError(e.toString());
      Logger.log('Error submitting lead: $e $stackTrace');
    }
  }

  Future<void> _processAndEnqueue({
    required String type,
    required String originalFilePath,
    required String originalFileName,
    required String originalMimeType,
    required bool publishToPublic,
    required String eventName,
    required List<Map<String, dynamic>> peopleList,
  }) async {
    try {
      // LoaderService().show();
      final branding = DeviceController.to.branding.value;
      String processedPath = originalFilePath;

      if (type == 'Photo') {
        await savePhoto();
        processedPath = capturedFileOriginal!.value.path;
      } else if (type == 'Ai') {
        await saveAIPhoto();
        processedPath = capturedFile!.value.path;
      } else if (type == 'Boomerang') {
        processedPath = await _applyAudioAndPromo(
          filePath: originalFilePath,
          audio: branding?.backgroundAudio,
          enableAudio: branding?.enableAudioBoomerang ?? false,
          promoVideo: branding?.promoVideo,
          enablePromo: branding?.enablePromoBoomerang ?? false,
          useGifConcatenation: false,
        );
        capturedFile = XFile(processedPath).obs;
        var flippedPath = await VideoUtils().flipVideoHorizontally(processedPath);
        capturedFile = XFile(flippedPath!).obs;
        await saveVideo();
      } else if (type == 'Shoutout') {
        processedPath = await _applyPromoOnly(
          filePath: originalFilePath,
          promoVideo: branding?.promoVideo,
          enablePromo: branding?.enablePromoShoutout ?? false,
          useGifConcatenation: false,
        );
        capturedFile = XFile(processedPath).obs;
        await saveVideo();
      } else if (type == 'Gif') {
        processedPath = await _applyAudioAndPromo(
          filePath: originalFilePath,
          audio: branding?.backgroundAudio,
          enableAudio: branding?.enableAudioGif ?? false,
          promoVideo: branding?.promoVideo,
          enablePromo: branding?.enablePromoAnimatedGif ?? false,
          useGifConcatenation: true,
        );
        capturedFile = XFile(processedPath).obs;
        await saveVideo();
      } else if (type == 'Slomo') {
        processedPath = await _applyAudioAndPromo(
          filePath: originalFilePath,
          audio: branding?.backgroundAudio,
          enableAudio: branding?.enableAudioSlowmo ?? false,
          promoVideo: branding?.promoVideo,
          enablePromo: branding?.enablePromoSlowmo ?? false,
          useGifConcatenation: false,
        );
        capturedFile = XFile(processedPath).obs;
        await saveVideo();
      }

      final bytes = (await File(processedPath).stat()).size;
      if (Get.isRegistered<UploadQueueService>()) {
      } else {
        await Get.putAsync(() async {
          final service = UploadQueueService(
            repository: UploadRepository(),
            connectivity: InternetServiceAdapter(Get.find<InternetService>()),
            credentials: MyCredentialsProvider(),
          );
          await service.init();
          return service;
        }, permanent: true);
      }

      final uploadQueue = Get.find<UploadQueueService>();
      // await uploadQueue.init();

      final mediaId = await uploadQueue.enqueue(
        UploadEnqueueRequest(
          filePath: processedPath,
          fileName: originalFileName,
          fileSize: bytes,
          mimeType: originalMimeType,
          eventName: eventName,
          compress: true,
          listOnGallery: publishToPublic,
          leadCapture: peopleList,
        ),
      );

      uploadQueue.onItemUpdated.where((item) => item.id == mediaId).listen((item) {
        switch (item.status) {
          case UploadStatus.uploading:
            print('Progress: ${(item.uploadProgress * 100).toStringAsFixed(1)}%');
          case UploadStatus.completed:
            print('Done! CDN URL: ${item.mediaUrl}');
            print('Share link: ${item.imageLink}');
          case UploadStatus.failed:
            print('Failed after ${item.retryCount} attempts: ${item.errorMessage}');
          default:
            break;
        }
      });
    } catch (e, stackTrace) {
      Logger.log('Background processing/enqueue error: $e $stackTrace');
      // Soft error — user is already on the next screen
      // CustomSnackbar.showError('Upload failed: ${e.toString()}');
    } finally {
      // LoaderService().hide();
    }
  }

  Future<String> _applyAudioAndPromo({
    required String filePath,
    required String? audio,
    required bool enableAudio,
    required String? promoVideo,
    required bool enablePromo,
    required bool useGifConcatenation,
  }) async {
    String current = filePath;
    if (audio != null && enableAudio) {
      current = (await VideoUtils.attachBackgroundAudio(videoPath: current, audioUrl: audio))!;
    }
    return _applyPromoOnly(
      filePath: current,
      promoVideo: promoVideo,
      enablePromo: enablePromo,
      useGifConcatenation: useGifConcatenation,
    );
  }

  Future<String> _applyPromoOnly({
    required String filePath,
    required String? promoVideo,
    required bool enablePromo,
    required bool useGifConcatenation,
  }) async {
    if (promoVideo != null && enablePromo) {
      final result =
          // useGifConcatenation
          //     ? await VideoUtils.concatenateVideos(localVideoPath: filePath, remoteVideoUrl: promoVideo)
          //     :
          await VideoUtils.concatenateVideosLocal(localVideoPath: filePath, remoteVideoUrl: promoVideo);
      return result!;
    }
    return filePath;
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

      // capturedFile = null;
    } catch (e) {
      CustomSnackbar.showError('Something went wrong while saving.');
    }
  }
}
