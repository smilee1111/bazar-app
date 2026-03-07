import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  // Note: Backend uses /api (NOT /api/v1)
  // static const String baseUrl = 'http://10.0.2.2:5050/api';
  // static const String baseUrl = 'http://10.0.2.2:5050/api';
  //static const String baseUrl = 'http://localhost:5050/api';
  // For Android Emulator use: 'http://10.0.2.2:5050/api'
  // For iOS Simulator use: 'http://localhost:5050/api'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:5050/api'

  // Configuration
  static const bool isPhysicalDevice = true;
  static const String _ipAddress = '192.168.1.165';
  //192.168.1.93
  //192.168.101.11'
  static const int _port = 5050;

  // Base URLs
  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api';
  static String get mediaServerUrl => serverUrl;

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Role Endpoints ============
  // Backend: app.use('/api/roles', roleRoutes)
  static const String roles = '/roles';
  static String roleById(String id) => '/roles/$id';

  // // ============ Category Endpoints ============
  static const String categories = '/categories';
  static const String userCategories = '/user/categories';
  static String categoryById(String id) => '/categories/$id';

  // ============ Seller Application Endpoints ============
  static const String sellerApplications = '/user/seller-applications';
  static const String mySellerApplication = '/user/seller-applications/my';
  static const String sellerApplicationUploadDocument =
      '/user/seller-applications/upload-document';

  // // ============ Shop Endpoints ============
  static const String shops = '/shops';
  static const String sellerShops = '/seller/shops';
  static const String publicShopsFeed = '/shops/public';
  static String publicShopsFeedPaged({int page = 1, int limit = 15}) =>
      '/shops/public?page=$page&limit=$limit';
  static String publicShopById(String shopId) => '/shops/public/$shopId';
  static String publicShopRouteById(String shopId) =>
      '/shops/public/$shopId/route';
  static const String publicNearestShops = '/shops/nearest';
  static String publicNearestShopsWithParams({
    required String categoryId,
    required double lat,
    required double lng,
    int limit = 10,
  }) =>
      '/shops/nearest?categoryId=$categoryId&lat=$lat&lng=$lng&limit=$limit';
  static String sellerShopById(String id) => '/seller/shops/$id';
  static const String mySellerShop = '/seller/shops/my';
  static const String userReviews = '/user/reviews';
  static const String userSavedShops = '/user/saved-shops';
  static const String userFavourites = '/user/favourites';
  static const String userNotifications = '/user/notifications';
  static String userNotificationById(String id) => '/user/notifications/$id';
  static String markUserNotificationAsRead(String id) =>
      '/user/notifications/$id/read';
  static const String userNotificationUnreadCount =
      '/user/notifications/unread-count';
  static const String userNotificationMarkMultipleRead =
      '/user/notifications/mark-multiple-read';
  static const String userNotificationMarkAllRead =
      '/user/notifications/mark-all-read';

  // ============ Shop Detail Endpoints ============
  static String shopDetailsByShop(String shopId) => '/shops/$shopId/details';
  static String shopDetailById(String shopId, String detailId) =>
      '/shops/$shopId/details/$detailId';

  // ============ Shop Review Endpoints ============
  static String shopReviewsByShop(String shopId) => '/shops/$shopId/reviews';
  static String shopReviewById(String shopId, String reviewId) =>
      '/shops/$shopId/reviews/$reviewId';
  static String likeShopReview(String shopId, String reviewId) =>
      '/shops/$shopId/reviews/$reviewId/like';
  static String unlikeShopReview(String shopId, String reviewId) =>
      '/shops/$shopId/reviews/$reviewId/unlike';
  static String isShopReviewLiked(String shopId, String reviewId) =>
      '/shops/$shopId/reviews/$reviewId/liked';
  static String dislikeShopReview(String shopId, String reviewId) =>
      '/shops/$shopId/reviews/$reviewId/dislike';
  static String undislikeShopReview(String shopId, String reviewId) =>
      '/shops/$shopId/reviews/$reviewId/undislike';
  static String isShopReviewDisliked(String shopId, String reviewId) =>
      '/shops/$shopId/reviews/$reviewId/disliked';

  // ============ Shop Photo Endpoints ============
  static String shopPhotosByShop(String shopId) => '/shops/$shopId/photos';
  static String shopPhotoById(String shopId, String photoId) =>
      '/shops/$shopId/photos/$photoId';

  // ============ Auth Endpoints ============
  // Backend: app.use('/api/auth', authRoutes)
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRequestPasswordReset = '/auth/request-password-reset';
  static const String authVerifyResetOtp = '/auth/verify-reset-otp';
  static String authResetPassword(String token) =>
      '/auth/reset-password/$token';
  static const String userUploadPhoto = '/auth/update-profile';
  static String userPicture(String filename) =>
      '$mediaServerUrl/user_photos/$filename';

  // ============ Admin User Endpoints ============
  // Backend: app.use('/api/admin/users', adminRoutes)
  static const String adminUsers = '/admin/users';
  static String adminUserById(String id) => '/admin/users/$id';
  // static String userPhoto(String id) => '/users/$id/photo';

  // // ============ Item Endpoints ============
  // static const String items = '/items';
  // static String itemById(String id) => '/items/$id';
  // static String itemClaim(String id) => '/items/$id/claim';

  // // ============ Comment Endpoints ============
  // static const String comments = '/comments';
  // static String commentById(String id) => '/comments/$id';
  // static String commentsByItem(String itemId) => '/comments/item/$itemId';
  // static String commentLike(String id) => '/comments/$id/like';
}
