import 'package:bazar/app.dart';
import 'package:bazar/screens/DashboardScreen.dart';
import 'package:bazar/screens/LandingPageScreen.dart';
import 'package:bazar/screens/LoginPageScreen.dart';
import 'package:bazar/screens/Onboarding2.dart';
import 'package:bazar/screens/Onboarding3.dart';
import 'package:bazar/screens/OnboardingScreen.dart';
import 'package:bazar/screens/SignupPageScreen.dart';
import 'package:bazar/screens/SplashScreen.dart';
import 'package:bazar/theme/theme_data.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: getApplicationTheme(),
      initialRoute: '/SplashScreen',
      routes:{
        '/SplashScreen': (context) => const Splashscreen(),
        '/LandingScreen':(context)=> const LandingPageScreen(),
        '/LoginScreen':(context)=>const Loginpagescreen(),
        '/RegisterScreen':(context)=>const Signuppagescreen(),
        '/DashboardScreen':(context)=>const Dashboardscreen(),
        '/OnboardingScreen':(context)=>const Onboardingscreen(),
        '/onboarding2':(context)=>const Onboarding2(),
        '/onboarding3':(context)=>const Onboarding3(),

      }
    );
  }
}