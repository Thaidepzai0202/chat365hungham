// import 'package:app_chat365_pc/modules/chat/model/chat_member_model.dart';
// import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
// import 'package:app_chat365_pc/modules/chat_conversations/models/result_chat_conversation.dart';
// import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
// import 'package:equatable/equatable.dart';
// import 'package:hive_flutter/hive_flutter.dart';
//
// @HiveType(typeId: 100, adapterName: 'LocalChatModelBox')
// class LocalChatModel extends Equatable {
//   @HiveField(0)
//   final int conversationId;
//   @HiveField(1)
//   final String conversationName;
//   @HiveField(2)
//   final int adminId;
//   @HiveField(3)
//   final String avatarConversation;
//   @HiveField(4)
//   final String lastMessage;
//   @HiveField(5)
//   final MessageType lastMessageType;
//   @HiveField(6)
//   final int lastSenderId;
//   @HiveField(7)
//   final DateTime createAt;
//   @HiveField(8)
//   final DateTime timeLastMessage;
//   @HiveField(9)
//   final int isFavorite;
//   @HiveField(10)
//   final int notification;
//   @HiveField(11)
//   final int isHidden;
//   @HiveField(12)
//   final int deleteTime;
//   @HiveField(13)
//   final int deleteType;
//   @HiveField(14)
//   final int unReader;
//   @HiveField(15)
//   final int isGroup;
//   @HiveField(16)
//   final String typeGroup;
//   @HiveField(17)
//   final List<ChatMemberModel> listMember;
//   @HiveField(18)
//   final List<SocketSentMessageModel> listMessage;
//
//   @override
//   List<Object> get props => [];
//
//   const LocalChatModel({
//     required this.conversationId,
//     required this.conversationName,
//     required this.adminId,
//     required this.avatarConversation,
//     required this.lastMessage,
//     required this.lastMessageType,
//     required this.lastSenderId,
//     required this.createAt,
//     required this.timeLastMessage,
//     required this.isGroup,
//     this.isFavorite = 0,
//     this.notification = 1,
//     this.isHidden = 0,
//     this.deleteTime = 0,
//     this.deleteType = 0,
//     this.unReader = 0,
//     this.typeGroup = 'Normal',
//     this.listMember = const <ChatMemberModel>[],
//     this.listMessage = const <SocketSentMessageModel>[],
//   });
//
//   factory fromChatItemModel(ChatItemModel model, List<SocketSentMessageModel> msgs) {
//     return LocalChatModel(
//       conversationId: model.conversationId,
//       conversationName: model.conversationBasicInfo.name,
//       adminId: model.adminId,
//       avatarConversation: model.conversationBasicInfo.avatar,
//       lastMessage: model.message,
//       lastMessageType: model.messageType??MessageType.text,
//       lastSenderId: model.senderId,
//       createAt: model.createAt,
//       timeLastMessage: model.lastMessages,
//       isGroup: isGroup,
//     );
//   }
// }
