import 'dart:io';

import 'package:bazar/core/api/api_client.dart';
import 'package:bazar/core/api/api_endpoints.dart';
import 'package:bazar/core/services/storage/token_service.dart';
import 'package:bazar/core/services/storage/user_session_service.dart';
import 'package:bazar/features/auth/data/datasources/auth_datasource.dart';
import 'package:bazar/features/auth/data/models/auth_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource  implements IAuthRemoteDataSource{
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  //constructor
  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
        _tokenService = tokenService;

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
      final token = response.data['token'] as String?;

      if (token == null || token.isEmpty) {
        throw Exception('Login succeeded but no token was returned');
      }

      await _tokenService.saveToken(token);

      // Save to session
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        fullName: user.fullName,
        username: user.username,
        roleId: user.roleId,
        profilePic: user.profilePic,
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
  Future<bool> updateUser(AuthApiModel user) async{
    final token = await _tokenService.getToken();
    await _apiClient.put(
      ApiEndpoints.adminUserById(user.id!),
      data: user.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return true;
  }


    @override
  Future<String> uploadPhoto(File photo) async {
    final fileName = photo.path.split('/').last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(photo.path, filename: fileName),
    });
    // Get token from token service
    final token = await _tokenService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing authentication token. Please login again.');
    }

    final response = await _apiClient.put(
      ApiEndpoints.userUploadPhoto,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: 'multipart/form-data',
      ),
    );

    final data = response.data['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Upload succeeded but no user payload was returned.');
    }

    final updatedUser = AuthApiModel.fromJson(data);
    final profilePic = updatedUser.profilePic;
    if (profilePic == null || profilePic.isEmpty) {
      throw Exception('Upload succeeded but no profilePic was returned.');
    }

    final userId = updatedUser.id;
    if (userId == null || userId.isEmpty) {
      throw Exception('Upload succeeded but user identifier was missing.');
    }

    await _userSessionService.saveUserSession(
      userId: userId,
      email: updatedUser.email,
      fullName: updatedUser.fullName,
      username: updatedUser.username,
      roleId: updatedUser.roleId,
      profilePic: profilePic,
    );

    return profilePic;
  }
}