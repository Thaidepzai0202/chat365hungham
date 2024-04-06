// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_member_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMemberModelAdapter extends TypeAdapter<ChatMemberModel> {
  @override
  final int typeId = 6;

  @override
  ChatMemberModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMemberModel(
      unReader: fields[19] as int,
      readMessageTime: fields[20] as DateTime?,
      id: fields[0] as int,
      name: fields[1] as String,
      avatar: fields[3] as String?,
      userStatus: fields[2] as UserStatus,
      status: fields[7] as String?,
      lastActive: fields[8] as DateTime?,
      companyId: fields[4] as int?,
      fromWeb: fields[13] as String?,
      seenMessage: fields[15] as int?,
    )
      ..email = fields[5] as String?
      ..id365 = fields[6] as int?
      ..password = fields[9] as String?
      ..friendStatus = fields[10] as FriendStatus?
      ..userType = fields[11] as UserType?
      ..userQr = fields[12] as String?
      ..idTimviec = fields[14] as int?
      ..depId = fields[16] as int?
      ..nameCom = fields[17] as String?
      ..isOnline = fields[18] as int?;
  }

  @override
  void write(BinaryWriter writer, ChatMemberModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(19)
      ..write(obj.unReader)
      ..writeByte(20)
      ..write(obj.readMessageTime)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.userStatus)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.companyId)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.id365)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.lastActive)
      ..writeByte(9)
      ..write(obj.password)
      ..writeByte(10)
      ..write(obj.friendStatus)
      ..writeByte(11)
      ..write(obj.userType)
      ..writeByte(12)
      ..write(obj.userQr)
      ..writeByte(13)
      ..write(obj.fromWeb)
      ..writeByte(14)
      ..write(obj.idTimviec)
      ..writeByte(15)
      ..write(obj.seenMessage)
      ..writeByte(16)
      ..write(obj.depId)
      ..writeByte(17)
      ..write(obj.nameCom)
      ..writeByte(18)
      ..write(obj.isOnline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMemberModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
