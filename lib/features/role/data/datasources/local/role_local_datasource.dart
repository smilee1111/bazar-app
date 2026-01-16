import 'package:bazar/core/services/hive/hive_service.dart';
import 'package:bazar/features/role/data/datasources/role_datasource.dart';
import 'package:bazar/features/role/data/models/role_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



// create provider
final roleLocalDatasourceProvider = Provider<RoleLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return RoleLocalDatasource(hiveService: hiveService);
});

class RoleLocalDatasource implements IRoleLocalDataSource{

  final HiveService _hiveService;

    RoleLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;
  
  @override
  Future<bool> createRole(RoleHiveModel role) async {
    try {
      await _hiveService.createRole(role);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteRole(String roleId) async {
      try {
      await _hiveService.deleteRole(roleId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<RoleHiveModel>> getAllRoles() async{
        try {
      return _hiveService.getAllRoles();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<RoleHiveModel?> getRoleById(String roleId) async{
       try {
      return _hiveService.getRoleById(roleId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateRole(RoleHiveModel role) async {
    try {
      await _hiveService.updateRole(role);
      return true;
    } catch (e) {
      return false;
    }
  }
  }