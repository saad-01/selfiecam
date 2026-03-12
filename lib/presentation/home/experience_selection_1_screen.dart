import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/controller/settings_controller.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:selfiecam1/presentation/component/back_button.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import '../../infrastructure/constants/app_assets.dart';
import 'package:sizer/sizer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final controller = Get.put(SettingsController());
  final deviceController = DeviceController.to;
  // bool _isImagePrecached = false;
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   if (!_isImagePrecached) {
  //     precacheImage(AssetImage(AppAssets.background1), context);
  //     precacheImage(AssetImage(AppAssets.logo2), context);
  //     precacheImage(AssetImage(AppAssets.logo1), context);
  //     _isImagePrecached = true;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
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
          Positioned(
            bottom: 10,
            right: 10,
            child: InkWell(
              child: Icon(Icons.logout, color: Colors.white, size: 4.h),
              onTap: () async {
                await PrefUtils().clearPreferencesData();
                Get.offAllNamed(Routes.SIGNIN);
              },
            ),
          ),
          SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 100.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 8.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomBackButton(),
                          Text(
                            '${deviceController.deviceInformation?.deviceName} | ${(deviceController.deviceInformation!.memoryInfo.availableStorageSpace / 1024 / 1024 / 1024).toStringAsFixed(2)} GB | ${deviceController.batteryInfo!.batteryLevel}%',
                            style: textTheme.labelMedium!.copyWith(fontSize: 16.sp),
                          ),
                          Text(PrefUtils().getString("email") ?? '', style: textTheme.labelMedium!.copyWith(fontSize: 16.sp)),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('SELECT EXPERIENCE', style: textTheme.displayLarge),
                        Text(
                          'Tap an experience to let users choose',
                          style: textTheme.labelMedium!.copyWith(letterSpacing: 0.3.w, fontWeight: FontWeight.w100),
                        ),
                        SizedBox(height: 3.h),

                        // SizedBox(
                        //   width: 90.w,
                        //   height: 20.h,
                        //   child: SingleChildScrollView(
                        //     scrollDirection: Axis.horizontal,
                        //     child: Row(
                        //       children: [
                        //         SizedBox(width: 2.w),
                        //         CustomIconButton1(
                        //           icon: AppAssets.selfie,
                        //           label: 'Photo Selfie',
                        //           borderRadius: 0.0,
                        //           onPressed: () {},
                        //         ),
                        //         SizedBox(width: 3.w),
                        //         CustomIconButton1(
                        //           icon: AppAssets.boomerang,
                        //           label: 'Boomerang',
                        //           borderRadius: 0.0,
                        //           onPressed: () {},
                        //         ),
                        //         SizedBox(width: 3.w),
                        //         CustomIconButton1(icon: AppAssets.gif, label: 'GIF', borderRadius: 0.0, onPressed: () {}),
                        //         SizedBox(width: 3.w),
                        //         CustomIconButton1(
                        //           icon: AppAssets.shoutout,
                        //           label: 'Shoutout',
                        //           borderRadius: 0.0,
                        //           onPressed: () {},
                        //         ),
                        //         SizedBox(width: 3.w),
                        //         CustomIconButton1(
                        //           icon: AppAssets.slowmo,
                        //           label: 'Slowmo',
                        //           borderRadius: 0.0,
                        //           onPressed: () {},
                        //         ),
                        //         SizedBox(width: 2.w),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            children: [
                              Row(
                                spacing: 1.w,
                                children: [
                                  CustomIconButton1(
                                    containerHeight: 18.h,
                                    containerWidth: 18.w,
                                    borderRadius: 0.0,
                                    // color: const Color(0xff500F86),
                                    icon: AppAssets.selfie,
                                    iconSize: 6.h,
                                    label: 'Photo',
                                    onPressed: () {
                                      Get.toNamed(Routes.COUNTDOWN);
                                    },
                                  ),

                                  CustomIconButton1(
                                    containerHeight: 18.h,
                                    containerWidth: 18.w,
                                    borderRadius: 0.0,
                                    // color: const Color(0xff500F86),
                                    icon: AppAssets.boomerang,
                                    iconSize: 6.h,
                                    label: 'Boomerang',
                                    onPressed: () {
                                      // Get.toNamed(Routes.WELCOME2);
                                    },
                                  ),

                                  CustomIconButton1(
                                    containerHeight: 18.h,
                                    containerWidth: 18.w,
                                    borderRadius: 0.0,
                                    // color: const Color(0xff500F86),
                                    icon: AppAssets.gif,
                                    iconSize: 6.h,
                                    label: 'GIF',
                                    onPressed: () {
                                      // Get.toNamed(Routes.WELCOME2);
                                    },
                                  ),
                                ],
                              ),
                              Gap(1.h),
                              Row(
                                spacing: 1.w,
                                children: [
                                  CustomIconButton1(
                                    containerHeight: 18.h,
                                    containerWidth: 18.w,
                                    borderRadius: 0.0,
                                    // color: const Color(0xff500F86),
                                    icon: AppAssets.shoutout,
                                    iconSize: 6.h,
                                    label: 'Shoutout',
                                    onPressed: () {
                                      // Get.toNamed(Routes.WELCOME2);
                                    },
                                  ),
                                  CustomIconButton1(
                                    containerHeight: 18.h,
                                    containerWidth: 18.w,
                                    borderRadius: 0.0,
                                    // color: const Color(0xff500F86),
                                    icon: AppAssets.slowmo,
                                    iconSize: 6.h,
                                    label: 'Slowmo',
                                    onPressed: () {
                                      // Get.toNamed(Routes.WELCOME2);
                                    },
                                  ),
                                  CustomIconButton1(
                                    containerHeight: 18.h,
                                    containerWidth: 18.w,
                                    borderRadius: 0.0,
                                    // color: const Color(0xff500F86),
                                    icon: AppAssets.slowmo,
                                    iconSize: 6.h,
                                    label: 'AI Photo',
                                    onPressed: () {
                                      // Get.toNamed(Routes.WELCOME2);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // // Padding(
                        //   padding: EdgeInsets.symmetric(horizontal: 14.0.w),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     // spacing: 1.w,
                        //     children: [

                        //     ],
                        //   ),
                        // ),
                        SizedBox(height: 5.h),
                        SizedBox(
                          width: 90.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Column(
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
                        Image.asset(AppAssets.qr, height: 12.h),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ],
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
