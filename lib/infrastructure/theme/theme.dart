import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

final ThemeData appTheme = ThemeData(
  textTheme: TextTheme(
    // Big / Display text
    displayLarge: TextStyle(
      fontFamily: 'Bebas',
      fontSize: 32.sp, // ≈ 70px on large screens
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),

    headlineMedium: TextStyle(
      fontFamily: 'Bebas',
      fontSize: 12.sp, // ≈ 28px
      fontWeight: FontWeight.w600,
      color: Colors.blueGrey,
    ),

    // Body text
    bodyLarge: TextStyle(
      fontFamily: 'th',
      fontSize: 10.sp, // ≈ 16px
      fontWeight: FontWeight.w400,
      color: const Color(0xFF333333),
    ),

    bodyMedium: TextStyle(
      fontSize: 9.sp, // ≈ 14px
      fontWeight: FontWeight.w400,
      color: const Color(0xFF666666),
    ),

    // Buttons / Labels
    labelLarge: TextStyle(
      fontFamily: 'Akshar',
      fontSize: 22.sp, // ≈ 40px
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),

    labelMedium: TextStyle(
      fontFamily: 'Akshar',
      fontSize: 16.sp, // ≈ 22px
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
  ),
);

/* final ThemeData appTheme = ThemeData(
  textTheme: const TextTheme(
    // Headline styles (Aam tor par bade aur numayaan text ke liye)
    displayLarge: TextStyle(
      fontFamily: 'Bebas',
      fontSize: 70,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Bebas',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: Colors.blueGrey,
    ),

    // Body styles (Aam text, paragraph ke liye)
    bodyLarge: TextStyle(
      fontFamily: 'th',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color(0xFF333333),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFF666666),
    ),

    // Label/Button styles (Chhote aur functional text ke liye)
    labelLarge: TextStyle(
      fontFamily: 'Akshar',
      fontSize: 40,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Akshar',
      fontSize: 22,
      color: Colors.white,
    ),
  ),
);
 */
