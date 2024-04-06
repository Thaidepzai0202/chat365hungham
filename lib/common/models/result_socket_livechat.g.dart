// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_socket_livechat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SocketSentLivechatMessageModelAdapter
    extends TypeAdapter<SocketSentLivechatMessageModel> {
  @override
  final int typeId = 28;

  @override
  SocketSentLivechatMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocketSentLivechatMessageModel(
      conversationId: fields[0] as int,
      messageId: fields[1] as String,
      senderId: fields[2] as int,
      emotion: (fields[5] as Map).cast<Emoji, Emotion>(),
      type: fields[3] as MessageType?,
      message: fields[4] as String?,
      replyMessage: fields[6] as ApiReplyMessageModel?,
      createAt: fields[7] as DateTime,
      files: (fields[8] as List?)?.cast<ApiFileModel>(),
      infoLink: fields[9] as InfoLink?,
      contact: fields[10] as IUserInfo?,
      linkNotification: fields[12] as String?,
      infoSupport: fields[14] as InfoSupport?,
      liveChat: fields[15] as LiveChat?,
      autoDeleteMessageTimeModel: fields[13] as AutoDeleteMessageTimeModel,
    ).._messageStatus = fields[11] as MessageStatus;
  }

  @override
  void write(BinaryWriter writer, SocketSentLivechatMessageModel obj) {
    writer
      ..writeByte(16)
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
      ..write(obj.replyMessage)
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
      ..write(obj.infoSupport)
      ..writeByte(15)
      ..write(obj.liveChat);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocketSentLivechatMessageModelAdapter &&
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
      suportId: fields[2] as String,
      haveConversation: fields[3] as int,
      userId: fields[4] as int,
      status: fields[5] as int,
      time: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InfoSupport obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.suportId)
      ..writeByte(3)
      ..write(obj.haveConversation)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.time);
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
      clientId: fields[0] as String,
      clientName: fields[1] as String,
      fromWeb: fields[2] as String,
      fromConversation: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LiveChat obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.clientId)
      ..writeByte(1)
      ..write(obj.clientName)
      ..writeByte(2)
      ..write(obj.fromWeb)
      ..writeByte(3)
      ..write(obj.fromConversation);
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
