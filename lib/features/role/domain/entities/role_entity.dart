import 'package:equatable/equatable.dart';

class RoleEntity extends Equatable{
  //defining variables
  final String? roleId;
  final String roleName;

  //constructor for role entity
  const RoleEntity({
    this.roleId,
    required this.roleName,
  });

  // Equatable props override
  @override
  List<Object?> get props => [
    roleId,
    roleName,
  ];

}