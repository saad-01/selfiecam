import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/animation_controller.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/presentation/component/button_component.dart';
import 'package:selfiecam1/presentation/component/progress_bar.dart';
import 'package:sizer/sizer.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key, required this.type});
  final String type;
  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  final camController = Get.find<CameraControllerX>();
  final controller = Get.put(AnimationControllerX());
  final deviceController = Get.find<DeviceController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.startFlow();
      controller.type.value = widget.type;
      if (widget.type == "Gif") {
        camController.timer2 = Timer.periodic(const Duration(seconds: 2), (timer) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    });

    // camController.startCountdown();
  }

  @override
  void dispose() {
    camController.timer?.cancel();
    if (widget.type == 'Gif') {
      camController.timer2?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Obx(() {
              if (!camController.isReady.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return
              // cameraWidget(context);
              CameraPreview(camController.cameraController);
            }),
            Obx(
              () => AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: camController.isFlashing.value ? 0.85 : 0.0,
                child: Container(color: Colors.white),
              ),
            ),
            if (deviceController.branding.value?.photoVideoOverlay != null &&
                deviceController.branding.value!.photoVideoOverlay!.isNotEmpty)
              Image.asset(deviceController.branding.value?.photoVideoOverlay ?? '', fit: BoxFit.fill),
            // Image.asset(AppAssets.demoFilter ?? '', fit: BoxFit.fill),
            if (controller.startAnimaton.value)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: Opacity(opacity: 0.5, child: Container(color: Colors.white)),
              ),
            if (controller.startAnimaton.value && controller.showCounter.value)
              Align(
                alignment: Alignment.center,
                child: AnimatedBuilder(
                  animation: controller.scaleController,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: controller.scaleAnimation.value,
                      child: Text(
                        controller.counter.value.toString(),
                        style: TextStyle(fontSize: 630, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    );
                  },
                ),
              ),
            if (controller.startAnimaton.value && controller.showReadyText.value)
              Align(
                alignment: Alignment.center,
                child: SlideTransition(
                  position: controller.readySlide,
                  child: FadeTransition(
                    opacity: controller.readyFade,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.type == 'Photo'
                              ? "GET READY TO STIKE A POSE!".toUpperCase()
                              : widget.type == 'Boomerang'
                              ? "GET READY TO BUST A MOVE!".toUpperCase()
                              : widget.type == 'Shoutout'
                              ? "GET READY TO RECORD A VIDEO!".toUpperCase()
                              : widget.type == 'Slomo'
                              ? "GET READY TO SHOW US YOUR MOVES!".toUpperCase()
                              : widget.type == 'Gif'
                              ? "GET READY FOR A PHOTO SHOOT! ".toUpperCase()
                              : "GET READY TO STIKE A POSE!".toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 80, fontWeight: FontWeight.w300),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "IT’S A ".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black, fontSize: 90, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.type == 'Photo'
                                  ? "PHOTO".toUpperCase()
                                  : widget.type == 'Boomerang'
                                  ? "Boomerang".toUpperCase()
                                  : widget.type == 'Shoutout'
                                  ? "Shoutout".toUpperCase()
                                  : widget.type == 'Slomo'
                                  ? "Slomo".toUpperCase()
                                  : widget.type == 'Gif'
                                  ? "Gif".toUpperCase()
                                  : "PHOTO".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black, fontSize: 90, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (controller.startAnimaton.value)
              Positioned(
                top: 40,
                right: 40,
                left: 40,
                child: Align(
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation: controller.bounceController,
                    builder: (_, child) {
                      return Transform.translate(offset: Offset(0, controller.bounceAnimation.value), child: child);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(color: Color(0xff008FC8), borderRadius: BorderRadius.circular(100)),
                      child: Text(
                        "LOOK 👆🏻 HERE",
                        style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
            if (camController.isRecording.value && (widget.type == 'Shoutout'))
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 300,
                    child: ButtonComponent(
                      text: 'STOP',
                      borderRadius: 0.0,
                      backgroundColor: Colors.red,
                      fontColor: Colors.white,
                      onPressed: () async {
                        await camController.stopShoutout(widget.type);
                      },
                    ),
                  ),
                ),
              ),
            if (camController.isRecording.value)
              Positioned(bottom: 50, left: 30, right: 30, child: RecordingProgressBar(height: 20)),

            Positioned(
              bottom: 6.h,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // if (camController.isCounting.value) ...[
                    //   Text(
                    //     _countdownText[camController.counter.value] ?? "",
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //       fontFamily: 'Bebas',
                    //       fontSize: 30.sp,
                    //       fontWeight: FontWeight.w700,
                    //       color: Colors.white,
                    //       shadows: const [Shadow(blurRadius: 5, color: Colors.black, offset: Offset(2, 2))],
                    //     ),
                    //   ),
                    //   Gap(6.h),
                    //   Container(
                    //     width: 50.w,
                    //     height: 50.w,
                    //     decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                    //     child: Center(
                    //       child: Text(
                    //         '${camController.counter.value}',
                    //         style: TextStyle(fontFamily: 'Akshar', fontSize: 50.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    //       ),
                    //     ),
                    //   ),
                    // ],
                    // else[

                    // ]
                    // else ...[
                    //   Text(
                    //     "GET READY FOR\n4 QUICK SHOTS!",
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //       fontFamily: 'Bebas',
                    //       fontSize: 30.sp,
                    //       fontWeight: FontWeight.w700,
                    //       color: Colors.white,
                    //       shadows: const [Shadow(blurRadius: 5, color: Colors.black, offset: Offset(2, 2))],
                    //     ),
                    //   ),
                    //   Gap(10.h),
                    if (widget.type == 'Gif')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (index) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 1.w),
                            child: InkWell(
                              onTap: () {
                                // Get.toNamed(Routes.PREVIEW);
                              },
                              child: Container(
                                width: 16.w,
                                height: 22.w,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: camController.capturedFile1?.value != null && index == 0
                                    ? Image.file(File(camController.capturedFile1!.value.path), fit: BoxFit.cover)
                                    : camController.capturedFile2?.value != null && index == 1
                                    ? Image.file(File(camController.capturedFile2!.value.path), fit: BoxFit.cover)
                                    : camController.capturedFile3?.value != null && index == 2
                                    ? Image.file(File(camController.capturedFile3!.value.path), fit: BoxFit.cover)
                                    : camController.capturedFile4?.value != null && index == 3
                                    ? Image.file(File(camController.capturedFile4!.value.path), fit: BoxFit.cover)
                                    : const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
