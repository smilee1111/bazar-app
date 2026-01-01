import 'package:bazar/core/error/failure.dart';
import 'package:bazar/core/usecases/app_usecase.dart';
import 'package:bazar/features/role/data/repositories/role_repository.dart';
import 'package:bazar/features/role/domain/entities/role_entity.dart';
import 'package:bazar/features/role/domain/repositories/role_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateRoleUsecaseParams extends Equatable{
  final String roleId;
  final String roleName;

  const UpdateRoleUsecaseParams({
    required this.roleId,
    required this.roleName,
  });
  
  @override
  List<Object?> get props => [roleId,roleName];
}


final updateRoleUseCaseProvider = Provider<UpdateRoleUsecase>((ref){
  return UpdateRoleUsecase(roleRepository: ref.read(roleRepositoryProvider));
});

class UpdateRoleUsecase 
implements UseCaseWithParams<bool, UpdateRoleUsecaseParams>{
  final IroleRepository _roleRepository;

  UpdateRoleUsecase({required IroleRepository roleRepository})
    : _roleRepository = roleRepository;
  
  @override
  Future<Either<Failure, bool>> call(UpdateRoleUsecaseParams params) {
   RoleEntity roleEntity = RoleEntity(
    roleId: params.roleId,
    roleName: params.roleName,
    );

    return _roleRepository.updateRole(roleEntity);
  }
  
}