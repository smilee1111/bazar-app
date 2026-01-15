import 'package:bazar/features/role/domain/entities/role_entity.dart';
import 'package:equatable/equatable.dart';

enum RoleStatus { initial, loading, loaded, error, created, updated, deleted }

class RoleState extends Equatable {
  final RoleStatus status;
  final List<RoleEntity> roles;
  final RoleEntity? selectedRole;
  final String? errorMessage;

  const RoleState({
    this.status = RoleStatus.initial,
    this.roles = const [],
    this.selectedRole,
    this.errorMessage,
  });

  RoleState copyWith({
    RoleStatus? status,
    List<RoleEntity>? roles,
    RoleEntity? selectedRole,
    String? errorMessage,
  }) {
    return RoleState(
      status: status ?? this.status,
      roles: roles ?? this.roles,
      selectedRole: selectedRole ?? this.selectedRole,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, roles, selectedRole, errorMessage];
}