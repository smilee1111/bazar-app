import 'package:bazar/core/error/failure.dart';
import 'package:bazar/core/services/connectivity/network_info.dart';
import 'package:bazar/features/shop/data/datasources/shop_remote_datasource.dart';
import 'package:bazar/features/shop/data/models/shop_api_model.dart';
import 'package:bazar/features/shop/domain/entities/shop_entity.dart';
import 'package:bazar/features/shop/domain/repositories/shop_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopRepositoryProvider = Provider<IShopRepository>((ref) {
  return ShopRepository(
    remoteDataSource: ref.read(shopRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ShopRepository implements IShopRepository {
  final IShopRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ShopRepository({
    required IShopRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  String _extractErrorMessage(Object? data, String fallback) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    if (data is String && data.isNotEmpty) return data;
    return fallback;
  }

  @override
  Future<Either<Failure, ShopEntity>> createShop(ShopEntity shop) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final model = ShopApiModel.fromEntity(shop);
      final response = await _remoteDataSource.createShop(model);
      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: _extractErrorMessage(
            e.response?.data,
            'Failed to create shop',
          ),
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteShop(String shopId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await _remoteDataSource.deleteShop(shopId);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: _extractErrorMessage(
            e.response?.data,
            'Failed to delete shop',
          ),
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopEntity>> getPublicShopById(String shopId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final model = await _remoteDataSource.getPublicShopById(shopId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: _extractErrorMessage(
            e.response?.data,
            'Failed to fetch public shop by id',
          ),
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ShopEntity>>> getPublicFeed({
    int page = 1,
    int limit = 15,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final models = await _remoteDataSource.getPublicFeed(
        page: page,
        limit: limit,
      );
      return Right(ShopApiModel.toEntityList(models));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: _extractErrorMessage(
            e.response?.data,
            'Failed to fetch public shops',
          ),
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopEntity>> getSellerShopById(String shopId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final model = await _remoteDataSource.getSellerShopById(shopId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: _extractErrorMessage(
            e.response?.data,
            'Failed to fetch seller shop by id',
          ),
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ShopEntity>>> getSellerShops() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final models = await _remoteDataSource.getSellerShops();
      return Right(ShopApiModel.toEntityList(models));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: _extractErrorMessage(
            e.response?.data,
            'Failed to fetch seller shops',
          ),
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopEntity?>> getMySellerShop() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final model = await _remoteDataSource.getMySellerShop();
      if (model == null) return const Right(null);
      return Right(model.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right(null);
      }
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: _extractErrorMessage(
            e.response?.data,
            'Failed to fetch my seller shop',
          ),
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopEntity>> updateShop(ShopEntity shop) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final model = ShopApiModel.fromEntity(shop);
      final response = await _remoteDataSource.updateShop(model);
      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: _extractErrorMessage(
            e.response?.data,
            'Failed to update shop',
          ),
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ShopEntity>>> getNearestShops({
    required String categoryId,
    required double lat,
    required double lng,
    int limit = 10,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final models = await _remoteDataSource.getNearestShops(
        categoryId: categoryId,
        lat: lat,
        lng: lng,
        limit: limit,
      );
      return Right(ShopApiModel.toEntityList(models));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: _extractErrorMessage(
            e.response?.data,
            'Failed to fetch nearest shops',
          ),
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
