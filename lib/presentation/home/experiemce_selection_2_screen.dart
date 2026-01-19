import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:sizer/sizer.dart';
import '../../infrastructure/constants/app_assets.dart';
import '../../infrastructure/navigation/routes.dart';
import '../component/button_component1.dart';

class ExperienceSelectionScreen2 extends StatefulWidget {
  const ExperienceSelectionScreen2({super.key});

  @override
  State<ExperienceSelectionScreen2> createState() => _ExperienceSelectionScreen2State();
}

class _ExperienceSelectionScreen2State extends State<ExperienceSelectionScreen2> {
  final camController = Get.put(CameraControllerX());
  final deviceController = Get.find<DeviceController>();

  @override
  void initState() {
    unawaited(deviceController.loadAllInfo());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        // fit: StackFit.expand,
        children: [
          Obx(() {
            if (!camController.isReady.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return
            // cameraWidget(context);
            CameraPreview(camController.cameraController);
          }),
          Positioned.fill(child: Image.asset(AppAssets.demoFilter, fit: BoxFit.fill)),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('SELECT YOUR EXPERIENCE', style: textTheme.displayLarge!.copyWith(fontSize: 25.sp)),
              Gap(3.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.0.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // spacing: 1.w,
                  children: [
                    CustomIconButton1(
                      containerHeight: 18.h,
                      containerWidth: 18.w,
                      borderRadius: 0.0,
                      color: const Color(0xff500F86),
                      icon: AppAssets.selfie,
                      iconSize: 6.h,
                      label: 'Photo',
                      onPressed: () {
                        Get.toNamed(Routes.COUNTDOWN);
                      },
                    ),

                    CustomIconButton1(
                      containerHeight: 18.h,
                      containerWidth: 18.w,
                      borderRadius: 0.0,
                      color: const Color(0xff500F86),
                      icon: AppAssets.boomerang,
                      iconSize: 6.h,
                      label: 'Boomerang',
                      onPressed: () {
                        // Get.toNamed(Routes.WELCOME2);
                      },
                    ),

                    CustomIconButton1(
                      containerHeight: 18.h,
                      containerWidth: 18.w,
                      borderRadius: 0.0,
                      color: const Color(0xff500F86),
                      icon: AppAssets.gif,
                      iconSize: 6.h,
                      label: 'GIF',
                      onPressed: () {
                        // Get.toNamed(Routes.WELCOME2);
                      },
                    ),

                    CustomIconButton1(
                      containerHeight: 18.h,
                      containerWidth: 18.w,
                      borderRadius: 0.0,
                      color: const Color(0xff500F86),
                      icon: AppAssets.shoutout,
                      iconSize: 6.h,
                      label: 'Shoutout',
                      onPressed: () {
                        // Get.toNamed(Routes.WELCOME2);
                      },
                    ),

                    CustomIconButton1(
                      containerHeight: 18.h,
                      containerWidth: 18.w,
                      borderRadius: 0.0,
                      color: const Color(0xff500F86),
                      icon: AppAssets.slowmo,
                      iconSize: 6.h,
                      label: 'Slowmo',
                      onPressed: () {
                        // Get.toNamed(Routes.WELCOME2);
                      },
                    ),
                  ],
                ),
              ),
              Gap(15.h),
            ],
          ),
        ],
      ),
    );
  }
}
