part of 'chat_detail_bloc.dart';

abstract class ChatDetailState {
  const ChatDetailState();

  @override
  List<Object> get props => [];
}

class ChatDetailInitial extends ChatDetailState {}

class ChatDetailStateLoading extends ChatDetailState {
  final bool markNeedBuild;

  ChatDetailStateLoading(this.markNeedBuild);
}

class ChatDetailStateLoadDetailDone extends ChatDetailState {
  final ChatItemModel detail;
  final bool isBroadcastUpdate;

  ChatDetailStateLoadDetailDone(
    this.detail, {
    this.isBroadcastUpdate = true,
  });

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatDetailStateAddmemberLoadone extends ChatDetailState {}

class ChatDetailStateLoadDoneListMessages extends ChatDetailState {
  final List<SocketSentMessageModel> listMsgModels;
  final bool scrollToBottom;

  ChatDetailStateLoadDoneListMessages(this.listMsgModels, {this.scrollToBottom = false});

  @override
  List<Object> get props => [DateTime.now()];
}

class ChatDetailStateError extends ChatDetailState {
  final ExceptionError error;

  ChatDetailStateError(this.error);

  @override
  List<Object> get props => [error, DateTime.now()];
}

class ChatDetailStateMarkReadMessage extends ChatDetailState {
  final int conversationId;
  final int senderId;
  final List<ChatMemberModel> members;

  ChatDetailStateMarkReadMessage(this.conversationId, this.senderId, this.members);
}

class ChatDetailStateAllMemberReadMessage extends ChatDetailState {
  final int conversationId;
  final String mesageId;

  ChatDetailStateAllMemberReadMessage(this.conversationId, this.mesageId);
}
