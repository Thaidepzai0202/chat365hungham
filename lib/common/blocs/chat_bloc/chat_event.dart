part of 'chat_bloc.dart';

abstract class ChatEvent {
  const ChatEvent();
}

// On Events: Các event on từ server

/// Có tin nhắn mới
class ChatEventOnReceivedMessage extends ChatEvent {
  final SocketSentMessageModel msg;

  ChatEventOnReceivedMessage(this.msg);

  @override
  int get hashCode => Object.hashAll([msg.messageId]);

  @override
  bool operator ==(Object other) =>
      other is ChatStateReceiveMessage &&
      other.runtimeType == runtimeType &&
      other.msg.messageId == msg.messageId;
}

/// ChatEventOnTyping: Có người bắt đầu gõ tin nhắn
class ChatEventOnTyping extends ChatEvent {
  final int senderId;
  final int conversationId;

  ChatEventOnTyping({
    required this.senderId,
    required this.conversationId,
  });
}

/// Có người dùng dừng gõ tin nhắn
class ChatEventOnStopTyping extends ChatEvent {
  final int senderId;
  final int conversationId;

  ChatEventOnStopTyping({
    required this.senderId,
    required this.conversationId,
  });
}

class ChatEventOnTapMemberInEmotionShowDialog extends ChatEvent {}

/// TL 22/2/2024: Nhận thả tim, thả cảm xúc vào tin nhắn?
class ChatEventOnRecievedEmotionMessage extends ChatEvent {
  final int senderId;
  final String messageId;
  final int conversationId;
  final Emoji emoji;
  final bool checked;
  final MessageType messageType;
  final String message;

  ChatEventOnRecievedEmotionMessage({
    required this.senderId,
    required this.messageId,
    required this.conversationId,
    required this.emoji,
    required this.checked,
    required this.messageType,
    required this.message,
  });
}

/// Có tin nhắn được chỉnh sửa
class ChatEventOnMessageEditted extends ChatEvent {
  final int conversationId;
  final String messageId;
  final String newMessage;

  ChatEventOnMessageEditted(
    this.conversationId,
    this.messageId,
    this.newMessage,
  );
}

/// Thành viên mới tham gia nhóm
class ChatEventOnNewMemberAddedToGroup extends ChatEvent {
  final int conversationId;
  final List<UserInfo> members;

  ChatEventOnNewMemberAddedToGroup(this.conversationId, this.members);
}

/// Có sự thay đổi trong trạng thái mối quan hệ (kết bạn, hủy bạn,...)
class ChatEventOnFriendStatusChanged extends ChatEvent {
  final int requestUserId;
  final int responseUserId;
  final FriendStatus status;

  ChatEventOnFriendStatusChanged(
      this.requestUserId, this.responseUserId, this.status);
}

/// Có tin nhắn được ghim
class ChatEventOnPinMessage extends ChatEvent {
  final int conversationId;
  final String messageId;

  ChatEventOnPinMessage(this.conversationId, this.messageId);
}

/// Có tin nhắn bỏ ghim
class ChatEventOnUnpinMessage extends ChatEvent {
  final int conversationId;

  ChatEventOnUnpinMessage(this.conversationId);
}

/// Có tin nhắn bị xóa
class ChatEventOnDeleteMessage extends ChatEvent {
  final int conversationId;
  final String messageId;

  ChatEventOnDeleteMessage(this.conversationId, this.messageId);
}

class ChatEventToEmitDeleteMessageWithMessageIndexInConversation
    extends ChatEvent {
  final int conversationId;
  final String messageId;
  final int messageIndex;
  final SocketSentMessageModel? aboveMessage;
  final SocketSentMessageModel? belowMessage;

  ChatEventToEmitDeleteMessageWithMessageIndexInConversation(
    this.conversationId,
    this.messageId,
    this.messageIndex, {
    this.aboveMessage,
    this.belowMessage,
  });
}

/// Không chắc: Xóa liên hệ (danh bạ?)
class ChatEventOnDeleteContact extends ChatEvent {
  final int userId;
  final int chatId;

  ChatEventOnDeleteContact(this.userId, this.chatId);
}

/// Người dùng sửa trạng thái yêu thích của CTC
class ChatEventOnChangeFavoriteStatus extends ChatEvent {
  final int conversationId;
  final bool isChangeToFavorite;

  ChatEventOnChangeFavoriteStatus(this.conversationId, this.isChangeToFavorite);
}

/// Người dùng sửa trạng thái nhận thông báo
class ChatEventOnChangeNotification extends ChatEvent {
  final int conversationId;
  final bool isNotification;

  ChatEventOnChangeNotification(this.conversationId, this.isNotification);
}

/// Tạo CTC bí mật
class ChatEventOnCreateSecretConversation extends ChatEvent {
  final int conversationId;
  final String typeGroup;

  ChatEventOnCreateSecretConversation(this.conversationId, this.typeGroup);
}

/// Sửa thời gian tin nhắn tự xóa
class ChatEventOnUpdateDeleteTime extends ChatEvent {
  final int conversationId;
  final List<dynamic> senderId;
  final int deletedTime;
  ChatEventOnUpdateDeleteTime(
      this.conversationId, this.senderId, this.deletedTime);
}

/// Rời/bị đá khỏi nhóm (có thể chính là bản thân)
class ChatEventOnOutGroup extends ChatEvent {
  final int conversationId;
  final int deletedMemberId;
  final int newAdminId;

  ChatEventOnOutGroup(
    this.conversationId,
    this.deletedMemberId,
    this.newAdminId,
  );
}

/// TL 19/2/2024:
///
/// Event thông báo cuộc trò chuyện bị xóa. Cache cũng sẽ nghe và xóa CTC.
class ChatEventOnDeleteConversation extends ChatEvent {
  final int conversationId;

  ChatEventOnDeleteConversation(
    this.conversationId,
  );
}

/// Có người dùng đã đọc hết tin nhắn CTC
class ChatEventOnMarkReadAllMessages extends ChatEvent {
  final int senderId;
  final int conversationId;

  ChatEventOnMarkReadAllMessages(
      {required this.senderId, required this.conversationId});
}

// ========================= END ON EVENT ======================================

// ========================= Emit Events: các event emit lên server =============

class ChatEventEmitSendMessage extends ChatEvent {
  final ApiMessageModel message;
  final List<int> recieveIds;
  final ConversationBasicInfo? conversationBasicInfo;
  final List<int>? onlineUsers;
  final int? isSecret;

  ChatEventEmitSendMessage(
    this.message, {
    required this.recieveIds,
    this.conversationBasicInfo,
    this.onlineUsers,
    this.isSecret,
  });
}

class ChatEventEmitReSendMessage extends ChatEvent {
  final Map<String, dynamic> errorMsgMap;

  const ChatEventEmitReSendMessage({
    required this.errorMsgMap,
  });
}

class ChatEventEmitTypingChanged extends ChatEvent {
  final bool isTyping;
  final int userId;
  final int conversationId;
  final List<int> listMembers;

  ChatEventEmitTypingChanged(
    this.isTyping, {
    required this.userId,
    required this.conversationId,
    required this.listMembers,
  });
}

class ChatEventEmitMarkReadMessage extends ChatEvent {
  /// Nếu [null]: đánh dấu Seen tất cả tin nhắn (chưa xem) trong cuộc trò chuyện
  final int? messageId;
  final int senderId;
  final int conversationId;
  final List<int> memebers;

  ChatEventEmitMarkReadMessage({
    this.messageId,
    required this.senderId,
    required this.conversationId,
    required this.memebers,
  });
}

class ChatEventEmitChangeReationMessage extends ChatEvent {
  final int userId;
  final String messageId;
  final int conversationId;
  final Emoji emoji;
  final bool isChecked;
  final MessageType messageType;
  final String message;
  List<int> allMemberIdsInConversation;
  List<int> memberReactThisEmoji;
  String conversationName;
  Map<Emoji, Emotion>? emotion;
  final SocketSentMessageModel messageModel;

  ChatEventEmitChangeReationMessage(
    this.userId,
    this.messageId,
    this.conversationId,
    this.emoji,
    this.isChecked,
    this.messageType,
    this.message,
    this.allMemberIdsInConversation,
    this.memberReactThisEmoji,
    this.conversationName, {
    this.emotion,
    required this.messageModel,
  });
}

class ChatEventEmitDeleteMessage extends ChatEvent {
  final ApiMessageModel message;
  final List<int> members;

  ChatEventEmitDeleteMessage(this.message, this.members);
}

class ChatEventEmitDeleteMessageFake extends ChatEvent {
  final ApiMessageModel message;

  ChatEventEmitDeleteMessageFake(this.message);
}

class ChatEventEmitDeleteMultiMessage extends ChatEvent {
  final List<ApiMessageModel> messages;
  final List<int> members;

  ChatEventEmitDeleteMultiMessage(
      {required this.messages, required this.members});
}

class ChatEventEmitRecallMessage extends ChatEvent {
  final ApiMessageModel message;
  final List<int> members;

  ChatEventEmitRecallMessage(this.message, this.members);
}

// thu hồi nhiều tin nhắn
class ChatEventEmitRecallMultiMessage extends ChatEvent {
  final List<ApiMessageModel> message;
  final List<int> members;

  ChatEventEmitRecallMultiMessage(
      {required this.message, required this.members});
}

class ChatEventEmitNewConversationCreated extends ChatEvent {
  final int conversationId;
  final List<int> members;

  ChatEventEmitNewConversationCreated(this.conversationId, this.members);
}

class ChatEventEmitEditMessage extends ChatEvent {
  final ApiMessageModel message;

  /// trường bên dưới dùng để đẩy socket
  final List<int> memebers;

  ChatEventEmitEditMessage(
    this.message, {
    required this.memebers,
  });
}

class ChatEventEmitChangeFavoriteConversation extends ChatEvent {
  final int userId;
  final int conversationId;
  final bool changeToFavorite;

  ChatEventEmitChangeFavoriteConversation(
    this.userId,
    this.conversationId,
    this.changeToFavorite,
  );
}

// ========================================END EMIT=========================================

class ChatEventRaiseSendMessageError extends ChatEvent {
  final ApiMessageModel message;
  final ExceptionError error;

  ChatEventRaiseSendMessageError(
    this.error, {
    required this.message,
  });
}

class ChatEventAddProcessingMessage extends ChatEvent {
  final ApiMessageModel message;
  final ProcessMessageType processingType;

  ChatEventAddProcessingMessage(
    this.message, {
    this.processingType = ProcessMessageType.sending,
  });
}

class ChatEventRemoveMessage extends ChatEvent {
  final String messageId;

  ChatEventRemoveMessage(this.messageId);
}

/// Event thay đổi trạng thái cập nhật tin nhắn hỗ trợ của Livechat
class ChatEventOnUpdateStatusMessageSupport extends ChatEvent {
  final int conversationId;
  final String messageId;
  final InfoSupport infoSupport;

  ChatEventOnUpdateStatusMessageSupport(
      {required this.conversationId,
      required this.messageId,
      required this.infoSupport});
}

// // Khác

// class ChatEventGetConversationId extends ChatEvent {
//   final int senderId;
//   final int? userId;
//   final int? conversationId;
//   final dynamic chatInfo;
//   final bool? isGroup;
//   final bool? isNeedToFetchChatInfo;
//   final ChatFeatureAction? action;
//   final String? groupType;
//   final String? deleteTime;
//   final String? messageId;
//   final bool backToNavigation;

//   ChatEventGetConversationId(
//     this.senderId, {
//     this.chatInfo,
//     this.userId,
//     this.conversationId,
//     this.isGroup,
//     this.isNeedToFetchChatInfo = false,
//     this.action,
//     this.groupType,
//     this.deleteTime,
//     this.messageId,
//     this.backToNavigation = true,
//   });
// }

class ChatEventAddFriend extends ChatEvent {
  final int senderId;
  final int chatId;

  ChatEventAddFriend(this.senderId, this.chatId);
}

class ChatEventResponseAddFriend extends ChatEvent {
  final FriendStatus status;

  /// Id người từ chối hoặc chấp nhận lợi mời
  final int responseId;

  /// Id người gửi lời mời
  final int requestId;

  ChatEventResponseAddFriend(this.responseId, this.requestId, this.status);
}

/// Có người dùng đăng nhập
class ChatEventOnLoggedIn extends ChatEvent {
  final int userId;

  ChatEventOnLoggedIn(this.userId);
}

/// Có người dùng chuyển trạng thái đăng nhập (? Không chắc ?) (?? Ủa sao không gộp luôn cùng [ChatEventOnLoggedIn]??)
class ChatEventOnAuthStatusChanged extends ChatEvent {
  final int userId;
  final AuthStatus authStatus;

  ChatEventOnAuthStatusChanged(
    this.userId,
    this.authStatus,
  );
}

class ChatEventResendMessage extends ChatEvent {
  final int conversationId;
  final List<ApiMessageModel> messages;
  final List<int> members;
  final Function(ApiMessageModel)? onResend;

  ChatEventResendMessage(
    this.conversationId,
    this.messages,
    this.members, {
    this.onResend,
  });
}

class ChatEventLogOutAllDevice extends ChatEvent {}

class ChatEventLogOutStrangeDevice extends ChatEvent {
  //final int userId;
  final String deviceId;
  ChatEventLogOutStrangeDevice(this.deviceId);
}

/// TL 18/2/2024:
///
/// Thấy có socket event này, nhưng không biết payload có gì.
///
/// Ai biết thì thêm vào hộ với.
class ChatEventOnGroupNameChanged extends ChatEvent {
  final String name;
  final int conversationId;

  ChatEventOnGroupNameChanged(
      {required this.name, required this.conversationId});
}

/// TL 18/2/2024:
///
/// Thấy có socket event này, nhưng không biết payload có gì.
///
/// Ai biết thì thêm vào hộ với.
class ChatEventOnGroupAvatarChanged extends ChatEvent {
  final String avatar;
  final int conversationId;

  ChatEventOnGroupAvatarChanged(
      {required this.avatar, required this.conversationId});
}

/// TL TODO: Tìm nội dung payload trong UserInfoRepo
class ChatEventOnNickNameChanged extends ChatEvent {
  final String name;
  final int userId;

  ChatEventOnNickNameChanged({required this.name, required this.userId});
}

/// TL TODO: Tìm nội dung payload trong UserInfoRepo
class ChatEventOnUserNameChanged extends ChatEvent {
  final String name;
  final int userId;

  ChatEventOnUserNameChanged({required this.name, required this.userId});
}

/// TL TODO: Tìm nội dung payload trong UserInfoRepo
class ChatEventOnUserStatusChanged extends ChatEvent {
  final UserStatus newStatus;
  final int userId;

  ChatEventOnUserStatusChanged({required this.newStatus, required this.userId});
}

/// Cập nhật dòng tin nhắn trạng thái
class ChatEventOnUserStatusMessageChanged extends ChatEvent {
  final String newStatusMessage;
  final int userId;

  ChatEventOnUserStatusMessageChanged(
      {required this.newStatusMessage, required this.userId});
}

class ChatEventUserActiveTimeChanged extends ChatEvent {
  final int userId;
  final AuthStatus newAuthStatus;

  /// Nếu online thì null
  final DateTime? lastActive;

  ChatEventUserActiveTimeChanged(
      {required this.userId,
      required this.newAuthStatus,
      required this.lastActive});
}

class ChatEventOnUserAvatarChanged extends ChatEvent {
  final int userId;
  final String avatar;

  ChatEventOnUserAvatarChanged({required this.userId, required this.avatar});
}

class ChatEventOnQRLogin extends ChatEvent {
  final int userId;
  final int userType;
  final String account;
  final String md5;

  ChatEventOnQRLogin(
      {required this.userId,
      required this.userType,
      required this.account,
      required this.md5});
}

class ChatEventOnQRLoginZalo extends ChatEvent {
  final String base6QR;

  ChatEventOnQRLoginZalo({required this.base6QR});
}

class ChatEventLoginSuccessZalo extends ChatEvent {
  final UserInfoZalo userInfoZalo;

  ChatEventLoginSuccessZalo({required this.userInfoZalo});
}

class CheckLoginZalo extends ChatEvent {
  final String checkcheck;

  CheckLoginZalo({required this.checkcheck});
}

class UpdateListZalo extends ChatEvent {
  List<FriendZalo> listFriend = [];

  UpdateListZalo({required this.listFriend});
}

class ListConversationZalo extends ChatEvent {
  List<ConversationItemZaloModel> listConversationZalo;
  ListConversationZalo({required this.listConversationZalo});
}
