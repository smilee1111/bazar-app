import 'package:bazar/app/routes/app_routes.dart';
import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/core/services/storage/user_session_service.dart';
import 'package:bazar/features/auth/presentation/pages/LoginPageScreen.dart';
import 'package:bazar/features/dashboard/presentation/pages/DashboardScreen.dart';
import 'package:bazar/features/splash/presentation/pages/LandingPageScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Splashscreen extends ConsumerStatefulWidget {
  const Splashscreen({super.key});

  @override
  ConsumerState<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends ConsumerState<Splashscreen> {
   @override
  void initState() {
    super.initState();

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      // Check if user is already logged in
      final userSessionService = ref.read(userSessionServiceProvider);
      final isLoggedIn = userSessionService.isLoggedIn();
      final isOnboardingCompleted = userSessionService.isOnboardingCompleted();

      if (isLoggedIn) {
        // Navigate to Dashboard if user is logged in
        AppRoutes.pushReplacement(context, const Dashboardscreen());
      } else if (isOnboardingCompleted) {
        // Navigate to Login if user has completed onboarding before (returning user)
        AppRoutes.pushReplacement(context, const Loginpagescreen());
      } else {
        // Navigate to Landing Page if user is completely new
        AppRoutes.pushReplacement(context, const LandingPageScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: Image.asset(
              'assets/images/bgimage.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fill
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Color(0xFFF5F0C5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/images/bazarlogo.png',),
                  Text(
                    "Find your Shop.",
                    style: AppTextStyle.landingTexts
                  ),
                  
                
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
