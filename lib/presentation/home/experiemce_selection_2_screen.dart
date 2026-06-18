import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/infrastructure/utils/custom_snackbar.dart';
import 'package:selfiecam1/presentation/auth/sign_in/signup_webview.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (deviceController.branding.value?.homeNoActivityVideo != null &&
          deviceController.branding.value!.homeNoActivityVideo!.isNotEmpty) {
        deviceController.isIdle.value = false;
        deviceController.startIdleTimer();
      }
      camController.requestPhotoPermissionAfterLogin();
    });

    // unawaited(deviceController.loadAllInfo());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.translucent, // catches taps on transparent areas
      onTap: () => deviceController.resetIdleTimer(),
      onPanDown: (_) => deviceController.resetIdleTimer(),
      child: Obx(
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
              if (deviceController.branding.value?.homeScreenMode == 'none')
                Positioned.fill(child: Image.asset(AppAssets.demoOverlay, fit: BoxFit.fill)),
              if (deviceController.branding.value?.homeScreenMode == 'image' &&
                  deviceController.branding.value!.homeImage!.isNotEmpty)
                Image.asset(deviceController.branding.value?.homeImage ?? '', fit: BoxFit.fill),
              if (deviceController.branding.value?.homeScreenMode == 'video' &&
                  deviceController.branding.value!.homeVideo!.isNotEmpty)
                Obx(() {
                  if (!deviceController.isVideoInitializedOverlay.value ||
                      deviceController.videoControllerForOverlay.value == null) {
                    return const SizedBox();
                  }

                  return Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: deviceController.videoControllerForOverlay.value!.value.size.width,
                        height: deviceController.videoControllerForOverlay.value!.value.size.height,
                        child: VideoPlayer(deviceController.videoControllerForOverlay.value!),
                      ),
                    ),
                  );
                }),
              // Positioned.fill(child: Image.asset(AppAssets.demoOverlay, fit: BoxFit.fill)),
              Positioned(
                top: 20,
                left: 20,
                child: InkWell(
                  onTap: () {
                    Get.toNamed(Routes.AUTHMENU);
                  },
                  child: SvgPicture.asset(AppAssets.alignLeft, width: 3.h, height: 3.h),
                ),
              ), // Gap(3.h),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'SELECT YOUR EXPERIENCE',
                    style: textTheme.displayLarge!.copyWith(
                      fontSize: 55,
                      color: deviceController.branding.value?.fontColor != null
                          ? Color(int.parse('0xff${deviceController.branding.value!.fontColor.substring(1)}'))
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(offset: Offset(0, 1), blurRadius: 6, color: Colors.black.withOpacity(0.6)),
                        Shadow(offset: Offset(0, 2), blurRadius: 12, color: Colors.black.withOpacity(0.4)),
                      ],
                    ),
                  ),
                  Gap(3.h),
                  experiencesGrid(),
                  Gap(5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // spacing: 5,
                    children: [
                      if (deviceController.settings.value?.explicitDisclaimerEnabled == true)
                        Transform.scale(
                          scale: 1.5,
                          child: Checkbox(
                            value: deviceController.disclaimerAccepted.value,
                            onChanged: (value) {
                              deviceController.disclaimerAccepted.value = value ?? false;
                            },
                            checkColor: Colors.white,
                            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.blue; // checked color
                              }
                              return Colors.grey; // unchecked filled color
                            }),
                          ),
                        ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          children: [
                            const TextSpan(text: 'By using this application you agree to our '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(
                                    () => SignupWebview(
                                      url:
                                          deviceController.settings.value?.privacyPolicyUrl ??
                                          'https://www.selfiecam.com/privacy',
                                    ),
                                  );
                                },
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Terms of Use',
                              style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Handle Terms click
                                  // Get.toNamed('/terms');
                                  Get.to(
                                    () => SignupWebview(
                                      url: deviceController.settings.value?.termsUrl ?? 'https://www.selfiecam.com/terms',
                                    ),
                                  );
                                },
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Gap(2.h),
                ],
              ),
              (!deviceController.isIdle.value)
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () => deviceController.resetIdleTimer(),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Full-screen idle video
                          if (deviceController.isVideoInitializedActivity.value &&
                              deviceController.videoControllerForActivity.value != null)
                            FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: deviceController.videoControllerForActivity.value!.value.size.width,
                                height: deviceController.videoControllerForActivity.value!.value.size.height,
                                child: VideoPlayer(deviceController.videoControllerForActivity.value!),
                              ),
                            ),

                          // Fallback dark background if video not ready
                          if (!deviceController.isVideoInitializedActivity.value) Container(color: Colors.black),

                          // "Tap anywhere to start" label
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 60),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Text(
                                  'TAP ANYWHERE TO START',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(offset: const Offset(0, 1), blurRadius: 6, color: Colors.black.withOpacity(0.6)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget experiencesGrid() {
    return Obx(() {
      final experiences = deviceController.experiences.value;
      final branding = deviceController.branding.value;

      if (experiences == null) return const SizedBox();

      final items = deviceController.getEnabledExperiences(experiences);

      if (items.isEmpty) return const SizedBox();

      final int crossAxisCount = items.length > 5 ? 3 : items.length;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: items.length > 5 ? 22.w : 3.w),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 1.h,
            crossAxisSpacing: 1.w,
            mainAxisExtent: 18.h,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return CustomIconButton1(
              containerHeight: 18.h,
              containerWidth: 18.w,
              borderRadius: branding?.buttonStyle == 'rounded' ? 10 : 0,
              color: branding?.buttonColor != null
                  ? Color(int.parse('0xff${branding!.buttonColor.substring(1)}'))
                  : const Color(0xff500F86),
              icon: item.icon,
              iconSize: 6.h,
              font: branding?.fontFamily,
              fontSize: branding?.fontSize,
              label: item.label,
              iconColor: branding?.buttonTextColor != null
                  ? Color(int.parse('0xff${branding!.buttonTextColor.substring(1)}'))
                  : Colors.white,
              onPressed: deviceController.settings.value?.explicitDisclaimerEnabled == true
                  ? () {
                      if (deviceController.disclaimerAccepted.value) {
                        item.onTap();
                      } else {
                        CustomSnackbar.showInfo("Please accept the disclaimer to proceed.");
                      }
                    }
                  : item.onTap,
            );
          },
        ),
      );
    });
  }
}
