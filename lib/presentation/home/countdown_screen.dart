import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:sizer/sizer.dart';
import '../../infrastructure/constants/app_assets.dart';
import '../../infrastructure/navigation/routes.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  final camController = Get.put(CameraControllerX());
 

  final Map<int, String> _countdownText = {3: "STRIKE A POSE!", 2: "STRIKE A POSE!", 1: "STRIKE A POSE!"};

  @override
  void initState() {
    super.initState();

    camController.startCountdown();
  }

 

  @override
  void dispose() {
    camController.timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Obx(() {
              if (!camController.isReady.value) {
                return const Center(child: CircularProgressIndicator());
              }
      
              return
              // cameraWidget(context);
              CameraPreview(camController.cameraController);
            }),
            Positioned.fill(child: Image.asset(AppAssets.demoFilter, )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (camController.isCounting.value) ...[
                  Text(
                    _countdownText[camController.counter.value] ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Bebas',
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: const [Shadow(blurRadius: 5, color: Colors.black, offset: Offset(2, 2))],
                    ),
                  ),
                  Gap(6.h),
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '${camController.counter.value}',
                        style: TextStyle(fontFamily: 'Akshar', fontSize: 25.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ]
                // else[

                // ]
                // else ...[
                //   Text(
                //     "GET READY FOR\n4 QUICK SHOTS!",
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //       fontFamily: 'Bebas',
                //       fontSize: 30.sp,
                //       fontWeight: FontWeight.w700,
                //       color: Colors.white,
                //       shadows: const [Shadow(blurRadius: 5, color: Colors.black, offset: Offset(2, 2))],
                //     ),
                //   ),
                //   Gap(10.h),
                //   Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: List.generate(
                //       4,
                //       (index) => Padding(
                //         padding: EdgeInsets.symmetric(horizontal: 1.w),
                //         child: InkWell(
                //           onTap: () {
                //             Get.toNamed(Routes.PREVIEW);
                //           },
                //           child: Container(
                //             width: 16.w,
                //             height: 22.w,
                //             decoration: BoxDecoration(
                //               color: Colors.white.withOpacity(0.1),
                //               border: Border.all(color: Colors.white, width: 2),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
