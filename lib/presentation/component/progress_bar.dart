import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/cam_controller.dart';

class RecordingProgressBar extends StatelessWidget {
  final double height;
  final Color backgroundColor;
  final Color progressColor;

  const RecordingProgressBar({
    super.key,
    this.height = 6,
    this.backgroundColor = Colors.white24,
    this.progressColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CameraControllerX>();

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(50)),
      child: AnimatedBuilder(
        animation: controller.animationController,
        builder: (_, __) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: controller.animationController.value,
            child: Container(
              decoration: BoxDecoration(color: progressColor, borderRadius: BorderRadius.circular(50)),
            ),
          );
        },
      ),
    );
  }
}
