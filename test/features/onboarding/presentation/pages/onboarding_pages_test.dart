import 'package:bazar/features/onboarding/presentation/pages/Onboarding2.dart';
import 'package:bazar/features/onboarding/presentation/pages/Onboarding3.dart';
import 'package:bazar/features/onboarding/presentation/pages/OnboardingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shows welcome headline on screen 1', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Onboardingscreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Bazar'), findsOneWidget);
  });

  testWidgets('Shows leave reviews copy on screen 2', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Onboarding2()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Leave your reviews'), findsOneWidget);
  });

  testWidgets('Shows search shops copy on screen 3', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Onboarding3()),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Search for the perfect shop to buy anything'),
      findsOneWidget,
    );
  });
}
