import 'package:bazar/app/routes/app_routes.dart';
import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/features/dashboard/presentation/pages/DashboardScreen.dart';
import 'package:flutter/material.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:  GestureDetector(
          onTap: () {
            AppRoutes.pushAndRemoveUntil(context, const Dashboardscreen());
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
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text('📍 Shops near you ',
                                  style: AppTextStyle.landingTexts,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text('📝 Leave your reviews ',
                                  style: AppTextStyle.landingTexts,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text('🔎 Search for the perfect shop to buy anything ',
                                  style: AppTextStyle.landingTexts,
                                  ),
                                ),
                               
                              ],
                              )
                          
                          ),
                        ),
                        SizedBox(height: 10),
                        Image.asset('assets/images/image2.png',
                        height: 150,
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