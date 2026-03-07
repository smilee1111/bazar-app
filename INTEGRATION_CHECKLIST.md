# 🚀 Integration Checklist - Nearest Shops Filter

Use this checklist to integrate the nearest shops filter into your app.

## Prerequisites
- [x] Implementation complete (all files created)
- [ ] Android permissions added to AndroidManifest.xml
- [ ] iOS permissions added to Info.plist
- [ ] Tested on physical device or emulator with location

## Step-by-Step Integration

### Phase 1: Permissions Setup (5 minutes)

#### Android
- [ ] Open `android/app/src/main/AndroidManifest.xml`
- [ ] Add inside `<manifest>` tag:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS
- [ ] Open `ios/Runner/Info.plist`
- [ ] Add before `</dict>`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find shops near you</string>
```

### Phase 2: UI Integration (15 minutes)

#### Find Your Shops Listing Page
- [ ] Locate the file (probably in `lib/features/dashboard/presentation/pages/`)
- [ ] Import required widgets:
```dart
import 'package:bazar/features/dashboard/presentation/widgets/nearest_shops_toggle.dart';
import 'package:bazar/features/shop/presentation/state/shop_state.dart';
import 'package:bazar/features/shop/presentation/view_model/shop_view_model.dart';
import 'package:bazar/core/utils/snackbar_utils.dart';
```

#### Add Category State (if not already present)
- [ ] Add state variable:
```dart
String? _selectedCategoryId;
```

#### Add Category Dropdown (if not already present)
- [ ] Add category selection widget
- [ ] Call on change:
```dart
ref.read(shopViewModelProvider.notifier).setSelectedCategory(categoryId);
```

#### Add Nearest Shops Toggle
- [ ] Add below category dropdown:
```dart
final shopState = ref.watch(shopViewModelProvider);

NearestShopsToggle(
  isEnabled: shopState.showNearestOnly,
  isLoading: shopState.isLoadingNearest,
  categorySelected: _selectedCategoryId != null,
  onToggle: (enabled) async {
    if (enabled && _selectedCategoryId == null) {
      SnackbarUtils.showWarning(context, 'Please select a category first');
      return;
    }
    
    final viewModel = ref.read(shopViewModelProvider.notifier);
    if (enabled) {
      SnackbarUtils.showInfo(context, 'Fetching your location...');
      await viewModel.toggleNearestFilter(enable: true);
      
      final state = ref.read(shopViewModelProvider);
      if (state.showNearestOnly) {
        SnackbarUtils.showSuccess(
          context, 
          'Found ${state.nearestShops.length} shops nearby',
        );
      }
    } else {
      await viewModel.toggleNearestFilter(enable: false);
    }
  },
)
```

#### Update Shop List Display
- [ ] Replace your shop list source with:
```dart
final shops = shopState.displayedShops; // Instead of shopState.publicShops
```

#### Add Distance to Shop Cards
- [ ] Find where PublicShopCard is used
- [ ] Add distance calculation:
```dart
final shopViewModel = ref.read(shopViewModelProvider.notifier);
final distance = shopViewModel.calculateDistance(shop);

PublicShopCard(
  shop: shop,
  distanceInKm: distance, // Add this parameter
  // ... other existing parameters
)
```

#### Add Error Listener (Optional but Recommended)
- [ ] Add in build method:
```dart
ref.listen<ShopState>(shopViewModelProvider, (previous, next) {
  if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
    SnackbarUtils.showError(context, next.errorMessage!);
  }
});
```

### Phase 3: Testing (15 minutes)

#### Basic Functionality
- [ ] Run app: `flutter run`
- [ ] Navigate to shops page
- [ ] Verify category dropdown is present
- [ ] Verify toggle is disabled without category
- [ ] Select a category
- [ ] Verify toggle becomes enabled

#### Location Permission Flow
- [ ] Enable toggle
- [ ] Verify loading spinner shows
- [ ] Verify location permission dialog appears
- [ ] Tap "Allow"
- [ ] Verify loading stops
- [ ] Verify success toast appears
- [ ] Verify shops are displayed

#### Distance Display
- [ ] Check shop cards show distance badges
- [ ] Verify distance format (m for < 1km, km for >= 1km)
- [ ] Verify badge styling matches design

#### Toggle Off
- [ ] Disable toggle
- [ ] Verify shops list switches back to all shops
- [ ] Verify distance badges remain visible (if location was fetched)

#### Edge Cases
- [ ] Toggle on without category (should show warning)
- [ ] Deny location permission (should show error)
- [ ] Disable location service (should show error)
- [ ] Select category with no nearby shops (should show empty state)
- [ ] Switch categories while filter is on (should refetch)

### Phase 4: Production Readiness (10 minutes)

#### Code Review
- [ ] Remove any console.log or print statements
- [ ] Verify all error cases are handled
- [ ] Check loading states are shown appropriately
- [ ] Verify toast messages are user-friendly

#### Performance Check
- [ ] Location fetch is reasonably fast (< 5 seconds)
- [ ] API call completes within 3 seconds
- [ ] UI remains responsive during loading
- [ ] No memory leaks or re-renders

#### User Experience
- [ ] Category selection is intuitive
- [ ] Toggle behavior is clear
- [ ] Error messages are helpful
- [ ] Empty states provide guidance
- [ ] Distance information is accurate

## Troubleshooting

### Toggle doesn't enable
**Check:**
- [ ] Category is selected and not null
- [ ] `categorySelected` prop is correctly passed
- [ ] State is updating correctly

### Location not working
**Check:**
- [ ] Permissions added to manifest/plist
- [ ] Location services enabled on device
- [ ] Using physical device or emulator with location set
- [ ] Check logs for specific errors

### Distance not displaying
**Check:**
- [ ] Shop has location data in response
- [ ] `distanceInKm` prop passed to PublicShopCard
- [ ] Location was successfully fetched
- [ ] Distance badge import is correct

### API errors
**Check:**
- [ ] Backend endpoint is correct: `/api/public/shops/nearest`
- [ ] Backend is running and accessible
- [ ] Query parameters are correct format
- [ ] Check network logs in dev tools

## Additional Resources

- **Full Documentation**: `NEAREST_SHOPS_IMPLEMENTATION.md`
- **Quick Reference**: `NEAREST_SHOPS_QUICK_REFERENCE.md`
- **Example Implementation**: `lib/features/dashboard/presentation/examples/nearest_shops_integration_example.dart`
- **Implementation Summary**: `IMPLEMENTATION_SUMMARY.md`

## Support

If you encounter issues:
1. Check the example file for reference implementation
2. Review error messages in Flutter logs
3. Verify backend API is returning correct data format
4. Test location permissions in device settings

---

## ✅ Sign-Off

Once all checkboxes are complete, the feature is ready for production! 🎉

**Completed by:** _______________
**Date:** _______________
**Tested on:** [ ] Android  [ ] iOS  [ ] Both
**Build version:** _______________
