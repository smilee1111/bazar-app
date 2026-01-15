import 'package:bazar/core/error/failure.dart';
import 'package:bazar/core/services/connectivity/network_info.dart';
import 'package:bazar/features/role/data/datasources/local/role_local_datasource.dart';
import 'package:bazar/features/role/data/datasources/remote/role_remote_datasource.dart';
import 'package:bazar/features/role/data/datasources/role_datasource.dart';
import 'package:bazar/features/role/data/models/role_api_model.dart';
import 'package:bazar/features/role/data/models/role_hive_model.dart';
import 'package:bazar/features/role/domain/entities/role_entity.dart';
import 'package:bazar/features/role/domain/repositories/role_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roleRepositoryProvider = Provider<IroleRepository>((ref) {
  final roleLocalDatasource = ref.read(roleLocalDatasourceProvider);
  final roleRemoteDatasource = ref.read(roleRemoteProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return RoleRepository(
  roleLocalDatasource: roleLocalDatasource,
  roleRemoteDatasource: roleRemoteDatasource,
  networkInfo: networkInfo
  );
});

class RoleRepository implements IroleRepository {
  final IRoleLocalDataSource _roleLocalDataSource;
  final IRoleRemoteDataSource _roleRemoteDataSource;
  final NetworkInfo _networkInfo;

  RoleRepository({
  required IRoleLocalDataSource roleLocalDatasource,
  required IRoleRemoteDataSource roleRemoteDatasource, 
  required NetworkInfo  networkInfo,})
    : _roleLocalDataSource = roleLocalDatasource,
    _roleRemoteDataSource = roleRemoteDatasource,
    _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> createRole(RoleEntity role) async {
    try {
      // conversion
      // entity lai model ma convert gara
      final roleModel = RoleHiveModel.fromEntity(role);
      final result = await _roleLocalDataSource.createRole(roleModel);
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
      final result = await _roleLocalDataSource.deleteRole(roleId);
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
    //check for internet first
    if(await _networkInfo.isConnected){
      try{
        //api model capture
        final apiModels = await  _roleRemoteDataSource.getAllRoles();
        //convert to entity
        final result = RoleApiModel.toEntityList(apiModels);
        return Right(result);
      }
      on DioException catch (e) {
        return Left(ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message']?? 'Failed to fetch roles'
        ));
      }catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }else{
    try {
      final models = await _roleLocalDataSource.getAllRoles();
      final entities = RoleHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
    }
    
  }

  @override
  Future<Either<Failure, RoleEntity>> getRoleById(String roleId) async {
    try {
      final model = await _roleLocalDataSource.getRoleById(roleId);
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
      final result = await _roleLocalDataSource.updateRole(roleModel);
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