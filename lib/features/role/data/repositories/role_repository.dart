import 'package:bazar/core/error/failure.dart';
import 'package:bazar/features/role/data/datasources/local/role_local_datasource.dart';
import 'package:bazar/features/role/data/datasources/role_datasource.dart';
import 'package:bazar/features/role/data/models/role_hive_model.dart';
import 'package:bazar/features/role/domain/entities/role_entity.dart';
import 'package:bazar/features/role/domain/repositories/role_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roleRepositoryProvider = Provider<IRoleRepository>((ref) {
  final roleDatasource = ref.read(roleLocalDatasourceProvider);
  return RoleRepository(roleDatasource: roleDatasource);
});

class RoleRepository implements IRoleRepository {
  final IRoleDataSource _roleDataSource;

  RoleRepository({required IRoleDataSource roleDatasource})
    : _roleDataSource = roleDatasource;

  @override
  Future<Either<Failure, bool>> createRole(RoleEntity role) async {
    try {
      // conversion
      // entity lai model ma convert gara
      final roleModel = RoleHiveModel.fromEntity(role);
      final result = await _roleDataSource.createRole(roleModel);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to create a role"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteRole(String roleId) async {
    try {
      final result = await _roleDataSource.deleteRole(roleId);
      if (result) {
        return Right(true);
      }

      return Left(LocalDatabaseFailure(message: ' Failed to delete role'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoleEntity>>> getAllRoles() async {
    try {
      final models = await _roleDataSource.getAllRoles();
      final entities = RoleHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoleEntity>> getRoleById(String roleId) async {
    try {
      final model = await _roleDataSource.getRoleById(roleId);
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'Role not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateRole(RoleEntity role) async {
    try {
      final roleModel = RoleHiveModel.fromEntity(role);
      final result = await _roleDataSource.updateRole(roleModel);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to update role"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}