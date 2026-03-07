import 'package:bazar/features/dashboard/presentation/widgets/shop_distance_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShopDistanceBadge Widget Tests', () {
    testWidgets('displays distance in meters when less than 1 km', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 0.5),
          ),
        ),
      );

      expect(find.text('500 m'), findsOneWidget);
      expect(find.byIcon(Icons.near_me_rounded), findsOneWidget);
    });

    testWidgets('displays distance in kilometers when 1 km or more', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 2.5),
          ),
        ),
      );

      expect(find.text('2.5 km'), findsOneWidget);
      expect(find.byIcon(Icons.near_me_rounded), findsOneWidget);
    });

    testWidgets('displays exactly 1 km correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 1.0),
          ),
        ),
      );

      expect(find.text('1.0 km'), findsOneWidget);
    });

    testWidgets('displays very small distance in meters', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 0.05),
          ),
        ),
      );

      expect(find.text('50 m'), findsOneWidget);
    });

    testWidgets('displays large distance correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 15.8),
          ),
        ),
      );

      expect(find.text('16 km'), findsOneWidget);
    });

    testWidgets('returns empty SizedBox when distanceInKm is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: null),
          ),
        ),
      );

      expect(find.byType(Container), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('m'), findsNothing);
      expect(find.text('km'), findsNothing);
    });

    testWidgets('rounds meters to integer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 0.4567),
          ),
        ),
      );

      // 0.4567 km = 456.7 m, should round to 457 m
      expect(find.text('457 m'), findsOneWidget);
    });

    testWidgets('displays badge with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 1.2),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.color, isNotNull);
      expect(decoration.borderRadius, isNotNull);
    });

    testWidgets('displays icon before text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 3.0),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, 3);
      expect(row.children[0], isA<Icon>());
      expect(row.children[1], isA<SizedBox>());
      expect(row.children[2], isA<Text>());
    });

    testWidgets('zero distance displays as 0 m', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 0.0),
          ),
        ),
      );

      expect(find.text('0 m'), findsOneWidget);
    });

    testWidgets('very close to 1 km displays in meters', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 0.999),
          ),
        ),
      );

      expect(find.text('999 m'), findsOneWidget);
    });

    testWidgets('badge has proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 1.5),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, isNotNull);
    });

    testWidgets('icon size is appropriate', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 2.0),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.near_me_rounded));
      expect(icon.size, 12);
    });
  });

  group('ShopDistanceBadge - Edge Cases', () {
    testWidgets('handles negative distance gracefully', (WidgetTester tester) async {
      // Note: In real usage, negative distances shouldn't occur,
      // but the widget should handle it gracefully
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: -1.0),
          ),
        ),
      );

      // Should still render without errors
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('handles extremely large distance', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 9999.99),
          ),
        ),
      );

      expect(find.text('10000 km'), findsOneWidget);
    });

    testWidgets('handles very small fractional distance', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShopDistanceBadge(distanceInKm: 0.001),
          ),
        ),
      );

      // 0.001 km = 1 m
      expect(find.text('1 m'), findsOneWidget);
    });
  });
}
