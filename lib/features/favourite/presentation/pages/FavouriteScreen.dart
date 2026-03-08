import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/features/dashboard/presentation/widgets/public_shop_card.dart';
import 'package:bazar/features/favourite/presentation/view_model/favourite_view_model.dart';
import 'package:bazar/features/savedShop/presentation/view_model/saved_shop_view_model.dart';
import 'package:bazar/features/shop/presentation/pages/shop_public_detail_page.dart';
import 'package:bazar/features/shop/presentation/view_model/shop_view_model.dart';
import 'package:bazar/features/shopReview/presentation/view_model/user_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Favouritescreen extends ConsumerStatefulWidget {
  const Favouritescreen({super.key});

  @override
  ConsumerState<Favouritescreen> createState() => _FavouritescreenState();
}

class _FavouritescreenState extends ConsumerState<Favouritescreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Future.wait([
        ref.read(shopViewModelProvider.notifier).loadPublicShops(),
        ref.read(savedShopViewModelProvider.notifier).loadSavedShops(),
        ref.read(favouriteViewModelProvider.notifier).loadFavourites(),
        ref.read(userReviewViewModelProvider.notifier).loadReviewedShops(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shopState = ref.watch(shopViewModelProvider);
    final savedState = ref.watch(savedShopViewModelProvider);
    final favouriteState = ref.watch(favouriteViewModelProvider);
    final userReviewState = ref.watch(userReviewViewModelProvider);

    final favouriteIds = favouriteState.favouriteShopIds;
    final reviewedIds = {
      ...userReviewState.reviewedShopIds,
      ...favouriteState.reviewedShopIds,
    };

    final shops = shopState.publicShops
        .where((shop) => favouriteIds.contains(shop.shopId ?? ''))
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref
              .read(shopViewModelProvider.notifier)
              .loadPublicShops(forceRefresh: true),
          ref
              .read(savedShopViewModelProvider.notifier)
              .loadSavedShops(forceRefresh: true),
          ref
              .read(favouriteViewModelProvider.notifier)
              .loadFavourites(forceRefresh: true),
          ref
              .read(userReviewViewModelProvider.notifier)
              .loadReviewedShops(forceRefresh: true),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Text(
            'Favourites',
            style: AppTextStyle.inputBox.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Shops you liked and shops auto-favourited after review.',
            style: AppTextStyle.minimalTexts.copyWith(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 12),
          if (favouriteState.isLoading && favouriteState.favourites.isEmpty)
            const LinearProgressIndicator(minHeight: 2),
          if (shops.isEmpty && !favouriteState.isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Center(
                child: Text(
                  'No favourites yet.',
                  style: AppTextStyle.minimalTexts.copyWith(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.74),
                  ),
                ),
              ),
            ),
          ...shops.map(
            (shop) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PublicShopCard(
                shop: shop,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShopPublicDetailPage(shop: shop),
                    ),
                  );
                },
                isSaved: savedState.savedShopIds.contains(shop.shopId ?? ''),
                isFavourite: true,
                isReviewed: reviewedIds.contains(shop.shopId ?? ''),
                isSaveBusy: savedState.processingShopIds.contains(
                  shop.shopId ?? '',
                ),
                isFavouriteBusy: favouriteState.processingShopIds.contains(
                  shop.shopId ?? '',
                ),
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
                        isReviewed: reviewedIds.contains(shopId) ? true : null,
                      );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
