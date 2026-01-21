import 'dart:io';

import 'package:bazar/core/error/failure.dart';
import 'package:bazar/core/services/connectivity/network_info.dart';
import 'package:bazar/features/auth/data/datasources/auth_datasource.dart';
import 'package:bazar/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:bazar/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:bazar/features/auth/data/models/auth_api_model.dart';
import 'package:bazar/features/auth/data/models/auth_hive_model.dart';
import 'package:bazar/features/auth/domain/entities/auth_entity.dart';
import 'package:bazar/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



//Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref){
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDataSource = ref.read(authRemoteDataSourceProvider);  
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
  authDatasource: authDatasource,
  authRemoteDataSource: authRemoteDataSource,
  networkInfo: networkInfo,);
});

class AuthRepository implements IAuthRepository{

  final IAuthLocalDataSource _authDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,})
    : _authDataSource = authDatasource,
    _authRemoteDataSource = authRemoteDataSource,
    _networkInfo = networkInfo;


  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDataSource.getCurrentUser();
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return const Left(
        LocalDatabaseFailure(message: "No user found"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid credentials"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _authDataSource.login(email, password);
        if (model != null) {
          final entity = model.toEntity();
          return Right(entity);
        }
        return const Left(
          LocalDatabaseFailure(message: "Invalid email or password"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logOut();
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity user, {String? roleName, String? confirmPassword}) async{
   if (await _networkInfo.isConnected){
   try{
    final apiModel = AuthApiModel.fromEnity(user);
    await _authRemoteDataSource.register(apiModel, roleName: roleName, confirmPassword: confirmPassword);
    return const Right(true);
   }on DioException catch (e) {
        return Left(ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message']?? 'Registration failed.'
        ));
   }catch(e){
    return Left(ApiFailure(message: e.toString()));
   }
   }else{
    try{
      //Check if eamil already exists
      final existingUser = await _authDataSource.getUserByEmail(user.email);
      if(existingUser!=null){
        return const Left(
          LocalDatabaseFailure(message: "Email is already registered."),
        );
      }

      final authModel = AuthHiveModel(
      fullName: user.fullName, 
      email: user.email, 
      username: user.username,
      password: user.password,
      profilePic: user.profilePic,
      roleId: user.roleId,);
      await _authDataSource.register(authModel);
      return const Right(true);
    }catch(e){
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
  }

  @override
  Future<Either<Failure, String>> uploadPhoto(File photo) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _authRemoteDataSource.uploadPhoto(photo);
        return Right(url);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }


}