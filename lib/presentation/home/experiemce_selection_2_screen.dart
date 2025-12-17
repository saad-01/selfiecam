import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../infrastructure/constants/app_assets.dart';
import '../../infrastructure/navigation/routes.dart';
import '../component/button_component1.dart';

class ExperienceSelectionScreen2 extends StatelessWidget {
  const ExperienceSelectionScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.background2, fit: BoxFit.fill),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'SELECT YOUR EXPERIENCE',
                style: textTheme.displayLarge!.copyWith(fontSize: 25.sp),
              ),
              Gap(3.h),
              SizedBox(
                width: 100.w,
                height: 20.h, // container height for icon buttons
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Row(
                    children: [
                      CustomIconButton1(
                        containerHeight: 18.h,
                        containerWidth: 20.w,
                        borderRadius: 0.0,
                        color: const Color(0xff500F86),
                        icon: AppAssets.selfie,
                        iconSize: 6.h,
                        label: 'Photo Selfie',
                        onPressed: () {
                          Get.toNamed(Routes.WELCOME2);
                        },
                      ),
                      SizedBox(width: 2.w),
                      CustomIconButton1(
                        containerHeight: 18.h,
                        containerWidth: 20.w,
                        borderRadius: 0.0,
                        color: const Color(0xff500F86),
                        icon: AppAssets.boomerang,
                        iconSize: 6.h,
                        label: 'Boomerang',
                        onPressed: () {
                          Get.toNamed(Routes.WELCOME2);
                        },
                      ),
                      SizedBox(width: 2.w),
                      CustomIconButton1(
                        containerHeight: 18.h,
                        containerWidth: 20.w,
                        borderRadius: 0.0,
                        color: const Color(0xff500F86),
                        icon: AppAssets.gif,
                        iconSize: 6.h,
                        label: 'GIF',
                        onPressed: () {
                          Get.toNamed(Routes.WELCOME2);
                        },
                      ),
                      SizedBox(width: 2.w),
                      CustomIconButton1(
                        containerHeight: 18.h,
                        containerWidth: 20.w,
                        borderRadius: 0.0,
                        color: const Color(0xff500F86),
                        icon: AppAssets.shoutout,
                        iconSize: 6.h,
                        label: 'Shoutout',
                        onPressed: () {
                          Get.toNamed(Routes.WELCOME2);
                        },
                      ),
                      SizedBox(width: 2.w),
                      CustomIconButton1(
                        containerHeight: 18.h,
                        containerWidth: 20.w,
                        borderRadius: 0.0,
                        color: const Color(0xff500F86),
                        icon: AppAssets.slowmo,
                        iconSize: 6.h,
                        label: 'Slowmo',
                        onPressed: () {
                          Get.toNamed(Routes.WELCOME2);
                        },
                      ),
                    ],
                  ),
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
