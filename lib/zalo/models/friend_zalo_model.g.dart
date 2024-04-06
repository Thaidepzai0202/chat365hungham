// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_zalo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FriendZaloAdapter extends TypeAdapter<FriendZalo> {
  @override
  final int typeId = 37;

  @override
  FriendZalo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FriendZalo(
      id: fields[0] as String,
      name: fields[1] as String,
      ava: fields[2] as String,
      numLabel: fields[3] as int,
      nameLabel: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FriendZalo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.ava)
      ..writeByte(3)
      ..write(obj.numLabel)
      ..writeByte(4)
      ..write(obj.nameLabel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendZaloAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
