import 'package:bazar/app/routes/app_routes.dart';
import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/features/onboarding/presentation/pages/OnboardingScreen.dart';
import 'package:flutter/material.dart';

class LandingPageScreen extends StatelessWidget {
  const LandingPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
      ),
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
              fit: BoxFit.fill,
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
                  Text(
                    "Find your Shop.",
                    style: TextStyle(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: Colors.brown[500],
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                    onPressed: () {
                      AppRoutes.push(context, const Onboardingscreen());
                    },
                    style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 7,horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    backgroundColor: AppColors.accent),
                      child: const Text("BEGIN",
                      style: TextStyle(color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w300),
                      ),
                    ),
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
