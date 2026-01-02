import 'package:bazar/app/app.dart';
import 'package:bazar/core/services/hive/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

    // initialize Hive or other services if needed
  await HiveService().init();
  runApp(
    ProviderScope(
      child: App(),
    ),
  );
}
