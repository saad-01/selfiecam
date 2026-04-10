import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/animation_controller.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/presentation/auth/sign_in/signup_webview.dart';
import 'package:selfiecam1/presentation/component/back_button.dart';
import 'package:selfiecam1/presentation/home/send_it_to_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import '../../infrastructure/constants/app_assets.dart';
import '../../infrastructure/navigation/routes.dart';
import '../component/button_component1.dart';
import '../component/toast_component.dart';

class PreviewApproveScreen extends StatefulWidget {
  const PreviewApproveScreen({super.key, this.capturedFile, required this.type, this.aiImageUrl});
  final XFile? capturedFile;
  final String type;
  final String? aiImageUrl;
  @override
  State<PreviewApproveScreen> createState() => _PreviewApproveScreenState();
}

class _PreviewApproveScreenState extends State<PreviewApproveScreen> {
  final camController = Get.find<CameraControllerX>();
  RxBool moveNext = false.obs;
  // void _handleButtonClick(BuildContext context) {
  //   showCustomToastWithCheckbox(context);
  // }
  Timer? _popupTimer;
  var counter = 30.obs;
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
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _popupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (counter.value == 1) {
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
      camController.videoController.value = null;
    }

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
            if (widget.type == 'Photo' || widget.type == 'Ai')
              Positioned.fill(child: Image.file(File(camController.capturedFile!.value.path), fit: BoxFit.fill)),
            if (widget.type != 'Photo' && widget.type != 'Ai')
              Obx(() {
                if (!camController.isVideoInitialized.value || camController.videoController.value == null) {
                  return const SizedBox();
                }

                return Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: camController.videoController.value!.value.size.width,
                      height: camController.videoController.value!.value.size.height,
                      child: VideoPlayer(camController.videoController.value!),
                    ),
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
                },
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'DO YOU LIKE IT?',
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
                            // Get.back();
                            // Get.put(AnimationControllerX());
                            CameraControllerX.to.capturedFile1 = null;
                            CameraControllerX.to.capturedFile2 = null;
                            CameraControllerX.to.capturedFile3 = null;
                            CameraControllerX.to.capturedFile4 = null;
                            Future.delayed(const Duration(milliseconds: 200), () {
                              AnimationControllerX.to.startFlow();
                            });

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
                            // Get.toNamed(Routes.SENDITTOME);
                            //  throw StateError('This is test exception');
                            // throw Sentry.addBreadcrumb(Breadcrumb(message: "Step 2 failed: looped video not created"));
                            final config = DeviceController.to.leadCaptureConfig.value;

                            final fields = config!.fields;

                            /// check if ANY field is enabled
                            final hasAnyFieldEnabled =
                                fields.name.enabled ||
                                fields.email.enabled ||
                                fields.phone.enabled ||
                                fields.company.enabled ||
                                fields.instagram.enabled ||
                                fields.tiktok.enabled ||
                                fields.consent.enabled;
                            if (DeviceController.to.leadCaptureConfig.value != null && hasAnyFieldEnabled) {
                              moveNext.value = true;
                              Get.off(
                                () => SenItToMeScreen(
                                  type: widget.type,
                                  capturedFile: widget.capturedFile,
                                  aiImageUrl: widget.aiImageUrl,
                                ),
                              );
                            } else {
                              // Directly upload and save without showing lead capture
                              camController.submitLead(widget.type);
                            }

                            // _handleButtonClick(context);
                            // if (widget.type == 'Photo') {
                            //   await camController.uploadToApi(widget.capturedFile!);
                            //   await camController.savePhoto();
                            // } else if (widget.type == 'Boomerang') {
                            //   if (DeviceController.to.branding.value?.backgroundAudio != null &&
                            //       DeviceController.to.branding.value!.enableAudioBoomerang) {
                            //     var video1 = await VideoUtils.attachBackgroundAudio(
                            //       videoPath: widget.capturedFile!.path,
                            //       audioUrl: DeviceController.to.branding.value!.backgroundAudio!,
                            //     );

                            //     if (DeviceController.to.branding.value?.promoVideo != null &&
                            //         DeviceController.to.branding.value!.enablePromoBoomerang) {
                            //       var video = await VideoUtils.concatenateVideos(
                            //         localVideoPath: video1!,
                            //         remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
                            //       );
                            //       camController.capturedFile = XFile(video!).obs;
                            //       await camController.uploadToApi(camController.capturedFile!.value);
                            //       await camController.saveVideo();
                            //     } else {
                            //       camController.capturedFile = XFile(video1!).obs;
                            //       await camController.uploadToApi(camController.capturedFile!.value);
                            //       await camController.saveVideo();
                            //     }
                            //   } else {
                            //     if (DeviceController.to.branding.value?.promoVideo != null &&
                            //         DeviceController.to.branding.value!.enablePromoBoomerang) {
                            //       var video = await VideoUtils.concatenateVideosSecond(
                            //         localVideoPath: widget.capturedFile!.path,
                            //         remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
                            //       );
                            //       Logger.log("hi");
                            //       camController.capturedFile = XFile(video!).obs;
                            //       await camController.uploadToApi(camController.capturedFile!.value);
                            //       await camController.saveVideo();
                            //     } else {
                            //       await camController.uploadToApi(widget.capturedFile!);
                            //       await camController.saveVideo();
                            //     }
                            //   }

                            //   // await camController.uploadToApi(widget.capturedFile!);
                            // } else if (widget.type == 'Shoutout') {
                            //   if (DeviceController.to.branding.value?.promoVideo != null &&
                            //       DeviceController.to.branding.value!.enablePromoShoutout) {
                            //     var video = await VideoUtils.concatenateVideosSecond(
                            //       localVideoPath: widget.capturedFile!.path,
                            //       remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
                            //     );
                            //     camController.capturedFile = XFile(video!).obs;
                            //     await camController.uploadToApi(camController.capturedFile!.value);
                            //     await camController.saveVideo();
                            //   } else {
                            //     await camController.uploadToApi(widget.capturedFile!);
                            //     await camController.saveVideo();
                            //   }

                            //   // await camController.uploadToApi(widget.capturedFile!);
                            // } else if (widget.type == 'Gif') {
                            //   if (DeviceController.to.branding.value?.backgroundAudio != null &&
                            //       DeviceController.to.branding.value!.enableAudioGif) {
                            //     var video1 = await VideoUtils.attachBackgroundAudio(
                            //       videoPath: widget.capturedFile!.path,
                            //       audioUrl: DeviceController.to.branding.value!.backgroundAudio!,
                            //     );

                            //     if (DeviceController.to.branding.value?.promoVideo != null &&
                            //         DeviceController.to.branding.value!.enablePromoAnimatedGif) {
                            //       var video = await VideoUtils.concatenateVideos(
                            //         localVideoPath: video1!,
                            //         remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
                            //       );
                            //       camController.capturedFile = XFile(video!).obs;
                            //       await camController.uploadToApi(camController.capturedFile!.value);
                            //       await camController.saveVideo();
                            //     } else {
                            //       camController.capturedFile = XFile(video1!).obs;
                            //       await camController.uploadToApi(camController.capturedFile!.value);
                            //       await camController.saveVideo();
                            //     }
                            //   } else {
                            //     if (DeviceController.to.branding.value?.promoVideo != null &&
                            //         DeviceController.to.branding.value!.enablePromoAnimatedGif) {
                            //       var video = await VideoUtils.concatenateVideosSecond(
                            //         localVideoPath: widget.capturedFile!.path,
                            //         remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
                            //       );
                            //       Logger.log("hi");
                            //       camController.capturedFile = XFile(video!).obs;
                            //       await camController.uploadToApi(camController.capturedFile!.value);
                            //       await camController.saveVideo();
                            //     } else {
                            //       await camController.uploadToApi(widget.capturedFile!);
                            //       await camController.saveVideo();
                            //     }
                            //   }

                            //   // await camController.uploadToApi(widget.capturedFile!);
                            // } else if (widget.type == 'Slomo') {
                            //   if (DeviceController.to.branding.value?.backgroundAudio != null &&
                            //       DeviceController.to.branding.value!.enableAudioSlowmo) {
                            //     var video1 = await VideoUtils.attachBackgroundAudio(
                            //       videoPath: widget.capturedFile!.path,
                            //       audioUrl: DeviceController.to.branding.value!.backgroundAudio!,
                            //     );

                            //     if (DeviceController.to.branding.value?.promoVideo != null &&
                            //         DeviceController.to.branding.value!.enablePromoSlowmo) {
                            //       var video = await VideoUtils.concatenateVideos(
                            //         localVideoPath: video1!,
                            //         remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
                            //       );
                            //       camController.capturedFile = XFile(video!).obs;
                            //       await camController.uploadToApi(camController.capturedFile!.value);
                            //       await camController.saveVideo();
                            //     } else {
                            //       camController.capturedFile = XFile(video1!).obs;
                            //       await camController.uploadToApi(camController.capturedFile!.value);
                            //       await camController.saveVideo();
                            //     }
                            //   } else {
                            //     if (DeviceController.to.branding.value?.promoVideo != null &&
                            //         DeviceController.to.branding.value!.enablePromoSlowmo) {
                            //       var video = await VideoUtils.concatenateVideosSecond(
                            //         localVideoPath: widget.capturedFile!.path,
                            //         remoteVideoUrl: DeviceController.to.branding.value!.promoVideo!,
                            //       );
                            //       Logger.log("hi");
                            //       camController.capturedFile = XFile(video!).obs;
                            //       await camController.uploadToApi(camController.capturedFile!.value);
                            //       await camController.saveVideo();
                            //     } else {
                            //       await camController.uploadToApi(widget.capturedFile!);
                            //       await camController.saveVideo();
                            //     }
                            //   }

                            //   // await camController.uploadToApi(widget.capturedFile!);
                            // } else if (widget.type == 'Ai') {
                            //   await camController.uploadToApi(camController.capturedFile!.value);
                            //   await camController.savePhoto();
                            // }

                            // Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Transform.scale(
                        scale: 2,
                        child: Checkbox(
                          value: camController.publishToPublic.value,
                          onChanged: (value) {
                            camController.publishToPublic.value = value ?? false;
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
                      Text(
                        'Publish to public gallery',
                        style: textTheme.displayLarge!.copyWith(
                          fontSize: 25,
                          shadows: [
                            Shadow(offset: Offset(0, 1), blurRadius: 6, color: Colors.black.withOpacity(0.6)),
                            Shadow(offset: Offset(0, 2), blurRadius: 12, color: Colors.black.withOpacity(0.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Gap(2.h),

                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 6.w),
                //   child: Text(
                //     'By pressing “OH YEAH!” you agree to the ',
                //     textAlign: TextAlign.center,
                //     style: textTheme.labelMedium!.copyWith(fontSize: 15.sp),
                //   ),
                // ),
                SizedBox(height: 15.h),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    children: [
                      const TextSpan(text: 'By pressing “OH YEAH!” you agree to the '),
                      TextSpan(
                        text: 'Photo release agreement',
                        style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Handle Privacy Policy click
                            // Get.toNamed('/privacy');
                            // OR launch URL
                            Get.to(() => SignupWebview(url: "https://hub.selfiecam.ai/photo-release-agreement-app"));
                          },
                      ),

                      const TextSpan(text: '.'),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),
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
      ),
    );
  }
}
