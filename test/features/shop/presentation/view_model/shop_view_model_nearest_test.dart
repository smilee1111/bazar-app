import 'package:bazar/core/models/geo_point.dart';
import 'package:bazar/core/services/location/geolocation_provider.dart';
import 'package:bazar/features/shop/domain/entities/shop_entity.dart';
import 'package:bazar/features/shop/domain/usecases/get_nearest_shops_usecase.dart';
import 'package:bazar/features/shop/presentation/state/shop_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleShop = ShopEntity(
    shopId: 'shop-1',
    shopName: 'Test Shop',
    shopAddress: 'Test Address',
    shopContact: '1234567890',
    description: 'Test description',
    location: const GeoPoint(latitude: 27.7172, longitude: 85.3240),
    categoryNames: const ['Electronics'],
  );

  group('ShopState - displayedShops Getter', () {
    test('returns publicShops when showNearestOnly is false', () {
      // Given
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

      // When
      final displayed = state.displayedShops;

      // Then
      expect(displayed, equals(state.publicShops));
      expect(displayed.length, 1);
      expect(displayed.first.shopId, 'shop-1');
    });

    test('returns nearestShops when showNearestOnly is true', () {
      // Given
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

      // When
      final displayed = state.displayedShops;

      // Then
      expect(displayed, equals(state.nearestShops));
      expect(displayed.length, 1);
      expect(displayed.first.shopId, 'nearby-1');
    });

    test('returns empty list when showNearestOnly is true but nearestShops is empty', () {
      // Given
      final state = ShopState(
        publicShops: [sampleShop],
        nearestShops: [],
        showNearestOnly: true,
      );

      // When
      final displayed = state.displayedShops;

      // Then
      expect(displayed, isEmpty);
    });

    test('returns all publicShops when showNearestOnly is false', () {
      // Given
      final shops = <ShopEntity>[
        sampleShop,
        const ShopEntity(
          shopId: 'shop-2',
          shopName: 'Second Shop',
          shopAddress: 'Address 2',
          shopContact: '0002',
        ),
        const ShopEntity(
          shopId: 'shop-3',
          shopName: 'Third Shop',
          shopAddress: 'Address 3',
          shopContact: '0003',
        ),
      ];
      
      final state = ShopState(
        publicShops: shops,
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

      // When
      final displayed = state.displayedShops;

      // Then
      expect(displayed.length, 3);
      expect(displayed, equals(shops));
    });
  });

  group('NearestShopsParams', () {
    test('creates params with all required fields', () {
      // Given
      const params = NearestShopsParams(
        categoryId: 'cat-123',
        lat: 27.7172,
        lng: 85.3240,
        limit: 20,
      );

      // Then
      expect(params.categoryId, 'cat-123');
      expect(params.lat, 27.7172);
      expect(params.lng, 85.3240);
      expect(params.limit, 20);
    });

    test('uses default limit when not specified', () {
      // Given
      const params = NearestShopsParams(
        categoryId: 'cat-123',
        lat: 27.7172,
        lng: 85.3240,
      );

      expect(params.limit, 10);
    });
  });

  group('UserLocation', () {
    test('distanceTo returns near-zero for same coordinates', () {
      final userLocation = UserLocation(
        latitude: 27.7172,
        longitude: 85.3240,
        fetchedAt: DateTime(2026, 1, 1),
      );

      final distance = userLocation.distanceTo(27.7172, 85.3240);

      expect(distance, lessThan(0.01));
    });
  });
}
