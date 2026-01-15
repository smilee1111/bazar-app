import 'package:bazar/features/role/domain/entities/role_entity.dart';

class RoleApiModel {
  final String? id;
  final String roleName;
  final String? status;


  RoleApiModel({
    this.id,
    required this.roleName,
    this.status,
  });

  //toJSON
  Map<String,dynamic> toJson(){
    return {
      "roleName" : roleName
    };
  }


//fromJSON
  factory RoleApiModel.fromJson(Map<String,dynamic> json){
    return RoleApiModel(
      id: json['_id'] as String,
      roleName: json['roleName'] as String,
      status: json['status'] as String,
    );
  }
  //toEntity
 RoleEntity toEntity(){
    return RoleEntity(
    roleId: id,
    roleName: roleName,
    status: status);
  }

  //fromEntity
  factory RoleApiModel.fromEntity(RoleEntity entity){
    return RoleApiModel(roleName: entity.roleName);
  }

  //toEntityList
  static List<RoleEntity> toEntityList(List<RoleApiModel> models){
    return models.map((model) => model.toEntity()).toList();
  } 

  //fromEntityList
  static List<RoleApiModel> fromEntityList(List<RoleEntity> entities) {
    return entities.map((entity) => RoleApiModel.fromEntity(entity)).toList();
  }
}