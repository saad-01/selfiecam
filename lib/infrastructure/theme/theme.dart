import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
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
