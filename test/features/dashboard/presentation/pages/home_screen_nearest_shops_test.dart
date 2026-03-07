import 'package:bazar/features/dashboard/presentation/widgets/nearest_shops_toggle.dart';
import 'package:bazar/core/models/geo_point.dart';
import 'package:bazar/features/shop/domain/entities/shop_entity.dart';
import 'package:bazar/features/shop/presentation/state/shop_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {

  // Create sample shop data
  final sampleShop = ShopEntity(
    shopId: 'shop-1',
    shopName: 'Test Shop',
    shopAddress: 'Test Address',
    shopContact: '1234567890',
    description: 'Test description',
    location: const GeoPoint(latitude: 27.7172, longitude: 85.3240),
    categoryNames: const ['Electronics'],
  );

  group('NearestShopsToggle', () {
    testWidgets('renders and toggles when enabled', (tester) async {
      bool? toggledValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearestShopsToggle(
              isEnabled: false,
              categorySelected: true,
              onToggle: (value) => toggledValue = value,
            ),
          ),
        ),
      );

      expect(find.text('Show nearest shops only'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(toggledValue, isTrue);
    });

    testWidgets('shows disabled hint when category is not selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NearestShopsToggle(
              isEnabled: false,
              categorySelected: false,
              onToggle: _noopToggle,
            ),
          ),
        ),
      );

      expect(find.text('Select a category first'), findsOneWidget);

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.onChanged, isNull);
    });
  });

  group('HomeScreen state mapping (displayedShops)', () {
    test('shopState returns publicShops when showNearestOnly is false', () {
      final state = ShopState(
        publicShops: [sampleShop],
        nearestShops: const [
          ShopEntity(
            shopId: 'nearby-1',
            shopName: 'Nearby Shop',
            shopAddress: 'Nearby Address',
            shopContact: '001',
          ),
        ],
        showNearestOnly: false,
      );

      expect(state.displayedShops, equals(state.publicShops));
      expect(state.displayedShops.length, 1);
      expect(state.displayedShops.first.shopId, 'shop-1');
    });

    test('shopState returns nearestShops when showNearestOnly is true', () {
      const nearbyShop = ShopEntity(
        shopId: 'nearby-1',
        shopName: 'Nearby Shop',
        shopAddress: 'Nearby Address',
        shopContact: '001',
      );
      final state = ShopState(
        publicShops: [sampleShop],
        nearestShops: [nearbyShop],
        showNearestOnly: true,
      );

      expect(state.displayedShops, equals(state.nearestShops));
      expect(state.displayedShops.length, 1);
      expect(state.displayedShops.first.shopId, 'nearby-1');
    });

    test('shopState returns empty list when nearestShops is empty and filter is on', () {
      final state = ShopState(
        publicShops: [sampleShop],
        nearestShops: [],
        showNearestOnly: true,
      );

      expect(state.displayedShops, isEmpty);
    });
  });
}

void _noopToggle(bool _) {}
