import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  static void showError(String title, {TextButton? mainButton}) {
    Get.snackbar(
      '',
      '',
      padding: const EdgeInsets.only(top: 10, bottom: 4, left: 10, right: 10),
      // margin: const EdgeInsets.all(0),
      duration: const Duration(seconds: 5),
      borderRadius: 14,
      backgroundColor: Color(0xffdedfdf),
      messageText: SizedBox(),
      mainButton: mainButton,
      titleText: Row(
        spacing: 4,
        children: [
          SvgPicture.asset('assets/icons/iconamoon_attention-circle-fill-red.svg', height: 24, width: 24),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF333333), fontSize: 18, fontWeight: FontWeight.w700),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  static void showInfo(String title) {
    Get.snackbar(
      '',
      '',
      padding: const EdgeInsets.only(top: 10, bottom: 4, left: 10, right: 10),
      // margin: const EdgeInsets.all(0),
      duration: const Duration(seconds: 5),
      borderRadius: 14,
      backgroundColor: Color(0xffdedfdf),
      messageText: SizedBox(),
      titleText: Row(
        spacing: 4,
        children: [
          SvgPicture.asset('assets/icons/iconamoon_attention-circle-fill.svg', height: 24, width: 24),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF333333), fontSize: 18, fontWeight: FontWeight.w700),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  static void showSuccess(String title) {
    Get.snackbar(
      '',
      '',
      padding: const EdgeInsets.only(top: 10, bottom: 4, left: 10, right: 10),
      // margin: const EdgeInsets.all(0),
      duration: const Duration(seconds: 5),
      borderRadius: 14,
      backgroundColor: Color(0xffdedfdf),
      messageText: SizedBox(),
      titleText: Row(
        spacing: 4,
        children: [
          SvgPicture.asset('assets/icons/iconamoon_attention-circle-fill-green.svg', height: 24, width: 24),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF333333), fontSize: 18, fontWeight: FontWeight.w700),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
