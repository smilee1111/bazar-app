import 'package:bazar/core/api/api_client.dart';
import 'package:bazar/core/api/api_endpoints.dart';
import 'package:bazar/features/role/data/datasources/role_datasource.dart';
import 'package:bazar/features/role/data/models/role_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';




//Provider

final roleRemoteProvider = Provider<IRoleRemoteDataSource>((ref){
  return RoleRemoteDatasource(apiClient: ref.read(apiClientProvider));
});
class RoleRemoteDatasource implements IRoleRemoteDataSource{

  
  final ApiClient _apiClient;

  RoleRemoteDatasource({
    required ApiClient apiClient
  }): _apiClient = apiClient;
  
  @override
  Future<bool> createRole(RoleApiModel role) async{
    final response = await _apiClient.get(ApiEndpoints.roles);
    return response.data['success'] == true;
  }

  @override
  Future<List<RoleApiModel>> getAllRoles() async{
    final response = await _apiClient.get(ApiEndpoints.roles);
    final data = response.data['data'] as  List;
    return data.map((json) => RoleApiModel.fromJson(json)).toList();
  }

  @override
  Future<RoleApiModel?> getRoleById(String roleId) {
    // TODO: implement getRoleById
    throw UnimplementedError();
  }

  @override
  Future<bool> updateRole(RoleApiModel role) {
    // TODO: implement updateRole
    throw UnimplementedError();
  }

}