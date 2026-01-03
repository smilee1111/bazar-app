import 'package:bazar/core/error/failure.dart';
import 'package:bazar/core/usecases/app_usecase.dart';
import 'package:bazar/features/role/data/repositories/role_repository.dart';
import 'package:bazar/features/role/domain/entities/role_entity.dart';
import 'package:bazar/features/role/domain/repositories/role_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateRoleParams extends Equatable {
  final String roleName;

  const CreateRoleParams({required this.roleName});

  @override
  List<Object?> get props => [roleName];
}

//Usecase

// Create Provider
final createRoleUsecaseProvider = Provider<CreateRoleUsecase>((ref) {
  final roleRepository = ref.read(roleRepositoryProvider);
  return CreateRoleUsecase(roleRepository: roleRepository);
});

class CreateRoleUsecase implements UsecaseWithParams<bool, CreateRoleParams> {
  final IroleRepository _roleRepository;

  CreateRoleUsecase({required IroleRepository roleRepository})
    : _roleRepository = roleRepository;

  @override
  Future<Either<Failure, bool>> call(CreateRoleParams params) {
    // object creation
    RoleEntity roleEntity = RoleEntity(roleName: params.roleName);

    return _roleRepository.createRole(roleEntity);
  }
}