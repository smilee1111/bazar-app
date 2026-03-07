# Backend Implementation Required: Nearest Shops Endpoint

## ⚠️ Issue

The Flutter app is trying to call the nearest shops API, but the backend doesn't have this endpoint implemented yet.

**Error:** `Cannot GET /api/shops/public/nearest`

## 🔧 Required Backend Implementation

The backend needs to implement the following endpoint:

### Endpoint Details

```
GET /api/shops/public/nearest
```

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `categoryId` | string | Yes | Category ID to filter shops |
| `lat` | number | Yes | User's latitude |
| `lng` | number | Yes | User's longitude |
| `limit` | number | No | Max shops to return (default: 10-20) |

### Example Request

```
GET /api/shops/public/nearest?categoryId=cat-123&lat=27.7172&lng=85.3240&limit=20
```

### Expected Response

```json
{
  "success": true,
  "data": [
    {
      "shopId": "shop-1",
      "shopName": "Electronics Hub",
      "shopAddress": "Kathmandu, Nepal",
      "shopContact": "9841234567",
      "shopLatitude": 27.7172,
      "shopLongitude": 85.3240,
      "shopRating": 4.5,
      "shopImage": "https://...",
      "shopDescription": "...",
      "categories": [
        {
          "categoryId": "cat-123",
          "categoryName": "Electronics"
        }
      ],
      "distance": 0.5
    }
  ]
}
```

### Backend Implementation Steps

#### 1. **Route Definition** (Express.js example)

```javascript
// routes/shops.js
router.get('/shops/public/nearest', getNearestShops);
```

#### 2. **Controller Implementation**

```javascript
// controllers/shopController.js
async function getNearestShops(req, res) {
  try {
    const { categoryId, lat, lng, limit = 20 } = req.query;
    
    // Validate required parameters
    if (!categoryId || !lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'categoryId, lat, and lng are required'
      });
    }
    
    // Parse coordinates
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);
    const maxLimit = parseInt(limit);
    
    // Query database for nearest shops
    // Using MongoDB GeoSpatial Query example:
    const shops = await Shop.find({
      'categories.categoryId': categoryId,
      shopLatitude: { $exists: true },
      shopLongitude: { $exists: true },
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [longitude, latitude]
          },
          $maxDistance: 50000 // 50km radius
        }
      }
    }).limit(maxLimit);
    
    // Calculate distances (if not using GeoSpatial query)
    const shopsWithDistance = shops.map(shop => {
      const distance = calculateDistance(
        latitude, longitude,
        shop.shopLatitude, shop.shopLongitude
      );
      return {
        ...shop.toObject(),
        distance
      };
    });
    
    res.json({
      success: true,
      data: shopsWithDistance
    });
    
  } catch (error) {
    console.error('Error fetching nearest shops:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch nearest shops'
    });
  }
}

// Haversine distance calculation
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth radius in km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c; // Distance in km
}

function toRad(degrees) {
  return degrees * Math.PI / 180;
}
```

#### 3. **Database Index** (MongoDB example)

```javascript
// Ensure geospatial index exists
shopSchema.index({ location: '2dsphere' });

// Or for simple lat/lng fields:
shopSchema.index({ shopLatitude: 1, shopLongitude: 1 });
shopSchema.index({ 'categories.categoryId': 1 });
```

#### 4. **Alternative: SQL Database** (PostgreSQL with PostGIS)

```sql
-- Using PostGIS for geospatial queries
SELECT 
  s.*,
  ST_Distance(
    ST_MakePoint(s.shop_longitude, s.shop_latitude)::geography,
    ST_MakePoint(:lng, :lat)::geography
  ) / 1000 AS distance_km
FROM shops s
INNER JOIN shop_categories sc ON s.shop_id = sc.shop_id
WHERE sc.category_id = :categoryId
  AND s.shop_latitude IS NOT NULL
  AND s.shop_longitude IS NOT NULL
ORDER BY distance_km
LIMIT :limit;
```

## 🔄 Updated Flutter Endpoint

The Flutter app has been updated to use the correct endpoint path that matches other public shop endpoints:

**Old (incorrect):** `/public/shops/nearest`  
**New (correct):** `/shops/public/nearest`

This matches the pattern used by other public shop endpoints:
- `/shops/public` - All public shops
- `/shops/public/:id` - Specific shop
- `/shops/public/nearest` - Nearest shops ✅

## ✅ Testing the Backend Endpoint

Once implemented, test with:

```bash
curl "http://localhost:5050/api/shops/public/nearest?categoryId=cat-123&lat=27.7172&lng=85.3240&limit=10"
```

Expected: JSON response with array of shops sorted by distance.

## 📝 Checklist

- [ ] Create route handler in backend
- [ ] Implement geospatial query logic
- [ ] Add distance calculation
- [ ] Filter by category ID
- [ ] Validate required parameters
- [ ] Add error handling
- [ ] Test endpoint with Postman/curl
- [ ] Verify response format matches Flutter expectations
- [ ] Deploy backend changes
- [ ] Test end-to-end with Flutter app

## 🚀 Quick Test

After backend implementation, restart the Flutter app and:
1. Select a category from filters
2. Enable "Show nearest shops only" toggle
3. Grant location permission
4. Should now see nearby shops!

---

**Note:** The Flutter app is already implemented and ready. Only the backend endpoint needs to be added.
