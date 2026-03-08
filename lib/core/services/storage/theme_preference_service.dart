import 'package:bazar/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themePreferenceServiceProvider = Provider<ThemePreferenceService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return ThemePreferenceService(prefs: prefs);
});

class ThemePreferenceService {
  ThemePreferenceService({required SharedPreferences prefs}) : _prefs = prefs;

  static const String _keyIsDarkMode = 'theme_is_dark_mode';

  final SharedPreferences _prefs;

  ThemeMode getThemeMode() {
    final isDarkMode = _prefs.getBool(_keyIsDarkMode) ?? false;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setBool(_keyIsDarkMode, mode == ThemeMode.dark);
  }
}
