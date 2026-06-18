import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/presentation/component/back_button.dart';
import 'package:sizer/sizer.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import 'package:video_player/video_player.dart';
import '../../infrastructure/constants/app_assets.dart';

class SenItToMeScreen2 extends StatefulWidget {
  const SenItToMeScreen2({super.key, this.capturedFile, required this.type, this.aiImageUrl});
  final XFile? capturedFile;
  final String type;
  final String? aiImageUrl;

  @override
  State<SenItToMeScreen2> createState() => _SenItToMeScreen2State();
}

class _SenItToMeScreen2State extends State<SenItToMeScreen2> {
  final camController = Get.find<CameraControllerX>();
  RxBool moveNext = false.obs;
  Timer? _popupTimer;
  var counter = 30.obs;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      camController.videoController.value?.play();
      _popupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (counter.value == 1) {
          Get.back();
          Get.back();
          Get.back();
          Get.back();
        } else {
          counter.value--;
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _popupTimer?.cancel();
    if (camController.videoController.value != null && camController.videoController.value!.value.isPlaying && !moveNext.value) {
      camController.videoController.value!.pause();
      camController.videoController.value!.seekTo(Duration.zero);
      // camController.videoController.value = null;
    }

    // Optionally, reset to start

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if ((widget.type == 'Photo' || widget.type == 'Ai') && widget.capturedFile != null)
            Positioned.fill(child: Image.file(File(camController.capturedFile!.value.path), fit: BoxFit.fill)),
          if (widget.type != 'Photo' && widget.type != 'Ai')
            Obx(() {
              if (!camController.isVideoInitialized.value || camController.videoController.value == null) {
                return const SizedBox();
              }
              final vc = camController.videoController.value!;
              return Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(width: vc.value.size.width, height: vc.value.size.height, child: VideoPlayer(vc)),
                ),
              );
            }),
          Positioned(
            top: 4.h,
            left: 3.w,
            child: CustomBackButton(
              onTap: () {
                Get.back();
                Get.back();
                Get.back();
                Get.back();
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'IT’S ON ITS WAY TO YOU!',
                style: textTheme.displayLarge!.copyWith(
                  fontSize: 28.sp,
                  shadows: [
                    Shadow(offset: Offset(0, 1), blurRadius: 6, color: Colors.black.withOpacity(0.6)),
                    Shadow(offset: Offset(0, 2), blurRadius: 12, color: Colors.black.withOpacity(0.4)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5.h),
              Text(
                'SENT. THANK YOU FOR TAPPING IN!',
                style: textTheme.displayLarge!.copyWith(
                  fontSize: 22.sp,
                  shadows: [
                    Shadow(offset: Offset(0, 1), blurRadius: 6, color: Colors.black.withOpacity(0.6)),
                    Shadow(offset: Offset(0, 2), blurRadius: 12, color: Colors.black.withOpacity(0.4)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Gap(2.h),
              SizedBox(height: 6.h),
              SizedBox(
                width: 90.w,
                child: ApprovalButton(
                  text: 'TAKE ANOTHER',
                  color: const Color(0xff00C846),
                  iconAssetPath: AppAssets.takePhoto,
                  onPressed: () {
                    Get.back();
                    Get.back();
                    Get.back();
                    Get.back();
                  },
                ),
              ),
              SizedBox(height: 25.h)
            ],
          ),
          Positioned(
            bottom: 10,
            left: 30,
            child: Container(
              height: 70,
              width: 70,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white, width: 10),
              ),
              child: Obx(() => Center(child: Text('${counter.value}', style: textTheme.labelMedium))),
            ),
          ),
        ],
      ),
    );
  }
}
