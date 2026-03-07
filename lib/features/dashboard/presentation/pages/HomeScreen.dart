import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/core/utils/snackbar_utils.dart';
import 'package:bazar/features/category/domain/entities/category_entity.dart';
import 'package:bazar/features/category/domain/usecases/get_all_category_usecase.dart';
import 'package:bazar/features/dashboard/presentation/view_model/shop_card_preview_provider.dart';
import 'package:bazar/features/dashboard/presentation/widgets/home_empty_state.dart';
import 'package:bazar/features/dashboard/presentation/widgets/home_skeleton_card.dart';
import 'package:bazar/features/dashboard/presentation/widgets/home_top_banner.dart';
import 'package:bazar/features/dashboard/presentation/widgets/nearest_shops_toggle.dart';
import 'package:bazar/features/dashboard/presentation/widgets/public_shop_card.dart';
import 'package:bazar/features/dashboard/presentation/widgets/shop_filter_sheet.dart';
import 'package:bazar/features/favourite/presentation/view_model/favourite_view_model.dart';
import 'package:bazar/features/savedShop/presentation/view_model/saved_shop_view_model.dart';
import 'package:bazar/features/sensor/presentation/state/sensor_state.dart';
import 'package:bazar/features/sensor/presentation/view_model/sensor_view_model.dart';
import 'package:bazar/features/shop/domain/entities/shop_entity.dart';
import 'package:bazar/features/shop/presentation/pages/shop_public_detail_page.dart';
import 'package:bazar/features/shop/presentation/state/shop_state.dart';
import 'package:bazar/features/shop/presentation/view_model/shop_view_model.dart';
import 'package:bazar/features/shopReview/presentation/view_model/user_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<CategoryEntity> _categories = const [];
  bool _isLoadingCategories = false;
  ShopFilters _filters = const ShopFilters();
  DateTime? _lastShakeRefreshAt;
  SensorViewModel? _sensorViewModel;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(() {
      ref.read(shopViewModelProvider.notifier).loadPublicShops();
      ref.read(savedShopViewModelProvider.notifier).loadSavedShops();
      ref.read(favouriteViewModelProvider.notifier).loadFavourites();
      ref.read(userReviewViewModelProvider.notifier).loadReviewedShops();
      _sensorViewModel = ref.read(sensorViewModelProvider.notifier);
      _sensorViewModel?.attach();
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _scrollCtrl
      ..removeListener(_onScroll)
      ..dispose();
    _searchCtrl.dispose();
    Future.microtask(() => _sensorViewModel?.detach());
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      ref.read(shopViewModelProvider.notifier).loadMorePublicShops();
    }
  }

  Future<void> _refreshFeeds({bool forceRefresh = true}) async {
    await Future.wait([
      ref
          .read(shopViewModelProvider.notifier)
          .loadPublicShops(forceRefresh: forceRefresh),
      ref
          .read(savedShopViewModelProvider.notifier)
          .loadSavedShops(forceRefresh: forceRefresh),
      ref
          .read(favouriteViewModelProvider.notifier)
          .loadFavourites(forceRefresh: forceRefresh),
      ref
          .read(userReviewViewModelProvider.notifier)
          .loadReviewedShops(forceRefresh: forceRefresh),
    ]);
  }

  Future<void> _onShakeDetected() async {
    final now = DateTime.now();
    if (_lastShakeRefreshAt != null &&
        now.difference(_lastShakeRefreshAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastShakeRefreshAt = now;
    await _refreshFeeds();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    final result = await ref.read(getAllCategoryUseCaseProvider)();
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _categories = const [];
        _isLoadingCategories = false;
      }),
      (items) => setState(() {
        _categories = items;
        _isLoadingCategories = false;
      }),
    );
  }

  Future<void> _openFilters() async {
    final applied = await ShopFilterSheet.show(
      context,
      initialFilters: _filters,
      categories: _categories,
    );
    if (applied != null) {
      setState(() => _filters = applied);
      // Update selected category in shop view model
      final categoryName = applied.categoryName;
      if (categoryName != null && categoryName.isNotEmpty) {
        final category = _categories.firstWhere(
          (c) => c.categoryName == categoryName,
          orElse: () => _categories.first,
        );
        ref.read(shopViewModelProvider.notifier).setSelectedCategory(
          category.categoryId,
        );
      } else {
        ref.read(shopViewModelProvider.notifier).setSelectedCategory(null);
      }
    }
  }

  bool _matchesCategoryAndLocation(ShopEntity shop) {
    final category = (_filters.categoryName ?? '').trim().toLowerCase();
    final location = _filters.locationQuery.trim().toLowerCase();
    final description = (shop.description ?? '').toLowerCase();
    final haystack =
        '${shop.shopName} ${shop.shopAddress} $description'.toLowerCase();
    final categoryFromField =
        shop.categoryNames.map((e) => e.toLowerCase()).toList();
    final matchesCategory =
        category.isEmpty ||
        categoryFromField.any((name) => name.contains(category)) ||
        haystack.contains(category);
    final matchesLocation =
        location.isEmpty || shop.shopAddress.toLowerCase().contains(location);
    return matchesCategory && matchesLocation;
  }

  bool _matchesPrice(ShopEntity shop) {
    if (_filters.priceFilter == PriceFilter.any) return true;
    final price = (shop.priceRange ?? '').trim().toLowerCase();
    if (price.isNotEmpty) {
      switch (_filters.priceFilter) {
        case PriceFilter.budget:
          return price.contains('budget') ||
              price.contains('low') ||
              price.contains('cheap') ||
              price.contains(r'$');
        case PriceFilter.mid:
          return price.contains('mid') ||
              price.contains('standard') ||
              price.contains('moderate') ||
              price.contains(r'$$');
        case PriceFilter.premium:
          return price.contains('premium') ||
              price.contains('high') ||
              price.contains('luxury') ||
              price.contains(r'$$$');
        case PriceFilter.any:
          return true;
      }
    }
    final text =
        '${shop.shopName} ${shop.description ?? ''} ${shop.shopAddress}'
            .toLowerCase();
    final isBudget =
        ['budget', 'cheap', 'affordable', 'low cost'].any(text.contains);
    final isPremium =
        ['premium', 'luxury', 'exclusive', 'high-end'].any(text.contains);
    final isMid = ['mid', 'standard', 'moderate'].any(text.contains);
    switch (_filters.priceFilter) {
      case PriceFilter.budget:
        return isBudget;
      case PriceFilter.mid:
        return isMid || (!isBudget && !isPremium);
      case PriceFilter.premium:
        return isPremium;
      case PriceFilter.any:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SensorState>(sensorViewModelProvider, (previous, next) {
      final previousCount = previous?.shakeCount ?? 0;
      if (next.shakeCount > previousCount) _onShakeDetected();
    });

    // Listen to shop state errors for toast notifications
    ref.listen<ShopState>(shopViewModelProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    final shopState = ref.watch(shopViewModelProvider);
    final shopViewModel = ref.read(shopViewModelProvider.notifier);
    final savedState = ref.watch(savedShopViewModelProvider);
    final favouriteState = ref.watch(favouriteViewModelProvider);
    final userReviewState = ref.watch(userReviewViewModelProvider);

    final reviewedIds = {
      ...userReviewState.reviewedShopIds,
      ...favouriteState.reviewedShopIds,
    };

    final query = _searchCtrl.text.trim().toLowerCase();
    // Use displayedShops which automatically switches between all shops and nearest shops
    final baseShops = shopState.displayedShops;
    final filtered = baseShops.where((shop) {
      final queryMatch =
          query.isEmpty ||
          shop.shopName.toLowerCase().contains(query) ||
          shop.shopAddress.toLowerCase().contains(query) ||
          shop.shopContact.toLowerCase().contains(query);
      return queryMatch &&
          _matchesCategoryAndLocation(shop) &&
          _matchesPrice(shop);
    }).toList();

    final isLoadingInitial =
        shopState.isLoadingPublic && !shopState.hasLoadedPublic;

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: _refreshFeeds,
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: HomeTopBanner(
                  searchCtrl: _searchCtrl,
                  activeFilterCount: _filters.activeCount,
                  loadingCategories: _isLoadingCategories,
                  onQueryChanged: () => setState(() {}),
                  onClear: () => setState(() => _searchCtrl.clear()),
                  onOpenFilters: _openFilters,
                ),
              ),
            ),
            // Nearest Shops Toggle
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: NearestShopsToggle(
                  isEnabled: shopState.showNearestOnly,
                  isLoading: shopState.isLoadingNearest,
                  categorySelected: shopState.selectedCategoryId != null,
                  onToggle: (enabled) async {
                    if (enabled && shopState.selectedCategoryId == null) {
                      SnackbarUtils.showWarning(
                        context,
                        'Please select a category from filters first',
                      );
                      return;
                    }

                    if (enabled) {
                      SnackbarUtils.showInfo(
                        context,
                        'Fetching your location...',
                      );
                      await shopViewModel.toggleNearestFilter(enable: true);

                      final state = ref.read(shopViewModelProvider);
                      if (state.showNearestOnly && mounted) {
                        final count = state.nearestShops.length;
                        SnackbarUtils.showSuccess(
                          context,
                          'Found $count shop${count != 1 ? "s" : ""} nearby',
                        );
                      }
                    } else {
                      await shopViewModel.toggleNearestFilter(enable: false);
                    }
                  },
                ),
              ),
            ),
            if (isLoadingInitial)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: 6,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ShopSkeletonCard(),
                  ),
                ),
              )
            else if ((shopState.errorMessage ?? '').isNotEmpty &&
                !shopState.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: HomeStatusCard(
                    message: shopState.errorMessage!,
                    isError: true,
                  ),
                ),
              )
            else if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                  child: HomeEmptyState(
                    query: query,
                    onClear: () => setState(() => _searchCtrl.clear()),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                sliver: SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final shop = filtered[index];
                    final previewAsync = ref.watch(
                      shopCardPreviewProvider(shop),
                    );
                    final ratingPass = _filters.minRating <= 0
                        ? true
                        : previewAsync.maybeWhen(
                            data: (value) =>
                                value.averageRating >= _filters.minRating,
                            orElse: () => true,
                          );
                    if (!ratingPass) return const SizedBox.shrink();
                    
                    // Calculate distance if location is available
                    final distance = shopViewModel.calculateDistance(shop);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PublicShopCard(
                        shop: shop,
                        distanceInKm: distance,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShopPublicDetailPage(shop: shop),
                          ),
                        ),
                        isSaved: savedState.savedShopIds
                            .contains(shop.shopId ?? ''),
                        isFavourite: favouriteState.favouriteShopIds
                            .contains(shop.shopId ?? ''),
                        isReviewed: reviewedIds.contains(shop.shopId ?? ''),
                        isSaveBusy: savedState.processingShopIds
                            .contains(shop.shopId ?? ''),
                        isFavouriteBusy: favouriteState.processingShopIds
                            .contains(shop.shopId ?? ''),
                        onToggleSave: () {
                          final shopId = shop.shopId ?? '';
                          if (shopId.isEmpty) return;
                          ref
                              .read(savedShopViewModelProvider.notifier)
                              .toggleSaved(shopId);
                        },
                        onToggleFavourite: () {
                          final shopId = shop.shopId ?? '';
                          if (shopId.isEmpty) return;
                          ref
                              .read(favouriteViewModelProvider.notifier)
                              .toggleFavourite(
                                shopId: shopId,
                                isReviewed:
                                    reviewedIds.contains(shopId) ? true : null,
                              );
                        },
                      ),
                    );
                  },
                ),
              ),

            // Load-more indicator
            SliverToBoxAdapter(
              child: shopState.isLoadingMore
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                  : (!shopState.hasMore && shopState.publicShops.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          child: Center(
                            child: Text(
                              "You've seen all shops",
                              style: AppTextStyle.minimalTexts.copyWith(
                                fontSize: 12,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(height: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
