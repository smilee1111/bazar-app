import 'package:bazar/core/services/storage/theme_preference_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeViewModelProvider =
    NotifierProvider<ThemeModeViewModel, ThemeMode>(ThemeModeViewModel.new);

class ThemeModeViewModel extends Notifier<ThemeMode> {
  late final ThemePreferenceService _themePreferenceService;

  @override
  ThemeMode build() {
    _themePreferenceService = ref.read(themePreferenceServiceProvider);
    return _themePreferenceService.getThemeMode();
  }

  Future<void> setDarkMode(bool enabled) async {
    final nextMode = enabled ? ThemeMode.dark : ThemeMode.light;
    if (state == nextMode) return;

    state = nextMode;
    await _themePreferenceService.saveThemeMode(nextMode);
  }
}
