import 'package:bazar/features/auth/presentation/pages/ForgotPasswordPageScreen.dart';
import 'package:bazar/features/auth/presentation/pages/LoginPageScreen.dart';
import 'package:bazar/features/auth/presentation/pages/SignupPageScreen.dart';
import 'package:bazar/features/auth/presentation/state/auth_state.dart';
import 'package:bazar/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:bazar/features/onboarding/presentation/pages/Onboarding2.dart';
import 'package:bazar/features/onboarding/presentation/pages/OnboardingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Minimal test notifier ─────────────────────────────────────────────────────
// Overrides build() without calling super so no real Riverpod providers are
// read. All async methods are no-ops; the widget receives a plain initial state.

class _TestAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState();

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {}

  @override
  Future<bool> requestPasswordReset({required String email}) async => false;

  @override
  Future<bool> verifyResetOtp({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async =>
      false;

  @override
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async =>
      false;

  @override
  Future<void> getCurrentUser() async {}

  @override
  Future<void> logout() async {}
}

// ── Helper ────────────────────────────────────────────────────────────────────

Widget _wrapWithAuth(Widget page) {
  return ProviderScope(
    overrides: [
      authViewModelProvider.overrideWith(_TestAuthViewModel.new),
    ],
    child: MaterialApp(home: page),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Login page ────────────────────────────────────────────────────────────

  testWidgets('LoginPage shows Welcome back heading', (tester) async {
    await tester.pumpWidget(_wrapWithAuth(const Loginpagescreen()));
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('LoginPage shows subtitle text', (tester) async {
    await tester.pumpWidget(_wrapWithAuth(const Loginpagescreen()));
    await tester.pump();

    expect(
      find.text('Sign in to continue to your account'),
      findsOneWidget,
    );
  });

  testWidgets('LoginPage contains email and password TextFormFields',
      (tester) async {
    await tester.pumpWidget(_wrapWithAuth(const Loginpagescreen()));
    await tester.pump();

    // Email + password = at least 2 form fields
    expect(find.byType(TextFormField), findsAtLeast(2));
  });

  // ── Signup page ───────────────────────────────────────────────────────────

  testWidgets('SignupPage shows Enter your details below text', (tester) async {
    await tester.pumpWidget(_wrapWithAuth(const Signuppagescreen()));
    await tester.pump();

    expect(find.text('Enter your details below'), findsOneWidget);
  });

  testWidgets('SignupPage has multiple TextFormField widgets', (tester) async {
    await tester.pumpWidget(_wrapWithAuth(const Signuppagescreen()));
    await tester.pump();

    // fullName + email + username + password + confirmPassword + phone = 6 fields
    expect(find.byType(TextFormField), findsAtLeast(4));
  });

  // ── Forgot password page ──────────────────────────────────────────────────

  testWidgets('ForgotPasswordPage has Forgot Password in AppBar', (tester) async {
    await tester.pumpWidget(_wrapWithAuth(const ForgotPasswordPageScreen()));
    await tester.pump();

    expect(find.text('Forgot Password'), findsOneWidget);
  });

  testWidgets('ForgotPasswordPage has a TextFormField for email', (tester) async {
    await tester.pumpWidget(_wrapWithAuth(const ForgotPasswordPageScreen()));
    await tester.pump();

    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('ForgotPasswordPage has Send OTP button', (tester) async {
    await tester.pumpWidget(_wrapWithAuth(const ForgotPasswordPageScreen()));
    await tester.pump();

    expect(find.text('Send OTP'), findsOneWidget);
  });

  // ── Onboarding pages (StatelessWidget – no Riverpod needed) ───────────────

  testWidgets('OnboardingScreen shows Welcome to Bazar title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Onboardingscreen()),
    );
    await tester.pump();

    expect(find.text('Welcome to Bazar'), findsOneWidget);
  });

  testWidgets('OnboardingScreen has a Skip button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Onboardingscreen()),
    );
    await tester.pump();

    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Onboarding2 shows Leave your reviews feature point',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Onboarding2()),
    );
    await tester.pump();

    expect(find.textContaining('Leave your reviews'), findsOneWidget);
  });
}
