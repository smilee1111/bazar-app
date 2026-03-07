import 'package:bazar/core/error/failure.dart';
import 'package:bazar/features/category/domain/entities/category_entity.dart';
import 'package:bazar/features/category/domain/repositories/category_repository.dart';
import 'package:bazar/features/category/domain/usecases/get_all_category_usecase.dart';
import 'package:bazar/features/dashboard/presentation/pages/HomeScreen.dart';
import 'package:bazar/features/favourite/domain/entities/favourite_entity.dart';
import 'package:bazar/features/favourite/presentation/state/favourite_state.dart';
import 'package:bazar/features/favourite/presentation/view_model/favourite_view_model.dart';
import 'package:bazar/features/savedShop/domain/entities/saved_shop_entity.dart';
import 'package:bazar/features/savedShop/presentation/pages/SavedScreen.dart';
import 'package:bazar/features/savedShop/presentation/state/saved_shop_state.dart';
import 'package:bazar/features/savedShop/presentation/view_model/saved_shop_view_model.dart';
import 'package:bazar/features/sensor/presentation/state/sensor_state.dart';
import 'package:bazar/features/sensor/presentation/view_model/sensor_view_model.dart';
import 'package:bazar/features/shop/domain/entities/shop_entity.dart';
import 'package:bazar/features/shop/presentation/state/shop_state.dart';
import 'package:bazar/features/shop/presentation/view_model/shop_view_model.dart';
import 'package:bazar/features/shopReview/presentation/state/user_review_state.dart';
import 'package:bazar/features/shopReview/presentation/view_model/user_review_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _shopState = ShopState(
  publicShops: const <ShopEntity>[],
  hasLoadedPublic: true,
  hasMore: false,
);

final _savedState = SavedShopState(
  savedShops: const <SavedShopEntity>[],
);

final _favouriteState = FavouriteState(
  favourites: const <FavouriteEntity>[],
);

final _userReviewState = UserReviewState(
  reviewedShopIds: const <String>{},
);

Widget _wrapWithProviders(Widget home) {
  final categoryUsecase = GetAllCategoryUsecase(
    categoryRepository: _StubCategoryRepository(),
  );

  return ProviderScope(
    overrides: [
      shopViewModelProvider.overrideWith(
        () => _FakeShopViewModel(_shopState),
      ),
      savedShopViewModelProvider.overrideWith(
        () => _FakeSavedShopViewModel(_savedState),
      ),
      favouriteViewModelProvider.overrideWith(
        () => _FakeFavouriteViewModel(_favouriteState),
      ),
      userReviewViewModelProvider.overrideWith(
        () => _FakeUserReviewViewModel(_userReviewState),
      ),
      sensorViewModelProvider.overrideWith(
        () => _FakeSensorViewModel(const SensorState()),
      ),
      getAllCategoryUseCaseProvider.overrideWithValue(categoryUsecase),
    ],
    child: MaterialApp(home: Scaffold(body: home)),
  );
}

void main() {
  testWidgets('Home screen shows banner and empty state', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const Homescreen()));
    await tester.pumpAndSettle();

    expect(find.text('Discover Shops'), findsOneWidget);
    expect(
      find.text('Browse verified shops and explore what they offer.'),
      findsOneWidget,
    );
    expect(find.text('No shops available'), findsOneWidget);
  });

  testWidgets('Saved screen renders placeholder text', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const Savedscreen()));
    await tester.pumpAndSettle();

    expect(find.text('Saved Shops'), findsOneWidget);
    expect(find.text('Save shops to revisit them later.'), findsOneWidget);
    expect(find.text('No saved shops yet.'), findsOneWidget);
  });
}

class _FakeShopViewModel extends ShopViewModel {
  _FakeShopViewModel(this._initialState);

  final ShopState _initialState;

  @override
  ShopState build() => _initialState;

  @override
  Future<void> loadPublicShops({bool forceRefresh = false}) async {}

  @override
  Future<void> loadMorePublicShops() async {}

  @override
  Future<void> loadSellerShops({bool forceRefresh = false}) async {}
}

class _FakeSavedShopViewModel extends SavedShopViewModel {
  _FakeSavedShopViewModel(this._initialState);

  final SavedShopState _initialState;

  @override
  SavedShopState build() => _initialState;

  @override
  Future<void> loadSavedShops({bool forceRefresh = false}) async {}

  @override
  Future<bool> toggleSaved(String shopId) async => true;
}

class _FakeFavouriteViewModel extends FavouriteViewModel {
  _FakeFavouriteViewModel(this._initialState);

  final FavouriteState _initialState;

  @override
  FavouriteState build() => _initialState;

  @override
  Future<void> loadFavourites({bool forceRefresh = false}) async {}

  @override
  Future<bool> toggleFavourite({required String shopId, bool? isReviewed})
    async => true;

  @override
  Future<bool> ensureReviewedFavourite(String shopId) async => true;
}

class _FakeUserReviewViewModel extends UserReviewViewModel {
  _FakeUserReviewViewModel(this._initialState);

  final UserReviewState _initialState;

  @override
  UserReviewState build() => _initialState;

  @override
  Future<void> loadReviewedShops({bool forceRefresh = false}) async {}
}

class _FakeSensorViewModel extends SensorViewModel {
  _FakeSensorViewModel(this._initialState);

  final SensorState _initialState;

  @override
  SensorState build() => _initialState;

  @override
  void attach() {}

  @override
  void detach() {}
}

class _StubCategoryRepository implements IcategoryRepository {
  const _StubCategoryRepository();

  @override
  Future<Either<Failure, bool>> createCategory(CategoryEntity role) async {
    return const Left(LocalDatabaseFailure(message: 'not needed in tests'));
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(String categoryId) async {
    return const Left(LocalDatabaseFailure(message: 'not needed in tests'));
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategorys() async {
    return const Right([
      CategoryEntity(categoryId: 'cat-1', categoryName: 'Cafe'),
    ]);
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(
    String roleId,
  ) async {
    return const Left(LocalDatabaseFailure(message: 'not needed in tests'));
  }

  @override
  Future<Either<Failure, bool>> updateCategory(CategoryEntity role) async {
    return const Left(LocalDatabaseFailure(message: 'not needed in tests'));
  }
}
