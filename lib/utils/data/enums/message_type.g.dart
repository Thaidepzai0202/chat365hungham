// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 5;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.image;
      case 2:
        return MessageType.file;
      case 3:
        return MessageType.time;
      case 4:
        return MessageType.contact;
      case 5:
        return MessageType.notification;
      case 6:
        return MessageType.link;
      case 7:
        return MessageType.map;
      case 8:
        return MessageType.missVideoCall;
      case 9:
        return MessageType.timeoutVideoCall;
      case 10:
        return MessageType.rejectVideoCall;
      case 11:
        return MessageType.mettingVideoCall;
      case 12:
        return MessageType.applying;
      case 13:
        return MessageType.OfferReceive;
      case 14:
        return MessageType.unknown;
      case 15:
        return MessageType.document;
      case 16:
        return MessageType.appointment;
      case 17:
        return MessageType.sendCV;
      case 18:
        return MessageType.sticker;
      case 19:
        return MessageType.video;
      case 20:
        return MessageType.reminder;
      case 21:
        return MessageType.reminderNoti;
      case 22:
        return MessageType.vote;
      case 23:
        return MessageType.notificationGroup;
      case 24:
        return MessageType.voice;
      case 25:
        return MessageType.adsCC;
      case 26:
        return MessageType.adsCV;
      case 27:
        return MessageType.adsNews;
      default:
        return MessageType.text;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.text:
        writer.writeByte(0);
        break;
      case MessageType.image:
        writer.writeByte(1);
        break;
      case MessageType.file:
        writer.writeByte(2);
        break;
      case MessageType.time:
        writer.writeByte(3);
        break;
      case MessageType.contact:
        writer.writeByte(4);
        break;
      case MessageType.notification:
        writer.writeByte(5);
        break;
      case MessageType.link:
        writer.writeByte(6);
        break;
      case MessageType.map:
        writer.writeByte(7);
        break;
      case MessageType.missVideoCall:
        writer.writeByte(8);
        break;
      case MessageType.timeoutVideoCall:
        writer.writeByte(9);
        break;
      case MessageType.rejectVideoCall:
        writer.writeByte(10);
        break;
      case MessageType.mettingVideoCall:
        writer.writeByte(11);
        break;
      case MessageType.applying:
        writer.writeByte(12);
        break;
      case MessageType.OfferReceive:
        writer.writeByte(13);
        break;
      case MessageType.unknown:
        writer.writeByte(14);
        break;
      case MessageType.document:
        writer.writeByte(15);
        break;
      case MessageType.appointment:
        writer.writeByte(16);
        break;
      case MessageType.sendCV:
        writer.writeByte(17);
        break;
      case MessageType.sticker:
        writer.writeByte(18);
        break;
      case MessageType.video:
        writer.writeByte(19);
        break;
      case MessageType.reminder:
        writer.writeByte(20);
        break;
      case MessageType.reminderNoti:
        writer.writeByte(21);
        break;
      case MessageType.vote:
        writer.writeByte(22);
        break;
      case MessageType.notificationGroup:
        writer.writeByte(23);
        break;
      case MessageType.voice:
        writer.writeByte(24);
        break;
      case MessageType.adsCC:
        writer.writeByte(25);
        break;
      case MessageType.adsCV:
        writer.writeByte(26);
        break;
      case MessageType.adsNews:
        writer.writeByte(27);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
