# Nearest Shops Feature Architecture

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────┐  ┌──────────────────┐  ┌─────────────────┐│
│  │   Category      │  │  NearestShops    │  │   Shop Cards    ││
│  │   Dropdown      │  │     Toggle       │  │  with Distance  ││
│  └────────┬────────┘  └────────┬─────────┘  └────────┬────────┘│
│           │                    │                      │          │
└───────────┼────────────────────┼──────────────────────┼──────────┘
            │                    │                      │
            │                    │                      │
┌───────────▼────────────────────▼──────────────────────▼──────────┐
│                    PRESENTATION LAYER                             │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              ShopViewModel (Notifier)                        │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │  • setSelectedCategory(categoryId)                          │ │
│  │  • toggleNearestFilter(enable)                              │ │
│  │  • loadNearestShops()                                       │ │
│  │  • calculateDistance(shop)                                  │ │
│  └───────────┬───────────────────────┬─────────────────────────┘ │
│              │                       │                           │
│  ┌───────────▼───────────────┐  ┌───▼──────────────────────────┐│
│  │      ShopState            │  │  GeolocationProvider         ││
│  ├───────────────────────────┤  ├──────────────────────────────┤│
│  │ • showNearestOnly: bool   │  │ • getCurrentLocation()       ││
│  │ • isLoadingNearest: bool  │  │ • state.userLocation         ││
│  │ • nearestShops: List      │  │ • state.isLoading            ││
│  │ • selectedCategoryId: id  │  │ • state.errorMessage         ││
│  │ • userLatitude: double?   │  └──────────────────────────────┘│
│  │ • userLongitude: double?  │                                  │
│  │ • displayedShops: getter  │                                  │
│  └───────────┬───────────────┘                                  │
│              │                                                   │
└──────────────┼───────────────────────────────────────────────────┘
               │
               │
┌──────────────▼───────────────────────────────────────────────────┐
│                       DOMAIN LAYER                                │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────────┐│
│  │         GetNearestShopsUsecase                               ││
│  ├──────────────────────────────────────────────────────────────┤│
│  │  call(NearestShopsParams) → Either<Failure, List<Shop>>     ││
│  └───────────┬──────────────────────────────────────────────────┘│
│              │                                                    │
│  ┌───────────▼──────────────────────────────────────────────────┐│
│  │         IShopRepository (Interface)                          ││
│  ├──────────────────────────────────────────────────────────────┤│
│  │  getNearestShops(categoryId, lat, lng, limit)               ││
│  └──────────────────────────────────────────────────────────────┘│
│                                                                   │
└───────────────────────────────┬───────────────────────────────────┘
                                │
                                │
┌───────────────────────────────▼───────────────────────────────────┐
│                         DATA LAYER                                 │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌────────────────────────────────────────────────────────────────┐
│  │          ShopRepository (Implementation)                       │
│  ├────────────────────────────────────────────────────────────────┤
│  │  • Network connectivity check                                  │
│  │  • Error handling & mapping                                    │
│  │  • Entity conversion                                           │
│  └────────────┬───────────────────────────────────────────────────┘
│               │                                                    │
│  ┌────────────▼───────────────────────────────────────────────────┐
│  │          ShopRemoteDataSource                                  │
│  ├────────────────────────────────────────────────────────────────┤
│  │  getNearestShops(categoryId, lat, lng, limit)                 │
│  │    → List<ShopApiModel>                                        │
│  └────────────┬───────────────────────────────────────────────────┘
│               │                                                    │
└───────────────┼────────────────────────────────────────────────────┘
                │
                │
┌───────────────▼────────────────────────────────────────────────────┐
│                   EXTERNAL SERVICES                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────┐         ┌──────────────────────────────┐ │
│  │   Backend API        │         │   Location Services          │ │
│  ├──────────────────────┤         ├──────────────────────────────┤ │
│  │ GET /api/public/     │         │  • Geolocator package        │ │
│  │     shops/nearest    │         │  • Permission handler        │ │
│  │                      │         │  • Device GPS                │ │
│  │ ?categoryId=xxx      │         └──────────────────────────────┘ │
│  │ &lat=40.7128         │                                          │
│  │ &lng=-74.0060        │                                          │
│  │ &limit=10            │                                          │
│  └──────────────────────┘                                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Data Flow

### Enabling Nearest Shops Filter

```
┌─────────────┐
│    User     │
│   Selects   │
│  Category   │
└──────┬──────┘
       │
       ▼
┌──────────────────────────┐
│ setSelectedCategory()    │───► Store in ShopState
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│   User Toggles ON        │
│ "Nearest Shops Only"     │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ toggleNearestFilter(enable=true) │
└──────┬───────────────────────────┘
       │
       ├──► Set isLoadingNearest = true
       │
       ▼
┌────────────────────────────────┐
│  Request Location Permission   │
└──────┬─────────────────────────┘
       │
       ├─────► Denied ──────► Show Error ──────┐
       │                                        │
       ▼                                        ▼
    Granted                              Filter OFF
       │
       ▼
┌──────────────────────┐
│  Get User Location   │
│  (lat, lng)          │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  Store lat/lng in ShopState      │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  Call getNearestShopsUsecase()       │
│  - categoryId: selected category     │
│  - lat: user latitude                │
│  - lng: user longitude               │
│  - limit: 10                         │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  Backend API Call                │
│  GET /api/public/shops/nearest   │
└──────┬───────────────────────────┘
       │
       ├──► Success ──────┐
       │                  │
       ▼                  ▼
    Error           Parse Response
       │                  │
       ▼                  ▼
  Show Error      Build ShopEntity List
       │                  │
       │                  ▼
       │          ┌──────────────────────┐
       │          │ Store in             │
       │          │ state.nearestShops   │
       │          └──────┬───────────────┘
       │                 │
       │                 ▼
       │          Set isLoadingNearest = false
       │                 │
       └─────────────────┴──────────────┐
                                        │
                                        ▼
                              ┌─────────────────────┐
                              │  UI Updates         │
                              │  - Show shops       │
                              │  - Show distances   │
                              │  - Show success     │
                              └─────────────────────┘
```

### Calculating Distance

```
┌──────────────────────┐
│   Building Shop      │
│   Card Widget        │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────────────┐
│ calculateDistance(shop)      │
└──────┬───────────────────────┘
       │
       ├──► No user location? ──────► Return null
       │
       ├──► No shop location? ───────► Return null
       │
       ▼
┌──────────────────────────────────┐
│  Use Distance package            │
│  distance.as(                    │
│    LengthUnit.Kilometer,         │
│    LatLng(userLat, userLng),     │
│    LatLng(shopLat, shopLng)      │
│  )                               │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│  Return distance in km       │
└──────┬───────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│  ShopDistanceBadge           │
│  Formats & Displays          │
│  - < 1km: "500 m"            │
│  - >= 1km: "2.5 km"          │
└──────────────────────────────┘
```

## State Transitions

```
Initial State
    │
    ├─► Category Selected
    │       │
    │       ├─► Toggle Enabled (but OFF)
    │       │       │
    │       │       ├─► User Toggles ON
    │       │       │       │
    │       │       │       ├─► Loading Location
    │       │       │       │       │
    │       │       │       │       ├─► Permission Denied
    │       │       │       │       │       │
    │       │       │       │       │       └─► Error State → Back to OFF
    │       │       │       │       │
    │       │       │       │       ├─► Permission Granted
    │       │       │       │       │       │
    │       │       │       │       │       ├─► Location Fetched
    │       │       │       │       │       │       │
    │       │       │       │       │       │       ├─► Loading Shops
    │       │       │       │       │       │       │       │
    │       │       │       │       │       │       │       ├─► API Error
    │       │       │       │       │       │       │       │       │
    │       │       │       │       │       │       │       │       └─► Error State
    │       │       │       │       │       │       │       │
    │       │       │       │       │       │       │       ├─► Success
    │       │       │       │       │       │       │       │       │
    │       │       │       │       │       │       │       │       └─► Filter Active State
    │       │       │       │       │       │       │       │               │
    │       │       │       │       │       │       │       │               ├─► Shops Displayed
    │       │       │       │       │       │       │       │               │   with Distances
    │       │       │       │       │       │       │       │               │
    │       │       │       │       │       │       │       │               └─► User Toggles OFF
    │       │       │       │       │       │       │       │                       │
    │       │       │       │       │       │       │       │                       └─► Back to Toggle OFF
    │       │       │       │       │       │       │       │
    │       │       │       │       │       │       │       └─► Empty State
    │       │       │       │       │       │       │               (No shops found)
```

## Key Interactions

### Category Selection → Toggle State
```
No Category Selected     Category Selected
        │                        │
        ├─► Toggle: DISABLED     ├─► Toggle: ENABLED
        │   (grey, no action)    │   (can be toggled)
```

### Toggle → Shop List Display
```
Toggle OFF                      Toggle ON
    │                               │
    ├─► publicShops displayed       ├─► nearestShops displayed
    │   (all shops in feed)         │   (only nearby shops)
    │                               │
    └─► displayedShops getter       └─► displayedShops getter
        returns publicShops             returns nearestShops
```

### Location State → UI Feedback
```
Location Request                Toast Notification
      │
      ├─► Starting  ──────────► "Fetching your location..."
      │
      ├─► Success   ──────────► "Found X shops nearby"
      │
      ├─► Denied    ──────────► "Location access denied"
      │
      └─► Error     ──────────► Error message details
```

## Dependencies Graph

```
ShopViewModel
    ├── GetNearestShopsUsecase
    ├── GeolocationProvider
    │   └── LocationService
    │       └── Geolocator (package)
    └── ShopState
        ├── nearestShops (List<ShopEntity>)
        └── user location (lat, lng)

NearestShopsToggle (Widget)
    └── ShopState (watch)
        ├── showNearestOnly
        ├── isLoadingNearest
        └── selectedCategoryId

PublicShopCard (Widget)
    ├── ShopEntity
    └── distanceInKm (optional)
        └── ShopViewModel.calculateDistance()

ShopDistanceBadge (Widget)
    └── distanceInKm (double?)
```

---

This architecture ensures:
- ✅ Separation of concerns
- ✅ Testability
- ✅ Scalability
- ✅ Clean data flow
- ✅ Proper error handling
- ✅ User feedback at every step
