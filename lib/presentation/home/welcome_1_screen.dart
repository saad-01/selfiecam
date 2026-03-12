import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/data/services/socket_service.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:sizer/sizer.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import '../../infrastructure/constants/app_assets.dart';

class Welcome1Screen extends StatefulWidget {
  const Welcome1Screen({super.key});

  @override
  State<Welcome1Screen> createState() => _Welcome1ScreenState();
}

class _Welcome1ScreenState extends State<Welcome1Screen> {
  final camController = Get.put(CameraControllerX());
  final deviceController = Get.find<DeviceController>();
  @override
  void initState() {
    SocketService.init();
    unawaited(deviceController.loadAllInfo());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      deviceController.getJoinedEvent();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Obx(
      () => Scaffold(
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
            // Positioned.fill(child: Image.asset(AppAssets.demoFilter, fit: BoxFit.fill)),
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
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomIconButton(
                  containerHeight: 14.h,
                  containerWidth: 14.h,
                  color: Colors.white,
                  borderRadius: 10.h,
                  icon: Icons.arrow_forward_rounded,
                  iconColor: Colors.black,
                  iconSize: 6.h,
                  onPressed: () async {
                    Get.toNamed(Routes.EXPERIENCESELECTION2);
                  },
                ),
                Gap(5.h),
                Text(
                  'TAP TO START',
                  style: textTheme.labelLarge!.copyWith(color: Colors.white, fontSize: 20.sp),
                ),
                Gap(15.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
