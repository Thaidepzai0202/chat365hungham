import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_chat365_pc/common/Widgets/forward_message_screen.dart';
import 'package:app_chat365_pc/common/Widgets/painter/percent_indicator.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/reaction_cubit/reaction_cubit.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_state.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/notification_message_display.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/common/widgets/measure_size.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat/screen/chat_screen.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/message_box.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/reaction_bar.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_input_bar.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/detail_emotion_bar.dart';
import 'package:app_chat365_pc/modules/chat/widgets/text_divider.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/conversation_item.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_cubit.dart';
import 'package:app_chat365_pc/modules/profile/repo/group_profile_repo.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/emoji.dart';
import 'package:app_chat365_pc/utils/data/enums/message_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/enums/process_message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/date_time_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/app_border_and_radius.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../common/Widgets/forward_message_screen.dart';
import '../../../../router/app_router.dart';
import '../../screen/chat_screen.dart';

class MessageItem extends StatefulWidget {
  MessageItem(
      {super.key,
      required this.messageItemModel,
      this.prevMessageItemModel,
      this.nextMessageItemModel,
      this.nickname,
      required this.isGroup,
      this.chatItemModel,
      this.chatDetailBloc,
      required this.reloadScreen,
      this.mesFinded,
      this.groupType,
      this.deleteTime,
      required this.foundMessageId,
      this.profileCubit,
      this.conversationId,
      required this.userInfoBloc,
      required this.chatInputBarKey});

  final GlobalKey<ChatInputBarState> chatInputBarKey;

  final SocketSentMessageModel messageItemModel;
  final SocketSentMessageModel? prevMessageItemModel;
  final SocketSentMessageModel? nextMessageItemModel;
  final String? nickname;
  final bool isGroup;
  final ChatItemModel? chatItemModel;
  final ChatDetailBloc? chatDetailBloc;
  final Function reloadScreen;
  final String? mesFinded;
  final ValueNotifier<String> foundMessageId;
  final String? groupType;
  final String? deleteTime;
  late final UserInfoBloc userInfoBloc;

  final ProfileCubit? profileCubit;
  final int? conversationId;

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  late SocketSentMessageModel _messageModel;
  late bool _isSentByCurrentUser;
  GlobalKey<State> repaintKey = GlobalKey();
  File? file;
  final TextEditingController _textFieldController = TextEditingController();
  late final GlobalKey<ChatInputBarState> _chatInputBarKey;

  // late final UnreadMessageCounterCubit _unreadMessageCounterCubit;
  late SocketSentMessageModel? _nextMessageItemModel;
  late SocketSentMessageModel? _prevMessageItemModel;
  bool _isInit = false;
  late final String? _nickname;
  final ValueNotifier<List<ChatMemberModel>> seenByUsers = ValueNotifier([]);
  final ValueNotifier<bool> viewAllSeenUsers = ValueNotifier(false);
  final ValueNotifier<bool> hasEmotion = ValueNotifier(false);
  final ValueNotifier<double> emotionBarSize = ValueNotifier(0);
  List<ChatMemberModel> members = [];


  /// Sender avatar
  late Widget _userAvatar;

  /// Sender info
  late UserInfoBloc _userInfoBloc;
  late final ChatBloc _chatBloc;
  late bool _isShowDateTimeDivider;
  late final ReactionCubit _reactionCubit;

  // late PrivacyCubit _privacyCubit = PrivacyCubit(context.userInfo().id);

  // late final AnimationController _animationController;
  // late final ReactionCubit _reactionCubit;
  late final ChatDetailBloc _chatDetailBloc;
  late final bool _isMergedUnderMessage;

  late final BorderRadius _borderRadius;

  late Iterable<int> _listUserUnReadThisMessage;

  late List<UserInfoBloc> _listUserReadThisMessage = [];

  late final _currentUserId;

  late final int _conversationId;

  /// Check show avatar và tên (+ thời gian) người gửi
  ///
  /// Show khi tin trước và tin sau khác người gửi,
  ///
  /// Nếu cùng người gửi, thời gian gửi 2 tin nhắn phải cách nhau >= 15p
  late ValueNotifier<bool> _isShowUserListTile;

  late bool _hasReplyMessage;

  late ValueNotifier<bool> _isShowUnreadMessageDivider;

  Widget? _dateTimeDivider;

  late final Widget _unreadMessageDivider;

  late final ValueNotifier<bool> _showLikeButton;

  // late ValueNotifier<Duration> _deleteMessageCountdown;
  Timer? _timer;

  int? _tempMessageIndex;

  // late final bool hasSpeaker;
  late final ValueNotifier<MessageStatus> _messageStatusListenable;

  // _setShowLikeButtonValue(bool value) {
  //   if (_messageModel.type?.isVideoCall == true) return;
  //   if (_showLikeButton.value != value)
  //     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //       _showLikeButton.value = value;
  //     });
  // }
  GlobalKey<State> _renderObjectKey = GlobalKey();

  getListMemberOfGroup() async {
    // await widget.profileCubit!
    //     .getListMemberOfGroup(conversationId: widget.conversationId, type: 1);
  }

  @override
  void initState() {
    // TODO: implement initState
    // _msgBoxWidth = ValueNotifier(300);
    _chatBloc = context.read<ChatBloc>();
    // _unreadMessageCounterCubit = context.read<UnreadMessageCounterCubit>();
    _nextMessageItemModel = widget.nextMessageItemModel;
    _prevMessageItemModel = widget.prevMessageItemModel;
    _nickname = widget.nickname;
    for (MapEntry<Emoji, Emotion> item in widget.messageItemModel.emotion.entries) {
      if (item.value.listUserId.isNotEmpty) {
        hasEmotion.value = true;
        break;
      }
    }

    getListMemberOfGroup();
    _onInit();
    super.initState();
  }

  _updateMessageStatus(MessageStatus status) {
    _messageModel.messageStatus = status;
    if (status == MessageStatus.deleted) {
      _messageModel.listDeleteUser = [
        ...(_messageModel.listDeleteUser ?? [])..add(AuthRepo().userId!)
      ];
    }
    if (_messageModel.messageStatus != _messageStatusListenable.value)
      _messageStatusListenable.value = status;
  }

  _onInit() async {
    _messageModel = widget.messageItemModel;
    _messageStatusListenable = ValueNotifier(_messageModel.messageStatus);
    // _showLikeButton = ValueNotifier(_messageModel.type?.isVideoCall == true
    //     ? false
    //     : _messageModel.messageStatus != MessageStatus.sending);
    _showLikeButton = ValueNotifier(false);
    _chatInputBarKey = context.read<GlobalKey<ChatInputBarState>>();
    _currentUserId = context.userInfo().id;
    _hasReplyMessage = _messageModel.hasRelyMessage;
    _chatDetailBloc = context.read<ChatDetailBloc>();
    _conversationId = _chatDetailBloc.conversationId;
    members = ChatRepo().getAllChatMembersSync(conversationId: _conversationId);
    _isShowUnreadMessageDivider = ValueNotifier(
        _chatDetailBloc.unreadMessageUserAndMessageId[_currentUserId] ==
            _nextMessageItemModel?.messageId);
    var infoBloc = _chatDetailBloc
        .allUserInfoBlocsAppearInConversation[_messageModel.senderId];
    if (infoBloc != null) {
      _userInfoBloc = infoBloc;
    } else {
      // TL 23/2/2024: Lấy thông tin người dùng gắn liền CTC
      var unknownInfoBloc = UserInfoBloc.fromChatMember(
          _messageModel.senderId, _messageModel.conversationId);
      _userInfoBloc = unknownInfoBloc;
      _chatDetailBloc.tempListUserInfoBlocs[_messageModel.senderId] =
          unknownInfoBloc;
    }
    _isSentByCurrentUser = _currentUserId == _messageModel.senderId;

    _isShowDateTimeDivider = _messageModel.createAt.toDmYString() !=
        _prevMessageItemModel?.createAt.toDmYString();
    _isShowUserListTile = ValueNotifier(_isShowDateTimeDivider ||
        _prevMessageItemModel?.senderId != _messageModel.senderId ||
        (_prevMessageItemModel == null ||
            _messageModel.createAt
                    .difference(_prevMessageItemModel!.createAt)
                    .inMinutes >=
                15));

    _isMergedUnderMessage =
        _nextMessageItemModel?.senderId == _messageModel.senderId &&
            _nextMessageItemModel!.createAt
                    .difference(_messageModel.createAt)
                    .inMinutes <=
                15;

    bool cutTop = _isShowUserListTile.value && _isMergedUnderMessage;
    bool cutBot = !cutTop && !_isMergedUnderMessage;

    _borderRadius = AppBorderAndRadius.defaultChatBorder(
      _isSentByCurrentUser,
      cutBot: cutBot,
      cutTop: cutTop,
    );
    _userAvatar = ValueListenableBuilder<bool>(
        valueListenable: _isShowUserListTile,
        builder: (_, _show, child) {
          return _show
              ? BlocBuilder<UserInfoBloc, UserInfoState>(
                  bloc: _userInfoBloc,
                  builder: (_, state) => InkWell(
                    onTap: () {
                      // if (widget.isGroup) {
                      //   _chatBloc.tryToChatScreen(
                      //     chatInfo: state.userInfo,
                      //     isGroup: false,
                      //   );
                      // }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 7.0),
                      child: InkWell(
                        onTap: () {
                        context.read<AppLayoutCubit>()
                          .toMainLayout(AppMainPages.chatScreen, providers: [
                            BlocProvider<UserInfoBloc>.value(value: _userInfoBloc),
                            BlocProvider<ChatDetailBloc>.value(
                                value: _chatDetailBloc),

                            // TL Note 23/12/2023: Theo luồng tạo ConversationItem, cả hai
                            // bloc này đều được lấy từ ChatConversationBloc. Vì thế nên hãy để
                            // ChatScreen tự giác lấy từ ChatConversationBloc, đừng truyền cho
                            // nó ở đây. Luồng lòng vòng ra.
                            BlocProvider<TypingDetectorBloc>.value(
                                value: context.read<TypingDetectorBloc>()),
                            // BlocProvider(create: (context) => TransVoiceToTextCubit()),
                            // BlocProvider(create: (context) => PollCubit()),
                            BlocProvider(
                                create: (context) => ProfileCubit(
                                    _chatDetailBloc.conversationId,
                                    isGroup: _chatDetailBloc.isGroup))
                          ], agruments: {
                            'chatType': widget.isGroup ? ChatType.GROUP : ChatType.SOLO,
                            'conversationId':
                                _chatDetailBloc.conversationId,
                            'senderId': context.userInfo().id,
                            'chatItemModel': widget.chatItemModel,
                            'name': _chatDetailBloc.conversationName.value,
                            'chatDetailBloc': _chatDetailBloc,
                          });
                        },
                        child: ClipOval(
                          child: (state.userInfo.avatar == null)
                              ? SvgPicture.asset(
                                  Images.ic_chat365,
                                  height: 50,
                                  width: 50,
                                )
                              : (state.userInfo.avatar is String)
                                  ? CachedNetworkImage(
                                      color: AppColors.green22A6B3,
                                      imageUrl: state.userInfo.avatar!,
                                      placeholder: (_, __) => Image.asset(
                                        Images.img_non_avatar,
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                      imageBuilder: (_, img) {
                                        return Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                            image: img,
                                            fit: BoxFit.cover,
                                          )),
                                        );
                                      },
                                      errorWidget: (_, __, ___) => Image.asset(
                                        Images.img_non_avatar,
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.memory(
                                      Uint8List.fromList(
                                          state.userInfo.avatar as List<int>),
                                      fit: BoxFit.fitWidth,
                                      height: 30,
                                      width: 30,
                                    ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: 36);
        });
    _reactionCubit = ReactionCubit(
      _messageModel.messageId,
      chatRepo: context.read<ChatRepo>(),
      initEmotions: _messageModel.emotion,
    );
    _setUpUnreadMessageDivider();
  }

  @override
  void didUpdateWidget(covariant MessageItem oldWidget) {
    _nextMessageItemModel = widget.nextMessageItemModel;
    _prevMessageItemModel = widget.prevMessageItemModel;
    _messageModel = widget.messageItemModel;

    // setupCountdown();

    _isShowUnreadMessageDivider.value =
        _chatDetailBloc.unreadMessageUserAndMessageId[_currentUserId] ==
            _nextMessageItemModel?.messageId;

    // _setUpUnreadMessageDivider();

    // if (!_isShowDateTimeDivider)
    _isShowDateTimeDivider = _messageModel.createAt.toDmYString() !=
        _prevMessageItemModel?.createAt.toDmYString();

      super.didUpdateWidget(oldWidget);
  }

  void _setUpUnreadMessageDivider() {
    // _unreadMessageDivider = ValueListenableBuilder<bool>(
    //   valueListenable: _isShowUnreadMessageDivider,
    //   builder: (_, isShow, child) {
    //     if (isShow && _messageModel.senderId == _currentUserId) {
    //       // if (_unreadMessageCounterCubit.hasUnreadMessage)
    //       //   _chatBloc.markReadMessages(
    //       //     senderId: _currentUserId,
    //       //     conversationId: _conversationId,
    //       //     memebers: _chatDetailBloc.listUserInfoBlocs.keys.toList(),
    //       //   );
    //       return const SizedBox();
    //     }
    //     return Visibility(
    //       visible: isShow,
    //       child: child!,
    //     );
    //   },
    //   child: VisibilityDetector(
    //     key: ValueKey(_nextMessageItemModel?.messageId),
    //     onVisibilityChanged: _readMessageOnVisibilityChanged,
    //     child: TextDivider(
    //       text: 'Tin nhắn chưa đọc',
    //       color: AppColors.red,
    //     ),
    //   ),
    // );
  }

  @override
  void dispose() {
    // _animationController.dispose();
    // _reactionCubit.close();
    // _chatDetailBloc.close();
    try {
      _listUserReadThisMessage.forEach((e) => e.close());
    } catch (e) {}
    BotToast.cleanAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isShowUserListTile.value = _isShowDateTimeDivider ||
        _prevMessageItemModel?.senderId != _messageModel.senderId ||
        (_prevMessageItemModel == null ||
            _messageModel.createAt
                    .difference(_prevMessageItemModel!.createAt)
                    .inMinutes >=
                15);
    List<ChatMemberModel> membersSeen = [];
    for (ChatMemberModel member in members) {
      if (member.unreadMessageId == _messageModel.messageId&&member.id != _currentUserId&&member.id != _messageModel.senderId) {
        membersSeen.add(member);
      }
    }
    seenByUsers.value = membersSeen;

    var nameAndTimeText = BlocBuilder<UserInfoBloc, UserInfoState>(
      bloc: _userInfoBloc,
      builder: (_, state) => Padding(
          padding: const EdgeInsets.only(left: 5, right: 10),
          child: ValueListenableBuilder(
            valueListenable: changeTheme,
            builder: (context, value, child) => Text(
              //if widget.chatType == ChatType.GROUP then show nickname
              (!_isSentByCurrentUser
                      ? ((_messageModel.liveChat != null &&
                              double.tryParse(
                                      _messageModel.liveChat?.clientName ??
                                          'a') ==
                                  null)
                          ? '${_messageModel.liveChat?.clientName ?? ''}, '
                          : '${!widget.isGroup ? _nickname ?? state.userInfo.name : state.userInfo.name}, ')
                      : '') +
                  _messageModel.createAt.toUtc().toHmsString(),
              style: AppTextStyles.regularW400(
                context,
                size: 12,
                color: context.theme.dividerHistoryColor,
                lineHeight: 15,
              ),
            ),
          )),
    );

    var seenUsers = BlocListener<ChatDetailBloc, ChatDetailState>(
      listener: (_, state) {
        if (state is ChatDetailStateMarkReadMessage) {
          if (state.senderId != _currentUserId) {
            String? lastMessageId = ChatRepo().getConversationModelSync(_conversationId)?.messageId;
            if (lastMessageId == _messageModel.messageId) {
              for (ChatMemberModel member in members) {
                if (state.senderId == member.id) {
                  if (seenByUsers.value.indexWhere((e) => e.id == member.id) == -1) {
                    seenByUsers.value = [...seenByUsers.value, member];
                  }
                }
              }
            } else {
              List<ChatMemberModel> seenByUsersClone = [...seenByUsers.value];
              seenByUsersClone.removeWhere((user) => user.id == state.senderId);
              seenByUsers.value = seenByUsersClone;
            }
          }
        }
      },
      child: ValueListenableBuilder(
        valueListenable: seenByUsers,
        builder: (_, __, ___) => ValueListenableBuilder(
          valueListenable: viewAllSeenUsers,
          builder:  (_, __, ___) => InkWell(
            onTap: () {
              viewAllSeenUsers.value = !viewAllSeenUsers.value;
            },
            child: Builder(
              builder: (context) {
                List<Widget> userAvatars = [];
                for (ChatMemberModel member in seenByUsers.value) {
                  userAvatars.add(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                      child: Tooltip(
                        message: "${member.name} - ${DateFormat("dd/MM/yyyy hh:mm:ss").format(member.readMessageTime??DateTime.now())}",
                        preferBelow: false,
                        child: SizedBox(
                          width: 15,
                          height: 15,
                          child: DisplayAvatarOnly(avatar: member.avatar)
                        ),
                      )
                    )
                  );
                }
                if (!viewAllSeenUsers.value&&userAvatars.length > 10) {
                  int remainingUser = userAvatars.length - 10;
                  userAvatars = userAvatars.sublist(0, 10);
                  userAvatars.add(Text("+$remainingUser", style: TextStyle(color: context.theme.textColor),));
                }
                return Wrap(
                  children: userAvatars
                );
              },
            ),
          ),
          )),
    );

    /// [MessageType.notification] là trường hợp đặc biệt, chỉ cần show text  [MessageType.reminder] cũng là trường hợp đặc biệt show containers
    if ((_messageModel.type?.isNotification ?? false) ||
        (_messageModel.type?.isreminderNoti ?? false) ||
        (_messageModel.type?.isreminder ?? false) ||
        (_messageModel.type?.isnotificationGroup ?? false)) {
      return BlocListener<ChatDetailBloc, ChatDetailState>(
        listenWhen: (prev, current) {
          return current is ChatDetailStateMarkReadMessage &&
              current.senderId == _currentUserId;
        },
        listener: (context, state) {
          if (state is ChatDetailStateMarkReadMessage &&
              state.senderId == _currentUserId) {
            _isShowUnreadMessageDivider.value = false;
          }
        },
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 12, bottom: 4),
          child: Column(
            children: [
              if (_isShowDateTimeDivider) TextDivider(
                text: _messageModel.createAt.diffWith(
                  showTimeStamp: false,
                  showSpecialTime: true,
                )),
              // _unreadMessageDivider,
              BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (previous, current) =>
                    current is ChatStateSendMessageSuccess &&
                    current.messageId == _messageModel.messageId,
                builder: (context, chatState) {
                  if (chatState is ChatStateSendMessageSuccess &&
                      chatState.messageId == _messageModel.messageId) {}
                  if (_messageModel.type?.isreminderNoti ?? false) {
                    // return NotificationReminderDisplay(
                    //   message: _messageModel.message,
                    //   listUserInfos:
                    //       _chatDetailBloc.allUserInfoBlocsAppearInConversation,
                    //   senderId: _messageModel.senderId,
                    // );
                  }
                  // if (_messageModel.type?.isnotificationGroup ?? false) {
                  //   List<int> deputyAdminId =
                  //       widget.chatItemModel?.deputyAdminId ?? [];
                  //   return NotificationGroupDisplay(
                  //       message: _messageModel.message,
                  //       adminId: [
                  //         ...deputyAdminId,
                  //         widget.chatItemModel?.adminId ?? -1
                  //       ],
                  //       currentId: _currentUserId,
                  //       conversationId: _messageModel.conversationId,
                  //       conversationName:
                  //           _chatDetailBloc.conversationName.value ??
                  //               'Thông báo Chat365',
                  //       messageId: _messageModel.messageId,
                  //       members:
                  //           _chatDetailBloc.listUserInfoBlocs.keys.toList(),
                  //       onDeleteSuccess: () {
                  //         var msgs = _chatDetailBloc.msgs;
                  //
                  //         var messageIndex = msgs.indexWhere(
                  //           (e) => e.messageId == _messageModel.messageId,
                  //         );
                  //
                  //         if (messageIndex != -1) {
                  //           _chatDetailBloc.msgs.removeAt(messageIndex);
                  //         }
                  //       });
                  // }
                  return NotificationMessageDisplay(
                    message: _messageModel.message,
                    listUserInfos:
                        _chatDetailBloc.allUserInfoBlocsAppearInConversation,
                    conversationId: _conversationId,
                    onGetUnknownUserIdsFound: (blocs) {
                      for (var bloc in blocs) {
                        _chatDetailBloc
                            .tempListUserInfoBlocs[bloc.userInfo.id] = bloc;
                      }
                    },
                    chatDetailBloc: _chatDetailBloc,
                    groupProfileRepo: GroupProfileRepo(_conversationId, true),
                    profileCubit: widget.profileCubit,
                    isGroup: widget.isGroup,
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
    var msgBox = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBoxExt.w8,
        if (_isSentByCurrentUser)
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: ValueListenableBuilder<MessageStatus>(
              valueListenable: _messageStatusListenable,
              builder: (_, status, __) {
                if (status == MessageStatus.sendError) {
                  return InkWell(
                    onTap: () {},
                    child: const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.red,
                          size: 24,
                        ),
                      ],
                    ),
                  );
                } else if (status == MessageStatus.edited)
                  //ignore: curly_braces_in_flow_control_structures
                  return const Icon(
                    Icons.edit_outlined,
                    color: AppColors.greyCC,
                    size: 16,
                  );
                return const SizedBox(key: ValueKey('none'));
              },
            ),
          ),
        Stack(
          clipBehavior: Clip.none,
          alignment: _isSentByCurrentUser
              ? Alignment.bottomLeft
              : Alignment.bottomRight,
          children: [
            ValueListenableBuilder(
              valueListenable: hasEmotion,
              builder: (_, __, ___) {
                var padding = hasEmotion.value
                 ? const EdgeInsets.only(bottom: 30)
                 : const EdgeInsets.only(bottom: 2);
                return Padding(
                  padding: padding,
                  child: BlocListener<ChatBloc, ChatState>(
                    bloc: _chatBloc,
                    listenWhen: _messageBoxBuildWhen,
                    listener: (_, chatState) {
                      // _setShowLikeButtonValue(true);
                      if (chatState is ChatStateReceiveMessage) {
                        setState(() {
                          _messageModel = chatState.msg;
                        });
                        var index = _chatDetailBloc.msgs.indexWhere(
                            (e) => e.messageId == _messageModel.messageId);
                        if (index != -1) {
                          _tempMessageIndex = index;
                          _chatDetailBloc.msgs[index] = chatState.msg;
                        }
                      } else if (chatState is ChatStateSendMessageSuccess) {
                        _updateMessageStatus(MessageStatus.normal);
                      } else if (chatState is ChatStateSendMessageError) {
                        // _setShowLikeButtonValue(false);
                        _updateMessageStatus(MessageStatus.sendError);
                      } else if (chatState is ChatStateInProcessingMessage) {
                        // _setShowLikeButtonValue(false);
                        if (chatState.processingType ==
                            ProcessMessageType.deleting) {
                          // _updateMessageStatus(MessageStatus.deleting);
                        } else {
                          _updateMessageStatus(MessageStatus.sending);
                        }
                      } else if (chatState is ChatStateEditMessageSuccess) {
                        _updateMessageStatus(chatState.editType == 1
                            ? MessageStatus.edited
                            : MessageStatus.recall);
                        _messageModel = _messageModel.copyWith(
                          type: chatState.editType == 1
                              ? _messageModel.type
                              : MessageType.text,
                          message: chatState.newMessage,
                          status: chatState.editType == 1
                              ? MessageStatus.edited
                              : MessageStatus.recall,
                        );
                        var index = _chatDetailBloc.msgs
                            .indexWhere((e) => e.messageId == chatState.messageId);
                        if (index != -1) {
                          _chatDetailBloc.msgs[index] = _messageModel;
                        }
                        setState(() {});
                        _chatDetailBloc.refreshListMessages();
                      } else if (chatState is ChatStateWarningMessageError) {
                        _updateMessageStatus(MessageStatus.sendError);
                      } else if (chatState is ChatStateDeleteMessageSuccess) {
                        // final msgs = _chatDetailBloc.msgs;
                        final String deletedMessageId = chatState.messageId;
                
                        /// Đối với tin nhắn mà tin nhắn phía trước là tin nhắn bị xóa
                        if (_prevMessageItemModel?.messageId == deletedMessageId) {
                          _prevMessageItemModel = chatState.messageAbove;
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              setState(() {
                                _isInit = false;
                              });
                            }
                            // logger.log(
                            //   'New PrevMessage of ${_messageModel.message}(${_messageModel.messageId}) is ${_prevMessageItemModel?.message}(${_prevMessageItemModel?.messageId})',
                            //   name: 'LogReader_NewPrev',
                            // );
                          });
                        }
                
                        /// Đối với tin nhắn mà tin nhắn tiếp theo là tin nhắn bị xóa
                        else if (_nextMessageItemModel?.messageId ==
                            deletedMessageId) {
                          _nextMessageItemModel = chatState.messageBelow;
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              setState(() {
                                _isInit = false;
                              });
                            }
                            // logger.log(
                            //   'New NextMessage of ${_messageModel.message}(${_messageModel.messageId}) is ${_nextMessageItemModel?.message}(${_nextMessageItemModel?.messageId})',
                            //   name: 'LogReader_NewNext',
                            // );
                          });
                        }
                
                        /// Đối với tin nhắn mà tin nhắn hiện tại là tin nhắn bị xóa
                        else {
                          _updateMessageStatus(MessageStatus.deleted);
                
                          _chatDetailBloc.unreadMessageUserAndMessageIndex
                              .forEach((userId, index) {
                            _chatDetailBloc
                                    .unreadMessageUserAndMessageIndex[userId] =
                                index - 1;
                          });
                
                          final String? nextMessageId =
                              chatState.messageBelow?.messageId;
                
                          /// Nếu tin nhắn tiếp theo không phải tin nhắn cuối cùng
                          ///
                          /// - Set unreadMessageId của những người đã xem tin nhắn này thành tin nhắn tiếp theo
                          /// - Set unreadMessageId của những người mà tin nhắn chưa xem là tin nhắn này thành tin nhắn tiếp theo
                          if (nextMessageId != null)
                            for (int userId in [
                              ..._listUserReadThisMessage.map((e) => e.userInfo.id),
                              ..._chatDetailBloc.unreadMessageUserAndMessageId.keys
                                  .where(
                                (e) =>
                                    _chatDetailBloc
                                        .unreadMessageUserAndMessageId[e] ==
                                    deletedMessageId,
                              ),
                            ]) {
                              _chatDetailBloc
                                      .unreadMessageUserAndMessageId[userId] =
                                  nextMessageId;
                            }
                
                          /// Còn nếu tin nhắn tiếp theo là tin nhắn cuối cùng
                          /// Set tin nhắn chưa xem của những người này thành null
                          else {
                            for (var user in _listUserReadThisMessage) {
                              var userId = user.userInfo.id;
                              _chatDetailBloc.unreadMessageUserAndMessageId
                                  .remove(userId);
                              _chatDetailBloc
                                  .unreadMessageUserAndMessageIndex[userId] = 0;
                            }
                          }
                
                          _chatDetailBloc.msgs.removeAt(chatState.messageIndex!);
                        }
                      }
                    },
                    child: RepaintBoundary(
                      key: _renderObjectKey,
                      child: InkWell(
                        onSecondaryTapUp: (TapUpDetails details) {
                          if(_messageModel.type?.isVideoCall != true)
                          // Gọi hàm hiển thị menu tại vị trí được nhấn
                          _showPopupMenu(context, details.globalPosition);
                        },
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        mouseCursor: MouseCursor.defer,
                        hoverColor: Colors.transparent,
                        child: MessageBox(
                          messageModel: _messageModel,
                          hasReplyMessage: _hasReplyMessage,
                          isSentByCurrentUser: _isSentByCurrentUser,
                          borderRadius: _borderRadius,
                          listUserInfoBlocs: _chatDetailBloc.listUserInfoBlocs,
                          maxWidth: _chatDetailBloc.isShowCheckBox
                              ? AppConst.maxMessageBoxWidth - 30
                              : AppConst.maxMessageBoxWidth,
                          mesFinded: widget.mesFinded,
                          emotionBarSize: emotionBarSize,
                          // ),
                          // ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
            ValueListenableBuilder(
              valueListenable: hasEmotion,
              builder: (_, __, ___) {
                return Positioned(
                  left: _isSentByCurrentUser ? 4 : null,
                  right: _isSentByCurrentUser ? null : 14,
                  bottom: hasEmotion.value? 20 : -8,
                  child: Row(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _showLikeButton,
                        builder: (_, __, ___) {
                          if (_showLikeButton.value) {
                            return ShowEmotionButton(
                              reactionCubit: _reactionCubit,
                              key: ValueKey('emoji-btn'),
                              onHoldLikeButton: (details) {
                                showMenu(
                                  color: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                      details.globalPosition.dx - 20,
                                      details.globalPosition.dy - 20,
                                      details.globalPosition.dx + 1,
                                      details.globalPosition.dy + 1),
                                  items: [
                                    PopupMenuItem(
                                      child: DetailEmotionBar(
                                        messageModel: _messageModel,
                                        chatDetailBloc: _chatDetailBloc,
                                        reactionCubit: reactionCubit)
                                    )
                                  ]);
                              },
                              onTapLikeButton: () {
                                 reactionCubit.reactedAtEmoji(
                                  context.userInfo().id,
                                  _messageModel,
                                  _chatDetailBloc.listUserInfoBlocs.keys.toList(),
                                  _chatDetailBloc.isGroup
                                      ? _chatDetailBloc.conversationName.value ??
                                      'Thông báo Chat365'
                                      : AuthRepo().userName,
                                  reactedPersonId: ChatRepo().currentUserId,
                                  reactedEmoji: Emoji.like,
                                );
                              },
                            );
                          } else {
                            return SizedBoxExt.shrink;
                          }
                        }
                      )

                    ],
                  ),
                );
              }
            ),
            Positioned(
              left: _isSentByCurrentUser ? null : 4,
              right: _isSentByCurrentUser ? 15 : null,
              bottom: 10,
              child: MeasureSize(
                onChange: (size) {
                  emotionBarSize.value = size.width;
                },
                child: BlocConsumer<ChatBloc, ChatState>(
                  bloc: _chatBloc,
                  listener:(context, state) {
                    if (
                      state is ChatStateOnReceivedEmotionMessage &&
                      _messageModel.messageId.compareTo(state.messageId) == 0
                      ) {
                      if (_messageModel.emotion[state.emoji] == null) {
                        _messageModel.emotion[state.emoji] = Emotion(type: state.emoji, listUserId: const [], isChecked: false);
                      }
                      _messageModel.emotion[state.emoji]!.listUserId.add(state.senderId);
                      hasEmotion.value = true;
                    }
                  },
                  buildWhen: (previous, current) {
                    if (current is ChatStateOnReceivedEmotionMessage) {
                      logger.log("${_messageModel.messageId} - ${current.messageId}");
                    }
                    return current is ChatStateOnReceivedEmotionMessage &&
                      _messageModel.messageId.compareTo(current.messageId) == 0;
                  },
                  builder: (context, state) {
                    return ReactionBar(
                      emotions: widget.messageItemModel.emotion,
                      chatDetailBloc: widget.chatDetailBloc!,
                      appLayoutCubit: context.read<AppLayoutCubit>(),
                      isSentByCurrentUser: _isSentByCurrentUser,
                      reactionCubit: reactionCubit,
                      chatBloc: _chatBloc);
                  }
                ),
              )
              )
          ],
        ),
        if (!_isSentByCurrentUser)
          ValueListenableBuilder<MessageStatus>(
            valueListenable: _messageStatusListenable,
            builder: (_, status, __) {
              if (status == MessageStatus.edited) {
                return const Icon(
                  Icons.edit_outlined,
                  color: AppColors.greyCC,
                  size: 16,
                );
              }
              return const SizedBox(key: ValueKey('none'));
            },
          ),
      ],
    );

    var rowItem = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: _isSentByCurrentUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!_isSentByCurrentUser) _userAvatar,
        // const SizedBox(width: 4),
        if (_isSentByCurrentUser) ...[
          const SizedBox(width: 4),
          msgBox,
        ] else ...[
          msgBox,
        ],
      ],
    );

    return MouseRegion(
      onHover: (event) {
        if (!_showLikeButton.value) {
          _showLikeButton.value = true;
        }
      },
      onExit: (event) {
         if (_showLikeButton.value) {
          _showLikeButton.value = false;
        }
      },
      child: ValueListenableBuilder<MessageStatus>(
        valueListenable: _messageStatusListenable,
        builder: (context, status, child) {
          return Visibility(
            // không hiển thị tin nhắn xóa từ 1 phía đối với người gửi
            visible: !(status == MessageStatus.deleted),
            child: AbsorbPointer(
              absorbing: !status.enableInteractive,
              child: child!,
            ),
            // child: child!,
          );
        },
        child: BlocListener<ChatDetailBloc, ChatDetailState>(
          listenWhen: (prev, current) {
            return current is ChatDetailStateMarkReadMessage &&
                current.senderId == _currentUserId;
          },
          listener: (context, state) {
            if (state is ChatDetailStateMarkReadMessage &&
                state.senderId == _currentUserId) {
              _isShowUnreadMessageDivider.value = false;
            }
          },
          child: _itemChat(_chatDetailBloc.isShowCheckBox, rowItem,
              nameAndTimeText, seenUsers),
        ),
      ),
    );
  }

  Widget _itemChat(bool isShowCheckBox, Widget rowItem, Widget nameAndTimeText,
      Widget seenUsers) {
    Widget _widget;

    if (isShowCheckBox) {
      List<Widget> items = [];

      items.add(Checkbox(
        shape: const CircleBorder(),
        value: _messageModel.isCheck,
        onChanged: (bool? newValue) {
          _messageModel.isCheck = newValue!;
          if (_messageModel.isCheck == true) {
            _chatDetailBloc.selectMultiMessages.add(_messageModel.message);
            _chatDetailBloc.counterNotifier.value++;
          } else {
            _chatDetailBloc.selectMultiMessages.remove(_messageModel.message);
            if (_chatDetailBloc.counterNotifier.value < 0) {
              _chatDetailBloc.counterNotifier.value = 0;
            } else {
              _chatDetailBloc.counterNotifier.value--;
            }
          }
          print('${_messageModel.message}- ${_messageModel.isCheck}');
          print('${_chatDetailBloc.selectMultiMessages}');
          setState(() {});
        },
      ));
      if (_isSentByCurrentUser) {
        items.add(const Spacer());
      }
      items.add(rowItem);
      _widget = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      );
    } else {
      _widget = rowItem;
    }

    return ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) {
        return Container(
          color: context.theme.backgroundChatContent,
          child: Column(
            key: ValueKey('column'),
            crossAxisAlignment: _isSentByCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 4),
              if (_isShowDateTimeDivider) TextDivider(
                text: _messageModel.createAt.diffWith(
                  showTimeStamp: false,
                  showSpecialTime: true,
              )),
              // _unreadMessageDivider,
              if (_isShowUserListTile.value)
                Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: 2,
                    left: 40,
                  ),
                  child: nameAndTimeText,
                ),
              InkWell(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                highlightColor: Colors.transparent,
                // onDoubleTap: _showActionBottomSheet,
                // onLongPress: _showActionBottomSheet,
                child: ValueListenableBuilder(
                  valueListenable: widget.foundMessageId,
                  builder: (_, __, ___) {
                    return Container(
                      padding: widget.foundMessageId.value == widget.messageItemModel.messageId
                        ? const EdgeInsets.all(2)
                        : EdgeInsets.zero,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: widget.foundMessageId.value == widget.messageItemModel.messageId
                          ? AppColors.orange.withOpacity(0.25)
                          : null,
                      ),
                      child: _widget);
                  }
                ),
              ),
              // Row(
              //   mainAxisAlignment: _isSentByCurrentUser
              //       ? MainAxisAlignment.end
              //       : MainAxisAlignment.start,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Visibility(
              //       visible: _chatDetailBloc.isShowCheckBox,
              //       child: Checkbox(
              //         shape: const CircleBorder(),
              //         value: _messageModel.isCheck,
              //         onChanged: (bool? newValue) {
              //           _messageModel.isCheck = newValue!;
              //           if (_messageModel.isCheck == true) {
              //             selectMultiMessages.add(_messageModel.message);
              //           } else {
              //             selectMultiMessages.remove(_messageModel.message);
              //           }
              //           print(
              //               '${_messageModel.message}- ${_messageModel.isCheck}');
              //           print('$selectMultiMessages');
              //           setState(() {
              //
              //           });
              //         },
              //       ),
              //     ),
              //     // Spacer(),
              //
              //   ],
              // ),

              // const SizedBox(height: 2),
              if (_chatDetailBloc.isGroup||_isSentByCurrentUser) Container(
                padding:
                  _isSentByCurrentUser?
                    const EdgeInsets.only(right: 10):
                    const EdgeInsets.only(left: 10),
                child: seenUsers,
              ),
              if (
                  // (widget.chatDetailBloc?.typeGroup == 'Secret' ||
                  //       widget.groupType == 'Secret') &&
                  // có thể bỏ điều kiện này vì dùng điều kiện listDeleteTime thay thế nhưng cứ để lại cho chắc
                  // ((widget.chatDetailBloc?.deleteTime ??
                  //         int.tryParse(widget.deleteTime ?? '-1') ??
                  //         -1) >
                  //     0) &&
                  ((listDeleteTime[_messageModel.messageId] ??
                                  ValueNotifier(Duration(
                                    seconds: -1,
                                  )))
                              .value
                              .inSeconds >
                          0) &&
                      _messageModel.isSecretGroup == 1)
                ValueListenableBuilder(
                  valueListenable: changeTheme,
                  builder: (context, value, child) =>
                      ValueListenableBuilder<Duration>(
                    valueListenable: listDeleteTime[_messageModel.messageId] ??
                        ValueNotifier(Duration(
                          seconds: 10,
                        )),
                    builder: (_, myDuration, child) {
                      final hours = myDuration.inHours;
                      final minutes = myDuration.inMinutes.remainder(60);
                      final seconds = myDuration.inSeconds.remainder(60);
                      return Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: context.theme.backgroundChatContent,
                        ),
                        child: BlocListener<ChatDetailBloc, ChatDetailState>(
                          listenWhen: (prev, current) {
                            return (current is ChatDetailStateMarkReadMessage ||
                                current is ChatDetailStateLoadDoneListMessages);
                          },
                          listener: (context, state) async {
                            if ((state is ChatDetailStateMarkReadMessage &&
                                    (state.senderId != _currentUserId ||
                                        (state.senderId == _currentUserId &&
                                            _messageModel.senderId !=
                                                _currentUserId)) &&
                                    state.conversationId ==
                                        _messageModel.conversationId &&
                                    _messageModel.senderId != -1 &&
                                    _messageModel.isSecretGroup == 1 &&
                                    !widget.isGroup) ||
                                (state is ChatDetailStateAllMemberReadMessage &&
                                    state.conversationId ==
                                        _messageModel.conversationId)) {
                              // phần này dành để đếm ngay cả khi tắt đi bật lại => tạm thời comment lại cho đỡ nặng
                              // HiveService().saveTimeDeleteBox(
                              //   _messageModel.messageId,
                              //   DateTime.now()
                              //       .add(Duration(seconds: myDuration.inSeconds)),
                              // );
                              // _startCoundownToDeleteSecret();
                            }
                            // phần này dành để đếm ngay cả khi tắt đi bật lại => tạm thời comment lại cho đỡ nặng
                            // if (state is ChatDetailStateLoadDoneListMessages &&
                            //     ((await HiveService().getTimeDeleteBox(
                            //                     _messageModel.messageId) ??
                            //                 DateTime.now())
                            //             .compareTo(DateTime.now())) >
                            //         0 &&
                            //     multitimer[_messageModel.messageId] == null) {
                            //   _startCoundownToDeleteSecret();
                            // }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Tin nhắn bị xóa sau    '),
                              child!,
                              Text(
                                '  $hours:$minutes:$seconds  ',
                                style: AppTextStyles.regularW400(
                                  context,
                                  size: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: SvgPicture.asset(
                      Images.ic_timer_pause,
                      height: 14,
                      width: 14,
                    ),
                  ),
                ),
              if ((_nextMessageItemModel == null &&
                      ((widget.chatItemModel?.typeGroup ?? '') ==
                              'liveChatV2' ||
                          widget.groupType == 'LiveChatV2') &&
                      _messageModel.liveChat != null &&
                      (context
                              .read<ChatDetailBloc>()
                              .listUserInfoBlocs
                              .length) <
                          3) &&
                  !_isSentByCurrentUser)
                // ValueListenableBuilder<Duration>(
                //   valueListenable: _deleteMessageCountdown,
                //   builder: (_, myDuration, child) {
                //     final hours = myDuration.inHours;
                //     final minutes = myDuration.inMinutes.remainder(60);
                //     final seconds = myDuration.inSeconds.remainder(60);
                //     return Container(
                //       padding: const EdgeInsets.all(2),
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(10),
                //         color: context.theme.backgroundColor,
                //       ),
                //       child: Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           Text('Tin nhắn nhỡ sau  '),
                //           child!,
                //           Text(
                //             '  $hours:$minutes:$seconds  ',
                //             style: AppTextStyles.regularW400(
                //               context,
                //               size: 12,
                //             ),
                //           ),
                //         ],
                //       ),
                //     );
                //   },
                //   child: SvgPicture.asset(
                //     Images.ic_timer_pause,
                //     height: 14,
                //     width: 14,
                //   ),
                // ),
                if (_nextMessageItemModel == null)
                  const SizedBox(height: 40)
                else
                  SizedBox()
              // SizedBox(height: hasSpeaker ? 10 : 2),
            ],
          ),
        );
      },
    );
  }

  List<PopupMenuItem> buildPopupMenuItemList() {
    return  [
          PopupMenuItem(
            height: 33,
            child: Text(
              AppLocalizations.of(context)?.reply ??'',
              style: TextStyle(color: context.theme.text2Color,fontSize: 14),
            ),
            onTap: () async {
              widget.chatInputBarKey.currentState?.replyMessage(
                ApiReplyMessageModel(
                  senderId: _userInfoBloc.state.userInfo.id,
                  senderName: _userInfoBloc.state.userInfo.name,
                  message: _messageModel.message.cut(100),
                  createAt:
                      _messageModel.createAt.subtract(const Duration(hours: 7)),
                  messageId: _messageModel.messageId,
                  type: _messageModel.type,
                ),
              );
            },
          ),
          if (_messageModel.type?.isImage == false)
            PopupMenuItem(
              height: 33,
              child: Text(
                AppLocalizations.of(context)?.copy ??'',
                style: TextStyle(color: context.theme.text2Color,fontSize: 14),
              ),
              onTap: () {
                if (_messageModel.type?.isText == true) {
                  if (_messageModel.message != null) {
                    messagePaste = SocketSentMessageGetPasteModel(
                        type: MessageType.text, message: _messageModel.message);
                    Clipboard.setData(
                        ClipboardData(text: _messageModel.message!));
                    BotToast.showText(text: 'Sao chép thành công');
                  } else if (_messageModel.type?.isLink == true) {
                    String? content =
                        _messageModel.infoLink?.link ?? _messageModel.message;
                    if (content != null) {
                      messagePaste = SocketSentMessageGetPasteModel(
                          type: MessageType.text, message: content);
                      Clipboard.setData(ClipboardData(text: content));
                      BotToast.showText(text: 'Sao chép thành công');
                    }
                  } else if (_messageModel.type?.isImage == true) {
                    // đnag lỗi copy ảnh mai check
                    ApiFileModel? content = _messageModel.files![0];
                    logger.log('sadasdasdad${_messageModel.files![0]}');

                    if (content != null) {
                      ApiFileModel image = ApiFileModel(
                          fileName: content.fileName,
                          fileType: MessageType.image,
                          fileSize: content.fileSize,
                          displayFileSize: content.displayFileSize,
                          filePath: content.filePath,
                          height: content.height,
                          imageSource: content.imageSource,
                          resolvedFileName: content.resolvedFileName,
                          uploaded: content.uploaded,
                          width: content.width);
                      messagePaste = SocketSentMessageGetPasteModel(
                          type: MessageType.image, file: image);
                      Clipboard.setData(const ClipboardData(text: ''));
                      BotToast.showText(text: 'Sao chép thành công');
                    }
                  }
                }
              },
            ),
          if (_isSentByCurrentUser)
            PopupMenuItem(
              height: 33,
              child: Text(
                AppLocalizations.of(context)?.edit ??'',
                style: TextStyle(color: context.theme.text2Color,fontSize: 14),
              ),
              onTap: () async {
                widget.chatInputBarKey.currentState?.editMessage(_messageModel);
              },
            ),
          PopupMenuItem(
            height: 33,
            child: Text(
              AppLocalizations.of(context)?.forward ??'',
              style: TextStyle(color: context.theme.text2Color,fontSize: 14),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ForwardMessageScreen(
                        message: widget.messageItemModel,
                        senderInfo: AuthRepo().userInfo!);
                  });
            },
          ),
          if (_messageModel.type?.isText == true)
            PopupMenuItem(
              height: 33,
              child: Text(
                AppLocalizations.of(context)?.pinMessage ??'',
                style: TextStyle(color: context.theme.text2Color,fontSize: 14),
              ),
              onTap: () {
                context.read<ChatDetailBloc>().pinMessage(
                    _messageModel.messageId, _messageModel.message ?? '');
              },
            ),
          if (_isSentByCurrentUser)
            PopupMenuItem(
              height: 33,
              child: Text(
                AppLocalizations.of(context)?.evic ??'',
                style: TextStyle(color: context.theme.text2Color,fontSize: 14),
              ),
              onTap: () {
                context.read<ChatBloc>().add(
                      ChatEventEmitDeleteMessage(
                        ApiMessageModel(
                          messageId: _messageModel.messageId,
                          conversationId: _messageModel.conversationId,
                          senderId: _messageModel.senderId,
                          type: _messageModel.type ?? MessageType.text,
                        ),
                        _chatDetailBloc.listUserInfoBlocs.keys.toList(),
                      ),
                    );
                BotToast.showText(text: 'Thu hồi thành công');
              },
            ),
          PopupMenuItem(
            height: 33,
            child: Text(
              AppLocalizations.of(context)?.delete ??'',
              style: TextStyle(color: Color.fromARGB(255, 255, 110, 110),fontSize: 14),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                        shadowColor: context.theme.textColor.withOpacity(0.5),
                        backgroundColor: context.theme.backgroundChatContent,
                        child: Container(
                          width: 350,
                          height: 124,
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                width: 350,
                                decoration: BoxDecoration(
                                    gradient: context.theme.gradient,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    )),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Bạn có chắc chắn muốn xoá không ?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                      color: AppColors.white),
                                ),
                              ),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  buttonWhite(
                                      AppLocalizations.of(context)?.cancel ??'',
                                      30,
                                      () => Navigator.of(context).pop(),
                                      context),
                                  buttonBlue(AppLocalizations.of(context)?.delete ??'', 80, () {
                                    context.read<ChatBloc>().add(
                                          ChatEventEmitDeleteMessage(
                                            ApiMessageModel(
                                              messageId:
                                                  _messageModel.messageId,
                                              conversationId:
                                                  _messageModel.conversationId,
                                              senderId: _messageModel.senderId,
                                              type: _messageModel.type ??
                                                  MessageType.text,
                                            ),
                                            [context.userInfo().id],
                                          ),
                                        );
                                    AppRouter.back(context);
                                    BotToast.showText(
                                        text: 'Xóa tin nhắn thành công');
                                  }, context),
                                ],
                              ),
                            ],
                          ),
                        ));
                  });
            },
          ),
        ];
  }

  // chức năng khi chon vào tin nhắn
  void _showPopupMenu(BuildContext context, Offset position) {
    showMenu(
        // shadowColor: context.theme.textColor,
        // surfaceTintColor: AppColors.green20744A,
        color: context.theme.backgroundOnForward,
        context: context,
        position: RelativeRect.fromLTRB(
            position.dx, position.dy, position.dx + 1, position.dy + 1),
        items: buildPopupMenuItemList());
  }

  bool _messageBoxBuildWhen(ChatState _, ChatState chatState) {
    if (chatState is! ChatMessageState ||
        (chatState is ChatStateDeleteMessageSuccess &&
            chatState.messageIndex == null)) return false;
    final String messageId = chatState.messageId;
    return messageId == _messageModel.messageId ||
        (chatState is ChatStateDeleteMessageSuccess &&
            (messageId == _nextMessageItemModel?.messageId ||
                messageId == _prevMessageItemModel?.messageId));
  }
}

class ShowEmotionButton extends StatelessWidget {
  ShowEmotionButton({
    Key? key,
    this.onSelected,
    required this.reactionCubit,
    required this.onTapLikeButton,
    required this.onHoldLikeButton,
  }) : super(key: key);

  final ValueChanged<Emoji>? onSelected;
  final ReactionCubit reactionCubit;
  final void Function() onTapLikeButton;
  final void Function(LongPressDownDetails) onHoldLikeButton;
  LongPressDownDetails holdDetails = const LongPressDownDetails();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTapLikeButton,
        onLongPressDown: (details) {holdDetails = details;},
        onLongPress: () {onHoldLikeButton(holdDetails);},
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.black.withOpacity(0.15), width: 0.5)
          ),
          height: AppConst.kLikeIconSize,
          width: AppConst.kLikeIconSize,
          padding: const EdgeInsets.all(4),
          child: BlocListener<ReactionCubit, ReactionState>(
          bloc: reactionCubit,
          listener: (context, state) {
            if (state is ReactionStateChangeReactionError) {
              AppDialogs.toast(state.error.error);
            }
          },
          child: SvgPicture.asset(
              Images.ic_thumb_up,
              width: 6,
              height: 6,
              colorFilter: const ColorFilter.mode(AppColors.dustyGray, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
