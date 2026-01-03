// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoleHiveModelAdapter extends TypeAdapter<RoleHiveModel> {
  @override
  final int typeId = 0;

  @override
  RoleHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoleHiveModel(
      roleId: fields[0] as String?,
      roleName: fields[1] as String,
      status: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RoleHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.roleId)
      ..writeByte(1)
      ..write(obj.roleName)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
