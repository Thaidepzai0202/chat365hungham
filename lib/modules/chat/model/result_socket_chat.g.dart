// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_socket_chat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SocketSentMessageModelAdapter
    extends TypeAdapter<SocketSentMessageModel> {
  @override
  final int typeId = 11;

  @override
  SocketSentMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocketSentMessageModel(
      isCheck: fields[23] as bool,
      conversationId: fields[0] as int,
      messageId: fields[1] as String,
      senderId: fields[2] as int,
      emotion: (fields[5] as Map).cast<Emoji, Emotion>(),
      type: fields[3] as MessageType?,
      message: fields[4] as String?,
      relyMessage: fields[6] as ApiReplyMessageModel?,
      createAt: fields[7] as DateTime,
      files: (fields[8] as List?)?.cast<ApiFileModel>(),
      infoLink: fields[9] as InfoLink?,
      contact: fields[10] as IUserInfo?,
      linkNotification: fields[12] as String?,
      autoDeleteMessageTimeModel: fields[13] as AutoDeleteMessageTimeModel,
      linkPdf: fields[14] as String?,
      linkPng: fields[15] as String?,
      infoSupport: fields[16] as InfoSupport?,
      liveChat: fields[17] as LiveChat?,
      IsFavorite: fields[18] as int,
      senderName: fields[19] as String?,
      senderAvatar: fields[20] as String?,
      listDeleteUser: (fields[21] as List?)?.cast<int>(),
      uscId: fields[22] as String?,
      isSecretGroup: fields[24] as int?,
      infoSeen: (fields[25] as List?)?.cast<InfoSeen>(),
      deleteTime: fields[26] as int?,
      deleteType: fields[27] as int?,
      strange: (fields[28] as List?)?.cast<dynamic>(),
      isClicked: fields[29] as int?,
    ).._messageStatus = fields[11] as MessageStatus;
  }

  @override
  void write(BinaryWriter writer, SocketSentMessageModel obj) {
    writer
      ..writeByte(30)
      ..writeByte(0)
      ..write(obj.conversationId)
      ..writeByte(1)
      ..write(obj.messageId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.message)
      ..writeByte(5)
      ..write(obj.emotion)
      ..writeByte(6)
      ..write(obj.relyMessage)
      ..writeByte(7)
      ..write(obj.createAt)
      ..writeByte(8)
      ..write(obj.files)
      ..writeByte(9)
      ..write(obj.infoLink)
      ..writeByte(10)
      ..write(obj.contact)
      ..writeByte(11)
      ..write(obj._messageStatus)
      ..writeByte(12)
      ..write(obj.linkNotification)
      ..writeByte(13)
      ..write(obj.autoDeleteMessageTimeModel)
      ..writeByte(14)
      ..write(obj.linkPdf)
      ..writeByte(15)
      ..write(obj.linkPng)
      ..writeByte(16)
      ..write(obj.infoSupport)
      ..writeByte(17)
      ..write(obj.liveChat)
      ..writeByte(18)
      ..write(obj.IsFavorite)
      ..writeByte(19)
      ..write(obj.senderName)
      ..writeByte(20)
      ..write(obj.senderAvatar)
      ..writeByte(21)
      ..write(obj.listDeleteUser)
      ..writeByte(22)
      ..write(obj.uscId)
      ..writeByte(23)
      ..write(obj.isCheck)
      ..writeByte(24)
      ..write(obj.isSecretGroup)
      ..writeByte(25)
      ..write(obj.infoSeen)
      ..writeByte(26)
      ..write(obj.deleteTime)
      ..writeByte(27)
      ..write(obj.deleteType)
      ..writeByte(28)
      ..write(obj.strange)
      ..writeByte(29)
      ..write(obj.isClicked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocketSentMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InfoLinkAdapter extends TypeAdapter<InfoLink> {
  @override
  final int typeId = 16;

  @override
  InfoLink read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InfoLink(
      messageId: fields[0] as String?,
      description: fields[1] as String?,
      title: fields[2] as String?,
      linkHome: fields[3] as String?,
      image: fields[4] as String?,
      haveImage: fields[5] as bool,
      isNotification: fields[7] as bool,
      link: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InfoLink obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.messageId)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.linkHome)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.haveImage)
      ..writeByte(6)
      ..write(obj.link)
      ..writeByte(7)
      ..write(obj.isNotification);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InfoLinkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InfoSupportAdapter extends TypeAdapter<InfoSupport> {
  @override
  final int typeId = 29;

  @override
  InfoSupport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InfoSupport(
      title: fields[0] as String,
      message: fields[1] as String,
      supportId: fields[2] as String?,
      haveConversation: fields[3] as int,
      userId: fields[4] as int,
      status: fields[5] as int?,
      time: fields[6] as String?,
      userName: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InfoSupport obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.supportId)
      ..writeByte(3)
      ..write(obj.haveConversation)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.time)
      ..writeByte(8)
      ..write(obj.userName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InfoSupportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InfoSeenAdapter extends TypeAdapter<InfoSeen> {
  @override
  final int typeId = 31;

  @override
  InfoSeen read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InfoSeen(
      memberId: fields[0] as int?,
      seenTime: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, InfoSeen obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.memberId)
      ..writeByte(1)
      ..write(obj.seenTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InfoSeenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LiveChatAdapter extends TypeAdapter<LiveChat> {
  @override
  final int typeId = 30;

  @override
  LiveChat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiveChat(
      clientId: fields[0] as String?,
      clientName: fields[1] as String?,
      fromWeb: fields[2] as String?,
      fromConversation: fields[3] as int?,
      clientAvatarUrl: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LiveChat obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.clientId)
      ..writeByte(1)
      ..write(obj.clientName)
      ..writeByte(2)
      ..write(obj.fromWeb)
      ..writeByte(3)
      ..write(obj.fromConversation)
      ..writeByte(4)
      ..write(obj.clientAvatarUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveChatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmotionAdapter extends TypeAdapter<Emotion> {
  @override
  final int typeId = 13;

  @override
  Emotion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Emotion(
      type: fields[0] as Emoji,
      listUserId: (fields[1] as List).cast<int>(),
      isChecked: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Emotion obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.listUserId)
      ..writeByte(2)
      ..write(obj.isChecked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
