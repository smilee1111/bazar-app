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
  Future<bool> updateUser(AuthHiveModel user) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }
  @override
  Future<bool> deleteUser(String authId) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) {
    // TODO: implement getUserByEmail
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<bool> logOut() {
    // TODO: implement logOut
    throw UnimplementedError();
  }



}