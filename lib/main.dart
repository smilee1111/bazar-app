import 'package:bazar/app/app.dart';
import 'package:bazar/core/services/hive/hive_service.dart';
import 'package:bazar/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

   // initialize Hive or other services if needed
  await HiveService().init();

  // Initialize SharedPreferences : because this is async operation
  // but riverpod providers are sync so we need to initialize it here
  final sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.clear();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const App(),
    ),
  );
}
