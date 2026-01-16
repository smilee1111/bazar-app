import 'package:bazar/core/constants/hive_table_constant.dart';
import 'package:bazar/features/auth/domain/entities/auth_entity.dart';
import 'package:bazar/features/role/domain/entities/role_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';


@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel extends HiveObject{
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String? password;

  @HiveField(5)
  final String? roleId;

  @HiveField(6)
  final String? phoneNumber;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.roleId,
  }) : authId =authId ??const Uuid().v4();



  AuthEntity toEntity({RoleEntity? role}){
      return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
      password: password,
      roleId: roleId,
      role: role,
    );
  }

  factory AuthHiveModel.fromEntity(AuthEntity entity){
      return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      password: entity.password,
      roleId: entity.roleId ?? entity.role?.roleId,
    );
  }

    // To Entity List
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}