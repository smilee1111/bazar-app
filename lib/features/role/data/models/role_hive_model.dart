import 'package:bazar/features/role/domain/entities/role_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:bazar/core/constants/hive_table_constant.dart';

part 'role_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.roleTypeId)

class RoleHiveModel extends HiveObject {
  @HiveField(0)
  final String? roleId;

  @HiveField(1)
  final String roleName;

  @HiveField(2)
  final String? status;
  
  RoleHiveModel({
    String? roleId,
    required this.roleName,String? status
  }) : roleId = roleId ?? Uuid().v4(),
    status = status ?? 'active';
  

  
  // TOENtity
  RoleEntity toEntity() {
    return RoleEntity(roleId: roleId, roleName: roleName, status: status);
  }

  // From Entity -> conversion
  factory RoleHiveModel.fromEntity(RoleEntity entity) {
    return RoleHiveModel(roleName: entity.roleName);
  }

  // EntityList
  static List<RoleEntity> toEntityList(List<RoleHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

}