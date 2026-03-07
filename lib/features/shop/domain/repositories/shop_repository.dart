import 'package:bazar/core/error/failure.dart';
import 'package:bazar/features/shop/domain/entities/shop_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IShopRepository {
  Future<Either<Failure, ShopEntity>> createShop(ShopEntity shop);
  Future<Either<Failure, List<ShopEntity>>> getSellerShops();
  Future<Either<Failure, ShopEntity?>> getMySellerShop();
  Future<Either<Failure, ShopEntity>> getSellerShopById(String shopId);
  Future<Either<Failure, ShopEntity>> updateShop(ShopEntity shop);
  Future<Either<Failure, bool>> deleteShop(String shopId);

  Future<Either<Failure, List<ShopEntity>>> getPublicFeed({
    int page = 1,
    int limit = 15,
  });
  Future<Either<Failure, ShopEntity>> getPublicShopById(String shopId);

  /// Get nearest shops by location and category
  Future<Either<Failure, List<ShopEntity>>> getNearestShops({
    required String categoryId,
    required double lat,
    required double lng,
    int limit = 10,
  });
}
