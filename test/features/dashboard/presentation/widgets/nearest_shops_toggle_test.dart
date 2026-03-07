import 'package:bazar/features/dashboard/presentation/widgets/nearest_shops_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NearestShopsToggle Widget Tests', () {
    testWidgets('renders correctly with default state', (WidgetTester tester) async {
      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearestShopsToggle(
              isEnabled: false,
              isLoading: false,
              categorySelected: true,
              onToggle: (value) {
                toggleCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(NearestShopsToggle), findsOneWidget);
      expect(find.text('Show nearest shops only'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('displays loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearestShopsToggle(
              isEnabled: true,
              isLoading: true,
              categorySelected: true,
              onToggle: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('switch is disabled when category is not selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearestShopsToggle(
              isEnabled: false,
              isLoading: false,
              categorySelected: false,
              onToggle: (_) {},
            ),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.onChanged, isNull);
    });

    testWidgets('switch is enabled when category is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearestShopsToggle(
              isEnabled: false,
              isLoading: false,
              categorySelected: true,
              onToggle: (_) {},
            ),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.onChanged, isNotNull);
    });

    testWidgets('calls onToggle when switch is tapped', (WidgetTester tester) async {
      bool toggledValue = false;
      bool callbackInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearestShopsToggle(
              isEnabled: false,
              isLoading: false,
              categorySelected: true,
              onToggle: (value) {
                toggledValue = value;
                callbackInvoked = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(callbackInvoked, true);
      expect(toggledValue, true);
    });

    testWidgets('switch reflects isEnabled state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearestShopsToggle(
              isEnabled: true,
              isLoading: false,
              categorySelected: true,
              onToggle: (_) {},
            ),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);
    });

    testWidgets('displays hint text when category is not selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearestShopsToggle(
              isEnabled: false,
              isLoading: false,
              categorySelected: false,
              onToggle: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Select a category first'), findsOneWidget);
    });

    testWidgets('does not display hint text when category is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearestShopsToggle(
              isEnabled: false,
              isLoading: false,
              categorySelected: true,
              onToggle: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Select a category first'), findsNothing);
    });

    testWidgets('toggle is tappable when enabled and not loading', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearestShopsToggle(
              isEnabled: false,
              isLoading: false,
              categorySelected: true,
              onToggle: (value) {
                tapCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(tapCount, 1);
    });

    testWidgets('displays proper color scheme when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearestShopsToggle(
              isEnabled: true,
              isLoading: false,
              categorySelected: true,
              onToggle: (_) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Show nearest shops only'),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.border, isNotNull);
    });
  });
}
