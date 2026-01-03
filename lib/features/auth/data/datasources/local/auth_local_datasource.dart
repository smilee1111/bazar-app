import 'package:bazar/core/services/hive/hive_service.dart';
import 'package:bazar/features/auth/data/datasources/auth_datasource.dart';
import 'package:bazar/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



// Create provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
  );
});
class AuthLocalDatasource implements IAuthDataSource{
  final HiveService _hiveService;

   AuthLocalDatasource({
    required HiveService hiveService,
  }) : _hiveService = hiveService;



  @override
  Future<AuthHiveModel?> login(String email, String password) async{
    try{
    final user =  _hiveService.login(email,password);
    return user;
   }catch(e){
    return null;
   }
  }

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    return await _hiveService.register(user);
  }
  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    try {
      return await _hiveService.updateUser(user);
    } catch (e) {
      return false;
    }
  }
  @override
 @override
  Future<bool> deleteUser(String authId) async {
    try {
      await _hiveService.deleteUser(authId);
      return true;
    } catch (e) {
      return false;
    }
  }
Future<AuthHiveModel?> getCurrentUser() async {
    try {
      // // Check if user is logged in
      // if (!_userSessionService.isLoggedIn()) {
      //   return null;
      // }

      // // Get user ID from session
      // final userId = _userSessionService.getCurrentUserId();
      // if (userId == null) {
      //   return null;
      // }

      // Fetch user from Hive database
      // return _hiveService.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return _hiveService.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) async {
    return await _hiveService.getUserById(authId);
  }

  
  @override
  Future<bool> logOut() async{
      try {
      await _hiveService.logOut();
      return true;
    } catch (e) {
      return false;
    }
  }


}