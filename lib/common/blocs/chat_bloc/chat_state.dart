part of 'chat_bloc.dart';

abstract class ChatState {
  ChatState();

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatInitial extends ChatState {}

/// Các State liên quan đến tin nhắn
abstract class ChatMessageState extends ChatState {
  final String messageId;

  ChatMessageState(this.messageId);
}

class ChatStateOnTapMemberInEmotionShowDialogLoaded extends ChatState {
  ChatStateOnTapMemberInEmotionShowDialogLoaded({
    required this.conversationId,
  });

  final int conversationId;

  @override
  List<Object> get props => [conversationId];
}

class ChatStateOnReceivedEmotionMessage extends ChatMessageState {
  final int senderId;
  final int conversationId;
  final Emoji emoji;
  final bool checked;
  final MessageType messageType;
  final String message;

  ChatStateOnReceivedEmotionMessage(
      super.messageId, {
    required this.senderId,
    required this.conversationId,
    required this.emoji,
    required this.checked,
    required this.messageType,
    required this.message,
  });

  @override
  List<Object> get props =>
      [
        senderId,
        messageId,
        conversationId,
        emoji,
        checked,
        messageType,
        message,
      ];
}

class ChatStateReceiveMessage extends ChatMessageState {
  final SocketSentMessageModel msg;

  /// Check tin nhắn nhận được là từ socket hay tin nhắn từ UI đẩy lên
  final bool isTempMessage;

  ChatStateReceiveMessage(
    this.msg, {
    this.isTempMessage = false,
  }) : super(msg.messageId);

  @override
  int get hashCode => Object.hashAllUnordered([msg.messageId, isTempMessage]);

  @override
  bool operator ==(Object other) =>
      other is ChatStateReceiveMessage &&
      other.runtimeType == runtimeType &&
      other.msg.messageId == msg.messageId &&
      other.isTempMessage == isTempMessage;
}

//
class ChatStateSendMessageSuccess extends ChatMessageState {
  final String messageId;

  ChatStateSendMessageSuccess(this.messageId) : super(messageId);

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatStateSendMessageError extends ChatMessageState {
  final ExceptionError error;
  final ApiMessageModel message;

  ChatStateSendMessageError(
    this.error, {
    required this.message,
  }) : super(message.messageId);

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatStateInProcessingMessage extends ChatMessageState {
  final ApiMessageModel message;
  final ProcessMessageType processingType;

  ChatStateInProcessingMessage(
    this.message, {
    this.processingType = ProcessMessageType.sending,
  }) : super(message.messageId);

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatStateEditMessageSuccess extends ChatMessageState {
  final int? conversationId;
  final String messageId;
  final String newMessage;
  final int editType;

  ChatStateEditMessageSuccess(
    this.conversationId,
    this.messageId,
    this.newMessage, {
    this.editType = 1,
  }) : super(messageId);

  @override
  List<Object> get props => [DateTime.now()];
}

//thu hoi
class ChatStateEditMultiMessageSuccess extends ChatMessageState {
  ChatStateEditMultiMessageSuccess() : super("");

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatStateWarningMessageError extends ChatMessageState {
  final ExceptionError error;
  final String messageId;

  ChatStateWarningMessageError(
    this.messageId,
    this.error,
  ) : super(messageId);

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatStateDeleteMessageSuccess extends ChatMessageState {
  final String messageId;
  final int conversationId;
  final int? messageIndex;
  final SocketSentMessageModel? messageBelow;
  final SocketSentMessageModel? messageAbove;

  ChatStateDeleteMessageSuccess(
    this.messageId,
    this.conversationId, {
    this.messageIndex,
    this.messageBelow,
    this.messageAbove,
  }) : super(messageId);

  @override
  List<Object> get props => [messageId];
}

class ChatStateDeleteMultiMessageSuccess extends ChatMessageState {
  ChatStateDeleteMultiMessageSuccess() : super("");

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatStateRecallMessageSuccess extends ChatMessageState {
  final String messageId;
  final int conversationId;
  final int? messageIndex;
  final SocketSentMessageModel? messageBelow;
  final SocketSentMessageModel? messageAbove;

  ChatStateRecallMessageSuccess(
    this.messageId,
    this.conversationId, {
    this.messageIndex,
    this.messageBelow,
    this.messageAbove,
  }) : super(messageId);

  @override
  List<Object> get props => [messageId];
}

class ChatStateNewMemberAddedToGroup extends ChatState {
  final int conversationId;
  final List<IUserInfo> members;

  ChatStateNewMemberAddedToGroup(this.conversationId, this.members);

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatStateFavoriteConversationStatusChanged extends ChatState {
  final int conversationId;
  final bool isChangeToFavorite;

  ChatStateFavoriteConversationStatusChanged(
    this.conversationId,
    this.isChangeToFavorite,
  );
}

class ChatStateNotificationConversationStatusChanged extends ChatState {
  final int conversationId;
  final bool isOnNotification;
  ChatStateNotificationConversationStatusChanged(
    this.conversationId,
    this.isOnNotification,
  );
}

class ChatStateCreateSecretConversation extends ChatState {
  final int conversationId;
  final String typeGroup;
  ChatStateCreateSecretConversation(
    this.conversationId,
    this.typeGroup,
  );
}

class ChatStateUpdateDeleteTime extends ChatState {
  final int conversationId;
  final List<dynamic> senderId;
  final int deleteTime;
  ChatStateUpdateDeleteTime(
    this.conversationId,
    this.senderId,
    this.deleteTime,
  );
}
// Get conversation ============================================================

class ChatStateGetConversationId extends ChatState {
  final IUserInfo? chatInfo;

  ChatStateGetConversationId({this.chatInfo});
}

@Deprecated("Chức năng này nên ở AuthRepo chứ")
class ChatStateLogOutAllDevice extends ChatState {
  ChatStateLogOutAllDevice();
}

class ChatStateGettingConversationId extends ChatStateGetConversationId {
  ChatStateGettingConversationId() : super();
}

class ChatStateGetConversationIdError extends ChatStateGetConversationId {
  final ExceptionError error;

  ChatStateGetConversationIdError(this.error, dynamic chatInfo) : super();
}

// class ChatStateGetConversationIdSuccess extends ChatStateGetConversationId {
//   final int conversationId;
//   final IUserInfo chatInfo;
//   final bool isGroup;
//   final ChatFeatureAction? action;
//   final ChatItemModel? chatItemModel;
//   final String? groupType;
//   final String? deleteTime;
//   final String? messageId;
//   final bool backToNavigation;
//   ChatStateGetConversationIdSuccess(
//     this.conversationId,
//     this.chatInfo,
//     this.isGroup, {
//     this.action,
//     this.chatItemModel,
//     this.groupType,
//     this.deleteTime,
//     this.messageId,
//     this.backToNavigation = true,
//   }) : super(chatInfo: chatInfo);
// }

// Response add friend =========================================================

class ChatStateOutGroup extends ChatState {
  final int conversationId;
  final int deletedId;
  final int newAdminId;

  ChatStateOutGroup(
    this.conversationId,
    this.deletedId,
    this.newAdminId,
  );
}

class SentMessageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitialSentMessageState extends SentMessageState {}

class LoadingSentMessageState extends SentMessageState {}

class LoadedSentMessageState extends SentMessageState {}

class ErrorSentMessageState extends SentMessageState {}
