import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
  );

  return _buildTheme(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
  );
}

ThemeData getApplicationDarkTheme() {
  const darkSurface = Color(0xFF221B16);
  const darkBackground = Color(0xFF171310);
  const onDarkSurface = Color(0xFFF3E9DC);

  final colorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.lightBrown,
    onPrimary: Color(0xFF2E1F12),
    secondary: AppColors.iconAccent,
    onSecondary: Color(0xFF2E1F12),
    error: Color(0xFFE58F86),
    onError: Color(0xFF2B1210),
    surface: darkSurface,
    onSurface: onDarkSurface,
  );

  return _buildTheme(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: darkBackground,
  );
}

ThemeData _buildTheme({
  required ColorScheme colorScheme,
  required Color scaffoldBackgroundColor,
}) {
  final isDark = colorScheme.brightness == Brightness.dark;
  final borderColor = isDark ? const Color(0xFF3B322C) : AppColors.border;
  final surfaceStrong = isDark
      ? const Color(0xFF2A221C)
      : AppColors.surfaceStrong;
  final iconOnSurface = isDark ? AppColors.lightBrown : AppColors.primary;
  final bottomBarColor = isDark ? const Color(0xFF211912) : AppColors.darkBrown;
  final inactiveBottomLabelColor = isDark
      ? const Color(0xFFEAD7C2).withValues(alpha: 0.72)
      : AppColors.cream.withValues(alpha: 0.86);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'Poppins',
    primaryColor: colorScheme.primary,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    splashColor: colorScheme.primary.withValues(alpha: 0.08),
    highlightColor: colorScheme.primary.withValues(alpha: 0.03),
    hoverColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: iconOnSurface, size: 22),
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: AppTextStyle.buttonText.copyWith(fontSize: 16),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.65)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyle.inputBox.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.secondary,
        textStyle: AppTextStyle.minimalTexts.copyWith(
          fontSize: 13,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w500,
          color: colorScheme.secondary,
        ),
      ),
    ),

    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontFamily: 'Poppins',
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(fontFamily: 'Poppins', color: colorScheme.onSurface),
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        color: colorScheme.onSurface.withValues(alpha: 0.75),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: bottomBarColor,
      selectedItemColor: colorScheme.secondary,
      unselectedItemColor: inactiveBottomLabelColor,
      selectedIconTheme: const IconThemeData(size: 24),
      unselectedIconTheme: const IconThemeData(size: 22),
      type: BottomNavigationBarType.fixed,
      elevation: 2,
      selectedLabelStyle: AppTextStyle.bottomnav.copyWith(fontSize: 11),
      unselectedLabelStyle: AppTextStyle.bottomnav.copyWith(fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceStrong,
      selectedColor: colorScheme.secondary.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: borderColor),
      labelStyle: AppTextStyle.inputBox.copyWith(fontSize: 12),
      secondaryLabelStyle: AppTextStyle.inputBox.copyWith(fontSize: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      labelStyle: AppTextStyle.minimalTexts.copyWith(
        color: colorScheme.onSurface,
        fontSize: 13,
      ),
      hintStyle: AppTextStyle.minimalTexts.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.62),
        fontSize: 12,
      ),
      prefixIconColor: colorScheme.secondary,
      suffixIconColor: colorScheme.secondary,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.error, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.error, width: 1.4),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
