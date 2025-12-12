import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import '../../infrastructure/constants/app_assets.dart';

class SenItToMeScreen2 extends StatefulWidget {
  const SenItToMeScreen2({super.key});

  @override
  State<SenItToMeScreen2> createState() => _SenItToMeScreen2State();
}

class _SenItToMeScreen2State extends State<SenItToMeScreen2> {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('IT’S ON ITS WAY TO YOU!', style: textTheme.displayLarge),
              SizedBox(height: Get.height * 0.05),
              Text(
                'SCAN TO VIEW GALLERY',
                style: textTheme.displayLarge!.copyWith(fontSize: 50),
              ),
              Image.asset(AppAssets.qr2, height: 400),
              SizedBox(height: Get.height * 0.06),
              SizedBox(
                width: Get.width * 0.9,
                child: ApprovalButton(
                  text: 'TAKE ANOTHER',
                  color: Color(0xff00C846),
                  iconAssetPath: AppAssets.takePhoto,
                  onPressed: () {
                    Get.toNamed(Routes.EMAIL);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
