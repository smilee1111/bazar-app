import 'package:bazar/theme/colors.dart';
import 'package:bazar/theme/textstyle.dart';
import 'package:flutter/material.dart';

class Dashboardscreen extends StatelessWidget {
  const Dashboardscreen({super.key});

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
              fit: BoxFit.fitHeight,
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
                    
                    child: Text("I am Home Screen",
                    style: AppTextStyle.landingTexts,),
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