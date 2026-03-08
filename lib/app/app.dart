import 'package:bazar/features/splash/presentation/pages/SplashScreen.dart';
import 'package:bazar/app/theme/theme_mode_view_model.dart';
import 'package:bazar/app/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeViewModelProvider);

    return MaterialApp(
      theme: getApplicationTheme(),
      darkTheme: getApplicationDarkTheme(),
      themeMode: themeMode,
      home: const Splashscreen(),
    );
  }
}
