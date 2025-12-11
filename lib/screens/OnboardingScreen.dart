import 'package:bazar/theme/colors.dart';
import 'package:bazar/theme/textstyle.dart';
import 'package:flutter/material.dart';

class Onboardingscreen extends StatelessWidget {
  const Onboardingscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:  GestureDetector(
           onTap: () {
            Navigator.pushNamed(context, '/onboarding2');  
          },
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Container(
                    alignment: Alignment.topLeft,
                  child: Image.asset('assets/images/bazarlogo.png',
                  width: 90,
                  height: 90,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/image.png')
                      )
                    ),
                    width: 500,
                    child: 
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text('Welcome , User!',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.h1),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Container(
                            height: 250,
                            width: 400,
                            decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)
                            ),
                            child: 
                            Padding(padding: EdgeInsets.all(15.0 ),
                            child: Text('📍 Shops near you ',
                            style: AppTextStyle.landingTexts,
                            ),
                          ),
                          ),
                        ),
                      ],
                    )
                    
                  ),
                ),
          
              ],
            ),
          ),
        ),
    );
  }
}