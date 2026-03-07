import 'package:bazar/features/auth/data/models/auth_api_model.dart';
import 'package:bazar/features/auth/domain/entities/auth_entity.dart';
import 'package:bazar/features/role/domain/entities/role_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  
  test("toJson tests for registration", () {
    final model = AuthApiModel(
      fullName: "Test User",
      email: "testuser1@gmail.com",
      username: "testuserre",
      password: "password123",
      phoneNumber: "9866321325",
      profilePic: null,
    );

    final json = model.toJson(
      confirmPassword: "password123",
    );

    expect(json["fullName"], "Test User");
    expect(json["email"], "testuser1@gmail.com");
    expect(json["username"], "testuserre");
    expect(json["password"], "password123");
    expect(json.containsKey("role"), isFalse);
    expect(json["roleId"], isNull);
    expect(json["confirmPassword"], "password123");
    expect(json["phoneNumber"], isA<int>());
    expect(json["phoneNumber"], 9866321325);
  });

  test("fromJson should create correct AuthApiModel object", () {
    final jsonData = {
      "_id": "696a0ac90ec828e9e8f5e65e",
      "fullName": "Test User",
      "email": "testuser1@gmail.com",
      "phoneNumber": 9800000014,
      "username": "testuserre",
      "roleId": "696a0ac60ec828e9e8f5e640",
      "role": {
        "_id": "696a0ac60ec828e9e8f5e640",
        "roleName": "user",
        "status": "active",
      }
    };

    final model = AuthApiModel.fromJson(jsonData);

    expect(model.id, "696a0ac90ec828e9e8f5e65e");
    expect(model.fullName, "Test User");
    expect(model.email, "testuser1@gmail.com");
    expect(model.phoneNumber, "9800000014");
    expect(model.username, "testuserre");
    expect(model.roleId, "696a0ac60ec828e9e8f5e640");
    expect(model.role, isNotNull);
    expect(model.role!.id, "696a0ac60ec828e9e8f5e640");
    expect(model.role!.roleName, "user");
    expect(model.role!.status, "active");
  });

  test("toEntity should convert AuthApiModel into AuthEntity", () {
    final model = AuthApiModel(
      id: "test123",
      fullName: "Test User",
      email: "testuser@gmail.com",
      phoneNumber: "9800000014",
      username: "testuser",
      profilePic: "test.png",
    );

    final entity = model.toEntity();

    expect(entity.authId, "test123");
    expect(entity.fullName, "Test User");
    expect(entity.email, "testuser@gmail.com");
    expect(entity.phoneNumber, "9800000014");
    expect(entity.username, "testuser");
    expect(entity.profilePic, "test.png");
  });

  test("fromEntity should convert AuthEntity into AuthApiModel", () {
    final entity = AuthEntity(
      authId: "test999",
      fullName: "Test User",
      email: "testuser@gmail.com",
      phoneNumber: "9800000014",
      username: "testuser",
      password: "testPass",
      profilePic: "test.png",
      roleId: "696a0ac60ec828e9e8f5e640",
      role: const RoleEntity(
        roleId: "role_user_001",
        roleName: "user",
        status: "active",
      ),
    );

    final model = AuthApiModel.fromEntity(entity);

    expect(model.id, "test999");
    expect(model.fullName, "Test User");
    expect(model.email, "testuser@gmail.com");
    expect(model.phoneNumber, "9800000014");
    expect(model.username, "testuser");
    expect(model.password, "testPass");
    expect(model.profilePic, "test.png");
    expect(model.roleId, "696a0ac60ec828e9e8f5e640");
    expect(model.role, isNotNull);
    expect(model.role!.roleName, "user");
  });
}