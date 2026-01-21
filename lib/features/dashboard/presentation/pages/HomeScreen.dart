import 'package:bazar/app/theme/textstyle.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.center,
                height: 50,
                width: double.infinity,
                color: Colors.brown,
                child: Text('Search Bar', style: AppTextStyle.buttonText),
              ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.center,
                height: 600,
                width: double.infinity,
                color: Colors.brown,
                child: Text('Home Screen', style: AppTextStyle.buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
