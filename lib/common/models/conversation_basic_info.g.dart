// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_basic_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationBasicInfoAdapter extends TypeAdapter<ConversationBasicInfo> {
  @override
  final int typeId = 8;

  @override
  ConversationBasicInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationBasicInfo(
      conversationId: fields[26] as int,
      isGroup: fields[19] as bool,
      userId: fields[27] as int,
      pinMessageId: fields[23] as String?,
      groupLastSenderId: fields[24] as int?,
      lastConversationMessageTime: fields[21] as DateTime?,
      lastConversationMessage: fields[20] as String?,
      countUnreadMessage: fields[22] as int?,
      totalGroupMemebers: fields[28] as int?,
      lastMessasgeId: fields[29] as String?,
      name: fields[1] as String,
      id365: fields[6] as int?,
      avatar: fields[3] as String?,
      userStatus: fields[2] as UserStatus,
      lastActive: fields[8] as DateTime?,
      companyId: fields[4] as int?,
      email: fields[5] as String?,
      friendStatus: fields[10] as FriendStatus?,
      fromWeb: fields[13] as String?,
      status: fields[7] as String?,
    )
      ..message = fields[25] as String?
      ..id = fields[0] as int
      ..password = fields[9] as String?
      ..userType = fields[11] as UserType?
      ..userQr = fields[12] as String?
      ..idTimviec = fields[14] as int?
      ..seenMessage = fields[15] as int?
      ..depId = fields[16] as int?
      ..nameCom = fields[17] as String?
      ..isOnline = fields[18] as int?;
  }

  @override
  void write(BinaryWriter writer, ConversationBasicInfo obj) {
    writer
      ..writeByte(30)
      ..writeByte(19)
      ..write(obj.isGroup)
      ..writeByte(20)
      ..write(obj.lastConversationMessage)
      ..writeByte(21)
      ..write(obj.lastConversationMessageTime)
      ..writeByte(22)
      ..write(obj.countUnreadMessage)
      ..writeByte(23)
      ..write(obj.pinMessageId)
      ..writeByte(24)
      ..write(obj.groupLastSenderId)
      ..writeByte(25)
      ..write(obj.message)
      ..writeByte(26)
      ..write(obj.conversationId)
      ..writeByte(27)
      ..write(obj.userId)
      ..writeByte(28)
      ..write(obj.totalGroupMemebers)
      ..writeByte(29)
      ..write(obj.lastMessasgeId)
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
      other is ConversationBasicInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
