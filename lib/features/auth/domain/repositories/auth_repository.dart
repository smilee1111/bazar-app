import 'dart:io';

import 'package:bazar/core/error/failure.dart';
import 'package:bazar/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IAuthRepository{
  Future<Either<Failure, bool>> register(AuthEntity user, {String? roleName, String? confirmPassword});
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, String>> uploadPhoto(File photo);
  

  
}