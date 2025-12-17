import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import '../../infrastructure/constants/app_assets.dart';

class Welcome1Screen extends StatelessWidget {
  const Welcome1Screen({super.key});

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
              CustomIconButton(
                containerHeight: 14.h,
                containerWidth: 14.h,
                color: Colors.white,
                borderRadius: 10.h,
                icon: Icons.arrow_forward_rounded,
                iconColor: Colors.black,
                iconSize: 6.h,
                onPressed: () {
                  Get.toNamed(Routes.EXPERIENCESELECTION2);
                },
              ),
              Gap(5.h),
              Text(
                'TAP ANYWHERE TO START',
                style: textTheme.labelLarge!.copyWith(
                  color: Colors.white,
                  fontSize: 20.sp,
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
