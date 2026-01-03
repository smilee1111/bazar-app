import 'package:bazar/app/routes/app_routes.dart';
import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/core/utils/snackbar_utils.dart';
import 'package:bazar/features/auth/presentation/pages/SignupPageScreen.dart';
import 'package:bazar/features/auth/presentation/state/auth_state.dart';
import 'package:bazar/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:bazar/features/dashboard/presentation/pages/DashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Loginpagescreen extends ConsumerStatefulWidget {
  const Loginpagescreen({super.key});

  @override
  ConsumerState<Loginpagescreen> createState() => _LoginpagescreenState();
}

class _LoginpagescreenState extends ConsumerState<Loginpagescreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();


   @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

    void _navigateToSignup() {
    AppRoutes.push(context, const Signuppagescreen());
  }

  
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

   void _handleGoogleSignIn() {
    // TODO: Implement Google Sign In
    SnackbarUtils.showInfo(context, 'Google Sign In coming soon');
  }
  @override     
  Widget build(BuildContext context) {
  final authState = ref.watch(authViewModelProvider);


  
    // Listen to auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        AppRoutes.pushReplacement(context, const Dashboardscreen());
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });
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
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "USERNAME",
                hintText: "e.g: John Doe",
              ),
               validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

            const SizedBox(height: 20),

            // PASSWORD
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "PASSWORD",
               hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15,),
            SizedBox(
              width: 150,
              child: ElevatedButton(
              onPressed: authState.status == AuthStatus.loading
                        ? null
                        : _handleLogin,
                 child: authState.status == AuthStatus.loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                  : Text(
                  "LOGIN",
                ),
              ),
            ),
            TextButton(
              onPressed: _navigateToSignup,
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
                  TextButton(
                            onPressed: _handleGoogleSignIn,
                            child: Text('Continue with Google', 
                              style: AppTextStyle.minimalTexts,
                            ),
                          ),
                          SizedBox(width: 10),
                          Image.asset('assets/icons/googlelogo.png',
                          width: 30,
                          height: 30)
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