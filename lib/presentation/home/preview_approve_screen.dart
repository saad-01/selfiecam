import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:sizer/sizer.dart';
import '../../infrastructure/constants/app_assets.dart';
import '../../infrastructure/navigation/routes.dart';
import '../component/button_component1.dart';
import '../component/toast_component.dart';

class PreviewApproveScreen extends StatefulWidget {
  const PreviewApproveScreen({super.key, this.capturedFile});
  final XFile? capturedFile;
  @override
  State<PreviewApproveScreen> createState() => _PreviewApproveScreenState();
}

class _PreviewApproveScreenState extends State<PreviewApproveScreen> {
  final camController = Get.find<CameraControllerX>();
  void _handleButtonClick(BuildContext context) {
    showCustomToastWithCheckbox(context);
  }

  void showCustomToastWithCheckbox(BuildContext context) {
    void navigate() {
      Get.toNamed(Routes.SENDITTOME);
    }

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => CustomToastWithCheckbox(overlayEntry: overlayEntry!, onCheckedNavigate: navigate),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: Image.file(File(camController.capturedFile!.value.path), fit: BoxFit.fill)),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('YOU LIKE IT?', style: textTheme.displayLarge!.copyWith(fontSize: 28.sp)),
                Gap(2.h),
                SizedBox(
                  width: 90.w,
                  child: Row(
                    children: [
                      Expanded(
                        child: ApprovalButton(
                          text: 'NO WAY',
                          color: const Color(0xffFF0000),
                          iconAssetPath: AppAssets.thumbdown,
                          onPressed: () {
                            Get.back();
                            camController.startCountdown();
                          },
                        ),
                      ),
                      Gap(2.w),
                      Expanded(
                        child: ApprovalButton(
                          text: 'OH YEAH',
                          color: const Color(0xff00C846),
                          iconAssetPath: AppAssets.thumbup,
                          onPressed: () async {
                            // _handleButtonClick(context);
                            await camController.savePhoto();
                            await camController.uploadToApi(widget.capturedFile!);
                            // Get.back();

                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(
                    'By pressing “OH YEAH!” you agree to our terms & conditions and privacy policy agreement',
                    textAlign: TextAlign.center,
                    style: textTheme.labelMedium!.copyWith(fontSize: 15.sp),
                  ),
                ),
                SizedBox(height: 15.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
