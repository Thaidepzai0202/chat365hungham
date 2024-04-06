// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationItemZaloModelAdapter
    extends TypeAdapter<ConversationItemZaloModel> {
  @override
  final int typeId = 38;

  @override
  ConversationItemZaloModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationItemZaloModel(
      name: fields[0] as String,
      ava: fields[1] as String,
      checkPined: fields[2] as bool,
      unread: fields[3] as bool,
      lastMess: fields[4] as String,
      timeMess: fields[5] as String,
      numUnread: fields[6] as dynamic,
      tagLabel: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationItemZaloModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.ava)
      ..writeByte(2)
      ..write(obj.checkPined)
      ..writeByte(3)
      ..write(obj.unread)
      ..writeByte(4)
      ..write(obj.lastMess)
      ..writeByte(5)
      ..write(obj.timeMess)
      ..writeByte(6)
      ..write(obj.numUnread)
      ..writeByte(7)
      ..write(obj.tagLabel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationItemZaloModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
