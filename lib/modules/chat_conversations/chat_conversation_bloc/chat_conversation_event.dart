part of 'chat_conversation_bloc.dart';

abstract class ChatConversationEvent {
  const ChatConversationEvent();

  @override
  List<Object> get props => [];
}

class ChatConversationEventAddData extends ChatConversationEvent {
  final List<ChatItemModel> list;
  final bool saveToLocal;
  final bool insertAtTop;
  final bool reset;
  final List<ChatItemModel>? listStrange;
  ChatConversationEventAddData(
    this.list, {
    this.listStrange,
    this.saveToLocal = false,
    this.insertAtTop = false,
    this.reset = false,
  }) : assert(reset && saveToLocal || !reset,
            'Nếu [reset] == true thì [saveToLocal] == true');

  @override
  List<Object> get props => [list];
}

class ChatConversationEventRaiseError extends ChatConversationEvent {
  final ExceptionError error;

  ChatConversationEventRaiseError(this.error);

  @override
  List<Object> get props => [DateTime.now()];
}

class ChangeHiddenStatusEvent extends ChatConversationEvent {
  final List<ChatItemModel> chatItemModel;
  ChangeHiddenStatusEvent(this.chatItemModel);
}

class ChatConversationEventAddLoadingState extends ChatConversationEvent {
  final bool? markNeedBuild;

  ChatConversationEventAddLoadingState({this.markNeedBuild = false});

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatConversationEventDeleteConversation extends ChatConversationEvent {
  final int conversationId;

  ChatConversationEventDeleteConversation(this.conversationId);

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatConversationEventAddFavoriteConversation
    extends ChatConversationEvent {
  final ChatItemModel item;

  ChatConversationEventAddFavoriteConversation(this.item);
}

class ChatConversationEventAddHiddenConversation extends ChatConversationEvent {
  final ChatItemModel item;

  ChatConversationEventAddHiddenConversation(this.item);
}

class ChatConversationEventRemoveFavoriteConversation
    extends ChatConversationEvent {
  final ChatItemModel item;

  ChatConversationEventRemoveFavoriteConversation(this.item);
}

class ChatConversationEmitEvent extends ChatConversationEvent {
  final List<ChatItemModel> list;

  ChatConversationEmitEvent(this.list);

  @override
  List<Object> get props => [this.list];
}

class ChatConversationEventChangeNotificationStatus
    extends ChatConversationEvent {
  final int conversationId;

  /// Mặc định luôn là người dùng hiện tại. AuthRepo id
  //final int userId;
  ChatConversationEventChangeNotificationStatus(this.conversationId);
}
