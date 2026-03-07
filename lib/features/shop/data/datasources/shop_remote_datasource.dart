import 'package:bazar/core/api/api_client.dart';
import 'package:bazar/core/api/api_endpoints.dart';
import 'package:bazar/features/shop/data/models/shop_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class IShopRemoteDataSource {
  Future<ShopApiModel> createShop(ShopApiModel shop);
  Future<List<ShopApiModel>> getSellerShops();
  Future<ShopApiModel?> getMySellerShop();
  Future<ShopApiModel> getSellerShopById(String shopId);
  Future<ShopApiModel> updateShop(ShopApiModel shop);
  Future<bool> deleteShop(String shopId);

  Future<List<ShopApiModel>> getPublicFeed({int page = 1, int limit = 15});
  Future<ShopApiModel> getPublicShopById(String shopId);

  /// Get nearest shops by location and category
  /// Parameters:
  /// - categoryId: The category ID to filter shops
  /// - lat: User's latitude
  /// - lng: User's longitude
  /// - limit: Maximum shops to return (default 10)
  Future<List<ShopApiModel>> getNearestShops({
    required String categoryId,
    required double lat,
    required double lng,
    int limit = 10,
  });
}

final shopRemoteDataSourceProvider = Provider<IShopRemoteDataSource>((ref) {
  return ShopRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class ShopRemoteDataSource implements IShopRemoteDataSource {
  final ApiClient _apiClient;

  ShopRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  List<ShopApiModel> _extractShopList(dynamic payload) {
    dynamic data = payload;
    if (payload is Map<String, dynamic>) {
      data = payload['data'] ?? payload['shops'] ?? payload['items'];
    }

    if (data is Map<String, dynamic>) {
      data = data['shops'] ?? data['items'] ?? data['data'];
    }

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ShopApiModel.fromJson)
          .toList();
    }
    return const [];
  }

  ShopApiModel _extractShop(dynamic payload) {
    dynamic data = payload;
    if (payload is Map<String, dynamic>) {
      data = payload['data'] ?? payload['shop'] ?? payload;
    }

    if (data is Map<String, dynamic>) {
      final nestedShop = data['shop'];
      if (nestedShop is Map<String, dynamic>) {
        return ShopApiModel.fromJson(nestedShop);
      }
      return ShopApiModel.fromJson(data);
    }

    throw Exception('Shop payload format is invalid.');
  }

  @override
  Future<ShopApiModel> createShop(ShopApiModel shop) async {
    final response = await _apiClient.post(
      ApiEndpoints.sellerShops,
      data: shop.toJson(),
    );
    return _extractShop(response.data);
  }

  @override
  Future<bool> deleteShop(String shopId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.sellerShopById(shopId),
    );
    if (response.data is Map<String, dynamic>) {
      return response.data['success'] == true;
    }
    return true;
  }

  @override
  Future<ShopApiModel?> getMySellerShop() async {
    final response = await _apiClient.get(ApiEndpoints.mySellerShop);
    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data == null) return null;
      return _extractShop(payload);
    }
    return null;
  }

  @override
  Future<List<ShopApiModel>> getPublicFeed({int page = 1, int limit = 15}) async {
    final response = await _apiClient.get(
      ApiEndpoints.publicShopsFeedPaged(page: page, limit: limit),
    );
    return _extractShopList(response.data);
  }

  @override
  Future<ShopApiModel> getPublicShopById(String shopId) async {
    final response = await _apiClient.get(ApiEndpoints.publicShopById(shopId));
    return _extractShop(response.data);
  }

  @override
  Future<ShopApiModel> getSellerShopById(String shopId) async {
    final response = await _apiClient.get(ApiEndpoints.sellerShopById(shopId));
    return _extractShop(response.data);
  }

  @override
  Future<List<ShopApiModel>> getSellerShops() async {
    final response = await _apiClient.get(ApiEndpoints.sellerShops);
    return _extractShopList(response.data);
  }

  @override
  Future<ShopApiModel> updateShop(ShopApiModel shop) async {
    final shopId = shop.shopId;
    if (shopId == null || shopId.isEmpty) {
      throw ArgumentError('shopId is required to update shop');
    }
    final response = await _apiClient.put(
      ApiEndpoints.sellerShopById(shopId),
      data: shop.toJson(),
    );
    return _extractShop(response.data);
  }

  @override
  Future<List<ShopApiModel>> getNearestShops({
    required String categoryId,
    required double lat,
    required double lng,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.publicNearestShopsWithParams(
        categoryId: categoryId,
        lat: lat,
        lng: lng,
        limit: limit,
      ),
    );
    return _extractShopList(response.data);
  }
}
