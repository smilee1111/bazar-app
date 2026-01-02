import 'package:bazar/core/constants/hive_table_constant.dart';
import 'package:bazar/features/auth/data/models/auth_hive_model.dart';
import 'package:bazar/features/role/data/models/role_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';


final hiveServiceProvider = Provider<HiveService>((ref){
  return HiveService();
});


class HiveService {

  //initialization 
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();        
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
     _registerAdapters();
    await _openBoxes();
    await insertDummyRoles();
  }

  Future<void> insertDummyRoles() async{
    // Use the already-opened box instead of opening it again
    final box = _roleBox;
    if(box.isNotEmpty) return;

    final dummyRoles = [
      RoleHiveModel(roleName: 'User'),
      RoleHiveModel(roleName: 'Seller'),
    ];
    for(var role in dummyRoles){
      await box.put(role.roleId,role);
    }
    // Don't close the box here - it's used throughout the app
  }

   //Register all type adapters 
  void _registerAdapters() {
    if(!Hive.isAdapterRegistered(HiveTableConstant.roleTypeId)){
      Hive.registerAdapter(RoleHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
    Hive.registerAdapter(AuthHiveModelAdapter());
    }

  }

//OPEN BOXES
  Future<void> _openBoxes() async {
    await Hive.openBox<RoleHiveModel>(HiveTableConstant.roleTable);
    await Hive.openBox<RoleHiveModel>(HiveTableConstant.userTable);

  }

    // box close
  Future<void> _close() async {
    await Hive.close();
  }


//ROLE METHODS
   Box<RoleHiveModel> get _roleBox =>
    Hive.box<RoleHiveModel>(HiveTableConstant.roleTable);

  
  //Create a new role 
  Future<RoleHiveModel> createRole(RoleHiveModel role) async {
    await _roleBox.put(role.roleId,role);
    return role;
  }

  //Get all roles
  List<RoleHiveModel> getAllRoles(){
    return _roleBox.values.toList();
  }


  //Get role by ID
  RoleHiveModel? getRoleById(String roleId){
    return _roleBox.get(roleId);
  }

  //Update a role
  Future<void> updateRole(RoleHiveModel role) async {
    await _roleBox.put(role.roleId,role);
  }


  //Delete a role
  Future<void> deleteRole(String roleId) async {
    await _roleBox.delete(roleId);
  }
 


//AUTH METHODS
Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.userTable);

  // Register user
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
    return user;
  }

  // Login - find user by email and password
  AuthHiveModel? login(String email, String password) {
    try {
      return _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  AuthHiveModel? getUserById(String authId) {
    return _authBox.get(authId);
  }

  // Get user by email
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Update user
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.authId)) {
      await _authBox.put(user.authId, user);
      return true;
    }
    return false;
  }

  // Delete user
  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }

}