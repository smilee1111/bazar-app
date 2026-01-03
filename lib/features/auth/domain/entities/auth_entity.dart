import 'package:bazar/features/role/domain/entities/role_entity.dart';
import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable{
  final String? authId;
  final String fullName;
  final String email;
  final String username;
  final String? password;
  final String? roleId;
  final RoleEntity? role; 

  //constructor
  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.roleId,
    this.role,
  });
  
  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    username,
    password,
    roleId,
    role,
  ];


}