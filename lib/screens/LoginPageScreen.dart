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
  backgroundColor: AppColors.background,
  appBar: AppBar(
    backgroundColor: AppColors.background,
  ),
  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  'CLICK\n\nTYPE\n\nFIND\n\nyour shop.',
                  style: AppTextStyle.h1,
                ),
                const SizedBox(width: 120),
                Image.asset(
                  'assets/images/shopping bag img.png',
                  width: 100,
                  height: 200,
                ),
              ],
            ),

            const SizedBox(height: 55),

            // USERNAME
            TextFormField(
              controller: usernameController,
              keyboardType: TextInputType.text,
              style: AppTextStyle.inputBox,
              decoration: InputDecoration(
                labelText: "USERNAME",
                hintText: "e.g: John Doe",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
              style: AppTextStyle.inputBox,
              decoration: InputDecoration(
                labelText: "PASSWORD",
                suffixIcon: Icon(Icons.visibility),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(82, 70, 50, 1),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "LOGIN",
                  style: AppTextStyle.buttonText,
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
              height: 85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue with Google', style: AppTextStyle.minimalTexts),
                  const SizedBox(width: 10),
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Google_Favicon_2025.svg/960px-Google_Favicon_2025.svg.png',
                    width: 40,
                    height: 40,
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