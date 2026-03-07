# Nearest Shops Feature - Testing Guide

This document provides comprehensive testing instructions for the nearest shops location filter feature.

## Test Files Overview

### 1. Widget Tests

#### `test/features/dashboard/presentation/widgets/nearest_shops_toggle_test.dart`
Tests the `NearestShopsToggle` widget in isolation.

**Coverage:**
- ✅ Widget renders correctly
- ✅ Loading indicator displays when fetching location
- ✅ Switch is disabled when no category selected
- ✅ Switch is enabled when category selected
- ✅ onToggle callback is invoked correctly
- ✅ isEnabled state reflects in UI
- ✅ Hint text shows when category not selected
- ✅ Proper styling and color schemes

**Run this test:**
```bash
flutter test test/features/dashboard/presentation/widgets/nearest_shops_toggle_test.dart
```

#### `test/features/dashboard/presentation/widgets/shop_distance_badge_test.dart`
Tests the `ShopDistanceBadge` widget for distance display.

**Coverage:**
- ✅ Displays distance in meters (< 1 km)
- ✅ Displays distance in kilometers (≥ 1 km)
- ✅ Rounds values appropriately
- ✅ Returns empty SizedBox when distance is null
- ✅ Handles edge cases (0, negative, very large)
- ✅ Icon and text positioning
- ✅ Proper styling and padding

**Run this test:**
```bash
flutter test test/features/dashboard/presentation/widgets/shop_distance_badge_test.dart
```

### 2. Integration Tests

#### `test/features/dashboard/presentation/pages/home_screen_nearest_shops_test.dart`
Tests the integration of nearest shops filter in HomeScreen.

**Coverage:**
- ✅ NearestShopsToggle renders in HomeScreen
- ✅ Toggle is disabled without category selection
- ✅ Toggle is enabled with category selection
- ✅ Loading state displays correctly
- ✅ Shop list uses displayedShops (switches between all/nearest)
- ✅ Distance badges show when location available
- ✅ Distance badges hide when location unavailable
- ✅ Category selection triggers setSelectedCategory
- ✅ Error handling with snackbar notifications
- ✅ displayedShops getter logic

**Run this test:**
```bash
flutter test test/features/dashboard/presentation/pages/home_screen_nearest_shops_test.dart
```

### 3. View Model Tests

#### `test/features/shop/presentation/view_model/shop_view_model_nearest_test.dart`
Tests the business logic and state management for nearest shops.

**Coverage:**
- ✅ setSelectedCategory updates state
- ✅ toggleNearestFilter fetches nearest shops
- ✅ toggleNearestFilter resets filter
- ✅ Location permission denied handling
- ✅ API failure handling
- ✅ calculateDistance returns correct values
- ✅ calculateDistance returns null when data missing
- ✅ displayedShops getter logic
- ✅ NearestShopsParams validation
- ✅ Complete user workflows (enable/disable/errors)

**Run this test:**
```bash
flutter test test/features/shop/presentation/view_model/shop_view_model_nearest_test.dart
```

## Running All Tests

### Run all nearest shops feature tests:
```bash
flutter test test/features/dashboard/presentation/widgets/nearest_shops_toggle_test.dart test/features/dashboard/presentation/widgets/shop_distance_badge_test.dart test/features/dashboard/presentation/pages/home_screen_nearest_shops_test.dart test/features/shop/presentation/view_model/shop_view_model_nearest_test.dart
```

### Run all tests in the project:
```bash
flutter test
```

### Run tests with coverage:
```bash
flutter test --coverage
```

### View coverage report:
```bash
# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open in browser (Windows)
start coverage/html/index.html

# Open in browser (macOS)
open coverage/html/index.html

# Open in browser (Linux)
xdg-open coverage/html/index.html
```

## Test Setup Requirements

### 1. Add test dependencies to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

### 2. Generate mocks:

Some tests use mockito for mocking dependencies. Generate the mock files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `home_screen_nearest_shops_test.mocks.dart`
- `shop_view_model_nearest_test.mocks.dart`

### 3. Ensure Android/iOS permissions are configured:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to show nearby shops.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs your location to show nearby shops.</string>
```

## Manual Testing Checklist

### Prerequisites:
- [ ] Device/emulator has location services enabled
- [ ] App has location permissions granted
- [ ] Backend API is running and accessible

### Test Scenarios:

#### Scenario 1: Enable Nearest Shops Filter
1. [ ] Open app and navigate to Home screen
2. [ ] Observe: Toggle switch is disabled (gray/inactive)
3. [ ] Tap filter icon
4. [ ] Select a category (e.g., "Electronics")
5. [ ] Tap "Apply"
6. [ ] Observe: Toggle switch is now enabled (blue/active)
7. [ ] Tap toggle switch to enable nearest filter
8. [ ] Observe: 
   - Loading indicator appears briefly
   - Toast: "Fetching your location..."
   - Toast: "Found X shops nearby"
9. [ ] Verify: Shop list updates to show only nearby shops
10. [ ] Verify: Each shop card shows distance badge (e.g., "500 m" or "2.5 km")

#### Scenario 2: Disable Nearest Shops Filter
1. [ ] With nearest filter enabled (from Scenario 1)
2. [ ] Tap toggle switch to disable
3. [ ] Observe: Toggle switches to off position
4. [ ] Verify: Shop list updates to show all shops again
5. [ ] Verify: Distance badges remain visible if calculated

#### Scenario 3: No Category Selected
1. [ ] Open app with no category filter applied
2. [ ] Observe: Toggle is disabled
3. [ ] Observe: Text shows "Select category to enable"
4. [ ] Tap toggle switch (should do nothing)
5. [ ] Verify: Filter does not activate

#### Scenario 4: Location Permission Denied
1. [ ] Deny location permission in device settings
2. [ ] Select a category
3. [ ] Enable nearest filter toggle
4. [ ] Observe: Error toast appears with permission message
5. [ ] Verify: Filter remains off
6. [ ] Verify: App prompts for permission

#### Scenario 5: Location Services Disabled
1. [ ] Disable location services in device settings
2. [ ] Select a category
3. [ ] Enable nearest filter toggle
4. [ ] Observe: Error message about location services
5. [ ] Verify: Filter remains off

#### Scenario 6: No Nearby Shops
1. [ ] Select a category with no nearby shops
2. [ ] Enable nearest filter
3. [ ] Observe: Toast shows "Found 0 shops nearby"
4. [ ] Verify: Empty state or message displayed

#### Scenario 7: Search + Nearest Filter
1. [ ] Enable nearest filter with shops displayed
2. [ ] Type search query (e.g., shop name)
3. [ ] Verify: Results are filtered from nearest shops only
4. [ ] Clear search
5. [ ] Verify: All nearest shops show again

#### Scenario 8: Price Filter + Nearest Filter
1. [ ] Enable nearest filter
2. [ ] Open filter sheet
3. [ ] Set price range filter
4. [ ] Apply
5. [ ] Verify: Nearest shops are filtered by price

#### Scenario 9: Change Category with Filter Active
1. [ ] Enable nearest filter for "Electronics"
2. [ ] Open filter sheet
3. [ ] Change category to "Clothing"
4. [ ] Apply
5. [ ] Verify: Filter remains active
6. [ ] Verify: New category's nearest shops are fetched and displayed

#### Scenario 10: Distance Calculation Accuracy
1. [ ] Enable nearest filter
2. [ ] Note distances shown on shop cards
3. [ ] Tap on a shop to view details
4. [ ] Use Google Maps to verify approximate distance
5. [ ] Verify: Distance is reasonably accurate (±10%)

#### Scenario 11: Refresh with Filter Active
1. [ ] Enable nearest filter
2. [ ] Pull down to refresh
3. [ ] Verify: Nearest shops are re-fetched
4. [ ] Verify: Filter remains active after refresh

#### Scenario 12: Background/Foreground
1. [ ] Enable nearest filter
2. [ ] Put app in background (home button)
3. [ ] Bring app back to foreground
4. [ ] Verify: Filter state is maintained
5. [ ] Verify: Shops are still displayed correctly

## Troubleshooting Test Failures

### Mock generation errors:
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Widget test timeouts:
- Increase timeout in test: `testWidgets('...', timeout: Timeout(Duration(seconds: 30)), ...)`
- Check that `await tester.pumpAndSettle()` completes

### Integration test failures:
- Verify all providers are properly mocked
- Check that mock responses match expected data structure
- Ensure `when()` stubs are called before widget interaction

### Golden test failures (if applicable):
```bash
flutter test --update-goldens
```

## Performance Testing

### Test location fetch performance:
1. Enable nearest filter
2. Measure time from tap to results displayed
3. Expected: < 3 seconds on normal network

### Test with many shops:
1. Load category with 100+ shops
2. Enable nearest filter
3. Verify: No lag or frame drops
4. Check memory usage remains stable

### Test distance calculation performance:
1. Display 50+ shops with distances
2. Scroll through list
3. Verify: Smooth scrolling (60 FPS)

## Automated CI/CD Integration

Add to your CI/CD pipeline (e.g., GitHub Actions):

```yaml
name: Test Nearest Shops Feature

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - run: flutter pub get
      - run: flutter pub run build_runner build --delete-conflicting-outputs
      - run: flutter test --coverage test/features/dashboard/presentation/widgets/nearest_shops_toggle_test.dart
      - run: flutter test --coverage test/features/dashboard/presentation/widgets/shop_distance_badge_test.dart
      - run: flutter test --coverage test/features/dashboard/presentation/pages/home_screen_nearest_shops_test.dart
      - run: flutter test --coverage test/features/shop/presentation/view_model/shop_view_model_nearest_test.dart
      - uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

## Coverage Goals

Target coverage for nearest shops feature:
- Widget tests: 100% (all UI states covered)
- Integration tests: 90%+ (all user workflows)
- View model tests: 95%+ (all business logic)
- Overall feature coverage: 85%+

## Known Issues / Limitations

1. **Mock limitations**: Some tests use simplified mocks and may not catch all edge cases
2. **Platform differences**: Location behavior may differ between iOS/Android
3. **Network dependency**: Integration tests assume network availability
4. **Time-dependent**: Location fetching may take variable time

## Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Riverpod Testing Guide](https://riverpod.dev/docs/cookbooks/testing)
- [Integration Testing Best Practices](https://docs.flutter.dev/cookbook/testing/integration/introduction)

## Support

For issues or questions about these tests:
1. Check test output for specific error messages
2. Review implementation files for recent changes
3. Verify test dependencies are up to date
4. Consult documentation in `/docs` folder
