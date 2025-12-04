import 'package:flutter/material.dart';

class AppTextStyle {
  // ---------- Colors ----------
  static const Color lightTextColor = Colors.white;
  static const Color darkTextColor = Colors.black87;
  static const Color greyTextColor = Colors.grey;

  // ---------- Font Family ----------
  static const String fontFamily = "Poppins";

  // ---------- Headings ----------
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 23,
    fontWeight: FontWeight.normal,
    color: darkTextColor,
  );

 static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 23,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static const TextStyle inputBox = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: darkTextColor,
  );

  static const TextStyle minimalTexts = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: darkTextColor,
  );

  // ---------- Custom Color Override ----------
  static TextStyle color(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}
