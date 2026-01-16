import 'package:bazar/core/api/api_client.dart';
import 'package:bazar/core/api/api_endpoints.dart';
import 'package:bazar/core/services/storage/user_session_service.dart';
import 'package:bazar/features/auth/data/datasources/auth_datasource.dart';
import 'package:bazar/features/auth/data/models/auth_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource  implements IAuthRemoteDataSource{
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  //constructor
  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  //methods
  @override
  Future<bool> deleteUser(String authId) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> getUserByEmail(String email) {
    // TODO: implement getUserByEmail
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<bool> logOut() {
    // TODO: implement logOut
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async{
 final response = await _apiClient.post(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      // Save to session
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        fullName: user.fullName,
        username: user.username,
      );
      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user, {String? roleName, String? confirmPassword}) async {
    final response = await _apiClient.post(
      ApiEndpoints.authRegister,
      data: user.toJson(roleName: roleName, confirmPassword: confirmPassword),
    );


    if(response.data['success']== true){
      final data = response.data['data'] as Map<String, dynamic>;
      final registerUser = AuthApiModel.fromJson(data);
    }

    return user;
  }

  @override
  Future<bool> updateUser(AuthApiModel user) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }
}