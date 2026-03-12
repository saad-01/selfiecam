import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/data/services/socket_service.dart';
import 'package:selfiecam1/infrastructure/constants/app_assets.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final deviceController = Get.find<DeviceController>();
  String get token => PrefUtils().getUserToken();
  bool _isImagePrecached = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isImagePrecached) {
      precacheImage(AssetImage(AppAssets.background1), context);
      precacheImage(AssetImage(AppAssets.logo2), context);
      precacheImage(AssetImage(AppAssets.logo1), context);
      _isImagePrecached = true;
    }
  }

  @override
  void initState() {
    super.initState();
    if (token.isNotEmpty) {
      if (PrefUtils().getString("eventJoined") == "true") {
        SocketService.init();
        unawaited(deviceController.loadAllInfo());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          deviceController.getJoinedEvent();
        });
        Timer(const Duration(seconds: 3), () {
          Get.offAllNamed(Routes.EXPERIENCESELECTION2);
        });
      } else {
        Timer(const Duration(seconds: 3), () {
          Get.offAllNamed(Routes.JOINEVENT);
        });
        Get.offAllNamed(Routes.JOINEVENT);
      }
    } else {
      Timer(const Duration(seconds: 3), () {
        Get.offAllNamed(Routes.SIGNIN);
      });
    }

    // unawaited(controller.loadAllInfo());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            /// Background
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                child: FadeInImage(
                  placeholder: AssetImage(AppAssets.background1), // same image
                  image: AssetImage(AppAssets.background1),
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 150),
                ),
              ),
            ),

            /// Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Top Logo
                  SizedBox(
                    height: 18.h,
                    child: Center(
                      child: Image.asset(AppAssets.logo1, width: 60.w, fit: BoxFit.contain),
                    ),
                  ),

                  /// Bottom Logo
                  Padding(
                    padding: EdgeInsets.only(bottom: 3.h),
                    child: Image.asset(AppAssets.logo2, width: 55.w, height: 10.h, fit: BoxFit.contain),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
