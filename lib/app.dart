import 'package:bazar/screens/LandingPageScreen.dart';
import 'package:bazar/screens/LoginPageScreen.dart';
import 'package:bazar/screens/SignupPageScreen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Loginpagescreen(),
    );
  }
}