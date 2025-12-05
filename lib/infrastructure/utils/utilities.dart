import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:get/get.dart';

import '../constants/app_colors.dart';
import 'logger_util.dart';


class Utilities {
  static Future<bool> isInternetAvailable({bool showToast = true}) async {
    try {
      // Check connectivity first
      final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        if (showToast) {
          Utilities.showToast(
            toastMsg: 'No internet connection. Please check your WiFi or mobile data.',
            isSuccess: false,
          );
        }
        return false;
      }

      // Perform a lightweight DNS lookup instead of full HTTP request
      final List<InternetAddress> result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw TimeoutException('Connection timed out'),
      );

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        LogUtil.logTrace('DNS lookup successful for google.com');
        return true;
      }

      return false;
    } catch (e) {
      if (showToast) {
        Utilities.showToast(
          toastMsg: 'Internet connection is not working. Please try again later.',
          isSuccess: false,
        );
      }
      LogUtil.logError('isInternetAvailable: $e');
      return false;
    }
  }

  static void showToast({
    required String toastMsg,
    Toast toastLength = Toast.LENGTH_SHORT,
    required bool isSuccess,
  }) {
    Fluttertoast.showToast(
      msg: toastMsg,
      toastLength: toastLength,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      textColor: AppColors.colorFFFFFF,
      // fontSize: 14.sp,
    );
  }

  static void showSnackBar({
    required String message,
    String? title,
    Color? textColor,
    double? borderRadius,
    bool isSuccess = true,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    Get.snackbar(
      title ?? '',
      message,
      backgroundColor: isSuccess ? AppColors.color2F9397 : Colors.red,
      colorText: textColor ?? AppColors.colorFFFFFF,
      duration: duration,
      // borderRadius: borderRadius ?? 12.r,
      borderRadius: borderRadius ?? 12,
      dismissDirection: DismissDirection.startToEnd,
    );

  }

  static bool isTablet(BuildContext context) {
    final double shortestSide = MediaQuery.of(context).size.shortestSide;

    // Determine if we should use mobile layout or not, 600 here is
    // a common breakpoint for a typical 7-inch tablet.
    return shortestSide > 600;
  }

  static String formatDateToDDMM(String dateStr) {
    try {
      // Parse the input date string
      final DateTime date = DateTime.parse(dateStr);

      // Format the date into dd/MM
      final String formattedDate =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
      return formattedDate;
    } catch (e) {
      // Handle errors (invalid format, etc.)
      LogUtil.logError('Error parsing date: $e');
      return '';
    }
  }

  // static String formatDate(String dateString) {
  //   final DateTime dateTime = DateTime.parse(dateString);
  //   return DateFormat('d/M/y').format(dateTime);
  // }

  //usable
  // static Future<void> openUrl(
  //     String url, {
  //       LaunchMode launchMode = LaunchMode.externalApplication,
  //     }) async {
  //   final Uri uri = Uri.parse(url);
  //
  //   if (url.startsWith('tel:')) {
  //     // Handle telephone numbers
  //     if (!await launchUrl(uri)) {
  //       throw Exception('Could not launch $url');
  //     }
  //   } else {
  //     // Handle URLs
  //     if (!await launchUrl(uri, mode: launchMode)) {
  //       throw Exception('Could not launch $url');
  //     }
  //   }
  // }

  // Future<void> openMap(double lat, double lng) async {
  //   final Uri googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
  //
  //   if (await canLaunchUrl(googleUrl)) {
  //     await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw 'Could not open the map.';
  //   }
  // }

///INPUT VALIDATORS

// String? nameValidator(String? value) {
//   if (value == null || value.isEmpty) {
//     return "Name can't be empty";
//   }
//   if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
//     return 'Please enter a valid name';
//   }
//   return null;
// }
//
// String? emailValidator(String? value) {
//   if (value == null || value.isEmpty) {
//     return "Email can't be empty";
//   }
//   // Add a simple email regex for validation
//   final RegExp regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//   if (!regex.hasMatch(value)) {
//     return 'Enter a valid email address';
//   }
//   return null;
// }
//
// String? passwordValidator(String? value) {
//   if (value == null || value.isEmpty) {
//     return "Password can't be empty";
//   }
//   if (value.length < 8) {
//     return 'Password must be at least 8 characters long';
//   }
//   return null;
// }
//
// String? confirmPasswordValidator(String? password, String? confirmPassword) {
//   if (confirmPassword == null || confirmPassword.isEmpty) {
//     return "Confirm password can't be empty";
//   }
//   if (password != confirmPassword) {
//     return 'Passwords do not match';
//   }
//   return null;
// }
//
// String? valueNotSelectedValidator(String? value) {
//   if (value == null || value.isEmpty) {
//     return "Value can't be empty";
//   }
//   return null;
// }
}
