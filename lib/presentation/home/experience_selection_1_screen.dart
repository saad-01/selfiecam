import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import '../../infrastructure/constants/app_assets.dart';
import 'package:sizer/sizer.dart';

class ExperienceSelectionScreen1 extends StatelessWidget {
  const ExperienceSelectionScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
              child: Image.asset(AppAssets.background1, fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 100.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 8.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomIconButton(
                              borderRadius: 1.5.w,
                              containerHeight: 4.h,
                              containerWidth: 4.h,
                              icon: Icons.close,
                              color: Colors.white,
                              iconColor: Colors.black,
                              containerPadding: 0,
                              label: '',
                              iconSize: 3.h,
                              onPressed: () {
                                Get.back();
                              },
                            ),
                            Text(
                              'iPad2Air | 32.6GB | 74%',
                              style: textTheme.labelMedium!.copyWith(
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              'saadbooth@gmail.com',
                              style: textTheme.labelMedium!.copyWith(
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 55.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SELECT EXPERIENCE',
                              style: textTheme.displayLarge,
                            ),
                            SizedBox(height: 1.5.h),
                            Text(
                              'Tap an experience to let users choose',
                              style: textTheme.labelMedium!.copyWith(
                                letterSpacing: 0.3.w,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            SizedBox(
                              width: 90.w,
                              height: 20.h,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SizedBox(width: 2.w),
                                    CustomIconButton1(
                                      icon: AppAssets.selfie,
                                      label: 'Photo Selfie',
                                      borderRadius: 0.0,
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 3.w),
                                    CustomIconButton1(
                                      icon: AppAssets.boomerang,
                                      label: 'Boomerang',
                                      borderRadius: 0.0,
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 3.w),
                                    CustomIconButton1(
                                      icon: AppAssets.gif,
                                      label: 'GIF',
                                      borderRadius: 0.0,
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 3.w),
                                    CustomIconButton1(
                                      icon: AppAssets.shoutout,
                                      label: 'Shoutout',
                                      borderRadius: 0.0,
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 3.w),
                                    CustomIconButton1(
                                      icon: AppAssets.slowmo,
                                      label: 'Slowmo',
                                      borderRadius: 0.0,
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 2.w),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 5.h),
                            SizedBox(
                              width: 90.w,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomUtilityButton(
                                    text: 'Refresh',
                                    color: const Color(0xFF00B09B),
                                    borderRadius: 0.0,
                                    onPressed: () {
                                      Get.toNamed(Routes.WELCOME1);
                                    },
                                  ),
                                  CustomUtilityButton(
                                    text: 'Test Bandwidth',
                                    color: const Color(0xFFE50914),
                                    borderRadius: 0.0,
                                    onPressed: () {
                                      Get.toNamed(Routes.WELCOME1);
                                    },
                                  ),
                                  CustomUtilityButton(
                                    text: 'Pending Uploads',
                                    color: const Color(0xFFFFC107),
                                    borderRadius: 0.0,
                                    onPressed: () {
                                      Get.toNamed(Routes.WELCOME1);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 28.h,
                        child: Column(
                          children: [
                            Text(
                              'SCAN FOR DASHBOARD',
                              style: textTheme.headlineMedium!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w100,
                                fontSize: 18.sp,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Image.asset(AppAssets.qr, height: 16.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* class ExperienceSelectionScreen1 extends StatelessWidget {
  const ExperienceSelectionScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
              child: Image.asset(AppAssets.background1, fit: BoxFit.cover),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomIconButton(
                          borderRadius: 5,
                          containerHeight: 45,
                          containerWidth: 45,
                          icon: Icons.close,
                          color: Colors.white,
                          iconColor: Colors.black,
                          containerPadding: 0,
                          label: '',
                          onPressed: () {
                            Get.back();
                          },
                        ),

                        Text(
                          'iPad2Air | 32.6GB | 74%',
                          style: textTheme.labelMedium!.copyWith(fontSize: 25),
                        ),

                        Text(
                          'saadbooth@gmail.com',
                          style: textTheme.labelMedium!.copyWith(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('SELECT EXPERIENCE', style: textTheme.displayLarge),

                      Text(
                        'Tap an experience to let users choose',
                        style: textTheme.labelMedium!.copyWith(
                          letterSpacing: 3,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      Gap(35),
                      SizedBox(
                        width: Get.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 15,
                          children: [
                            CustomIconButton1(
                              icon: AppAssets.selfie,
                              iconSize: 70,
                              label: 'Photo Selfie',
                              onPressed: () {},
                            ),
                            CustomIconButton1(
                              icon: AppAssets.boomerang,
                              iconSize: 70,
                              label: 'Boomerang',
                              onPressed: () {},
                            ),
                            CustomIconButton1(
                              icon: AppAssets.gif,
                              iconSize: 70,
                              label: 'GIF',
                              onPressed: () {},
                            ),
                            CustomIconButton1(
                              icon: AppAssets.shoutout,
                              iconSize: 70,
                              label: 'Shoutout',
                              onPressed: () {},
                            ),
                            CustomIconButton1(
                              icon: AppAssets.slowmo,
                              iconSize: 70,
                              label: 'Slowmo',
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      Gap(180),
                      SizedBox(
                        width: Get.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomUtilityButton(
                              text: 'Refresh',
                              color: const Color(0xFF00B09B),
                              onPressed: () {
                                Get.toNamed(Routes.WELCOME1);
                              },
                            ),
                            CustomUtilityButton(
                              text: 'Test Bandwidth',
                              color: const Color(0xFFE50914),
                              onPressed: () {
                                Get.toNamed(Routes.WELCOME1);
                              },
                            ),
                            CustomUtilityButton(
                              text: 'Pending Uploads',
                              color: const Color(0xFFFFC107),
                              onPressed: () {
                                Get.toNamed(Routes.WELCOME1);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Gap(40),
                      Text(
                        'SCAN FOR DASHBOARD',
                        style: textTheme.headlineMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      Image.asset(AppAssets.qr, height: 180),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 */
