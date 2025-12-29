import 'package:bazar/theme/textstyle.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/bazarlogo.png', height: 50, width: 50,),
                    const SizedBox(width: 10,),
                    Icon(Icons.notifications, size: 30, color: Colors.grey[700],),
                    
                  ],
                ),
                const SizedBox(height: 20,),
                  Container(
                  alignment: Alignment.center,
                  height: 50,
                  width: double.infinity,
                  color: Colors.brown,
                  child: Text('Search Bar',
                  style: AppTextStyle.buttonText),
                ),
                const SizedBox(height: 20,),
                Container(
                  alignment: Alignment.center,
                  height: 600,
                  width: double.infinity,
                  color: Colors.brown,
                  child: Text('Home Screen',
                  style: AppTextStyle.buttonText),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}