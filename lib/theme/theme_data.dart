import 'package:bazar/theme/colors.dart';
import 'package:bazar/theme/textstyle.dart';
import 'package:flutter/material.dart';

ThemeData getApplicationTheme(){
  return ThemeData(
    primarySwatch: Colors.orange,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    fontFamily: 'Poppins Regular',
    scaffoldBackgroundColor: AppColors.background,
    splashColor: Colors.white.withOpacity(0.08),
    highlightColor: Colors.white.withOpacity(0.03),
    hoverColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins SemiBold',
        fontSize: 20,
        color: Colors.black
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        ),
        textStyle: AppTextStyle.buttonText,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    ),

    textTheme: TextTheme(
      titleLarge:  TextStyle(
        fontFamily: 'Poppins Bold'
      ),
    ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF524632),
      unselectedIconTheme: IconThemeData(color: Colors.white),
      selectedItemColor: Color(0xFFA48256),
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppTextStyle.bottomnav,
      unselectedLabelStyle: AppTextStyle.bottomnav,
    ),
    inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
    labelStyle: AppTextStyle.minimalTexts.copyWith(color: AppColors.textPrimary),
    hintStyle: AppTextStyle.minimalTexts.copyWith(color: Colors.grey),

    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.accent2, width: 1.3),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red, width: 1.3),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red, width: 1.6),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
      );
    
}