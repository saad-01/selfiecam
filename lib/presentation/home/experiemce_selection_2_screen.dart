import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
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
    // unawaited(deviceController.loadAllInfo());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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

            if (deviceController.branding.value?.homeOverlay == null || deviceController.branding.value!.homeOverlay!.isEmpty)
              Positioned.fill(child: Image.asset(AppAssets.demoOverlay, fit: BoxFit.fill)),
            if (deviceController.branding.value?.homeOverlay != null && deviceController.branding.value!.homeOverlay!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: deviceController.branding.value?.homeOverlay ?? '',
                fit: BoxFit.fill,
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
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
                    fontSize: 25.sp,
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
                // GridView.builder(gridDelegate: gridDelegate, itemBuilder: , itemCount: 6, shrinkWrap: true),
                experiencesGrid(),

                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 22.0.w),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     // spacing: 1.w,
                //     children: [
                //       CustomIconButton1(
                //         containerHeight: 18.h,
                //         containerWidth: 18.w,
                //         borderRadius: deviceController.branding.value?.buttonStyle == 'rounded' ? 10 : 0.0,
                //         color: deviceController.branding.value?.buttonColor != null
                //             ? Color(int.parse('0xff${deviceController.branding.value!.buttonColor.substring(1)}'))
                //             : const Color(0xff500F86),
                //         icon: AppAssets.selfie,
                //         font: deviceController.branding.value?.fontFamily,
                //         fontSize: deviceController.branding.value?.fontSize,
                //         iconSize: 6.h,
                //         label: 'Photo',
                //         iconColor: deviceController.branding.value?.buttonTextColor != null
                //             ? Color(int.parse('0xff${deviceController.branding.value!.buttonTextColor.substring(1)}'))
                //             : Colors.white,
                //         onPressed: () {
                //           Get.toNamed(Routes.COUNTDOWN);
                //         },
                //       ),

                //       CustomIconButton1(
                //         containerHeight: 18.h,
                //         containerWidth: 18.w,
                //         borderRadius: deviceController.branding.value?.buttonStyle == 'rounded' ? 10 : 0.0,
                //         color: deviceController.branding.value?.buttonColor != null
                //             ? Color(int.parse('0xff${deviceController.branding.value!.buttonColor.substring(1)}'))
                //             : const Color(0xff500F86),
                //         icon: AppAssets.boomerang,
                //         iconSize: 6.h,
                //         font: deviceController.branding.value?.fontFamily,
                //         fontSize: deviceController.branding.value?.fontSize,
                //         label: 'Boomerang',
                //         iconColor: deviceController.branding.value?.buttonTextColor != null
                //             ? Color(int.parse('0xff${deviceController.branding.value!.buttonTextColor.substring(1)}'))
                //             : Colors.white,
                //         onPressed: () {
                //           // Get.toNamed(Routes.WELCOME2);
                //         },
                //       ),

                //       CustomIconButton1(
                //         containerHeight: 18.h,
                //         containerWidth: 18.w,
                //         borderRadius: deviceController.branding.value?.buttonStyle == 'rounded' ? 10 : 0.0,
                //         color: deviceController.branding.value?.buttonColor != null
                //             ? Color(int.parse('0xff${deviceController.branding.value!.buttonColor.substring(1)}'))
                //             : const Color(0xff500F86),
                //         icon: AppAssets.gif,
                //         iconSize: 6.h,
                //         font: deviceController.branding.value?.fontFamily,
                //         fontSize: deviceController.branding.value?.fontSize,
                //         label: 'GIF',
                //         iconColor: deviceController.branding.value?.buttonTextColor != null
                //             ? Color(int.parse('0xff${deviceController.branding.value!.buttonTextColor.substring(1)}'))
                //             : Colors.white,
                //         onPressed: () {
                //           // Get.toNamed(Routes.WELCOME2);
                //         },
                //       ),
                //     ],
                //   ),
                // ),
                // Gap(1.h),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 22.0.w),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     // spacing: 1.w,
                //     children: [
                //       CustomIconButton1(
                //         containerHeight: 18.h,
                //         containerWidth: 18.w,
                //         borderRadius: deviceController.branding.value?.buttonStyle == 'rounded' ? 10 : 0.0,
                //         color: deviceController.branding.value?.buttonColor != null
                //             ? Color(int.parse('0xff${deviceController.branding.value!.buttonColor.substring(1)}'))
                //             : const Color(0xff500F86),
                //         icon: AppAssets.shoutout,
                //         font: deviceController.branding.value?.fontFamily,
                //         fontSize: deviceController.branding.value?.fontSize,
                //         iconSize: 6.h,
                //         label: 'Shoutout',
                //         iconColor: deviceController.branding.value?.buttonTextColor != null
                //             ? Color(int.parse('0xff${deviceController.branding.value!.buttonTextColor.substring(1)}'))
                //             : Colors.white,
                //         onPressed: () {
                //           // Get.toNamed(Routes.WELCOME2);
                //         },
                //       ),

                //       CustomIconButton1(
                //         containerHeight: 18.h,
                //         containerWidth: 18.w,
                //         borderRadius: deviceController.branding.value?.buttonStyle == 'rounded' ? 10 : 0.0,
                //         color: deviceController.branding.value?.buttonColor != null
                //             ? Color(int.parse('0xff${deviceController.branding.value!.buttonColor.substring(1)}'))
                //             : const Color(0xff500F86),
                //         icon: AppAssets.slowmo,
                //         iconSize: 6.h,
                //         font: deviceController.branding.value?.fontFamily,
                //         fontSize: deviceController.branding.value?.fontSize,
                //         label: 'Slowmo',
                //         iconColor: deviceController.branding.value?.buttonTextColor != null
                //             ? Color(int.parse('0xff${deviceController.branding.value!.buttonTextColor.substring(1)}'))
                //             : Colors.white,
                //         onPressed: () {
                //           // Get.toNamed(Routes.WELCOME2);
                //         },
                //       ),
                //       CustomIconButton1(
                //         containerHeight: 18.h,
                //         containerWidth: 18.w,
                //         borderRadius: deviceController.branding.value?.buttonStyle == 'rounded' ? 10 : 0.0,
                //         color: deviceController.branding.value?.buttonColor != null
                //             ? Color(int.parse('0xff${deviceController.branding.value!.buttonColor.substring(1)}'))
                //             : const Color(0xff500F86),
                //         icon: AppAssets.aiPhoto,
                //         iconSize: 6.h,
                //         font: deviceController.branding.value?.fontFamily,
                //         fontSize: deviceController.branding.value?.fontSize,
                //         label: 'AI Photo',
                //         iconColor: deviceController.branding.value?.buttonTextColor != null
                //             ? Color(int.parse('0xff${deviceController.branding.value!.buttonTextColor.substring(1)}'))
                //             : Colors.white,
                //         onPressed: () {
                //           // Get.toNamed(Routes.WELCOME2);
                //         },
                //       ),
                //     ],
                //   ),
                // ),
                Gap(10.h),
              ],
            ),
          ],
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
              onPressed: item.onTap,
            );
          },
        ),
      );
    });
  }
}
