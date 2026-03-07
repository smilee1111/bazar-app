# Nearest Shops Filter Feature - Implementation Guide

This document provides a comprehensive guide for the nearest shops filter feature in the Flutter Bazar app.

## Overview

The nearest shops filter allows users to find shops near their current location within a selected category. The feature uses geolocation services, integrates with the backend API, and provides a seamless user experience with proper error handling and feedback.

## Architecture

### Feature Components

1. **Backend API Integration**
   - Endpoint: `GET /api/public/shops/nearest`
   - Query Parameters: `categoryId`, `lat`, `lng`, `limit`

2. **Data Layer**
   - `ShopRemoteDataSource`: Added `getNearestShops()` method
   - `ShopRepository`: Added `getNearestShops()` method

3. **Domain Layer**
   - `GetNearestShopsUsecase`: Business logic for fetching nearest shops
   - `NearestShopsParams`: Parameters model for the usecase

4. **Presentation Layer**
   - `ShopState`: Extended with nearest shops fields
   - `ShopViewModel`: Added location management and toggle logic
   - `NearestShopsToggle`: UI widget for the filter toggle
   - `ShopDistanceBadge`: UI widget to display distance

5. **Services**
   - `GeolocationProvider`: Manages user location state
   - `LocationService`: Wraps geolocator functionality

## Key Files Added/Modified

### New Files
- `lib/core/services/location/geolocation_provider.dart` - Geolocation state management
- `lib/features/shop/domain/usecases/get_nearest_shops_usecase.dart` - Nearest shops usecase
- `lib/features/dashboard/presentation/widgets/nearest_shops_toggle.dart` - Toggle widget
- `lib/features/dashboard/presentation/widgets/shop_distance_badge.dart` - Distance badge widget
- `lib/features/dashboard/presentation/examples/nearest_shops_integration_example.dart` - Integration example

### Modified Files
- `lib/core/api/api_endpoints.dart` - Added nearest shops endpoint
- `lib/features/shop/data/datasources/shop_remote_datasource.dart` - Added API call
- `lib/features/shop/data/repositories/shop_repository.dart` - Added repository method
- `lib/features/shop/domain/repositories/shop_repository.dart` - Added interface method
- `lib/features/shop/presentation/state/shop_state.dart` - Added nearest shops state
- `lib/features/shop/presentation/view_model/shop_view_model.dart` - Added location logic
- `lib/features/dashboard/presentation/widgets/public_shop_card.dart` - Added distance display

## Usage Guide

### Step 1: Category Selection

Users must select a category before enabling the nearest shops filter:

```dart
// In your shops page
String? selectedCategoryId;

DropdownButtonFormField<String?>(
  value: selectedCategoryId,
  items: categories.map((cat) => DropdownMenuItem(
    value: cat.categoryId,
    child: Text(cat.categoryName),
  )).toList(),
  onChanged: (categoryId) {
    setState(() => selectedCategoryId = categoryId);
    ref.read(shopViewModelProvider.notifier)
        .setSelectedCategory(categoryId);
  },
);
```

### Step 2: Add Nearest Shops Toggle

Add the toggle widget below the category selector:

```dart
final shopState = ref.watch(shopViewModelProvider);

NearestShopsToggle(
  isEnabled: shopState.showNearestOnly,
  isLoading: shopState.isLoadingNearest,
  categorySelected: selectedCategoryId != null,
  onToggle: (enabled) async {
    if (enabled && selectedCategoryId == null) {
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
);
```

### Step 3: Display Shop List with Distance

Use `displayedShops` to get the correct shop list:

```dart
final shopState = ref.watch(shopViewModelProvider);
final shopViewModel = ref.read(shopViewModelProvider.notifier);
final shops = shopState.displayedShops; // Auto-switches based on filter

ListView.builder(
  itemCount: shops.length,
  itemBuilder: (context, index) {
    final shop = shops[index];
    final distance = shopViewModel.calculateDistance(shop);

    return PublicShopCard(
      shop: shop,
      distanceInKm: distance, // Shows distance badge
      onTap: () => navigateToShopDetail(shop),
      // ... other properties
    );
  },
);
```

## State Management

### ShopState Fields

```dart
class ShopState {
  // Nearest shops filter
  final bool showNearestOnly;           // Filter toggle state
  final bool isLoadingNearest;          // Loading indicator
  final List<ShopEntity> nearestShops;  // Filtered shops
  final String? selectedCategoryId;     // Selected category
  final double? userLatitude;           // User location
  final double? userLongitude;          // User location

  // Helper getter
  List<ShopEntity> get displayedShops => 
      showNearestOnly ? nearestShops : publicShops;
}
```

### View Model Methods

```dart
// Set selected category
shopViewModel.setSelectedCategory(categoryId);

// Toggle nearest filter (with location fetch)
await shopViewModel.toggleNearestFilter(enable: true);

// Manually load nearest shops
await shopViewModel.loadNearestShops();

// Calculate distance to a shop
final distance = shopViewModel.calculateDistance(shop);
```

## Location Permissions

### Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS Configuration

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find shops near you</string>
```

## Error Handling

The implementation handles all common error scenarios:

### 1. Category Not Selected
```dart
// Shows warning: "Please select a category first"
// Filter toggle remains disabled
```

### 2. Location Permission Denied
```dart
// Shows error: "Location permission denied"
// Filter is turned off automatically
// User can try again or enable in settings
```

### 3. Location Service Disabled
```dart
// Shows error: "Location service is disabled. Please enable it in settings."
// Filter is turned off
```

### 4. No Shops Found
```dart
// Shows empty state with message
// Suggests selecting different category or checking radius
```

### 5. Network Error
```dart
// Shows error from backend/network
// Filter state preserved, can retry
```

## User Feedback

All user actions provide immediate feedback:

```dart
// Info: Starting location fetch
SnackbarUtils.showInfo(context, 'Fetching your location...');

// Success: Shops found
SnackbarUtils.showSuccess(context, 'Found 5 shops nearby');

// Warning: Minor issues
SnackbarUtils.showWarning(context, 'No shops found nearby');

// Error: Critical failures
SnackbarUtils.showError(context, error.message);
```

## Testing Checklist

- [ ] Category selection works correctly
- [ ] Toggle requires category to be selected
- [ ] Location permission request flow works
- [ ] "Allow" permission shows nearby shops
- [ ] "Deny" permission shows error and disables filter
- [ ] Location service disabled is handled
- [ ] Distance badges display correctly (m vs km)
- [ ] Distance calculation is accurate
- [ ] Empty state shows when no shops nearby
- [ ] Network errors are handled gracefully
- [ ] Switch between filtered and unfiltered views works
- [ ] Refresh works for both modes
- [ ] Location updates when user moves (optional)
- [ ] Performance is acceptable (location + API call)

## Performance Considerations

### Location Caching
User location is stored in `ShopState` to avoid repeated requests:
```dart
final userLatitude = state.userLatitude;
final userLongitude = state.userLongitude;
```

### Distance Calculation
Distance is calculated on-demand in the view model:
```dart
final distance = shopViewModel.calculateDistance(shop);
```

### Optimizations
- Location is only fetched when filter is enabled
- Category selection is required before location request
- API limit parameter controls number of shops (default: 10)
- Use `displayedShops` getter to avoid conditional logic

## API Response Format

Expected response from backend:

```json
[
  {
    "_id": "shop_id",
    "shopId": "shop_id",
    "name": "Shop Name",
    "categoryId": "category_id",
    "location": {
      "type": "Point",
      "coordinates": [lng, lat]
    },
    "photos": [...],
    "reviews": [...],
    "details": {...},
    "category": {
      "name": "Category Name"
    },
    "avgRating": 4.5,
    "reviewCount": 10
  }
]
```

## Future Enhancements

1. **Adjustable Radius**: Allow users to set max distance (5km, 10km, 20km)
2. **Live Location Updates**: Re-fetch when user moves 100m+
3. **Map View**: Show nearest shops on a map
4. **Smart Sorting**: Sort by distance, rating, or combination
5. **Location History**: Remember user's home/work locations
6. **Offline Support**: Cache last known location
7. **Distance Filters**: Filter by specific distance ranges

## Troubleshooting

### Location not working on emulator
- Android Emulator: Set location in Extended Controls
- iOS Simulator: Features > Location > Custom Location

### Permission always denied
- Check AndroidManifest.xml permissions
- Check Info.plist usage descriptions
- Clear app data and reinstall

### Distance calculation incorrect
- Verify GeoPoint coordinates are (longitude, latitude) from backend
- Check Distance package configuration
- Ensure coordinates are in correct order

### Toggle doesn't enable
- Verify category is selected first
- Check state.selectedCategoryId is not null
- Look for error messages in logs

## Support

For questions or issues:
1. Check the example file: `nearest_shops_integration_example.dart`
2. Review error logs for specific error messages
3. Test location permissions in device settings
4. Verify backend API is returning correct data format
