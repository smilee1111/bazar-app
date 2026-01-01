import 'package:bazar/app/app.dart';
import 'package:bazar/features/dashboard/presentation/pages/DashboardScreen.dart';
import 'package:bazar/features/splash/presentation/pages/LandingPageScreen.dart';
import 'package:bazar/features/auth/presentation/pages/LoginPageScreen.dart';
import 'package:bazar/features/onboarding/presentation/pages/Onboarding2.dart';
import 'package:bazar/features/onboarding/presentation/pages/Onboarding3.dart';
import 'package:bazar/features/onboarding/presentation/pages/OnboardingScreen.dart';
import 'package:bazar/features/auth/presentation/pages/SignupPageScreen.dart';
import 'package:bazar/features/splash/presentation/pages/SplashScreen.dart';
import 'package:bazar/app/theme/theme_data.dart';
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