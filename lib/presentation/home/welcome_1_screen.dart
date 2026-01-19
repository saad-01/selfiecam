import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/data/services/socket_service.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:selfiecam1/presentation/home/experiemce_selection_2_screen.dart';
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
  @override
  void initState() {
    SocketService.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: Image.asset(AppAssets.background2, fit: BoxFit.fill)),
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
                  Get.offAllNamed(Routes.EXPERIENCESELECTION2);
                },
              ),
              Gap(5.h),
              Text(
                'TAP ANYWHERE TO START',
                style: textTheme.labelLarge!.copyWith(color: Colors.white, fontSize: 20.sp),
              ),
              Gap(15.h),
              InkWell(
                child: Text(
                  "SIGN OUT (for testing)",
                  style: textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    fontSize: 20.sp,
                  ),
                ),
                onTap: () async {
                  await PrefUtils().clearPreferencesData();
                  Get.offAllNamed(Routes.SIGNIN);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
