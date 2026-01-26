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
  static const String _ipAddress = '192.168.101.9';
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
  // static const String categories = '/categories';
  // static String categoryById(String id) => '/categories/$id';

  // ============ Auth Endpoints ============
  // Backend: app.use('/api/auth', authRoutes)
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
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
