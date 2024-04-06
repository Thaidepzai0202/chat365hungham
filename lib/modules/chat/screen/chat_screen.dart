// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:app_chat365_pc/common/Widgets/app_error_widget.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_library_cubit/cubit/chat_library_cubit.dart';
import 'package:app_chat365_pc/common/blocs/friend_cubit/cubit/friend_cubit.dart';
import 'package:app_chat365_pc/common/blocs/friend_cubit/cubit/friend_state.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/models/auto_delete_message_time_model.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/models/draft_model.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_service.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat/screen/group_chat_drawer/group_chat_drawer.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/message_item.dart';
import 'package:app_chat365_pc/modules/chat/widgets/app_noti_widget.dart';
import 'package:app_chat365_pc/modules/chat/widgets/appbar_chat.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_input_bar.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_input_bar.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_cubit.dart';
import 'package:app_chat365_pc/modules/profile/repo/group_profile_repo.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/clients/unified_realtime_data_source.dart';
import 'package:app_chat365_pc/utils/data/enums/chat_feature_action.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_status.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';


// TODO: Make another ChatScreenGroup for group chat
SocketSentMessageGetPasteModel? messagePaste;

class ChatScreen extends StatefulWidget {
  ChatScreen({
    Key? key,
    required this.chatType,
    required this.conversationId,
    required this.senderId,
    this.chatItemModel,
    this.messageDisplay,
    this.action,
    this.nickname,
    this.groupType,
    this.deleteTime,
    required this.chatDetailBloc,
    this.messageId,
  });

  final ChatType chatType;
  final String? nickname;
  final int conversationId;
  final int senderId;
  final int? messageDisplay;
  final ChatItemModel? chatItemModel;
  final ChatFeatureAction? action;
  final String? groupType;
  final String? deleteTime;
  final String? messageId;
  final ChatDetailBloc chatDetailBloc;

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late AuthRepo authRepo = AuthRepo();
  ValueNotifier<bool> isFriend = ValueNotifier(false);
  ValueNotifier<String> foundMessageId = ValueNotifier("");
  late SocketSentMessageModel _messageModel;
  late UserInfoBloc _userInfoBloc;
  var kSliverExpandedHeight = 60.0;
  late GroupProfileRepo? _groupProfileRepo;
  late ChatBloc _chatBloc;
  late int _conversationId;
  late ChatConversationBloc _chatConversationBloc;
  late int _currentUserId;
  late int _senderId;
  final ValueKey _centerKey = const ValueKey('center-key');
  late TextEditingController _textFindController;
  bool? autoFocus;
  int? loadedConvId;
  bool _showPinnedMessage = true;
  final StreamController<List<XFile>> fileDropController = StreamController.broadcast();
  Stream<List<XFile>> get fileDropStream => fileDropController.stream;

  // late ProfileCubit _profileCubit;

  // Iterable<int> get listMemeberIds => widget.chatDetailBloc.listUserInfoBlocs.keys;
  late AutoScrollController _scrollController;
  String inputData = '';
  TextEditingController messageController = TextEditingController();
  final GlobalKey<ChatInputBarState> _chatInputBarKey =
      GlobalObjectKey<ChatInputBarState>(DateTime.now());

  /// Check trạng thái đang fetch list message, khi đó [SliverAppBar] sẽ hiển thị
  /// loading
  final ValueNotifier<bool> _isFetchingListMsgs = ValueNotifier(false);
  List<SocketSentMessageModel> messages = [];
  final ValueNotifier<String> _latestMessageId = ValueNotifier("");

  late UnreadMessageCounterCubit _unreadMessageCounterCubit;

  /// Check show nút cuộn xuống cuối danh sách tin
  final ValueNotifier<bool> _isShowFAB = ValueNotifier(false);
  Timer? debounce;

  /// Check show [SliverAppBar]
  ///
  /// Trong trường hợp list message không fill viewport, ẩn [SliverAppBar]
  final ValueNotifier<bool> _isShowSliverAppBar = ValueNotifier(false);
  final ValueNotifier<bool> _isDroppingFile = ValueNotifier(false);


  late TypingDetectorBloc _typingDetectorBloc;

  TextEditingController _textfindController = TextEditingController();

  int totalFound = 0;
  int currentFound = 0;
  List<String> mesFindedCreateAt = [];
  var listMesFinded = Map<int, String>();
  bool scroll = false;
  bool _scrolling = false;
  List<SocketSentMessageModel> msgs = [];
  bool _scrollUp = true;
  int speedFactor = 1000;

  @override
  void initState() {
    _conversationId = widget.chatItemModel?.conversationId ?? 0;
    _textFindController = TextEditingController();
    _scrollController = AutoScrollController(
        // initialScrollOffset: _scrollController.position.maxScrollExtent,
        viewportBoundaryGetter: () => Rect.fromLTRB(
            0, AppDimens.paddingBottom + 100, 0, AppDimens.paddingTop + 60),
        axis: Axis.vertical);

    _userInfoBloc = context.read<UserInfoBloc>();
    _currentUserId = context.userInfo().id;
    autoFocus = true;
    _chatConversationBloc = context.read<ChatConversationBloc>();
    _unreadMessageCounterCubit = context
            .read<ChatConversationBloc>()
            .unreadMessageCounterCubits[_conversationId] ??
        UnreadMessageCounterCubit(
            conversationId: _conversationId, countUnreadMessage: 0);
    logger.log("Conversation id ${widget.chatItemModel?.conversationId}");
    _senderId = widget.senderId;
    _chatBloc = context.read<ChatBloc>();
    _scrollController.addListener(_scrollListener);
    _typingDetectorBloc = context.read<TypingDetectorBloc>();
    if (widget.chatType == ChatType.GROUP)
      _groupProfileRepo =
          GroupProfileRepo(_conversationId, widget.chatType == ChatType.GROUP);

    /// TL 13/1/2024: Dùng mark read mới
    // List<int> list = [];
    // widget.chatItemModel?.memberList.forEach((e) => list.add(e.id));
    // _chatBloc.markReadMessages(
    //     senderId: context.userInfo().id,
    //     conversationId: _conversationId,
    //     memebers: list
    //     //memebers: listMemeberIds.toList(),
    //     );
    ChatRepo().markReadMessage(conversationId: _conversationId);
    checkClear.addListener(() {
      clearFound();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    _textFindController = TextEditingController();
    _scrollController = AutoScrollController(
        // initialScrollOffset: _scrollController.position.maxScrollExtent,
        viewportBoundaryGetter: () => Rect.fromLTRB(
            0, AppDimens.paddingBottom + 100, 0, AppDimens.paddingTop + 60),
        axis: Axis.vertical);
    _userInfoBloc = context.read<UserInfoBloc>();
    _currentUserId = context.userInfo().id;
    autoFocus = true;
    _conversationId = widget.chatItemModel?.conversationId ?? 0;
    _chatConversationBloc = context.read<ChatConversationBloc>();
    _unreadMessageCounterCubit = context
            .read<ChatConversationBloc>()
            .unreadMessageCounterCubits[_conversationId] ??
        UnreadMessageCounterCubit(
            conversationId: _conversationId, countUnreadMessage: 0);
    logger.log("Conversation id ${widget.chatItemModel?.conversationId}");
    _senderId = widget.senderId;
    _chatBloc = context.read<ChatBloc>();
    _scrollController.addListener(_scrollListener);
    _typingDetectorBloc = context.read<TypingDetectorBloc>();
    // TL 15/1/2024: Cứ tạo luôn trong build thôi. Không cần phải gắn
    // if (widget.chatType == ChatType.GROUP)
    //   _groupProfileRepo =
    //       GroupProfileRepo(_conversationId, widget.chatType == ChatType.GROUP);

    // widget.chatDetailBloc = ChatDetailBloc(

    // TL 19/2/2024: Bắt các event realtime từ socket
    ChatRepo().stream.listen((event) {
      if (event is ChatEventOnFriendStatusChanged) {
        checkFriendStatus();
      } else if (event is ChatEventOnReceivedMessage ||
          event is ChatEventOnMessageEditted ||
          event is ChatEventOnDeleteMessage ||
          event is ChatEventOnUpdateStatusMessageSupport) {
        widget.chatDetailBloc.refreshListMessages();
      }
    });
    //_typingDetectorBloc = context.read<TypingDetectorBloc>();
    // TL note 16/12/2023: Đã tạo ở MultiRepositoryProvider trong build()
    // if (widget.chatType == ChatType.GROUP)
    //   _groupProfileRepo =
    //       GroupProfileRepo(_conversationId, widget.chatType == ChatType.GROUP);

    //_chatDetailBloc = widget.chatDetailBloc;

    // TODO: Thêm cả chặn chiếc các thứ vào
    //context.read<PrivacyCubit>().checkBlockMessage(_contactId!);

    // _chatDetailBloc = ChatDetailBloc(
    //     conversationId: _conversationId,
    //     senderId: _senderId,
    //     userInfoRepo: context.read<UserInfoRepo>(),
    //     chatRepo: context.read<ChatRepo>(),
    //     isGroup: widget.chatType == ChatType.GROUP,
    //     initMemberHasNickname:
    //     widget.chatType == ChatType.GROUP ? [] : [_userInfoBloc.userInfo],
    //     messageDisplay: widget.messageDisplay,
    //     chatItemModel: widget.chatItemModel,
    //     unreadMessageCounterCubit: _unreadMessageCounterCubit,
    //     deleteTime: widget.chatItemModel?.deleteTime ??
    //         int.tryParse(widget.deleteTime ?? '-1') ??
    //         -1,
    //     otherDeleteTime:
    //     widget.chatItemModel?.firstOtherMember(_currentUserId).deleteTime ??
    //         -1,
    //     myDeleteTime: widget.chatItemModel?.memberList
    //         .firstWhere((e) => e.id == _currentUserId)
    //         .deleteTime ??
    //         -1,
    //     messageId: widget.messageId,
    //     typeGroup: widget.groupType ?? widget.chatItemModel?.typeGroup)
    //   ..add(ChatDetailEventLoadConversationDetail())
    //   ..getDetailInfo(uInfo: _userInfoBloc.userInfo)
    //   ..conversationName.value = widget.nickname;
    List<int> list = [];
    widget.chatItemModel?.memberList.forEach((e) => list.add(e.id));

    /// TL 19/2/2024: Chuyển qua ChatRepo để cập nhật cả cache
    ChatRepo().markReadMessage(conversationId: _conversationId);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    super.deactivate();
    var chatInputBarState = _chatInputBarKey.currentState;
    if (chatInputBarState != null) {
      var draftContent = chatInputBarState.inputController.text;
      var draftModel;
      if (draftContent.isNotEmpty) {
        if (chatInputBarState.replyingMessage != null) {
          // draftModel = DraftModel(
          //   draftContent,
          //   replyingMessage: chatInputBarState.replyingMessage,
          // );
        } else if (chatInputBarState.isEditing)
          draftModel = DraftModel(
            draftContent,
            editingMessage: chatInputBarState.originMessage,
          );
        else
          draftModel = DraftModel(draftContent);
        _chatConversationBloc.drafts[_conversationId] = draftModel;
      } else {
        _chatConversationBloc.drafts.remove(_conversationId);
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (!widget.chatDetailBloc.isShowOfflineMessage) {
      _chatConversationBloc.chatsMap[_conversationId]?.lastMessages =
          widget.chatDetailBloc.currentLastMessages;
    }
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _chatBloc..cachedMessageImageFile.clear();
    widget.chatDetailBloc.close();
    try {
      _onTypingStatusChanged(navigatorKey.currentContext!, isTyping: false);
    } catch (e) {}
    super.dispose();
  }

  //điều kiện load message
  _scrollListener() {
    if (_scrollController.hasClients) {
      _computeToShowFAB();
      // TL 28/12/2023: Cứ gọi cho nó tải thêm tin nhắn đi.
      // Còn việc tải hay không thì để ChatRepo quyết định
      // if (widget.chatDetailBloc.totalMessages >
      //     widget.chatDetailBloc.loadedMessages) {
      _computeToLoadMoreMessages();
      // }
      _computeReadAllMessage();
    }
  }

  /// FAB: Floating Action Button
  _computeToShowFAB() {
    var isAtBottom =
        _scrollController.position.atEdge && _scrollController.offset == 0;
    if (isAtBottom && _isShowFAB.value) {
      _isShowFAB.value = false;
    } else if (!isAtBottom && !_isShowFAB.value) {
      _isShowFAB.value = true;
    }
  }

  _computeToLoadMoreMessages() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      // print("loadingMessages");
      _isFetchingListMsgs.value = true;
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 250),
          () => widget.chatDetailBloc.add(ChatDetailEventFetchListMessages()));
    }
  }

  _computeToShowSliverAppBar(BuildContext context) {
    if (_scrollController.position.minScrollExtent -
                MediaQuery.of(context).viewInsets.bottom >=
            0 &&
        _isShowSliverAppBar.value) {
      _isShowSliverAppBar.value = false;
    } else if (_scrollController.position.maxScrollExtent != 0 &&
        !_isShowSliverAppBar.value) {
      _isShowSliverAppBar.value = true;
    }
  }

  _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  clearFound() {
    checkSearchMess.value = false;
    totalFound = 0;
    currentFound = 0;
    foundMessageId.value = "";
    mesFindedCreateAt = [];
    listMesFinded = Map<int, String>();
    scroll = false;
    _scrolling = false;
    _scrollUp = true;
    speedFactor = 1000;
    _textfindController.clear();
  }

  _computeReadAllMessage() {
    if (_scrollController.position.atEdge &&
        _scrollController.offset == 0 &&
        _unreadMessageCounterCubit.hasUnreadMessage) {
      _chatBloc.markReadMessages(
        senderId: context.userInfo().id,
        conversationId: _conversationId,
        memebers: listMemeberIds.toList(),
      );
    }
  }

  Iterable<int> get listMemeberIds =>
      widget.chatDetailBloc.listUserInfoBlocs.keys;

  _onTypingStatusChanged(
    BuildContext context, {
    required bool isTyping,
  }) =>
      _chatBloc.add(
        ChatEventEmitTypingChanged(
          isTyping,
          conversationId: _conversationId,
          listMembers: listMemeberIds.toList(),
          userId: context.userInfo().id,
        ),
      );

  //gửi tin nhắn
  _sendMessage(List<ApiMessageModel> messages) {
    _onTypingStatusChanged(context, isTyping: false);

    if (_chatInputBarKey.currentState!.isEditMode) {
      return _chatBloc.add(
        ChatEventEmitEditMessage(
          messages[0],
          memebers: widget.chatDetailBloc.listUserInfoBlocs.keys.toList(),
        ),
      );
    }

    Future.delayed(
      const Duration(milliseconds: 200),
      _scrollToBottom,
    );

    for (var message in messages) {
      widget.chatDetailBloc.add(
        ChatDetailEventAddNewListMessages(
          [
            SocketSentMessageModel(
              conversationId: message.conversationId,
              messageId: message.messageId,
              senderId: message.senderId,
              type: message.type,
              contact: message.contact,
              files: message.files,
              message: message.message,
              relyMessage: message.replyMessage,
              createAt: DateTime.now().add(const Duration(hours: 7)),
              messageStatus: MessageStatus.sending,
              autoDeleteMessageTimeModel:
                  AutoDeleteMessageTimeModel.defaultModel,
              isCheck: false,
              isSecretGroup:
                  // ((widget.groupType ?? (widget.chatDetailBloc.typeGroup ?? '')) ==
                  //         'Secret')
                  //     ? 1
                  //     :
                  0,
              deleteTime:
                  // widget.chatDetailBloc.myDeleteTime ??
                  //     widget.chatItemModel?.memberList
                  //         .firstWhere((e) => e.id == _currentUserId)
                  //         .deleteTime ??
                  -1,
              deleteType:
                  // ((widget.groupType ?? (widget.chatDetailBloc.typeGroup ?? '')) ==
                  //         'Secret')
                  //     ? 1:
                  0,
            ),
          ],
          isTempMessage: true,
        ),
      );
      var members = Map<int, int>();

      for (var entry in widget.chatDetailBloc.listUserInfoBlocs.entries) {
        members[entry.key] =
            entry.value.state.userInfo.lastActive == null ? 1 : 0;
      }
      var newMessage = message.copyWith(
        messageId: message.messageId,
        deleteTime: widget.chatDetailBloc.myDeleteTime ??
            widget.chatItemModel?.memberList
                .firstWhere((e) => e.id == _currentUserId)
                .deleteTime ??
            1,
        deleteType:
            ((widget.groupType ?? (widget.chatDetailBloc.typeGroup ?? '')) ==
                    'Secret')
                ? 1
                : 0,
      );
      //thêm trường companyIdReceive lúc gửi tin nhắn trong cuộc trò chuyện 1-1 để phục vụ cho tin nhắn người lạ
      int? companyId = widget.chatDetailBloc.detail?.memberList
          .firstWhere((e) => e.id != _currentUserId)
          .companyId;

      _chatBloc.sendMessage(
        newMessage,
        memberIds: members.keys.toList(),
        conversationId: _conversationId,
        conversationBasicInfo: ConversationBasicInfo(
          conversationId: _conversationId,
          isGroup: widget.chatType == ChatType.GROUP,
          name: widget.chatType == ChatType.GROUP
              ? _userInfoBloc.state.userInfo.name
              : context.userInfo().name,
          userId: _userInfoBloc.userInfo.id,
          companyId: companyId,
        ),
        onlineUsers: members.values.toList(),
        isSecret:
            ((widget.groupType ?? (widget.chatDetailBloc.typeGroup ?? '')) ==
                    'Secret')
                ? 1
                : 0,
      );
    }
  }

  TextEditingController get inputController =>
      _chatInputBarKey.currentState!.inputController;

  // Trần Lâm Note 25/12/2023:
  // Đây là thủ phạm nháy màn hình xanh khi thêm/xóa thành viên cuộc trò chuyện
  _detailStateListener(BuildContext context, ChatDetailState detailState) {
    BotToast.cleanAll();
    if (detailState is ChatDetailStateError ||
        detailState is ChatDetailStateLoadDoneListMessages) {
      _isFetchingListMsgs.value = false;
    }
    if (detailState is ChatDetailStateError) {
      if (detailState.error.error != 'Cuộc trò chuyện không tồn tại' &&
          !detailState.error.isExceedListChat)
        BotToast.showText(
            text: detailState.error.toString(), contentColor: AppColors.black);
      // AppDialogs.toast(detailState.error.toString());
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_scrollController.hasClients)
          _scrollController.animateTo(
            _scrollController.offset -
                kSliverExpandedHeight +
                context.mediaQueryPadding.top,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
      });
    } else if (detailState is ChatDetailStateLoading &&
        !detailState.markNeedBuild) {
      BotToast.showText(
        text: 'Đang cập nhật cuộc trò chuyện ...',
        contentColor: AppColors.black,
        // textStyle: TextStyle(color: AppColors.white),
        // TL Note 25/12/2023: Quả backgroundColor này chí mạng quá.
        // Nó tô xanh cả màn hình luôn. Xong rồi vụt tắt. Nháy nháy đau hết cả mắt
        //backgroundColor: context.theme.primaryColor);
      );
    } else if (detailState is ChatDetailStateLoadDetailDone &&
        detailState.isBroadcastUpdate) {
      var userInfoRepo = context.read<UserInfoRepo>();

      if (widget.chatType == ChatType.GROUP)
        userInfoRepo.broadCastConversationInfo(
          detailState.detail.conversationBasicInfo,
        );
      else {
        userInfoRepo.broadCastUserInfo(
          detailState.detail.firstOtherMember(_currentUserId),
          name: detailState.detail.effectiveConversationName(_currentUserId),
        );
      }
    }
  }

  _scrollToFindmessage(bool up, {String? messageId}) async {
    int index = -1;
    while (index == -1&&foundMessageId.value.isNotEmpty) {
      if (totalFound > 0 || messageId != null) {
        String messId = messageId ?? foundMessageId.value;
        listMesFinded[currentFound] = foundMessageId.value;
        // logger.log(listMesFinded);
        index = messages.reversed
            .toList()
            .indexWhere((element) => element.messageId == messId);
        // logger.log(messId + msgs.reversed.toList().map((e) => e.messageId).toList().toString());
        logger.log('found index: $index');
        if (index == -1 && checkSearchMess.value) {
          debounce?.cancel();
          debounce = Timer(
              const Duration(milliseconds: 200),
              () => widget.chatDetailBloc
                  .add(ChatDetailEventFetchListMessages()));
          await _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear);
        } else
          await _scrollController.scrollToIndex(index,
          
              preferPosition: AutoScrollPosition.end,
              duration: const Duration(milliseconds: 100));
      } else
        break;
      await Future.delayed(const Duration(milliseconds: 200));
    }
    _scrolling = false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.chatDetailBloc),
        BlocProvider.value(
          value: _unreadMessageCounterCubit,
        ),
        BlocProvider(
            create: (context) => ChatLibraryCubit(
                conversationId: widget.chatDetailBloc.conversationId)),
        BlocProvider(
            create: (context) => ProfileCubit(
                widget.chatDetailBloc.conversationId,
                isGroup: widget.chatDetailBloc.isGroup)),
      ],
      // TL 4/1/2024: Sửa thành scaffold để hiện màn chức năng group chat
      child: RepositoryProvider(
        create: (context) {
          _groupProfileRepo = GroupProfileRepo(_conversationId, true);
          return _groupProfileRepo;
        },
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (value) {
            if (value is! KeyDownEvent) return;
            if (value.logicalKey == LogicalKeyboardKey.f5) {
              chatRepo.refreshConversationMessages(widget.chatDetailBloc.conversationId).then((value) {
                widget.chatDetailBloc.refreshListMessages(range: 20);
              });
              chatRepo.refreshCachedConversations().then((value) {
                _chatConversationBloc.loadData(countLoaded: 0, reset: true);
              });
            }
          },
          child: GestureDetector(
            child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(100.0), // 
                  child: ChatAppBar(
                    nameConversation: widget.chatDetailBloc.conversationName,
                    userInfoBloc: _userInfoBloc,
                    isGroup: widget.chatType == ChatType.GROUP,
                    chatDetailBloc: widget.chatDetailBloc,
                    conversationId: _conversationId,
                  ),
                ),
                endDrawer: const SizedBox(
                  width: 400,
                  child: Drawer(
                    backgroundColor: AppColors
                        .whiteLilac, // TODO: Sửa lại theo Theme khi Thái làm xong
                    child: GroupChatDrawer(),
                  ),
                ),
                body: DropTarget(
                  onDragDone: (detail) {
                    _isDroppingFile.value = false;
                    fileDropController.add(detail.files);
                  },
                  onDragEntered: (detail) {
                    _isDroppingFile.value = true;
                  },
                  onDragExited: (detail) {
                    _isDroppingFile.value = false;
                  },
                  child: SelectionArea(
                    contextMenuBuilder: (context, state) => AdaptiveTextSelectionToolbar(anchors: state.contextMenuAnchors, children: const []),
                    child: Container(
                      color: context.theme.backgroundChatContent,
                      child: Stack(
                        children: [
                          ValueListenableBuilder(
                            valueListenable: changeTheme,
                            builder: (context, value, child) => Column(
                              children: [
                                // ghim tin nhắn
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    if (!_showPinnedMessage) return const SizedBox();
                                    return ValueListenableBuilder<
                                        List<SocketSentMessageModel?>>(
                                      valueListenable: widget.chatDetailBloc.pinnedMessage,
                                      builder: (context, message, child) {
                                        if (!message.isBlank) {
                                          String pinnedBy = ChatRepo()
                                          .getAllChatMembersSync(conversationId: widget.conversationId)
                                          .firstWhereOrNull((e) => e.id == message.first?.senderId)?.name??
                                            "Tin nhắn ghim";
                          
                                          return Container(
                                            color: context.theme.backgroundListChat,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 15.0,
                                                      ),
                                                      child: SvgPicture.asset(
                                                        Images.ic_pin,
                                                        color: context
                                                            .theme.colorPirimaryNoDarkLight,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            AppLocalizations.of(context)!.message,
                                                            style: AppTextStyles.regularW500(
                                                                context,
                                                                size: 14,
                                                                lineHeight: 20,
                                                                color:
                                                                    context.theme.text2Color),
                                                          ),
                                                          //handle too long text
                                                          GestureDetector(
                                                            onTap: () {
                                                              // AppRouter.toPage(
                                                              //   context,
                                                              //   AppPages.List_Pin_Message,
                                                              //   arguments: {
                                                              //     'chatDetailBloc':
                                                              //     _chatDetailBloc
                                                              //   },
                                                              // );
                                                            },
                                                            child: RichText(
                                                              text: TextSpan(
                                                                text:
                                                                    '$pinnedBy: ',
                                                                style:
                                                                    AppTextStyles.regularW500(
                                                                        context,
                                                                        size: 16,
                                                                        lineHeight: 20,
                                                                        color: context.theme
                                                                            .text2Color),
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        '${message.first?.message}',
                                                                    style: context.theme
                                                                        .messageTextStyle,
                                                                  ),
                                                                ],
                                                              ),
                                                              maxLines: 2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    child!,
                                                    const SizedBox(width: 15),
                                                  ],
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(top: 8),
                                                  color: context.theme.isDarkTheme
                                                      ? AppColors.white
                                                      : AppColors.greyCC,
                                                  height: 0.3,
                                                  width: double.infinity,
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        return const SizedBox(
                                          key: ValueKey('non-pinned-message'),
                                        );
                                      },
                                      child: PopupMenuButton(
                                        offset: Offset(20, 20),
                                        padding: EdgeInsets.zero,
                                        color: AppColors.whiteLilac,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        onSelected: (value) async {},
                                        itemBuilder: (context) {
                                          return [
                                            PopupMenuItem(
                                              height: double.minPositive,
                                              value: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  AppLocalizations.of(context)!.copy,
                                                  style:
                                                      context.theme.pinDropdownItemTextStyle,
                                                ),
                                              ),
                                              onTap: () => SystemUtils.copyToClipboard(
                                                widget.chatDetailBloc.pinnedMessage.value
                                                        .first?.message ??
                                                    '',
                                              ),
                                            ),
                                            PopupMenuItem(
                                              height: double.minPositive,
                                              value: 2,
                                              onTap: () =>
                                                  setState(() => _showPinnedMessage = false),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  AppLocalizations.of(context)!.hideMesPIN,
                                                  style:
                                                      context.theme.pinDropdownItemTextStyle,
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              height: double.minPositive,
                                              value: 3,
                                              onTap: () => widget.chatDetailBloc.unPinMessage(
                                                widget.chatDetailBloc.pinnedMessage.value
                                                        .first?.messageId ??
                                                    '',
                                                widget.chatDetailBloc.pinnedMessage.value
                                                        .first?.message ??
                                                    '',
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  AppLocalizations.of(context)!.unpinMess,
                                                  style: context
                                                      .theme.pinDropdownItemTextStyle
                                                      .copyWith(
                                                    color: AppColors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ];
                                        },
                                        child: SvgPicture.asset(
                                          Images.ic_3_dot,
                                          color: context.theme.colorPirimaryNoDarkLight,
                                          width: 24,
                                          height: 20,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ValueListenableBuilder(
                                    valueListenable: checkSearchMess,
                                    builder: (context, value, _) {
                                      return checkSearchMess.value
                                          ? Container(
                                            width: AppDimens.widthPC,
                                            color: context.theme.backgroundChatContent,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 20),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: 33,
                                                      child: TextField(
                                                        controller: _textfindController,
                                                        onChanged: (value) async {
                                                          Future.delayed(const Duration(
                                                              microseconds: 1000));
                                                          var res = await widget
                                                              .chatDetailBloc
                                                              .getCountFindMessage(
                                                                  _textfindController
                                                                      .text,
                                                                  '0');
                                                          totalFound =
                                                              res['count_results'] ?? 0;
                                                          foundMessageId.value = res['mes_finded']
                                                                  ['_id'] ??
                                                              '';
                                                          mesFindedCreateAt.clear();
                                                          mesFindedCreateAt.add(
                                                              res['mes_finded']
                                                                      ['createAt'] ??
                                                                  '');
                                                          currentFound =
                                                              totalFound == 0 ? 0 : 1;
                                                          _scrollToFindmessage(scroll);
                                    
                                                          setState(() {});
                                                        },
                                                        decoration: InputDecoration(
                                                          fillColor: AppColors.transparentGrey,
                                                          hintText:
                                                              'Tìm tin nhắn trong cuộc hội thoại hiện tại',
                                                          hintStyle: const TextStyle(fontSize: 14),
                                                          border:
                                                              const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.horizontal(
                                                                    left: Radius.circular(
                                                                        10)),
                                                            borderSide: BorderSide(
                                                                color: AppColors.black,
                                                                width: 0.3),
                                                          ),
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.horizontal(
                                                                    left: Radius.circular(
                                                                        10)),
                                                            borderSide: BorderSide(
                                                                color: AppColors.black,
                                                                width:
                                                                    0.3), // Màu khi focus
                                                          ),
                                                          prefixIcon: Padding(
                                                            padding:
                                                                const EdgeInsets.all(4),
                                                            child: SvgPicture.asset(
                                                              Images.ic_uil_search,
                                                            ),
                                                          ),
                                                          enabledBorder:
                                                              const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.horizontal(
                                                                    left: Radius.circular(
                                                                        10)),
                                                            borderSide: BorderSide(
                                                                color: AppColors.black,
                                                                width:
                                                                    0.3), // Màkhi không focus
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 33,
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius.horizontal(
                                                                right:
                                                                    Radius.circular(10)),
                                                        border: Border.all(
                                                            color: AppColors.black,
                                                            width: 0.3)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(
                                                          left: 10, right: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              "$currentFound / $totalFound"),
                                                          InkWell(
                                                            onTap: currentFound <
                                                                    totalFound
                                                                ? () async {
                                                                    var res = await widget
                                                                        .chatDetailBloc
                                                                        .getCountFindMessage(
                                                                            _textfindController
                                                                                .text,
                                                                            mesFindedCreateAt[
                                                                                    currentFound -
                                                                                        1]
                                                                                .valueIfNull(
                                                                                    '0'));
                                                                    foundMessageId.value =
                                                                        res['mes_finded']
                                                                            ['_id'];
                                                                    mesFindedCreateAt.add(
                                                                        res['mes_finded']
                                                                            ['createAt']);
                                                                    _scrollUp = true;
                                                                    currentFound++;
                                                                    await _scrollToFindmessage(
                                                                        _scrollUp);
                                                                    listMesFinded[
                                                                            currentFound] =
                                                                        foundMessageId.value;
                                                                    setState(
                                                                      () {},
                                                                    );
                                                                  }
                                                                : null,
                                                            child: Container(
                                                              height: 20,
                                                              width: 20,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(20),
                                                                  color: AppColors
                                                                      .blueGradients1),
                                                              child: SvgPicture.asset(
                                                                  Images.ic_arrow_up,
                                                                  color: AppColors.white),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: currentFound > 1
                                                                ? () {
                                                                    logger.log(
                                                                        listMesFinded);
                                                                    if (currentFound > 1)
                                                                      currentFound--;
                                                                    mesFindedCreateAt
                                                                        .removeLast();
                                                                    foundMessageId.value =
                                                                        listMesFinded[
                                                                                currentFound] ??
                                                                            '';
                                                                    logger
                                                                        .log(foundMessageId.value);
                                                                    _scrollUp = false;
                                                                    _scrollToFindmessage(
                                                                        _scrollUp);
                                                                    setState(
                                                                      () {},
                                                                    );
                                                                  }
                                                                : null,
                                                            child: Container(
                                                              height: 20,
                                                              width: 20,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(20),
                                                                  color: AppColors
                                                                      .blueGradients1),
                                                              child: SvgPicture.asset(
                                                                  Images.ic_arrow_down,
                                                                  color: AppColors.white),
                                                            ),
                                                          ),
                                                          InkWell(
                                                              onTap: () {
                                                                clearFound();
                                                                setState(
                                                                  () {},
                                                                );
                                                              },
                                                              child: const Text("Hủy")),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                          : const SizedBox();
                                    }),
                                    
                                /// [SliverList] bên trong chỉ thay đổi UI khi [detailState]
                                /// is [ChatDetailStateLoadDoneListMessages]
                                Expanded(
                                  child: BlocConsumer<ChatDetailBloc, ChatDetailState>(
                                    bloc: widget.chatDetailBloc,
                                    listener: _detailStateListener,
                                    buildWhen: (prev, current) =>
                                        mounted &&
                                        (current is ChatDetailStateLoadDoneListMessages ||
                                            (current is ChatDetailStateError &&
                                                current.error.isServerError) ||
                                            (current is ChatDetailStateLoading &&
                                                current.markNeedBuild)),
                                    builder: (context, detailState) {
                                      if (detailState
                                          is ChatDetailStateLoadDoneListMessages) {
                                        if (_scrolling || !foundMessageId.value.isBlank) {
                                          _scrollToFindmessage(true, messageId: foundMessageId.value);
                                          _scrolling = false;
                                        }
                                        if (widget.chatDetailBloc.msgs.isEmpty) {
                                          return AppNotiWidget(
                                            noti: "Chưa có cuộc trò chuyện",
                                            buttonLabel: 'Xin chào',
                                            onTap: () {},
                                          );
                                        }
                                        if (detailState.scrollToBottom) {
                                          WidgetsBinding.instance.addPostFrameCallback(
                                            (_) {
                                              _computeToShowSliverAppBar(context);
                                              // logger.log(
                                              //     "---------------------------------------${detailState.scrollToBottom}");
                                              _scrollToBottom();
                                            },
                                          );
                                        }
                                    
                                        // bỏ phần tử giống nhau trong list
                                        messages = detailState.listMsgModels.toSet().toList();
                                    
                                        // logger.log(
                                        //     "ChatScreen ${messages.length} messages: ${messages.map((e) => e.message ?? "unknown").toList()}",
                                        //     name: "$runtimeType.build");
                                        _latestMessageId.value = messages.last.messageId;
                                    
                                        return BlocListener<ChatBloc, ChatState>(
                                          bloc: _chatBloc,
                                          listenWhen: (previous, current) {
                                            /// Nhận được tin nhắn và cùng [conversationId]
                                            var isReciveMessage = current
                                                    is ChatStateReceiveMessage &&
                                                current.msg.conversationId == _conversationId;
                                            var isMessageDeleted =
                                                current is ChatStateDeleteMessageSuccess &&
                                                    current.conversationId == _conversationId;
                                            var isEdittedMessage = current
                                                    is ChatStateEditMessageSuccess &&
                                                current.messageId ==
                                                    _chatInputBarKey.currentState!.messageId;
                                            var isAddedNewMemberToThisGroup =
                                                current is ChatStateNewMemberAddedToGroup &&
                                                    current.conversationId == _conversationId;
                                            var isMemberOutGroup =
                                                current is ChatStateOutGroup &&
                                                    current.conversationId == _conversationId;
                                            var isRecallSuccess =
                                                current is ChatStateEditMultiMessageSuccess;
                                            var isMultiMessageDeleted =
                                                current is ChatStateDeleteMultiMessageSuccess;
                                            var isCreateSecretGroup =
                                                current is ChatStateCreateSecretConversation;
                                            var isUpdateDeleteTime =
                                                current is ChatStateUpdateDeleteTime;
                                    
                                            return mounted && isReciveMessage ||
                                                isMessageDeleted ||
                                                isEdittedMessage ||
                                                isRecallSuccess ||
                                                isMessageDeleted;
                                            // isAddedNewMemberToThisGroup ||
                                            //     isMultiMessageDeleted ||
                                            //     isMemberOutGroup ||
                                            //     isCreateSecretGroup ||
                                            //     isUpdateDeleteTime;
                                          },
                                          listener: (context, state) {
                                            if (state is ChatStateReceiveMessage) {
                                              logger.log("Receive Message");
                                              if (state.msg.senderId == _currentUserId ||
                                                  state.msg.conversationId ==
                                                      _conversationId) {
                                                if (canRead)
                                                  ChatRepo().markReadMessage(conversationId: _conversationId);
                                              }
                                              if (!state.isTempMessage) {
                                                widget.chatDetailBloc
                                                  ..totalMessages += 1
                                                  ..loadedMessages += 1;
                                              }
                                              // if (!detailState.listMsgModels.contains(state.msg)) {
                                              //   widget.chatDetailBloc.add(
                                              //     ChatDetailEventAddNewListMessages([state.msg],
                                              //         isRemoteMessage: true),
                                              //   );
                                              // }
                                            } else if (state
                                                is ChatStateCreateSecretConversation) {
                                              if (state.conversationId == _conversationId) {
                                                widget.chatDetailBloc.typeGroup =
                                                    state.typeGroup;
                                              }
                                            } else if (state is ChatStateUpdateDeleteTime) {
                                              if (state.conversationId == _conversationId) {
                                                if (state.senderId.contains(_currentUserId)) {
                                                  widget.chatDetailBloc.myDeleteTime =
                                                      state.deleteTime;
                                                } else {
                                                  widget.chatDetailBloc.otherDeleteTime =
                                                      state.deleteTime;
                                                }
                                              }
                                            } else if (state is ChatStateEditMessageSuccess) {
                                              _chatInputBarKey.currentState!.exitEditMode();
                                            } else if (state
                                                is ChatStateNewMemberAddedToGroup) {
                                              widget.chatDetailBloc.newMember.addAll(
                                                  state.members.map((e) => e.id).toList());
                                              widget.chatDetailBloc.listUserInfoBlocs.addAll(
                                                Map<int, UserInfoBloc>.fromIterable(
                                                  state.members,
                                                  key: (e) => (e as IUserInfo).id,
                                                  value: (v) => UserInfoBloc(v as IUserInfo),
                                                ),
                                              );
                                              widget.chatDetailBloc.countConversationMember
                                                      .value =
                                                  widget.chatDetailBloc.listUserInfoBlocs
                                                      .length;
                                            } else if (state is ChatStateOutGroup) {
                                              var deletedId = state.deletedId;
                                              var conversationId = state.conversationId;
                                              var member = widget
                                                  .chatDetailBloc.listUserInfoBlocs
                                                  .remove(deletedId);
                                              widget.chatDetailBloc.countConversationMember
                                                      .value =
                                                  widget.chatDetailBloc.listUserInfoBlocs
                                                      .length;
                                              // check member khác null và conversationid có giống nhau không
                                              /// TL 16/2/2024: Bỏ dùng một số biến của ChatDetailBloc
                                              // if (member != null &&
                                              //     conversationId == _conversationId) {
                                              //   widget.chatDetailBloc
                                              //     ..newMember.remove(deletedId)
                                              //     ..tempListUserInfoBlocs[deletedId] = member
                                              //     ..unreadMessageUserAndMessageId
                                              //         .remove(deletedId)
                                              //     ..unreadMessageUserAndMessageIndex
                                              //         .remove(deletedId);
                                              // }
                                              if (deletedId == context.userInfo().id &&
                                                  conversationId == _conversationId) {
                                                HiveService()
                                                    .conversationListBox
                                                    ?.delete(conversationId);
                                                // AppRouter.backToPage(context, AppPages.Navigation);
                                              }
                                            } else if (state
                                                    is ChatStateDeleteMessageSuccess &&
                                                state.messageIndex == null) {
                                              var msgs = widget.chatDetailBloc.msgs;
                                              logger.log(
                                                  '${state.messageId}  ${msgs.map((e) => e.messageId).toList()}',
                                                  name: 'delete log');
                                              var messageIndex = msgs.indexWhere(
                                                (e) => e.messageId == state.messageId,
                                              );
                                    
                                              if (messageIndex != -1) {
                                                var aboveMsg;
                                                var belowMsg;
                                                try {
                                                  aboveMsg = msgs[messageIndex - 1];
                                                } catch (e) {}
                                                try {
                                                  belowMsg = msgs[messageIndex + 1];
                                                } catch (e) {}
                                                _chatBloc.add(
                                                  ChatEventToEmitDeleteMessageWithMessageIndexInConversation(
                                                    state.conversationId,
                                                    state.messageId,
                                                    messageIndex,
                                                    aboveMessage: aboveMsg,
                                                    belowMessage: belowMsg,
                                                  ),
                                                );
                                              }
                                            }
                                            switch (state.runtimeType) {
                                              case ChatStateEditMultiMessageSuccess:
                                              case ChatStateDeleteMultiMessageSuccess:
                                                // log('ChatStateEditMultiMessageSuccess');
                                                widget.chatDetailBloc.isShowCheckBox = false;
                                                widget.chatDetailBloc.add(
                                                    const ChatDetailEventLoadConversationDetail());
                                                setState(() {});
                                                break;
                                            }
                                          },
                                          // Thanh cuộn chứa các tin nhắn
                                    
                                          child: ValueListenableBuilder(
                                            valueListenable: _latestMessageId,
                                            builder: (_, __, ___) => ValueListenableBuilder(
                                              valueListenable: changeTheme,
                                              builder: (context, value, child) => Container(
                                                color: context.theme.backgroundChatContent,
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: CustomScrollView(
                                                  controller: _scrollController,
                                                  center: _centerKey,
                                                  reverse: true,
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  slivers: [
                                                    SliverList(
                                                        key: _centerKey,
                                                        delegate: SliverChildBuilderDelegate(
                                                          (context, index) {
                                                            try {
                                                              var currentIndex =
                                                                  messages.length - 1 - index;
                                                              var msg =
                                                                  messages[currentIndex];
                                                              var prevMsg;
                                                              var nextMsg;
                                                              if (currentIndex != 0) {
                                                                prevMsg = messages[
                                                                    currentIndex - 1];
                                                              }
                                                              if (currentIndex <
                                                                  messages.length - 1) {
                                                                nextMsg = messages[
                                                                    currentIndex + 1];
                                                              }
                                    
                                                              var msgItem = MultiBlocProvider(
                                                                  providers: [
                                                                    BlocProvider<
                                                                        ChatDetailBloc>.value(
                                                                      value: widget
                                                                          .chatDetailBloc,
                                                                    ),
                                                                    // BlocProvider<
                                                                    //     UnreadMessageCounterCubit>.value(
                                                                    //   value:
                                                                    //   _unreadMessageCounterCubit,
                                                                    // ),
                                                                  ],
                                                                  child: MessageItem(
                                                                    chatInputBarKey:
                                                                        _chatInputBarKey,
                                                                    key: ValueKey(widget
                                                                            .chatDetailBloc
                                                                            .isShowOfflineMessage
                                                                        ? msg.messageId +
                                                                            '_offline'
                                                                        : msg.messageId),
                                                                    messageItemModel: msg,
                                                                    prevMessageItemModel:
                                                                        prevMsg,
                                                                    nextMessageItemModel:
                                                                        nextMsg,
                                                                    nickname: widget.nickname,
                                                                    isGroup:
                                                                        widget.chatType ==
                                                                            ChatType.GROUP,
                                                                    chatItemModel:
                                                                        widget.chatItemModel,
                                                                    chatDetailBloc:
                                                                        widget.chatDetailBloc,
                                                                    reloadScreen: () {
                                                                      setState(() {});
                                                                    },
                                                                    mesFinded:
                                                                        _textFindController
                                                                                .text.isBlank
                                                                            ? null
                                                                            : _textFindController
                                                                                .text,
                                                                    foundMessageId: foundMessageId,
                                                                    groupType:
                                                                        widget.groupType,
                                                                    deleteTime:
                                                                        widget.deleteTime,
                                                                    // profileCubit: _profileCubit,
                                                                    conversationId:
                                                                        _conversationId,
                                                                    userInfoBloc:
                                                                        _userInfoBloc,
                                                                  ));
                                    
                                                              return RepositoryProvider.value(
                                                                value: _chatInputBarKey,
                                                                child: AutoScrollTag(
                                                                  key: ValueKey(index),
                                                                  controller:
                                                                      _scrollController,
                                                                  index: index,
                                                                  child: msgItem,
                                                                ),
                                                              );
                                                            } catch (e) {
                                                              return null;
                                                            }
                                                          },
                                                          childCount: messages.length,
                                                          addRepaintBoundaries: true,
                                                          addAutomaticKeepAlives: false,
                                                        )),
                                                    SliverToBoxAdapter(
                                                      child: ValueListenableBuilder<bool>(
                                                        valueListenable: _isShowSliverAppBar,
                                                        builder: (context, isShow, child) {
                                                          return isShow
                                                              ? child!
                                                              : const SizedBox();
                                                        },
                                                        child: AppBar(
                                                          elevation: 0,
                                                          backgroundColor: Theme.of(context)
                                                              .scaffoldBackgroundColor
                                                              .withOpacity(0.6),
                                                          leading: const SizedBox.shrink(),
                                                          centerTitle: true,
                                                          title: ValueListenableBuilder<bool>(
                                                            valueListenable:
                                                                _isFetchingListMsgs,
                                                            builder:
                                                                (context, isFetching, child) {
                                                              return SizedBox.square(
                                                                dimension: 20,
                                                                child: isFetching
                                                                    ? const CircularProgressIndicator(
                                                                        strokeWidth: 1.0,
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<
                                                                                    Color>(
                                                                                AppColors
                                                                                    .blue3B86D4))
                                    
                                                                    // CircularProgressIndicator.adaptive(
                                                                    //         strokeWidth: 2,
                                                                    //       )
                                                                    : null,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      if (detailState is ChatDetailStateError &&
                                          widget
                                              .chatDetailBloc.msgs.isEmpty) if (detailState
                                          .error.isNetworkException) {
                                        return AppErrorWidget(
                                          error: detailState.error.toString(),
                                          onTap: () {
                                            widget.chatDetailBloc.add(
                                                const ChatDetailEventLoadConversationDetail());
                                            // if (widget.chatType == ChatType.SOLO)
                                            // _friendCubit
                                            //     .checkFriendStatus(_contactId!);
                                          },
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                      // Thanh cuộn chứa các tin nhắn);
                                    
                                      return WidgetUtils.centerLoadingCircle(context);
                                    },
                                  ),
                                ),
                                ChatScreenInputBar(
                                  chatDetailBloc: widget.chatDetailBloc,
                                  chatInputBarKey: _chatInputBarKey,
                                  onSend: _sendMessage,
                                  fileDropStream: fileDropStream,
                                  onTypingChanged: (value) => _onTypingStatusChanged(
                                    context,
                                    isTyping: value,
                                  ),
                                  autoFocus: autoFocus ?? false,
                                )
                              ],
                            ),
                          ),
                          ValueListenableBuilder(valueListenable: _isDroppingFile, builder: (_, __, ___) {
                            return _isDroppingFile.value ? ClipRRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 5.0,
                                  sigmaY: 5.0,
                                ),
                                child: const SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.file_download_outlined, weight: 1, size: 50,),
                                        SizedBox(width: 10,),
                                        Text('Thả file để tải lên', style: TextStyle(fontSize: 20),)
                                      ],
                                    ),
                                  ),
                                ))) : const SizedBox();
                          }),
                        ],
                      ),
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }

  // revokeInvitation(bool value) {
  //   return Container(
  //     height: 50,
  //     color: context.theme.backgroundDarkListChat,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Container(
  //             padding: const EdgeInsets.only(left: 30),
  //             child: const Text(
  //               AppLocalizations.of(context)!.makeFriend,
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //             )),
  //         Container(
  //           padding: const EdgeInsets.only(right: 30),
  //           height: 30,
  //           child: ElevatedButton(
  //             onPressed: () {
  //               isFriend.value = !value;
  //             },
  //             style: ElevatedButton.styleFrom(
  //               primary: AppColors.primary,
  //               padding:
  //                   const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius:
  //                     BorderRadius.circular(20.0), // Đường viền nút bo góc
  //               ),
  //             ),
  //             child: const Text(AppLocalizations.of(context)!.evic),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  sendFriendInvitation(bool value) {
    return Container(
      height: 50,
      color: AppColors.colorsappbar,
      child: InkWell(
        onTap: () {
          isFriend.value = !value;
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Images.add_person,
              width: 20,
              height: 20,
              color: AppColors.primary,
            ),
             Text(
              StringConst.inviteFriend,
              style:const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }

  void checkFriendStatus() {
    var friendCubit = context.read<FriendCubit>();

    var otherPerson = widget.chatDetailBloc.chatItemModel!
        .firstOtherMember(AuthRepo().userInfo!.id);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!widget.chatDetailBloc.isGroup) {
        friendCubit.checkFriendStatus(otherPerson.id);
      }
    });
  }

  /// Thanh trạng thái bạn bè
  /// NOTE: Sau khi bấm đồng ý kết bạn thì cả hai hóa SizedBox
  Widget friendStatusBar() {
    var friendStatusBarTextStyle = const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.mineShaft);
    var iconKetBan = Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 20,
        height: 20,
        child: SvgPicture.asset(
          Images.ic_ket_ban,
          colorFilter:
              const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
      ),
    );
    var sendRequestTextStyle = const TextStyle(
        color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w600);
    // Bọc Builder để mỗi lần đổi màn trò chuyện, conversationId thay đổi,
    // thì lại checkFriendStatus một lần
    return Builder(
      key: Key(widget.chatDetailBloc.conversationId.toString()),
      builder: (context) {
        checkFriendStatus();

        var friendCubit = context.read<FriendCubit>();

        var otherPerson = widget.chatDetailBloc.chatItemModel!
            .firstOtherMember(AuthRepo().userInfo!.id);
        int otherPersonId = otherPerson.id;
        String otherPersonName = otherPerson.name;

        return BlocBuilder<FriendCubit, FriendState>(
          builder: (context, state) {
            // Lờ đi thanh lời mời khi không phải cuộc trò chuyện 2 người
            if (widget.chatDetailBloc.isGroup) return SizedBox();

            if (state is FriendStateLoading) {
              return const SizedBox();
            } else //if (state is FriendStateLoadSuccess ||
            //state is FriendStateAddFriendSuccess)
            {
              // Xem xem trạng thái request giữa mình với họ thế nào
              // Nếu chưa có thì gọi API hỏi
              var currentRequest = friendCubit.friendsRequest[otherPersonId];
              if (currentRequest == null) {
                return const SizedBox(); // DEBUG: Text("TEST: Chưa biết. Đang tải");
              }

              Widget friendStatusContent;
              // logger.log(
              //     "$runtimeType conv ${widget.chatDetailBloc.conversationId} Friend status with $otherPersonName: ${currentRequest.status}");
              switch (currentRequest.status) {
                case FriendStatus.accept:
                  return SizedBox();
                case FriendStatus.unknown:
                  friendStatusContent = Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconKetBan,
                      SizedBoxExt.w5,
                      RichText(
                        text: TextSpan(
                          text: "Gửi lời mời kết bạn",
                          style: sendRequestTextStyle,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TL Note: Méo thể nào mà cái userInfo này có thể null được
                              // Nhưng vẫn hơi lo lo
                              friendCubit.addFriend(context
                                  .read<ChatDetailBloc>()
                                  .listUserInfoBlocs[otherPersonId]!
                                  .userInfo);
                            },
                        ),
                      ),
                    ],
                  );
                  break;
                case FriendStatus.send:
                  friendStatusContent = Row(
                    children: [
                      Text(
                        "Đang chờ $otherPersonName đồng ý",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: friendStatusBarTextStyle,
                      ),
                      const Expanded(child: SizedBox()),
                      SizedBox(
                        height: 40,
                        width: 150,
                        child: friendStatusBarActionButton(
                            onPressed: () {
                              friendCubit.deleteRequestAddFriend(
                                  AuthRepo().userInfo!.id, otherPersonId);
                            },
                            text: "Thu hồi"),
                      ),
                    ],
                  );
                  break;
                case FriendStatus.decline:
                  friendStatusContent = Row(
                    children: [
                      Text(
                        "Lời mời đã bị từ chối",
                        style: friendStatusBarTextStyle,
                      ),
                      const Expanded(child: SizedBox()),
                      InkWell(
                        onTap: () {
                          friendCubit.addFriend(context
                              .read<ChatDetailBloc>()
                              .listUserInfoBlocs[otherPersonId]!
                              .userInfo);
                        },
                        child: Row(
                          children: [
                            iconKetBan,
                            SizedBoxExt.w10,
                            Text(
                              "Gửi lời mời kết bạn",
                              style: sendRequestTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                  break;
                case FriendStatus.request:
                  friendStatusContent = Row(
                    children: [
                      Text(
                        "$otherPersonName muốn kết bạn với bạn",
                        style: friendStatusBarTextStyle,
                      ),
                      const Expanded(child: SizedBox()),
                      // Nút chấp nhận kết bạn
                      SizedBox(
                        width: 120,
                        height: 35,
                        child: friendStatusBarActionButton(
                            onPressed: () {
                              friendCubit.responseAddFriend(
                                  AuthRepo().userInfo!.id,
                                  context
                                      .read<ChatDetailBloc>()
                                      .listUserInfoBlocs[otherPersonId]!
                                      .userInfo,
                                  FriendStatus.accept);
                            },
                            text: "Chấp nhận"),
                      ),
                      SizedBoxExt.w10,
                      // Nút từ chối kết bạn

                      SizedBox(
                        width: 120,
                        height: 35,
                        child: friendStatusBarActionButton(
                            onPressed: () {
                              friendCubit.responseAddFriend(
                                  AuthRepo().userInfo!.id,
                                  context
                                      .read<ChatDetailBloc>()
                                      .listUserInfoBlocs[otherPersonId]!
                                      .userInfo,
                                  FriendStatus.decline);
                            },
                            text: "Từ chối"),
                      )
                    ],
                  );
                  break;
              }
              var friendStatusContainer = Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 0, 0),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                  height: 50,
                  decoration:
                      const BoxDecoration(color: AppColors.colorsappbar),
                  child: friendStatusContent,
                ),
              );
              return friendStatusContainer;
            }
            // else {
            //   logger.log(
            //       "$runtimeType Friend status wtf: ${state.runtimeType}, ${state.toString()}");
            // }

            // return const Text("Chưa hiện mời kết bạn");
          },
        );
      },
    );
  }

  // Mấy nút nền xanh chữ trắng trên thanh kết bạn
  Widget friendStatusBarActionButton(
      {required Function() onPressed, String text = ""}) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(AppColors.primary),
        foregroundColor: MaterialStateProperty.all(AppColors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}
