import 'package:bazar/core/error/failure.dart';
import 'package:bazar/core/usecases/app_usecase.dart';
import 'package:bazar/features/auth/data/repositories/auth_repository.dart';
import 'package:bazar/features/auth/domain/entities/auth_entity.dart';
import 'package:bazar/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String username;
  final String password;
  final String confirmPassword;
  final String roleName;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.roleName,
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    phoneNumber,
    username,
    password,
    confirmPassword,
    roleName,
  ];
}

// Create Provider
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase implements UsecaseWithParams<bool, RegisterParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterParams params) {
    final authEntity = AuthEntity(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      username: params.username,
      password: params.password,
    );

    return _authRepository.register(authEntity, roleName: params.roleName, confirmPassword: params.confirmPassword);
  }
}