import 'package:bazar/theme/colors.dart';
import 'package:bazar/theme/textstyle.dart';
import 'package:flutter/material.dart';

class Signuppagescreen extends StatefulWidget {
  const Signuppagescreen({super.key});


  @override
  State<Signuppagescreen> createState() => _SignuppagescreenState();
}

class _SignuppagescreenState extends State<Signuppagescreen> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

 
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        ),
      body: 
      Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        child: Image.asset('assets/images/bazarlogo.png',
                        width: 90,
                        height: 90,
                        ),
                      ),
                      SizedBox(width: 20),
                      Text("Let's get you\nshopping smarter.",
                      style: AppTextStyle.h1,
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('enter your details below',
                  style: TextStyle(
                    fontSize: 16
                  ),),
                  SizedBox(height: 30),
                  TextFormField(
                  controller: fullnameController,
                  keyboardType: TextInputType.text,
                  style: AppTextStyle.inputBox,
                  decoration: InputDecoration(
                    labelText: "Full Name",
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
                SizedBox(height: 15),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyle.inputBox,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    hintText: "e.g: example.com",
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
                      return "Please enter your email address.";
                    }
                    return null;
                    },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: usernameController,
                  keyboardType: TextInputType.text,
                  style: AppTextStyle.inputBox,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "e.g: john_doe123",
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
                      return "Please enter your username.";
                    }
                    return null;
                    },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  style: AppTextStyle.inputBox,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "password must have special characters",
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
                      return "Please enter your password.";
                    }
                    return null;
                    },
                ),
                SizedBox(height: 15),
                TextFormField(
                controller: confirmPasswordController,
                keyboardType: TextInputType.visiblePassword,
                style: AppTextStyle.inputBox,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  hintText: "password must have special characters",
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
                    return "Please enter your password.";
                  }
                  return null;
                  },
                ),
                SizedBox(height: 15,),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                       if(_formKey.currentState!.validate()){
                        Navigator.pushNamed(context, '/OnboardingScreen');
                       }
                    }, 
                    style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(82, 70, 50, 1),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                    )
                    ),
                    child: Text("SIGN UP",
                    style: AppTextStyle.buttonText,),
                  ),
                ),
                TextButton(onPressed: () {
                    Navigator.pushNamed(context, '/LoginScreen');
                  
                }, child: Text("Already have an account? Sign In",
                style: AppTextStyle.minimalTexts.copyWith(
                decoration: TextDecoration.underline,))),
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
                          SizedBox(width: 10),
                          Image.asset('assets/icons/googlelogo.png',
                          width: 40,
                          height: 40)
                        ],
                      ),
                    )
                  )
                ]
                  
              ),
            ),
          ),
        ),
      ),
    );
  }
}