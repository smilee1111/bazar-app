import 'package:bazar/app/routes/app_routes.dart';
import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/core/utils/snackbar_utils.dart';
import 'package:bazar/features/auth/presentation/pages/LoginPageScreen.dart';
import 'package:bazar/features/auth/presentation/state/auth_state.dart';
import 'package:bazar/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:bazar/features/role/presentation/state/role_state.dart';
import 'package:bazar/features/role/presentation/view_model/role_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Signuppagescreen extends ConsumerStatefulWidget {
  const Signuppagescreen({super.key});


  @override
  ConsumerState<Signuppagescreen> createState() => _SignuppagescreenState();
}

class _SignuppagescreenState extends ConsumerState<Signuppagescreen> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedRole;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


    @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Call load batches when the widget is built
      ref.read(roleViewModelProvider.notifier).getAllRoles();
    });
  }

   Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      await ref
      .read(authViewModelProvider.notifier)
      .register(
        fullName: _fullnameController.text.trim(),
        email: _emailController.text.trim(),
        username: _emailController.text.trim().split('@').first,
        password: _passwordController.text,
        roleId: _selectedRole,
      );
    }
   }

   void _navigateToLogin() {
    AppRoutes.pushReplacement(context, const Loginpagescreen());
  }


     void _handleGoogleSignUp() {
    // TODO: Implement Google Sign In
    SnackbarUtils.showInfo(context, 'Google Sign Up coming soon');
  }
  @override
  Widget build(BuildContext context) {

    //provider watch 
    final roleState = ref.watch(roleViewModelProvider);
    final authState = ref.watch(authViewModelProvider);

     // Listen to auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(
          context,
          'Registration successful! Please login.',
        );
        AppRoutes.pushReplacement(context, const Loginpagescreen());
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      body: 
      Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                  style: AppTextStyle.minimalTexts,),
                  SizedBox(height: 30),
                  TextFormField(
                  controller: _fullnameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    hintText: "e.g: Ram kc",
                  ),
                 validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    hintText: "e.g: example.com",
                  ),
                  validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "e.g: john_doe123",
                  ),
                  validator: (value){
                    if(value==null || value.isEmpty){
                      return "Please enter your username.";
                    }
                    return null;
                    },
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  style: AppTextStyle.minimalTexts.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                  labelText: 'Role',
                  hintText: roleState.status ==RoleStatus.loading
                      ? 'Loading roles...'
                      : 'Select your role',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: roleState.roles.map((role){
                    return DropdownMenuItem<String>(
                    value: role.roleId,
                    child: Text(
                      role.roleName,
                      style: AppTextStyle.minimalTexts.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your role.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "password must have special characters",
                  prefixIcon: Icon(Icons.lock_outline_rounded),
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
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: 15,),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: authState.status == AuthStatus.loading ? null : _handleSignup,
                    child: authState.status == AuthStatus.loading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text("SIGN UP"),
                    
                  ),
                ),
                TextButton(onPressed: _navigateToLogin,
                child: Text("Already have an account? Sign In",
                style: AppTextStyle.minimalTexts.copyWith(
                decoration: TextDecoration.underline,))),
                Container(
                  width:500,
                  height: 80,
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
                          TextButton(
                            onPressed: _handleGoogleSignUp,
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