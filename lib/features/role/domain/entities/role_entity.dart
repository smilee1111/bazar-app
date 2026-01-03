import 'package:equatable/equatable.dart';

class RoleEntity extends Equatable{
  //defining variables
  final String? roleId;
  final String roleName;
  final String? status;

  //constructor for role entity
  const RoleEntity({
    this.roleId,
    required this.roleName,
    this.status
  });

  // Equatable props override
  @override
  List<Object?> get props => [
    roleId,
    roleName,
    status
  ];

}