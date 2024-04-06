// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApiContactAdapter extends TypeAdapter<ApiContact> {
  @override
  final int typeId = 17;

  @override
  ApiContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApiContact(
      id: fields[0] as int,
      name: fields[1] as String,
      avatar: fields[3] as String?,
      lastActive: fields[8] as DateTime?,
      companyId: fields[4] as int?,
      status: fields[7] as String?,
      active: fields[33] as int?,
      isOnline: fields[18] as int?,
      looker: fields[35] as int?,
      statusEmotion: fields[36] as int?,
      email: fields[5] as String?,
      friendStatus: fields[10] as FriendStatus,
    )
      ..lastConversationMessage = fields[20] as String?
      ..lastConversationMessageTime = fields[21] as DateTime?
      ..countUnreadMessage = fields[22] as int?
      ..pinMessageId = fields[23] as String?
      ..groupLastSenderId = fields[24] as int?
      ..message = fields[25] as String?
      ..totalGroupMemebers = fields[28] as int?
      ..lastMessasgeId = fields[29] as String?
      ..userStatus = fields[2] as UserStatus
      ..id365 = fields[6] as int?
      ..password = fields[9] as String?
      ..userType = fields[11] as UserType?
      ..userQr = fields[12] as String?
      ..fromWeb = fields[13] as String?
      ..idTimviec = fields[14] as int?
      ..seenMessage = fields[15] as int?
      ..depId = fields[16] as int?
      ..nameCom = fields[17] as String?;
  }

  @override
  void write(BinaryWriter writer, ApiContact obj) {
    writer
      ..writeByte(34)
      ..writeByte(30)
      ..write(obj.id)
      ..writeByte(31)
      ..write(obj.groupName)
      ..writeByte(32)
      ..write(obj.status)
      ..writeByte(33)
      ..write(obj.active)
      ..writeByte(34)
      ..write(obj.isOnline)
      ..writeByte(35)
      ..write(obj.looker)
      ..writeByte(36)
      ..write(obj.statusEmotion)
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
      ..write(obj.nameCom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
