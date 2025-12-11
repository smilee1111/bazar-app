import 'package:bazar/theme/colors.dart';
import 'package:bazar/theme/textstyle.dart';
import 'package:flutter/material.dart';

class Loginpagescreen extends StatefulWidget {
  const Loginpagescreen({super.key});

  @override
  State<Loginpagescreen> createState() => _LoginpagescreenState();
}

class _LoginpagescreenState extends State<Loginpagescreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
return Scaffold(
  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  'CLICK\n\nTYPE\n\nFIND\n\nyour shop.',
                  style: AppTextStyle.h1,
                ),
                SizedBox(width:5),
                SizedBox(
                  width: 200,
                  height: 300,
                  child: Image.asset(
                  'assets/images/image2.png',
                  fit: BoxFit.cover,
                  width: 100,
                  height: 200,
                ),
                )
                
              ],
            ),
            const SizedBox(height: 55),
            // USERNAME
            TextFormField(
              controller: usernameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "USERNAME",
                hintText: "e.g: John Doe",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your full name.";
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // PASSWORD
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "PASSWORD",
                suffixIcon: Icon(Icons.visibility),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your password.";
                }
                return null;
              },
            ),

            TextButton(
              onPressed: () {},
              child: Text(
                "Forgot Password?",
                style: AppTextStyle.minimalTexts.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushNamed(context, '/DashboardScreen');
                  }
                },
                child: Text(
                  "LOGIN",
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/RegisterScreen');
              },
              child: Text(
                "Don't have an account?",
                style: AppTextStyle.minimalTexts.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue with Google', style: AppTextStyle.minimalTexts),
                  const SizedBox(width: 10),
                  Image.asset('assets/icons/googlelogo.png',
                    width: 30,
                    height: 30,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  ),
);
  }
}