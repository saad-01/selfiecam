import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
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
              Text('SELECT YOUR EXPERIENCE', style: textTheme.displayLarge),
              Gap(35),
              SizedBox(
                width: Get.width * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 15,
                  children: [
                    CustomIconButton1(
                      containerWidth: 110,
                      color: Color(0xff500F86),
                      icon: AppAssets.selfie,
                      iconSize: 70,
                      label: 'Photo Selfie',
                      onPressed: () {
                        Get.toNamed(Routes.WELCOME2);
                      },
                    ),
                    CustomIconButton1(
                      containerWidth: 110,
                      color: Color(0xff500F86),
                      icon: AppAssets.boomerang,
                      iconSize: 70,
                      label: 'Boomerang',
                      onPressed: () {
                        Get.toNamed(Routes.WELCOME2);
                      },
                    ),
                    CustomIconButton1(
                      containerWidth: 110,
                      color: Color(0xff500F86),
                      icon: AppAssets.gif,
                      iconSize: 70,
                      label: 'GIF',
                      onPressed: () {
                        Get.toNamed(Routes.WELCOME2);
                      },
                    ),
                    CustomIconButton1(
                      containerWidth: 110,
                      color: Color(0xff500F86),
                      icon: AppAssets.shoutout,
                      iconSize: 70,
                      label: 'Shoutout',
                      onPressed: () {
                        Get.toNamed(Routes.WELCOME2);
                      },
                    ),
                    CustomIconButton1(
                      containerWidth: 110,
                      color: Color(0xff500F86),
                      icon: AppAssets.slowmo,
                      iconSize: 70,
                      label: 'Slowmo',
                      onPressed: () {
                        Get.toNamed(Routes.WELCOME2);
                      },
                    ),
                  ],
                ),
              ),
              Gap(150),
            ],
          ),
        ],
      ),
    );
  }
}
