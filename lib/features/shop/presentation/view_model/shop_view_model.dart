import 'package:bazar/core/usecases/app_usecase.dart';
import 'package:bazar/features/shop/domain/entities/shop_entity.dart';
import 'package:bazar/features/shop/domain/usecases/create_shop_usecase.dart';
import 'package:bazar/features/shop/domain/usecases/delete_shop_usecase.dart';
import 'package:bazar/features/shop/domain/usecases/get_my_seller_shop_usecase.dart';
import 'package:bazar/features/shop/domain/usecases/get_public_feed_usecase.dart';
import 'package:bazar/features/shop/domain/usecases/get_nearest_shops_usecase.dart';
import 'package:bazar/features/shop/domain/usecases/update_shop_usecase.dart';
import 'package:bazar/features/shop/presentation/state/shop_state.dart';
import 'package:bazar/core/services/location/geolocation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopViewModelProvider = NotifierProvider<ShopViewModel, ShopState>(
  ShopViewModel.new,
);

class ShopViewModel extends Notifier<ShopState> {
  late final GetPublicFeedUsecase _getPublicFeedUsecase;
  late final GetMySellerShopUsecase _getMySellerShopUsecase;
  late final CreateShopUsecase _createShopUsecase;
  late final UpdateShopUsecase _updateShopUsecase;
  late final DeleteShopUsecase _deleteShopUsecase;
  late final GetNearestShopsUsecase _getNearestShopsUsecase;

  @override
  ShopState build() {
    _getPublicFeedUsecase = ref.read(getPublicFeedUsecaseProvider);
    _getMySellerShopUsecase = ref.read(getMySellerShopUsecaseProvider);
    _createShopUsecase = ref.read(createShopUsecaseProvider);
    _updateShopUsecase = ref.read(updateShopUsecaseProvider);
    _deleteShopUsecase = ref.read(deleteShopUsecaseProvider);
    _getNearestShopsUsecase = ref.read(getNearestShopsUsecaseProvider);
    return const ShopState();
  }

  Future<void> loadPublicShops({bool forceRefresh = false}) async {
    if (state.isLoadingPublic) return;
    if (!forceRefresh && state.hasLoadedPublic) return;

    state = state.copyWith(
      isLoadingPublic: true,
      clearError: true,
      // Reset pagination on fresh load
      currentPage: 0,
      hasMore: true,
    );
    final result = await _getPublicFeedUsecase(
      const PaginationParams(page: 1),
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingPublic: false,
          hasLoadedPublic: true,
          errorMessage: failure.message,
        );
      },
      (shops) {
        state = state.copyWith(
          isLoadingPublic: false,
          hasLoadedPublic: true,
          publicShops: shops,
          currentPage: 1,
          hasMore: shops.length >= kShopPageSize,
          clearError: true,
        );
      },
    );
  }

  /// Appends the next page of public shops. Called when the user scrolls to
  /// the end of the feed list.
  Future<void> loadMorePublicShops() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoadingPublic) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);
    final nextPage = state.currentPage + 1;
    final result = await _getPublicFeedUsecase(
      PaginationParams(page: nextPage),
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        );
      },
      (shops) {
        state = state.copyWith(
          isLoadingMore: false,
          publicShops: [...state.publicShops, ...shops],
          currentPage: nextPage,
          hasMore: shops.length >= kShopPageSize,
          clearError: true,
        );
      },
    );
  }

  Future<void> loadSellerShops({bool forceRefresh = false}) async {
    if (state.isLoadingSeller) return;
    if (!forceRefresh && state.hasLoadedSeller) return;

    state = state.copyWith(isLoadingSeller: true, clearError: true);

    final myShopResult = await _getMySellerShopUsecase();
    final myShop = myShopResult.fold<ShopEntity?>((_) => null, (shop) => shop);
    final error = myShopResult.fold<String?>((f) => f.message, (_) => null);
    final sellerShops = myShop == null
        ? const <ShopEntity>[]
        : <ShopEntity>[myShop];

    state = state.copyWith(
      isLoadingSeller: false,
      hasLoadedSeller: true,
      myShop: myShop,
      sellerShops: sellerShops,
      errorMessage: error,
      clearError: error == null,
    );
  }

  Future<bool> createShop(ShopEntity shop) async {
    if (state.isSaving) return false;
    state = state.copyWith(isSaving: true, clearError: true);

    final result = await _createShopUsecase(CreateShopParams(shop: shop));
    return result.fold(
      (failure) {
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
        return false;
      },
      (_) async {
        state = state.copyWith(isSaving: false, clearError: true);
        await loadSellerShops(forceRefresh: true);
        await loadPublicShops(forceRefresh: true);
        return true;
      },
    );
  }

  Future<bool> updateShop(ShopEntity shop) async {
    if (state.isSaving) return false;
    state = state.copyWith(isSaving: true, clearError: true);

    final result = await _updateShopUsecase(UpdateShopParams(shop: shop));
    return result.fold(
      (failure) {
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
        return false;
      },
      (_) async {
        state = state.copyWith(isSaving: false, clearError: true);
        await loadSellerShops(forceRefresh: true);
        await loadPublicShops(forceRefresh: true);
        return true;
      },
    );
  }

  Future<bool> deleteShop(String shopId) async {
    if (state.isDeleting) return false;
    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _deleteShopUsecase(DeleteShopParams(shopId: shopId));
    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) async {
        state = state.copyWith(isDeleting: false, clearError: true);
        await loadSellerShops(forceRefresh: true);
        await loadPublicShops(forceRefresh: true);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Set the selected category ID for filtering
  void setSelectedCategory(String? categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategoryId: categoryId == null,
      clearError: true,
    );
  }

  /// Toggle the "show nearest only" filter
  /// If enabled and category is selected, fetches nearest shops
  Future<void> toggleNearestFilter({bool? enable}) async {
    final newValue = enable ?? !state.showNearestOnly;

    // If enabling the filter, require a category
    if (newValue && state.selectedCategoryId == null) {
      state = state.copyWith(
        errorMessage: 'Please select a category first',
      );
      return;
    }

    // Update state to reflect toggle
    state = state.copyWith(
      showNearestOnly: newValue,
      clearError: true,
    );

    // If enabling, load nearest shops
    if (newValue && state.selectedCategoryId != null) {
      await loadNearestShops();
    }
  }

  /// Load nearest shops based on user location and selected category
  Future<void> loadNearestShops() async {
    if (state.isLoadingNearest) return;

    // Validate category is selected
    final categoryId = state.selectedCategoryId;
    if (categoryId == null) {
      state = state.copyWith(
        errorMessage: 'Please select a category',
        showNearestOnly: false,
      );
      return;
    }

    state = state.copyWith(isLoadingNearest: true, clearError: true);

    try {
      // Get user location
      final geolocationNotifier = ref.read(geolocationProvider.notifier);
      final userLocation = await geolocationNotifier.getCurrentLocation();

      if (userLocation == null) {
        // Location fetch failed
        final geolocationState = ref.read(geolocationProvider);
        state = state.copyWith(
          isLoadingNearest: false,
          showNearestOnly: false,
          errorMessage: geolocationState.errorMessage ??
              'Failed to get your location',
        );
        return;
      }

      // Store user location in state
      state = state.copyWith(
        userLatitude: userLocation.latitude,
        userLongitude: userLocation.longitude,
      );

      // Fetch nearest shops
      final result = await _getNearestShopsUsecase(
        NearestShopsParams(
          categoryId: categoryId,
          lat: userLocation.latitude,
          lng: userLocation.longitude,
          limit: 10,
        ),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoadingNearest: false,
            showNearestOnly: false,
            errorMessage: failure.message,
          );
        },
        (shops) {
          state = state.copyWith(
            isLoadingNearest: false,
            nearestShops: shops,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingNearest: false,
        showNearestOnly: false,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  /// Calculate distance from user to a shop in km
  double? calculateDistance(ShopEntity shop) {
    if (state.userLatitude == null ||
        state.userLongitude == null ||
        shop.location == null) {
      return null;
    }

    final userLocation = UserLocation(
      latitude: state.userLatitude!,
      longitude: state.userLongitude!,
      fetchedAt: DateTime.now(),
    );

    return userLocation.distanceTo(
      shop.location!.latitude,
      shop.location!.longitude,
    );
  }
}
