import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/presentation/home/preview_approve_screen.dart';

class AnimationControllerX extends GetxController with GetTickerProviderStateMixin {
  static AnimationControllerX get to => Get.find();

  RxBool startAnimaton = false.obs;
  RxBool showReadyText = false.obs;
  RxBool showCounter = false.obs;
  RxInt counter = 3.obs;
  RxString type = ''.obs;
  late AnimationController bounceController;
  late AnimationController scaleController;
  late AnimationController readyController;

  late Animation<double> bounceAnimation;
  late Animation<double> scaleAnimation;
  late Animation<Offset> readySlide;
  late Animation<double> readyFade;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _initAnimations();
  }

  void _initAnimations() {
    bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    bounceAnimation = Tween<double>(
      begin: 0,
      end: -20,
    ).animate(CurvedAnimation(parent: bounceController, curve: Curves.easeInOut));

    scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

    scaleAnimation = Tween<double>(
      begin: 1.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: scaleController, curve: Curves.easeOutBack));

    readyController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    readySlide = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: readyController, curve: Curves.easeOut));

    readyFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: readyController, curve: Curves.easeOut));
  }

  /// 🔁 CALL THIS EVERY TIME SCREEN OPENS
  void startFlow() async {
    _timer?.cancel();

    counter.value = 3;
    startAnimaton.value = true;
    showReadyText.value = true;
    showCounter.value = false;

    bounceController
      ..reset()
      ..repeat(reverse: true);

    readyController
      ..reset()
      ..forward();

    await Future.delayed(const Duration(seconds: 3));

    await readyController.reverse();

    showReadyText.value = false;
    showCounter.value = true;

    scaleController
      ..reset()
      ..forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter.value == 1) {
        timer.cancel();
        _finish();
      } else {
        counter.value--;
        scaleController
          ..reset()
          ..forward();
      }
    });
  }

  Future<void> startFlowGif(int index) async {
    _timer?.cancel();

    counter.value = 3;
    startAnimaton.value = true;
    showCounter.value = true;

    bounceController
      ..reset()
      ..repeat(reverse: true);

    scaleController
      ..reset()
      ..forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (counter.value == 1) {
        timer.cancel();
        showCounter.value = false;
        startAnimaton.value = false;
        await CameraControllerX.to.subrecordGif(index);
      } else {
        counter.value--;
        scaleController
          ..reset()
          ..forward();
      }
    });
  }

  Future<void> _finish() async {
    bounceController.stop();
    startAnimaton.value = false;
    if (type.value == "Photo") {
      await CameraControllerX.to.takePhoto();
    }
    if (type.value == 'Boomerang') {
      await CameraControllerX.to.recordBoomerang();
    }
    if (type.value == 'Shoutout') {
      await CameraControllerX.to.recordShoutout(seconds: DeviceController.to.experiences.value!.shoutout.timeLimit);
    }
    if (type.value == 'Slomo') {
      await CameraControllerX.to.recordSlomo();
    }
    if (type.value == 'Gif') {
      await CameraControllerX.to.recordGif();
    }
    if (type.value == 'Ai') {
      await CameraControllerX.to.generateAiStyle();
      return;
    }

    Get.to(() => PreviewApproveScreen(capturedFile: CameraControllerX.to.capturedFile!.value, type: type.value));
  }

  @override
  void onClose() {
    _timer?.cancel();
    bounceController.dispose();
    scaleController.dispose();
    readyController.dispose();
    super.onClose();
  }
}
