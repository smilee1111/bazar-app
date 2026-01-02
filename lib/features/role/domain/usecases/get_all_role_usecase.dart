import 'package:bazar/core/error/failure.dart';
import 'package:bazar/core/usecases/app_usecase.dart';
import 'package:bazar/features/role/data/repositories/role_repository.dart';
import 'package:bazar/features/role/domain/entities/role_entity.dart';
import 'package:bazar/features/role/domain/repositories/role_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAllRoleUseCaseProvider = Provider<GetAllRoleUsecase>((ref){
  return GetAllRoleUsecase(roleRepository: ref.read(roleRepositoryProvider));
});

class GetAllRoleUsecase  implements UsecaseWithoutParams<List<RoleEntity>>{
  final IroleRepository _roleRepository;

  GetAllRoleUsecase({required IroleRepository roleRepository})
  :_roleRepository = roleRepository;


  @override
  Future<Either<Failure, List<RoleEntity>>> call() {
   return _roleRepository.getAllRoles();
  }

}