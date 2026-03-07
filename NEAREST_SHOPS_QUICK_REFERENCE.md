# Nearest Shops Feature - Quick Reference

## Quick Start

### 1. Add to your shop listing page

```dart
import 'package:bazar/features/dashboard/presentation/widgets/nearest_shops_toggle.dart';
import 'package:bazar/features/dashboard/presentation/widgets/shop_distance_badge.dart';

// Add category dropdown
String? selectedCategoryId;

// Add toggle under category dropdown
final shopState = ref.watch(shopViewModelProvider);
final shopViewModel = ref.read(shopViewModelProvider.notifier);

NearestShopsToggle(
  isEnabled: shopState.showNearestOnly,
  isLoading: shopState.isLoadingNearest,
  categorySelected: selectedCategoryId != null,
  onToggle: (enabled) async {
    if (enabled) {
      await shopViewModel.toggleNearestFilter(enable: true);
    } else {
      await shopViewModel.toggleNearestFilter(enable: false);
    }
  },
)

// Display shops with distance
final shops = shopState.displayedShops; // Auto-filtered

PublicShopCard(
  shop: shop,
  distanceInKm: shopViewModel.calculateDistance(shop),
  // ... other props
)
```

## API Endpoint

**Backend:** `GET /api/public/shops/nearest`

**Query Parameters:**
- `categoryId` (required): Category ID string
- `lat` (required): Latitude number
- `lng` (required): Longitude number
- `limit` (optional): Max shops (default: 10)

**Flutter:** `ApiEndpoints.publicNearestShopsWithParams()`

## State Management

### Get Current State
```dart
final shopState = ref.watch(shopViewModelProvider);
final isFilterOn = shopState.showNearestOnly;
final shops = shopState.displayedShops; // Switches automatically
```

### View Model Methods
```dart
final viewModel = ref.read(shopViewModelProvider.notifier);

// Set category (required before enabling filter)
viewModel.setSelectedCategory(categoryId);

// Toggle filter on/off
await viewModel.toggleNearestFilter(enable: true);

// Calculate distance to shop
final distanceKm = viewModel.calculateDistance(shop);
```

## UI Components

### NearestShopsToggle
Toggle widget with location icon and loading state
- Auto-disables if no category selected
- Shows loading spinner during location fetch
- Updates state automatically

### ShopDistanceBadge
Distance badge for shop cards
- Formats as "500 m" or "2.5 km"
- Primary color styling
- Auto-hides if distance is null

## Permissions Required

### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find shops near you</string>
```

## User Flow

1. User selects category → `setSelectedCategory()`
2. User enables filter → `toggleNearestFilter(enable: true)`
3. App requests location permission → User allows/denies
4. If allowed → Fetch location → Call API → Display shops with distance
5. If denied → Show error → Disable filter
6. User can toggle off → Shows all shops in category

## Error Handling

| Error | Behavior |
|-------|----------|
| No category selected | Warning toast, toggle disabled |
| Location denied | Error toast, filter disabled |
| Location service off | Error toast, filter disabled |
| No shops found | Empty state with message |
| Network error | Error toast, can retry |

## Toast Messages

```dart
// Location fetching
SnackbarUtils.showInfo(context, 'Fetching your location...');

// Success
SnackbarUtils.showSuccess(context, 'Found 5 shops nearby');

// Warning
SnackbarUtils.showWarning(context, 'Please select a category first');

// Error
SnackbarUtils.showError(context, error.message);
```

## Distance Display

```dart
// In shop card
ShopDistanceBadge(distanceInKm: 2.5) → "2.5 km"
ShopDistanceBadge(distanceInKm: 0.5) → "500 m"
ShopDistanceBadge(distanceInKm: null) → (hidden)
```

## Common Issues

**Toggle doesn't enable**
- Ensure category is selected first
- Check `categorySelected` prop is true

**Distance not showing**
- Check shop has location data
- Verify location permission granted
- Ensure filter was enabled successfully

**Permission always denied**
- Check manifest/plist permissions
- Try reinstalling app
- Check device location settings

## Files Reference

| Component | File |
|-----------|------|
| API Endpoint | `lib/core/api/api_endpoints.dart` |
| Usecase | `lib/features/shop/domain/usecases/get_nearest_shops_usecase.dart` |
| State | `lib/features/shop/presentation/state/shop_state.dart` |
| View Model | `lib/features/shop/presentation/view_model/shop_view_model.dart` |
| Toggle Widget | `lib/features/dashboard/presentation/widgets/nearest_shops_toggle.dart` |
| Distance Badge | `lib/features/dashboard/presentation/widgets/shop_distance_badge.dart` |
| Full Example | `lib/features/dashboard/presentation/examples/nearest_shops_integration_example.dart` |
| Documentation | `NEAREST_SHOPS_IMPLEMENTATION.md` |

## Example Integration

See complete example: `lib/features/dashboard/presentation/examples/nearest_shops_integration_example.dart`

## Testing

```bash
# Run app on physical device
flutter run

# Test location on emulator
# Android: Extended Controls > Location
# iOS: Features > Location > Custom Location

# Check logs
flutter logs | grep -i location
```
