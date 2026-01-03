
import 'package:bazar/features/role/data/models/role_hive_model.dart';

abstract interface class IRoleDataSource {
  Future<List<RoleHiveModel>> getAllRoles();
  Future<RoleHiveModel?> getRoleById(String roleId);
  Future<bool> createRole(RoleHiveModel role);
  Future<bool> updateRole(RoleHiveModel role);
  Future<bool> deleteRole(String roleId);
}