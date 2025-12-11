import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import '../../infrastructure/constants/app_assets.dart';

class ExperienceSelectionScreen1 extends StatelessWidget {
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
