part of 'chat_detail_bloc.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object> get props => [];
}

class ChatDetailEventLoadConversationDetail extends ChatDetailEvent {
  final bool loadMessage;

  const ChatDetailEventLoadConversationDetail({
    this.loadMessage = true,
  });
}

/// Event fetch data từ api
///
/// Dùng để load ds Message khi vào màn ChatScreen và chức năng Loadmore
class ChatDetailEventFetchListMessages extends ChatDetailEvent {}

/// TL 18/1/2024: Event khi có tin nhắn mới realtime, dùng để làm mới lại màn chat,
/// nhưng không muốn gọi API
class ChatDetailEventRefreshListMessages extends ChatDetailEvent {
  final int? range;
  const ChatDetailEventRefreshListMessages({this.range});
}

/// addAll([listMsgs]) vào sau list
class ChatDetailEventAddNewListMessages extends ChatDetailEvent {
  final List<SocketSentMessageModel> listMsgs;

  /// Dành cho tin nhắn notification add member

  /// Check tin nhắn thêm vào là tin nhắn từ socket hay tin nhắn fake lên UI
  final bool isTempMessage;
  final bool isRemoteMessage;

  ChatDetailEventAddNewListMessages(
    this.listMsgs, {
    this.isTempMessage = false,
    this.isRemoteMessage = false,
  });

  @override
  List<Object> get props => [DateTime.now()];
}

/// insertAll([listMsgs]) vào trước list
class ChatDetailEventInsertNewListMessages extends ChatDetailEvent {
  final List<SocketSentMessageModel> listMsgs;
  final bool scrollToBottom;

  ChatDetailEventInsertNewListMessages(this.listMsgs,
      {this.scrollToBottom = false});

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatDetailEventRaiseError extends ChatDetailEvent {
  final ExceptionError error;

  ChatDetailEventRaiseError(this.error);

  @override
  List<Object> get props => [error];
}

class ChatDetailEventMarkReadMessage extends ChatDetailEvent {
  final int conversationId;
  final int senderId;

  ChatDetailEventMarkReadMessage(this.conversationId, this.senderId);
}

class ChatDetailEventAllMemberReadMessage extends ChatDetailEvent {
  final int conversationId;
  final String messageId;

  ChatDetailEventAllMemberReadMessage(this.conversationId, this.messageId);
}
