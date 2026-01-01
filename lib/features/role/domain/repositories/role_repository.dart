import 'package:bazar/core/error/failure.dart';
import 'package:bazar/features/role/domain/entities/role_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IRoleRepository {
  Future<Either<Failure, List<RoleEntity>>> getAllRoles();
  Future<Either<Failure, RoleEntity>> getRoleById(String roleId);
  Future<Either<Failure, bool>> createRole(RoleEntity role);
  Future<Either<Failure, bool>> updateRole(RoleEntity role);
  Future<Either<Failure, bool>> deleteRole(String roleId);


}