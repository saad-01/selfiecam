import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import '../../infrastructure/constants/app_assets.dart';

class SenItToMeScreen extends StatefulWidget {
  const SenItToMeScreen({super.key});

  @override
  State<SenItToMeScreen> createState() => _SenItToMeScreenState();
}

class _SenItToMeScreenState extends State<SenItToMeScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.background4, fit: BoxFit.fill),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'SEND IT TO YOURSELF',
                style: textTheme.displayLarge!.copyWith(fontSize: 28.sp),
              ),
              Gap(2.h),
              SizedBox(
                width: 90.w,
                child: Row(
                  children: [
                    Expanded(
                      child: ApprovalButton(
                        text: 'RETAKE',
                        color: const Color(0xffFFAA00),
                        iconAssetPath: AppAssets.retake,
                        onPressed: () {},
                      ),
                    ),
                    Gap(2.w),
                    Expanded(
                      child: ApprovalButton(
                        text: 'SEND ME',
                        color: const Color(0xff00C846),
                        iconAssetPath: AppAssets.sendme,
                        onPressed: () {
                          Get.toNamed(Routes.SENDITTOME2);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ],
      ),
    );
  }
}
