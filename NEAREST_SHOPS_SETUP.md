# Nearest Shops Feature - Quick Setup

## ✅ Feature Integration Complete!

The nearest shops filter has been successfully integrated into the HomeScreen. Here's what was added:

### 🎯 Integration Points

1. **NearestShopsToggle Widget** - Added below search/filter banner
2. **Category Selection Integration** - `setSelectedCategory()` called when filters applied
3. **Shop List Update** - Uses `displayedShops` getter (auto-switches between all/nearest)
4. **Distance Calculation** - Each shop displays distance badge when location available
5. **Error Handling** - Toast notifications via `ref.listen` for errors
6. **User Feedback** - Success/warning messages for toggle actions

### 📱 How to Test the Feature

#### Immediate Testing (No setup required):

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Test the feature:**
   - Notice the toggle is initially disabled (gray)
   - Tap the filter icon and select a category
   - The toggle becomes enabled (can be switched)
   - Tap the toggle to enable "Show Nearest Shops"
   - Grant location permission when prompted
   - See shops filtered to nearest ones with distance badges

#### User Flow:
```
1. Open HomeScreen
2. Tap Filter → Select Category → Apply
3. Toggle "Show Nearest Shops" ON
4. Grant location permission (if requested)
5. View nearby shops with distances
6. Toggle OFF to see all shops again
```

### 🧪 To Run Unit Tests (Optional):

The unit tests require additional setup:

1. **Add test dependencies to `pubspec.yaml`:**
   ```yaml
   dev_dependencies:
     flutter_test:
       sdk: flutter
     mockito: ^5.4.4
     build_runner: ^2.4.8
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate mocks:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run tests:**
   ```bash
   # Run specific test file
   flutter test test/features/dashboard/presentation/widgets/nearest_shops_toggle_test.dart

   # Run all nearest shops tests
   flutter test test/features/dashboard/ test/features/shop/presentation/view_model/shop_view_model_nearest_test.dart

   # Run all tests with coverage
   flutter test --coverage
   ```

### 📝 What Changed in HomeScreen.dart

**Imports Added:**
- `snackbar_utils.dart` - For toast notifications
- `nearest_shops_toggle.dart` - The toggle widget

**State Updates:**
- `ref.listen` added for error handling
- `shopViewModel` variable for easier access

**Category Filter Enhancement:**
- `_openFilters()` now calls `setSelectedCategory()` when category changes
- Maps category name to category ID for API calls

**Shop List Changes:**
- Changed from `shopState.publicShops` to `shopState.displayedShops`
- This automatically switches between all shops and nearest shops

**Distance Display:**
- Added `calculateDistance()` call for each shop
- Pass `distanceInKm` parameter to `PublicShopCard`

**UI Addition:**
- `NearestShopsToggle` widget in `SliverToBoxAdapter`
- Toast notifications for toggle actions
- Loading states and category validation

### 🎨 UI Components Available

All widgets are already created and integrated:

1. **NearestShopsToggle** - Toggle switch with location icon
   - Shows loading spinner when fetching
   - Disabled when no category selected
   - Shows hint text when disabled

2. **ShopDistanceBadge** - Displays distance from user
   - Formats as "500 m" or "2.5 km"
   - Auto-hidden when distance unavailable
   - Location icon prefix

### 🔧 Backend Requirements

The feature expects this API endpoint:
```
GET /api/public/shops/nearest
Query Parameters:
  - categoryId: string (required)
  - lat: number (required)
  - lng: number (required)
  - limit: number (optional, default: 20)
```

Response should be an array of shop objects with latitude/longitude.

### ✨ User Experience Features

✅ **Permission Handling** - Prompts for location permission gracefully
✅ **Loading States** - Shows spinner while fetching location/shops
✅ **Error Messages** - Clear feedback when things go wrong
✅ **Category Validation** - Can't enable without selecting category
✅ **Toggle State** - Remembers on/off state during session
✅ **Distance Display** - Shows proximity to each shop
✅ **Smooth Transitions** - No jarring UI changes
✅ **Search Integration** - Works alongside existing search/filters

### 📂 Files Created/Modified

**Created:**
- `lib/core/services/location/geolocation_provider.dart`
- `lib/features/shop/domain/usecases/get_nearest_shops_usecase.dart`
- `lib/features/dashboard/presentation/widgets/nearest_shops_toggle.dart`
- `lib/features/dashboard/presentation/widgets/shop_distance_badge.dart`
- `docs/NEAREST_SHOPS_FEATURE.md`
- `docs/NEAREST_SHOPS_IMPLEMENTATION.md`
- `docs/NEAREST_SHOPS_API_INTEGRATION.md`
- `docs/NEAREST_SHOPS_UI_COMPONENTS.md`
- `docs/NEAREST_SHOPS_TESTING_GUIDE.md`

**Modified:**
- `lib/core/network/api_endpoints.dart`
- `lib/features/shop/data/datasources/remote/shop_remote_datasource.dart`
- `lib/features/shop/data/repositories/shop_repository.dart`
- `lib/features/shop/presentation/state/shop_state.dart`
- `lib/features/shop/presentation/view_model/shop_view_model.dart`
- `lib/features/dashboard/presentation/widgets/public_shop_card.dart`
- `lib/features/dashboard/presentation/pages/HomeScreen.dart` ← **Main UI integration**

### 🚀 Next Steps

1. **Run the app** and test the feature manually
2. **Grant location permissions** when prompted
3. **Select a category** to enable the toggle
4. **Toggle nearest shops** on to see filtered results
5. **(Optional)** Set up unit tests as described above

### 📚 Documentation

Full documentation available in `/docs`:
- `NEAREST_SHOPS_FEATURE.md` - Feature overview
- `NEAREST_SHOPS_IMPLEMENTATION.md` - Technical implementation details
- `NEAREST_SHOPS_API_INTEGRATION.md` - Backend API documentation
- `NEAREST_SHOPS_UI_COMPONENTS.md` - Widget usage guide
- `NEAREST_SHOPS_TESTING_GUIDE.md` - Comprehensive testing guide

### ❓ Troubleshooting

**Toggle is disabled:**
- Make sure you've selected a category from filters first

**No shops showing:**
- Check that location permission is granted
- Verify backend API is running and accessible
- Check network connectivity

**Distance not showing:**
- Ensure shops have valid latitude/longitude in database
- Verify location permission is granted
- Check that geolocator package is properly configured

**Permission dialog not appearing:**
- Check AndroidManifest.xml / Info.plist for location permissions
- Restart app after changing permission settings

---

**The feature is ready to use!** Just run the app and try it out. 🎉
