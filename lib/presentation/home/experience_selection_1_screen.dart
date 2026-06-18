import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/controller/settings_controller.dart';
import 'package:selfiecam1/data/services/credentials.dart';
import 'package:selfiecam1/data/services/internet_service.dart';
import 'package:selfiecam1/data/services/internet_service_adapter.dart';
import 'package:selfiecam1/data/services/upload_queue_service.dart';
import 'package:selfiecam1/data/services/upload_repository.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/infrastructure/utils/pref_utils.dart';
import 'package:selfiecam1/presentation/auth/sign_in/event_join_screen.dart';
import 'package:selfiecam1/presentation/auth/sign_in/signup_webview.dart';
import 'package:selfiecam1/presentation/component/back_button.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import 'package:selfiecam1/presentation/home/pending_uploads.dart';
import 'package:selfiecam1/presentation/home/test_bandwidth.dart';
import '../../infrastructure/constants/app_assets.dart';
import 'package:sizer/sizer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final controller = Get.find<SettingsController>();
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
                DeviceController.to.clearSession();
                await PrefUtils().clearPreferencesData();

                /// 1️⃣ Clear Hive boxes
                if (Hive.isBoxOpen("brandingBox")) {
                  await Hive.box("brandingBox").clear();
                }

                if (Hive.isBoxOpen("experiencesBox")) {
                  await Hive.box("experiencesBox").clear();
                }
                SettingsController.to.resetAllSettings();

                /// 2️⃣ Delete downloaded media folder
                final dir = await getApplicationDocumentsDirectory();
                final mediaDir = Directory("${dir.path}/event_media");

                if (await mediaDir.exists()) {
                  await mediaDir.delete(recursive: true);
                }
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
                      height: 5.h,
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
                        Text(
                          'SELECT EXPERIENCE',
                          style: textTheme.displayLarge!.copyWith(fontSize: 25.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Tap an experience to let users choose',
                          style: textTheme.labelMedium!.copyWith(
                            letterSpacing: 0.3.w,
                            fontWeight: FontWeight.w100,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),

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

                        // // Padding(
                        //   padding: EdgeInsets.symmetric(horizontal: 14.0.w),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     // spacing: 1.w,
                        //     children: [

                        //     ],
                        //   ),
                        // ),
                        experiencesGrid(),
                        SizedBox(height: 3.h),
                        SizedBox(
                          width: 90.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomUtilityButton(
                                text: 'Change Event',
                                color: const Color(0xFF00B09B),
                                borderRadius: 0.0,
                                onPressed: () {
                                  Get.to(() => EventDropdownView());
                                },
                              ),
                              CustomUtilityButton(
                                text: 'Test Bandwidth',
                                color: const Color(0xFFE50914),
                                borderRadius: 0.0,
                                onPressed: () {
                                  Get.to(() => SpeedTest());
                                  // Get.toNamed(Routes.WELCOME1);
                                },
                              ),
                              CustomUtilityButton(
                                text: 'Pending Uploads',
                                color: const Color(0xFFFFC107),
                                borderRadius: 0.0,
                                onPressed: () async {
                                  // Get.toNamed(Routes.WELCOME1);
                                  if (Get.isRegistered<UploadQueueService>()) {
                                  } else {
                                    await Get.putAsync(() async {
                                      final service = UploadQueueService(
                                        repository: UploadRepository(),
                                        connectivity: InternetServiceAdapter(Get.find<InternetService>()),
                                        credentials: MyCredentialsProvider(),
                                      );
                                      await service.init();
                                      return service;
                                    }, permanent: true);
                                  }
                                  Get.to(() => PendingUploads());
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 1.h),
                        SizedBox(
                          width: 90.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 30.w),
                              CustomUtilityButton(
                                text: 'DASHBOARD',
                                color: const Color.fromARGB(255, 120, 0, 176),
                                borderRadius: 0.0,
                                onPressed: () {
                                  Get.to(() => SignupWebview(url: "https://hub.selfiecam.ai/auth/login"));
                                },
                              ),

                              SizedBox(width: 30.w),
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

  Widget experiencesGrid() {
    return Obx(() {
      final experiences = deviceController.experiences.value;
      final branding = deviceController.branding.value;

      if (experiences == null) return const SizedBox();

      final items = deviceController.getEnabledExperiencesForSettings(experiences);

      if (items.isEmpty) return const SizedBox();

      final int crossAxisCount = items.length > 5 ? 3 : items.length;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: items.length > 5 ? 18.w : 3.w),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 1.h,
            crossAxisSpacing: 1.w,
            mainAxisExtent: 14.h,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final isEnabled = controller
                .isEnabled(
                  item.key,
                  true, // helper below
                )
                .obs;
            return Obx(
              () => CustomIconButton1(
                containerHeight: 14.h,
                containerWidth: 14.w,
                borderRadius: branding?.buttonStyle == 'rounded' ? 10 : 0,
                color: isEnabled.value
                    ? (branding?.buttonColor != null
                          ? Color(int.parse('0xff${branding!.buttonColor.substring(1)}'))
                          : const Color(0xff500F86))
                    : Colors.grey.shade400, // 👈 DISABLED COLOR
                icon: item.icon,
                iconSize: 5.h,
                font: branding?.fontFamily,
                fontSizeAbsolute: 25,
                label: item.label,
                iconColor: branding?.buttonTextColor != null
                    ? Color(int.parse('0xff${branding!.buttonTextColor.substring(1)}'))
                    : Colors.white,
                onPressed: () {
                  controller.toggle(item.key, !isEnabled.value);
                  setState(() {});
                },
              ),
            );
          },
        ),
      );
    });
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
