import 'package:bazar/core/error/failure.dart';
import 'package:bazar/core/usecases/app_usecase.dart';
import 'package:bazar/features/shop/data/repositories/shop_repository.dart';
import 'package:bazar/features/shop/domain/entities/shop_entity.dart';
import 'package:bazar/features/shop/domain/repositories/shop_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getNearestShopsUsecaseProvider = Provider<GetNearestShopsUsecase>((ref) {
  return GetNearestShopsUsecase(repository: ref.read(shopRepositoryProvider));
});

/// Parameters for nearest shops request
class NearestShopsParams {
  final String categoryId;
  final double lat;
  final double lng;
  final int limit;

  const NearestShopsParams({
    required this.categoryId,
    required this.lat,
    required this.lng,
    this.limit = 10,
  });

  @override
  String toString() =>
      'NearestShopsParams(categoryId: $categoryId, lat: $lat, lng: $lng, limit: $limit)';
}

/// Usecase for fetching nearest shops based on user location and category
class GetNearestShopsUsecase
    implements UsecaseWithParams<List<ShopEntity>, NearestShopsParams> {
  final IShopRepository _repository;

  GetNearestShopsUsecase({required IShopRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<ShopEntity>>> call(
    NearestShopsParams params,
  ) {
    return _repository.getNearestShops(
      categoryId: params.categoryId,
      lat: params.lat,
      lng: params.lng,
      limit: params.limit,
    );
  }
}
