import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  // Keys for storing user data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserUsername = 'user_username';
  static const String _keyUserPhoneNumber = 'user_phone_number';
  static const String _keyUserRoleId = 'user_role_id';
  static const String _keyUserProfilePic = 'user_profile_pic';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Save user session after login
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    required String username,
    String? phoneNumber,
    String? roleId,
    String? profilePic,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setBool(_keyOnboardingCompleted, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFullName, fullName);
    await _prefs.setString(_keyUserUsername, username);
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      await _prefs.setString(_keyUserPhoneNumber, phoneNumber);
    } else {
      await _prefs.remove(_keyUserPhoneNumber);
    }
    if (roleId != null) {
      await _prefs.setString(_keyUserRoleId, roleId);
    }
    if (profilePic != null && profilePic.isNotEmpty) {
      await _prefs.setString(_keyUserProfilePic, profilePic);
    } else {
      await _prefs.remove(_keyUserProfilePic);
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  // Get current user full name
  String? getCurrentUserFullName() {
    return _prefs.getString(_keyUserFullName);
  }

  // Get current user username
  String? getCurrentUserUsername() {
    return _prefs.getString(_keyUserUsername);
  }

  // Get current user phone number
  String? getCurrentUserPhoneNumber() {
    return _prefs.getString(_keyUserPhoneNumber);
  }

  // Get current user role ID
  String? getCurrentUserRoleId() {
    return _prefs.getString(_keyUserRoleId);
  }

  // Get current user profile picture
  String? getCurrentUserProfilePic() {
    return _prefs.getString(_keyUserProfilePic);
  }

  Future<void> updateProfilePic(String? profilePic) async {
    if (profilePic == null || profilePic.isEmpty) {
      await _prefs.remove(_keyUserProfilePic);
    } else {
      await _prefs.setString(_keyUserProfilePic, profilePic);
    }
  }

  // Check if onboarding is completed
  bool isOnboardingCompleted() {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  // Clear user session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyUserUsername);
    await _prefs.remove(_keyUserPhoneNumber);
    await _prefs.remove(_keyUserRoleId);
    await _prefs.remove(_keyUserProfilePic);
    // Keep onboarding_completed flag so user sees login next time
  }
}