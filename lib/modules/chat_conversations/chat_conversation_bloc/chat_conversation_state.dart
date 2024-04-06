part of 'chat_conversation_bloc.dart';

abstract class ChatConversationState {
  const ChatConversationState();

  List<Object> get props => [];

  // void doAffect(BuildContext context, ConversationListState view) {}
}

class ChatConversationInitial extends ChatConversationState {}

class ChatConversationStateLoading extends ChatConversationState {
  final bool markNeedBuild;

  ChatConversationStateLoading({required this.markNeedBuild});

  @override
  List<Object> get props => [markNeedBuild];
}

class ChatConversationStateLoadDone extends ChatConversationState {
  final List<ChatItemModel> _chatItems;
  List<ChatItemModel>? strangers;

  ChatConversationStateLoadDone(List<ChatItemModel> chatItems, {this.strangers})
      : _chatItems = [...chatItems];

  List<ChatItemModel> get chatItems => _chatItems;

  List<ChatItemModel>? get listStrangers => strangers;

  @override
  List<Object> get props => [DateTime.now()];

  // @override
  // void doAffect(BuildContext context, ConversationListState view) {
  //   view.cims = _chatItems;
  // }

  @override
  String toString() {
    // TODO: implement toString
    return "${_chatItems}";
  }
}

class ChatConversationStateError extends ChatConversationState {
  final ExceptionError error;
  final bool markNeedBuild;

  ChatConversationStateError(
    this.error, {
    required this.markNeedBuild,
  });

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatConversationAddFavoriteSuccessState
    extends ChatConversationStateLoadDone {
  ChatConversationAddFavoriteSuccessState(
    List<ChatItemModel> chatItems,
    this.item,
  ) : super(chatItems);

  final ChatItemModel item;
}

class ChatConversationRemoveFavoriteSuccessState
    extends ChatConversationStateLoadDone {
  ChatConversationRemoveFavoriteSuccessState(
    List<ChatItemModel> chatItems,
    this.item,
  ) : super(chatItems);

  final ChatItemModel item;
}

class ChatConversationChangeNotificationSuccessState
    extends ChatConversationStateLoadDone {
  ChatConversationChangeNotificationSuccessState(
    List<ChatItemModel> chatItems,
    this.item,
  ) : super(chatItems);
  final ChatItemModel item;
}

/// hien thi tin nhan chua doc
class ShowUnreadMessageState extends ChatConversationState {}

class ShowUnreadMessageLoadingState extends ChatConversationState {}

class ShowUnreaderFailState extends ChatConversationState {}

// Danh sach cuoc tro chuyen

class InitialChatState extends ChatConversationState {}

class LoadingChatState extends ChatConversationState {}

class LoadedChatState extends ChatConversationState {
  LoadedChatState(this.listConversation);
  final List<ConversationModel> listConversation;
}

class EmptyChatState extends ChatConversationState {}

class ErrorChatState extends ChatConversationState {
  ErrorChatState(this.mess);
  final String mess;
}

// them vao muc yeu thich
class InitialAddFavouriteChatState extends ChatConversationState {}

class LoadingAddFavouriteChatState extends ChatConversationState {}

class LoadedAddFavouriteChatState extends ChatConversationState {}

class ErrorAddFavouriteChatState extends ChatConversationState {
  ErrorAddFavouriteChatState(this.mess);
  final String mess;
}
// class AddFavouriteChatState extends ChatConversationState {}

// bat, tat quang cao
class InitialChangeNotifyChatState extends ChatConversationState {}

class LoadingChangeNotifyChatState extends ChatConversationState {}

class LoadedChangeNotifyChatState extends ChatConversationState {}

class ErrorChangeNotifyChatState extends ChatConversationState {
  ErrorChangeNotifyChatState(this.mess);
  final String mess;
}

// xoá cuộc trò chuyện
class InitialDeleteConversationChatState extends ChatConversationState {}

class LoadingDeleteConversationChatState extends ChatConversationState {}

class LoadedDeleteConversationChatState extends ChatConversationState {}

class ErrorDeleteConversationChatState extends ChatConversationState {
  ErrorDeleteConversationChatState(this.mess);
  final String mess;
}

// danh sach cuộc trò chuyện bị ẩn - list hidden conversation
class InitialHiddenConversationState extends ChatConversationState {}

class LoadingHiddenConversationState extends ChatConversationState {}

class LoadedHiddenConversationState extends ChatConversationState {
  LoadedHiddenConversationState(this.listHiddenConversation);
  List<ConversationHidden> listHiddenConversation;
}

class ErrorHiddenConversationState extends ChatConversationState {
  ErrorHiddenConversationState(this.mess);
  final String mess;
}

// an cuoc tro chuyen
class BeforeHiddenState extends ChatConversationState {}

class SuccessHiddenState extends ChatConversationState {}

// danh sach cuoc tro chuyen chua doc
class InitialUnReadConversationState extends ChatConversationState {}

class LoadingUnReadConversationState extends ChatConversationState {}

class LoadedUnReadConversationState extends ChatConversationState {
  LoadedUnReadConversationState(this.listUnReadConversation);
  List<ConversationModel> listUnReadConversation;
}

class ErrorUnReadConversationState extends ChatConversationState {
  ErrorUnReadConversationState(this.mess);
  final String mess;
}

class ChatConversationStateNotificationStatusChanging
    extends ChatConversationState {}

class ChatConversationStateNotificationStatusChangeError
    extends ChatConversationState {
  final String errMsg;
  ChatConversationStateNotificationStatusChangeError({required this.errMsg});
}

class ChatConversationStateNotificationStatusChanged
    extends ChatConversationState {
  final int conversationId;
  final bool newNotificationStatus;
  ChatConversationStateNotificationStatusChanged(
      {required this.conversationId, required this.newNotificationStatus});
}
