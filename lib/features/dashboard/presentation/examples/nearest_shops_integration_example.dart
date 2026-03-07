/// Example implementation for nearest shops filter feature
/// This file demonstrates how to integrate the nearest shops functionality
/// into your shop listing pages.

import 'package:bazar/core/utils/snackbar_utils.dart';
import 'package:bazar/features/category/domain/entities/category_entity.dart';
import 'package:bazar/features/dashboard/presentation/widgets/nearest_shops_toggle.dart';
import 'package:bazar/features/dashboard/presentation/widgets/public_shop_card.dart';
import 'package:bazar/features/shop/presentation/state/shop_state.dart';
import 'package:bazar/features/shop/presentation/view_model/shop_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Example: Shops listing page with nearest shops filter
class ShopsListingExample extends ConsumerStatefulWidget {
  const ShopsListingExample({super.key});

  @override
  ConsumerState<ShopsListingExample> createState() =>
      _ShopsListingExampleState();
}

class _ShopsListingExampleState extends ConsumerState<ShopsListingExample> {
  String? _selectedCategoryId;
  List<CategoryEntity> _categories = []; // Load from category provider

  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopViewModelProvider);
    final shopViewModel = ref.read(shopViewModelProvider.notifier);

    // Listen to state changes for error notifications
    ref.listen<ShopState>(shopViewModelProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shops'),
      ),
      body: Column(
        children: [
          // Category dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String?>(
              value: _selectedCategoryId,
              hint: const Text('Select category'),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.categoryId,
                      child: Text(category.categoryName),
                    ),
                  )
                  .toList(),
              onChanged: (categoryId) {
                setState(() => _selectedCategoryId = categoryId);
                shopViewModel.setSelectedCategory(categoryId);
                
                // If nearest filter is on, reload nearest shops
                if (shopState.showNearestOnly && categoryId != null) {
                  _loadNearestShops(shopViewModel, context);
                }
              },
            ),
          ),

          // Nearest shops toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: NearestShopsToggle(
              isEnabled: shopState.showNearestOnly,
              isLoading: shopState.isLoadingNearest,
              categorySelected: _selectedCategoryId != null,
              onToggle: (enabled) async {
                if (enabled) {
                  if (_selectedCategoryId == null) {
                    SnackbarUtils.showWarning(
                      context,
                      'Please select a category first',
                    );
                    return;
                  }

                  // Show info toast
                  SnackbarUtils.showInfo(context, 'Fetching your location...');

                  // Toggle the filter (will trigger location fetch)
                  await shopViewModel.toggleNearestFilter(enable: true);

                  final state = ref.read(shopViewModelProvider);
                  if (state.showNearestOnly) {
                    final count = state.nearestShops.length;
                    SnackbarUtils.showSuccess(
                      context,
                      'Found $count shops nearby',
                    );
                  }
                } else {
                  // Turn off filter
                  await shopViewModel.toggleNearestFilter(enable: false);
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          // Shop list
          Expanded(
            child: _buildShopList(shopState, shopViewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildShopList(ShopState state, ShopViewModel viewModel) {
    // Show loading indicator
    if (state.isLoadingPublic || state.isLoadingNearest) {
      return const Center(child: CircularProgressIndicator());
    }

    // Get shops based on filter state
    final shops = state.displayedShops; // Uses showNearestOnly internally

    // Show empty state
    if (shops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              state.showNearestOnly
                  ? 'No shops found nearby'
                  : 'No shops available',
              style: const TextStyle(fontSize: 16),
            ),
            if (state.showNearestOnly)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Text(
                  'Try increasing search radius or selecting a different category',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      );
    }

    // Show shop list
    return RefreshIndicator(
      onRefresh: () async {
        if (state.showNearestOnly) {
          await viewModel.loadNearestShops();
        } else {
          await viewModel.loadPublicShops(forceRefresh: true);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];
          
          // Calculate distance if location is available
          final distance = viewModel.calculateDistance(shop);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PublicShopCard(
              shop: shop,
              distanceInKm: distance, // Show distance badge
              onTap: () {
                // Navigate to shop details
              },
              onToggleSave: () {
                // Handle save/unsave
              },
              onToggleFavourite: () {
                // Handle favourite toggle
              },
              isSaved: false, // Load from saved shops state
              isFavourite: false, // Load from favourites state
              isReviewed: false, // Check if user reviewed
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadNearestShops(
    ShopViewModel viewModel,
    BuildContext context,
  ) async {
    SnackbarUtils.showInfo(context, 'Fetching nearby shops...');
    await viewModel.loadNearestShops();
    
    final state = ref.read(shopViewModelProvider);
    if (!mounted) return;
    
    if (state.nearestShops.isNotEmpty) {
      SnackbarUtils.showSuccess(
        context,
        'Found ${state.nearestShops.length} shops nearby',
      );
    } else if (state.errorMessage == null) {
      SnackbarUtils.showWarning(
        context,
        'No shops found nearby',
      );
    }
  }
}

/// INTEGRATION STEPS:
/// 
/// 1. Add category dropdown to allow user to select a category
///    - Use CategoryEntity from category feature
///    - Call shopViewModel.setSelectedCategory(categoryId)
/// 
/// 2. Add NearestShopsToggle widget below category selector
///    - Pass isEnabled from shopState.showNearestOnly
///    - Pass isLoading from shopState.isLoadingNearest
///    - Pass categorySelected = selectedCategoryId != null
///    - Handle onToggle to call shopViewModel.toggleNearestFilter()
/// 
/// 3. Update shop cards to display distance
///    - Get distance via shopViewModel.calculateDistance(shop)
///    - Pass distanceInKm to PublicShopCard
/// 
/// 4. Use shopState.displayedShops to get current shop list
///    - Automatically returns nearestShops when filter is on
///    - Returns publicShops when filter is off
/// 
/// 5. Add user feedback with SnackbarUtils
///    - "Fetching your location..." (info)
///    - "Found X shops nearby" (success)
///    - "No shops found nearby" (warning)
///    - Error messages from state (error)
/// 
/// 6. Handle edge cases:
///    - Category not selected: Show warning, don't enable filter
///    - Location denied: Error message shown automatically
///    - No shops nearby: Show empty state with helpful message
///    - Network error: Error message shown automatically
/// 
/// 7. Add refresh functionality
///    - Call loadNearestShops() when filter is on
///    - Call loadPublicShops() when filter is off
/// 
/// 8. Empty state handling
///    - Different messages for filtered vs unfiltered view
///    - Suggest actions for empty filtered results

