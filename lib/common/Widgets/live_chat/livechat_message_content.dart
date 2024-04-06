import 'package:app_chat365_pc/common/Widgets/live_chat/livechat_message_display.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/common/widgets/live_chat/timer_repo.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/text_message_display.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Hiển thị message theo [MessageType] khác nhau
///
/// [files] là các file đính kèm 1 message
class LivechatMessageContent extends StatefulWidget {
  const LivechatMessageContent({
    Key? key,
    required this.onTapImageMessage,
    required this.messageModel,
    this.senderInfo,
    this.listUserInfoBlocs,
  }) : super(key: key);
  final Map<int, UserInfoBloc>? listUserInfoBlocs;
  final SocketSentMessageModel messageModel;
  final IUserInfo? senderInfo;

  /// Callback navigate đến [WidgetSlider] hiển các ảnh trong conversation hiện tại
  final ValueChanged<ApiFileModel> onTapImageMessage;

  @override
  State<LivechatMessageContent> createState() => _LivechatMessageContentState();
}

class _LivechatMessageContentState extends State<LivechatMessageContent> {
  late AppLayoutCubit _appLayoutCubit;
  late ChatDetailBloc _chatDetailBloc;
  late TypingDetectorBloc _typingDetectorBloc;
  late ChatConversationBloc _chatConversationBloc;
  late UserInfoRepo userInfoRepo;
  late ChatRepo chatRepo;
  late ChatBloc _chatBloc;

  @override
  void initState() {
    _appLayoutCubit = context.read<AppLayoutCubit>();
    _chatConversationBloc = context.read<ChatConversationBloc>();
    userInfoRepo = context.read<UserInfoRepo>();
    chatRepo = context.read<ChatRepo>();
    _chatBloc = context.read<ChatBloc>();
    super.initState();
  }

  Future<void> goToChatScreenBeforeLogin() async {
    var conversationIdLiveChaBeforeLogin =
        _chatBloc.conversationIdLiveChatBeforeLogin!;

    // print('milo2 $conversationIdLiveChaBeforeLogin');
    var chatItemModel =
        await ChatRepo().getChatItemModel(conversationIdLiveChaBeforeLogin!);
    var userInfoBloc = UserInfoBloc.fromConversation(
      chatItemModel!.conversationBasicInfo,
      status: chatItemModel.status,
    );
    _typingDetectorBloc =
        _chatConversationBloc.typingBlocs[conversationIdLiveChaBeforeLogin] ??
            TypingDetectorBloc(conversationIdLiveChaBeforeLogin);
    _chatDetailBloc = ChatDetailBloc(
        conversationId: conversationIdLiveChaBeforeLogin,
        senderId: AuthRepo().userInfo!.id,
        isGroup: false,
        initMemberHasNickname: [userInfoBloc.userInfo],
        messageDisplay: -1,
        chatItemModel: chatItemModel,
        unreadMessageCounterCubit: UnreadMessageCounterCubit(
          conversationId: conversationIdLiveChaBeforeLogin,
          countUnreadMessage: 0,
        ),
        deleteTime: -1,
        otherDeleteTime: chatItemModel
                .firstOtherMember(AuthRepo().userInfo!.id)
                .deleteTime ??
            -1,
        myDeleteTime: -1,
        messageId: '',
        typeGroup: chatItemModel.typeGroup)
      ..add(const ChatDetailEventLoadConversationDetail())
      ..getDetailInfo(uInfo: userInfoBloc.userInfo)
      ..conversationName.value =
          '${AuthRepo().userInfo!.name} _ ${widget.messageModel.liveChat!.clientName}(timviec365)_${AuthRepo().userInfo!.id}';
    await _appLayoutCubit.toMainLayout(AppMainPages.chatScreen, providers: [
      BlocProvider<UserInfoBloc>(create: (context) => userInfoBloc),
      BlocProvider<TypingDetectorBloc>.value(value: _typingDetectorBloc),
      BlocProvider<UnreadMessageCounterCubit>(
          create: (context) => UnreadMessageCounterCubit(
              conversationId: conversationIdLiveChaBeforeLogin,
              countUnreadMessage: 0)),
    ], agruments: {
      'chatType':
          chatItemModel.isGroup == true ? ChatType.GROUP : ChatType.SOLO,
      'conversationId': conversationIdLiveChaBeforeLogin,
      'senderId': AuthRepo().userInfo!.id,
      'chatItemModel': chatItemModel,
      'name': chatItemModel.conversationBasicInfo.name,
      'chatDetailBloc': _chatDetailBloc,
      'messageDisplay': -1,
    });
  }

  Widget build(BuildContext context) {
    final Widget child;
    final bool isSentByCurrentUser =
        widget.messageModel.senderId == context.userInfo().id;
    final String? message = widget.messageModel.message;
    final ChatBloc _chatBloc = context.read<ChatBloc>();

    //live chat
    if (widget.messageModel.liveChat != null &&
        widget.messageModel.infoSupport != null) {
      return InkWell(
        child: LiveChatDisplay(
          isSentByCurrentUser: isSentByCurrentUser,
          message: message,
          sentTime: widget.messageModel.createAt.toLocal(),
          messageModel: widget.messageModel,
          listUserInfoBlocs: widget.listUserInfoBlocs,
          senderInfo: widget.senderInfo,
        ),
        onTap: () async {
          timerRepo.stopLivechatMessageTimer(widget.messageModel.messageId);
          if (widget.messageModel.liveChat!.clientId!.contains('liveChatV2')) {
            await _chatBloc.updateStatusMessageSupport(
                conversationId: widget.messageModel.conversationId,
                messageId: widget.messageModel.messageId,
                listmembers: widget.listUserInfoBlocs?.keys.toList(),
                infoSupports: widget.messageModel.infoSupport,
                senderId: widget.messageModel.senderId,
                liveChat: widget.messageModel.liveChat,
                userId: AuthRepo().userInfo!.id);
            var conversationIdLiveChat = _chatBloc.conversationIdLiveChat;

            var chatItemModel =
                await ChatRepo().getChatItemModel(conversationIdLiveChat!);
            var userInfoBloc = UserInfoBloc.fromConversation(
              chatItemModel!.conversationBasicInfo,
              status: chatItemModel.status,
            );
            _typingDetectorBloc =
                _chatConversationBloc.typingBlocs[conversationIdLiveChat] ??
                    TypingDetectorBloc(conversationIdLiveChat);
            _chatDetailBloc = ChatDetailBloc(
                conversationId: conversationIdLiveChat,
                senderId: AuthRepo().userInfo!.id,
                isGroup: false,
                initMemberHasNickname: [userInfoBloc.userInfo],
                messageDisplay: -1,
                chatItemModel: chatItemModel,
                unreadMessageCounterCubit: UnreadMessageCounterCubit(
                  conversationId: conversationIdLiveChat,
                  countUnreadMessage: 0,
                ),
                // _unreadMessageCounterCubit,
                deleteTime: -1,
                otherDeleteTime: chatItemModel
                        .firstOtherMember(AuthRepo().userInfo!.id)
                        .deleteTime ??
                    -1,
                myDeleteTime: -1,
                messageId: '',
                typeGroup: chatItemModel.typeGroup)
              ..add(const ChatDetailEventLoadConversationDetail())
              ..getDetailInfo(uInfo: userInfoBloc.userInfo)
              ..conversationName.value =
                  '${AuthRepo().userInfo!.name} - ${widget.messageModel.liveChat!.clientName}(timviec365)_${AuthRepo().userInfo!.id}';

            chatRepo.deleteLivechatMessage(widget.messageModel);

            chatRepo.updateStatusMessageLivechatSocket(
                conversationIdLiveChat,
                widget.messageModel.messageId,
                widget.listUserInfoBlocs?.keys.toList(),
                widget.messageModel.infoSupport,
                widget.messageModel.senderId,
                widget.messageModel.liveChat);

            await _appLayoutCubit
                .toMainLayout(AppMainPages.chatScreen, providers: [
              BlocProvider<UserInfoBloc>(create: (context) => userInfoBloc),
              BlocProvider<TypingDetectorBloc>.value(
                  value: _typingDetectorBloc),
              BlocProvider<UnreadMessageCounterCubit>(
                  create: (context) => UnreadMessageCounterCubit(
                      conversationId: conversationIdLiveChat,
                      countUnreadMessage: 0)),
            ], agruments: {
              'chatType': chatItemModel.isGroup == true
                  ? ChatType.GROUP
                  : ChatType.SOLO,
              'conversationId': conversationIdLiveChat,
              'senderId': AuthRepo().userInfo!.id,
              'chatItemModel': chatItemModel,
              'name': chatItemModel.conversationBasicInfo.name,
              'chatDetailBloc': _chatDetailBloc,
              'messageDisplay': -1,
            });
          } else {
            _chatBloc.updateStatusMessageSupportBeForeLogin(
                widget.messageModel.conversationId,
                widget.messageModel.messageId,
                widget.listUserInfoBlocs?.keys.toList(),
                widget.messageModel.infoSupport,
                widget.messageModel.senderId,
                widget.messageModel.liveChat,
                context.userInfo().id,
                goToChatScreenBeforeLogin,
                _chatBloc);
          }
        },
      );
    }

    /// Khác, không xác định
    else {
      child = InkWell(
        onTap: () => Clipboard.setData(
            ClipboardData(text: widget.messageModel.toString())),
        child: TextDisplay(
          isSentByCurrentUser: isSentByCurrentUser,
          message: StringConst.canNotDisplayMessage,
          emotionBarSize: ValueNotifier(0),
        ),
      );
    }

    return child;
  }
}
