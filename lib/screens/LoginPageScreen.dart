import 'package:bazar/theme/colors.dart';
import 'package:bazar/theme/textstyle.dart';
import 'package:flutter/material.dart';

class Loginpagescreen extends StatefulWidget {
  const Loginpagescreen({super.key});

  @override
  State<Loginpagescreen> createState() => _LoginpagescreenState();
}

class _LoginpagescreenState extends State<Loginpagescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
    ),
    body: 
    Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Text('CLICK\n\nTYPE\n\nFIND\n\nyour shop.',
              style: AppTextStyle.h1, 
              ),
              SizedBox(width: 120),
              Image.asset('assets/images/shopping bag img.png',
              width: 100,
              height: 200,)
            ],
          ),
          SizedBox(height: 55),
           TextFormField(
            keyboardType: TextInputType.text,
            style: AppTextStyle.inputBox,
            decoration: InputDecoration(
              labelText: "USERNAME",
              hintText: "e.g: John Doe",
              border:  OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: AppColors.accent)
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: AppColors.accent),
              )
            ),
            validator: (value){
              if(value==null || value.isEmpty){
                return "Please enter your full name.";
              }
              return null;
              },
          ),
          SizedBox(height: 20),
          Expanded(
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ 
            TextFormField(
            keyboardType: TextInputType.text,
            style: AppTextStyle.inputBox,
            decoration: InputDecoration(
              labelText: "PASSWORD",
              suffixIcon: IconButton(onPressed: () {}, icon: Icon(Icons.visibility)),
              hintText: "e.g: John Doe",
              border:  OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: AppColors.accent)
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: AppColors.accent),
              )
            ),
            validator: (value){
              if(value==null || value.isEmpty){
                return "Please enter your full name.";
              }
              return null;
              },
          ),
          TextButton(onPressed: () {}, child: Text("Forgot Password?",
          style: AppTextStyle.minimalTexts.copyWith(
          decoration: TextDecoration.underline,))),
           SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {}, 
              style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(82, 70, 50, 1),
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
              )
              ),
              child: Text("LOGIN",
              style: AppTextStyle.buttonText,),
            ),
          ),
          TextButton(onPressed: () {}, child: Text("Don't have an account?",
          style: AppTextStyle.minimalTexts.copyWith(
          decoration: TextDecoration.underline,))),
          SizedBox(height: 15),
            Container(
            width:500,
            height: 85,
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)
              ),
              child:
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Continue with Google', 
                    style: AppTextStyle.minimalTexts,),
                    SizedBox(width: 20),
                    Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Google_Favicon_2025.svg/960px-Google_Favicon_2025.svg.png',
                    width: 40,
                    height: 40)
                  ],
                ),
              )
            )
            ]
            
          )
                    )
           
        ],
      ),
    )
    );
  }
}