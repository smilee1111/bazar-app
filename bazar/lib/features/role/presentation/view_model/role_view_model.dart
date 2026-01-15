import 'package:bazar/features/role/domain/usecases/create_role_usecase.dart';
import 'package:bazar/features/role/domain/usecases/get_all_role_usecase.dart';
import 'package:bazar/features/role/domain/usecases/update_role_usecase.dart';
import 'package:bazar/features/role/presentation/state/role_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



final roleViewModelProvider = NotifierProvider<RoleViewModel, RoleState>(RoleViewModel.new);
class RoleViewModel extends Notifier<RoleState>{

  late final GetAllRoleUsecase _getAllRoleUsecase;
  late final CreateRoleUsecase _createRoleUsecase;
  late final UpdateRoleUsecase _updateRoleUsecase;
  
  @override
  RoleState build() {
   _getAllRoleUsecase = ref.read(getAllRoleUseCaseProvider);
    _createRoleUsecase = ref.read(createRoleUsecaseProvider);
    _updateRoleUsecase = ref.read(updateRoleUseCaseProvider);
    return const RoleState();
  }


  Future<void> getAllRoles() async{
    state= state.copyWith(status: RoleStatus.loading);

    final result = await _getAllRoleUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: RoleStatus.error,
        errorMessage: failure.message,
      ),
      (roles) => 
        state = state.copyWith(
          status: RoleStatus.loaded,
          roles: roles,
        ),
    );
  }

    Future<void> createRole(String roleName) async {
    state = state.copyWith(status: RoleStatus.loading);

    final result = await _createRoleUsecase(
      CreateRoleParams(roleName: roleName),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: RoleStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: RoleStatus.created);
        getAllRoles();
      },
    );
  }

    Future<void> updateRole({
    required String roleId,
    required String roleName,
    String? status,
  }) async {
    state = state.copyWith(status: RoleStatus.loading);

    final result = await _updateRoleUsecase(
      UpdateRoleParams(roleId: roleId, roleName: roleName, status: status),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: RoleStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: RoleStatus.updated);
        getAllRoles();
      },
    );
  }

}