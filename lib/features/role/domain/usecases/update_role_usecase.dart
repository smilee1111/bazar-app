import 'package:bazar/core/error/failure.dart';
import 'package:bazar/core/usecases/app_usecase.dart';
import 'package:bazar/features/role/data/repositories/role_repository.dart';
import 'package:bazar/features/role/domain/entities/role_entity.dart';
import 'package:bazar/features/role/domain/repositories/role_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateRoleParams extends Equatable{
  final String roleId;
  final String roleName;
  final String? status;

  const UpdateRoleParams({
    required this.roleId,
    required this.roleName,
    this.status,
  });
  
  @override
  List<Object?> get props => [roleId,roleName,status];
}


final updateRoleUseCaseProvider = Provider<UpdateRoleUsecase>((ref){
  return UpdateRoleUsecase(roleRepository: ref.read(roleRepositoryProvider));
});

class UpdateRoleUsecase 
implements UsecaseWithParams<bool, UpdateRoleParams>{
  final IroleRepository _roleRepository;

  UpdateRoleUsecase({required IroleRepository roleRepository})
    : _roleRepository = roleRepository;
  
  @override
  Future<Either<Failure, bool>> call(UpdateRoleParams params) {
   RoleEntity roleEntity = RoleEntity(
    roleId: params.roleId,
    roleName: params.roleName,
    status: params.status,
    );

    return _roleRepository.updateRole(roleEntity);
  }
  
}