
import 'package:bazar/features/role/data/models/role_api_model.dart';
import 'package:bazar/features/role/data/models/role_hive_model.dart';

abstract interface class IRoleLocalDataSource {
  Future<List<RoleHiveModel>> getAllRoles();
  Future<RoleHiveModel?> getRoleById(String roleId);
  Future<bool> createRole(RoleHiveModel role);
  Future<bool> updateRole(RoleHiveModel role);
  Future<bool> deleteRole(String roleId);
}

abstract interface class IRoleRemoteDataSource {
  Future<List<RoleApiModel>> getAllRoles();
  Future<RoleApiModel?> getRoleById(String roleId);
  Future<bool> createRole(RoleApiModel role);
  Future<bool> updateRole(RoleApiModel role);
  // Future<bool> deleteRole(String roleId);
}