// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model_zalo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserInfoZaloAdapter extends TypeAdapter<UserInfoZalo> {
  @override
  final int typeId = 36;

  @override
  UserInfoZalo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserInfoZalo(
      ava: fields[1] as String,
      idZalo: fields[2] as String,
      name: fields[0] as String,
      numPhoneZalo: fields[3] as String,
      status: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserInfoZalo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.ava)
      ..writeByte(2)
      ..write(obj.idZalo)
      ..writeByte(3)
      ..write(obj.numPhoneZalo)
      ..writeByte(4)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoZaloAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
