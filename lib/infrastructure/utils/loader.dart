import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoaderService extends GetxService {
  bool _isShowing = false;

  void show() {
    if (_isShowing) return;
    _isShowing = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black38,
            ),
            child: const Center(
              child: CupertinoActivityIndicator(
                radius: 60,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hide() {
    if (_isShowing) {
      _isShowing = false;
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }
}
