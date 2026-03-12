import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/presentation/component/back_button.dart';
import 'package:selfiecam1/presentation/home/countdown_screen.dart';
import 'package:selfiecam1/presentation/home/preview_approve_screen.dart';
import 'package:sizer/sizer.dart';
import '../../infrastructure/constants/app_assets.dart';
import '../component/button_component1.dart';

class AiStylePreview extends StatefulWidget {
  const AiStylePreview({super.key, this.aiImageUrl});
  final String? aiImageUrl;
  @override
  State<AiStylePreview> createState() => _AiStylePreviewState();
}

class _AiStylePreviewState extends State<AiStylePreview> {
  final camController = Get.find<CameraControllerX>();
  // void _handleButtonClick(BuildContext context) {
  //   showCustomToastWithCheckbox(context);
  // }

  @override
  void dispose() {
    // Optionally, reset to start

    super.dispose();
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
            Positioned.fill(
              child: CachedNetworkImage(imageUrl: widget.aiImageUrl!, fit: BoxFit.fill),
            ),
            Positioned(
              top: 4.h,
              left: 3.w,
              child: CustomBackButton(
                onTap: () {
                  Get.back();
                },
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'This will be final result.\nDO YOU want to proceed?'.toUpperCase(),
                  style: textTheme.displayLarge!.copyWith(
                    fontSize: 28.sp,
                    shadows: [
                      Shadow(offset: Offset(0, 1), blurRadius: 6, color: Colors.black.withOpacity(0.6)),
                      Shadow(offset: Offset(0, 2), blurRadius: 12, color: Colors.black.withOpacity(0.4)),
                    ],
                  ),
                ),
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

                            // AnimationControllerX.to.startFlow();
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
                            // Get.back();
                            Get.off(() => CountdownScreen(type: 'Ai'));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(2.h),
                SizedBox(height: 15.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
