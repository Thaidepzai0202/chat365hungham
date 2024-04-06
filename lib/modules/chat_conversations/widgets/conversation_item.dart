import 'dart:async';
import 'dart:convert';

import 'package:app_chat365_pc/common/Widgets/ellipsized_text.dart';
import 'package:app_chat365_pc/common/Widgets/typing_detector.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/theme_cubit/theme_cubit.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_state.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/components/display/time_badge.dart';
import 'package:app_chat365_pc/common/components/display_image_with_status_badge.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/notification_message_display.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_cubit.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/create_new_group_chat_dialog.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_model.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/pin_code_pages.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/unicorn_button.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_cubit.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/date_time_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:sp_util/sp_util.dart';
import '../../../common/repos/chat_repo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConversationItem extends StatefulWidget {
  const ConversationItem({
    super.key,
    required this.message,
    required this.chatItemModel,
    required this.chatType,
    required this.createdAt,
    required this.conversationBasicInfo,
    required this.userInfoBloc,
    this.isDraft = false,
    this.users = const [],
    this.lastMessageId,
    required this.messageType,
    this.messageDisplay,
    required this.unreadMessageCubit,
    this.totalMessage,
    required this.indexColor,
    required this.index,
  });

  @Deprecated("Đây là chatItemModel.messageType")
  final MessageType? messageType;

  @Deprecated("Đây là chatItemModel.message")
  final String message;

  @Deprecated("Đây là chatItemModel.conversationBasicInfo.lastMessagesId")
  final String? lastMessageId;

  //
  final bool isDraft;

  final ChatItemModel chatItemModel;
  final ChatType chatType;

  @Deprecated("Đây là chatItemModel.conversationBasicInfo")
  final ConversationBasicInfo conversationBasicInfo;

  final UserInfoBloc userInfoBloc;

  @Deprecated(
      "Đây là SocketSentMessageModel().createAt (thời gian tin nhắn cuối)")
  final DateTime createdAt;

  @Deprecated("Đây là chatItemModel.memberList")
  final List<IUserInfo> users;

  /// Dùng để nhét vào ChatDetailBloc, để giới hạn số tin nhắn trả về khi gọi API (?)
  final int? messageDisplay;
  final ValueNotifier<int>? totalMessage;
  final ValueNotifier<int> indexColor;

  @Deprecated("Cho nhưng không hề dùng")
  final int index;

  final UnreadMessageCounterCubit unreadMessageCubit;

  @override
  State<ConversationItem> createState() => _ConversationItemState();
}

class _ConversationItemState extends State<ConversationItem> {
  var senderAvatar = '';
  late final int conversationId;

  late final ValueNotifier<List<IUserInfo>> _usersNotifier;
  ValueNotifier<bool> _isOnNotifications = ValueNotifier<bool>(true);

  late ChatDetailBloc _chatDetailBloc;
  late UserInfoBloc _userInfoBloc;
  late final ValueNotifier<MessageType?> messageTypeNotifier;

  late Widget _unreadMessageIndicator;
  late Widget _displayMsgText;
  late final ValueNotifier<int?> _lastSenderId;
  ValueNotifier<int> isHidden = ValueNotifier<int>(1);

  List<IUserInfo> get users => _usersNotifier.value;
  late bool _isDraft;
  late AppLayoutCubit appLayoutCubit;
  late final ChatConversationBloc _chatConversationBloc;
  late final ChatBloc _chatBloc;
  late final int _currentUserId;
  late final ValueNotifier<String> displayMsg;
  String? _lastMessageId;
  late Widget _msgWidget;
  late ChatConversationCubit chatConversationCubit;

  late final TypingDetectorBloc _typingDetectorBloc;

  late StreamSubscription<ChatEvent> _chatRepoSub;

  String _getSenderAvatar(int senderId) {
    try {
      /// TL 13/1/2024: Sửa lỗi lấy avatar bị No host specified in URI
      //final IUserInfo user = users.firstWhere((e) => e.id == senderId);
      final IUserInfo user = UserInfoRepo().getUserInfoSync(senderId) ??
          users.firstWhere((e) => e.id == senderId);
      widget.chatItemModel.senderId = user.id;

      // TL 13/1/2024: Sửa IUserInfo về hết thành URL
      return user.avatar!;
    } catch (e) {
      logger.logError(
        'Không tìm thấy userId = $senderId trong groupId = $conversationId',
      );
    }
    return '';
  }

  ChatMemberModel? get firstOtherMember {
    try {
      return widget.chatItemModel.memberList.firstWhere(
          (element) => element.id != widget.conversationBasicInfo.userId);
    } catch (e) {
      return null;
    }
  }

  String get conversationName {
    if (widget.chatType == ChatType.GROUP || firstOtherMember != null) {
      return widget.conversationBasicInfo.name;
    }
    return firstOtherMember!.name;
  }

  ValueNotifier<bool> isRead = ValueNotifier(false);
  late String? groupType;

  late String? messageId;
  String deleteTime = DateTime(3000).toIso8601String();
  late final MyTheme _theme;

//ham show menu khi an chuot phai
  void _showPopupMenu(BuildContext context, Offset position) {
    showMenu(
        // shadowColor: AppColors.red,
        shadowColor: context.theme.text2Color, //
        color: context.theme.backgroundColor,
        context: context,
        position: RelativeRect.fromLTRB(
            position.dx, position.dy, position.dx + 1, position.dy + 1),
        items: [
          PopupMenuItem(
            height: 32,
            child: BlocListener(
                bloc: chatConversationCubit,
                listener: (context, state) {
                  if (state is LoadedAddFavouriteChatState) {
                    _chatConversationBloc.loadData();
                  }
                },
                child: Container(
                    child: widget.chatItemModel.isFavorite == false
                        ? Text(
                            AppLocalizations.of(context)!.addFavourite,
                            style: TextStyle(
                                color: context.theme.text2Color, fontSize: 14),
                          )
                        : Text(
                            AppLocalizations.of(context)!.deleteFavourite,
                            style: TextStyle(
                                color: context.theme.text2Color, fontSize: 14),
                          ))),
            onTap: () async {
              // TL 18/1/2024: Sửa trạng thái yêu thích ở ChatRepo
              await ChatRepo().changeFavoriteStatus(
                  conversationId: conversationId,
                  favorite: !widget.chatItemModel.isFavorite);
              _chatConversationBloc.loadData(countLoaded: 0, reset: true);
            },
          ),
          PopupMenuItem(
            height: 32,
            child: Text(AppLocalizations.of(context)!.viewProfile,
                style:
                    TextStyle(color: context.theme.text2Color, fontSize: 14)),
            onTap: () {},
          ),

          // Mục tạo trò chuyện nhóm
          if (!widget.chatItemModel.isGroup)
            PopupMenuItem(
              // TL 14/12/2023: Tạo nhóm với tên thật của người chat kia
              height: 32,
              child: Text(
                '${AppLocalizations.of(context)!.makeGroupWith} ',
                style: TextStyle(fontSize: 14, color: context.theme.text2Color),
              ),
              onTap: () async {
                var pressedUser =
                    await UserInfoRepo().getUserInfo(firstOtherMember!.id);
                await showDialog(
                    context: context,
                    builder: (new_context) {
                      return CreateNewGroupChatDialog(
                          originContext: context, initialUser: pressedUser!);
                    });
              },
            ),
          PopupMenuItem(
            height: 32,
            child: PopupMenuButton(
              tooltip: '',
              offset: const Offset(150, 0),
              child:
                  rowItemChat(AppLocalizations.of(context)!.classify, context),
              itemBuilder: (context) => [
                PopupMenuItem(
                  height: 32,
                  onTap: () {
                    setState(() {});
                  },
                  child: const Text('No no no'),
                )
              ],
            ),
            onTap: () {},
          ),
          PopupMenuItem(
            height: 32,
            child: Text(AppLocalizations.of(context)!.maskAsUnread,
                style:
                    TextStyle(color: context.theme.text2Color, fontSize: 14)),
            onTap: () {},
          ),
          PopupMenuItem(
            height: 32,
            child: Text(AppLocalizations.of(context)!.hideConversation,
                style:
                    TextStyle(color: context.theme.text2Color, fontSize: 14)),
            onTap: () async {
              await chatConversationCubit.takePINcode();
              // ignore: use_build_context_synchronously
              showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                        backgroundColor: context.theme.backgroundColor,
                        child: chatConversationCubit.pinCode != ''
                            ? BlocListener(
                                bloc: chatConversationCubit,
                                listener: (context, state) {
                                  if (state is SuccessHiddenState) {
                                    AppRouter.back(context);
                                  }
                                },
                                child: Container(
                                  height: 220,
                                  width: 380,
                                  decoration: BoxDecoration(
                                      color: context.theme.backgroundColor,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            gradient: context.theme.gradient,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15))),
                                        height: 45,
                                        width: 380,
                                        child: const Text(
                                          'Nhập mã PIN để ẩn cuộc trò chuyện',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.white),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      PinCodePages(
                                        validator: (v) {
                                          if (v!.length < 6) {
                                            return "Mã pin không đúng";
                                          } else if (v !=
                                              chatConversationCubit.pinCode) {
                                            return "Mã pin không đúng, vui lòng kiểm tra lại!";
                                          } else {
                                            return null;
                                          }
                                        },
                                        onComplete: (v) async {
                                          if (v ==
                                              chatConversationCubit.pinCode) {
                                            await chatConversationCubit
                                                .hiddenConversation(
                                                    conversationId: widget
                                                        .chatItemModel
                                                        .conversationId,
                                                    isHidden: 1);
                                            _chatConversationBloc.loadData(
                                                countLoaded: 0, reset: true);
                                          }
                                        },
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Nếu quên mã pin,bạn phải ',
                                            style: TextStyle(
                                                color:
                                                    context.theme.text2Color),
                                          ),
                                          InkWell(
                                            onTap: () {},
                                            child: Text(
                                              'Cài đặt lại mã',
                                              style: TextStyle(
                                                  color: context.theme
                                                      .colorPirimaryNoDarkLight,
                                                  decoration:
                                                      TextDecoration.underline),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                width: 450,
                                height:
                                    changeLanguage.value == 'vi' ? 230 : 200,
                                decoration: BoxDecoration(
                                    color: context.theme.backgroundColor,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 500,
                                      height: 48,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        gradient: context.theme.gradient,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15)),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .hiddenConversationOnChat365,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.white),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .hiddenConversationOnChat365Content1,
                                      style: AppTextStyles.text(context),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .hiddenConversationOnChat365Content2,
                                        style: AppTextStyles.text(context),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        buttonWhite(
                                            AppLocalizations.of(context)!
                                                .cancel,
                                            108, () {
                                          AppRouter.back(context);
                                        }, context),
                                        const SizedBox(
                                          width: 60,
                                        ),
                                        buttonBlue(
                                            AppLocalizations.of(context)!
                                                .setPIN,
                                            112, () {
                                          AppRouter.back(context);
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    content: Container(
                                                      padding: EdgeInsets.zero,
                                                      height: 200,
                                                      width: 400,
                                                      decoration: BoxDecoration(
                                                          color: context.theme
                                                              .backgroundColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                              height: 50,
                                                              decoration: BoxDecoration(
                                                                  gradient: context
                                                                      .theme
                                                                      .gradient,
                                                                  borderRadius: const BorderRadius
                                                                      .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              15),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              15))),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            30),
                                                                    child:
                                                                        Text(
                                                                      AppLocalizations.of(context)!.setPIN,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              22,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              AppColors.white),
                                                                    ),
                                                                  ),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        AppRouter.back(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          const Icon(
                                                                        Icons
                                                                            .close,
                                                                        color: AppColors
                                                                            .white,
                                                                        size:
                                                                            30,
                                                                      )),
                                                                ],
                                                              )),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(context)!.enterPINcode,
                                                            style: AppTextStyles
                                                                .text(context),
                                                          ),
                                                          // const SizedBox(
                                                          //   height: 20,
                                                          // ),
                                                          PinCodePages(
                                                              validator: (v) {
                                                            if (v!.length < 6) {
                                                              return AppLocalizations.of(context)!.least6digit;
                                                            } else {
                                                              return null;
                                                            }
                                                          }, onComplete: (v) {
                                                            AppRouter.back(
                                                                context);
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                      contentPadding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      content:
                                                                          Container(
                                                                        padding:
                                                                            EdgeInsets.zero,
                                                                        height:
                                                                            200,
                                                                        width:
                                                                            400,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                context.theme.backgroundColor,
                                                                            borderRadius: BorderRadius.circular(15)),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Container(
                                                                                height: 50,
                                                                                decoration: BoxDecoration(gradient: context.theme.gradient, borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Container(
                                                                                      margin: const EdgeInsets.only(left: 30),
                                                                                      child:  Text(
                                                                                        AppLocalizations.of(context)!.confirmPINCode,
                                                                                        style:const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white),
                                                                                      ),
                                                                                    ),
                                                                                    TextButton(
                                                                                        onPressed: () {
                                                                                          AppRouter.back(context);
                                                                                        },
                                                                                        child: const Icon(
                                                                                          Icons.close,
                                                                                          color: AppColors.white,
                                                                                          size: 30,
                                                                                        )),
                                                                                  ],
                                                                                )),
                                                                            const SizedBox(
                                                                              height: 20,
                                                                            ),
                                                                            Text(
                                                                              AppLocalizations.of(context)!.enterPINcode,
                                                                              style: AppTextStyles.text(context),
                                                                            ),
                                                                            PinCodePages(validator:
                                                                                (value) {
                                                                              if (value!.length < 6) {
                                                                                return AppLocalizations.of(context)!.least6digit;
                                                                              } else if (value != v) {
                                                                                return AppLocalizations.of(context)!.codePinNotMatch;
                                                                              } else {
                                                                                return null;
                                                                              }
                                                                            }, onComplete:
                                                                                (v1) async {
                                                                              if (v1 == v) {
                                                                                await chatConversationCubit.updatePINCode(v1);
                                                                                await chatConversationCubit.hiddenConversation(conversationId: widget.chatItemModel.conversationId, isHidden: 1);
                                                                                AppRouter.back(context);
                                                                                _chatConversationBloc.loadData(countLoaded: 0, reset: true);
                                                                              }
                                                                            })
                                                                          ],
                                                                        ),
                                                                      ));
                                                                });
                                                          })
                                                        ],
                                                      ),
                                                    ));
                                              });
                                        }, context)
                                      ],
                                    )
                                  ],
                                ),
                              ));
                  });
            },
          ),

          /// TL 16/2/2024: Sửa thành ListenableBuilder để cập nhật bật tắt thông báo
          /// NOTE: Vẫn lỗi. Chắc là do widget.chatItemModel rồi -.-
          PopupMenuItem(
            height: 32,
            child: ValueListenableBuilder(
                valueListenable: _isOnNotifications,
                builder: ((context, value, child) {
                  return value == true
                      ? Text(
                          AppLocalizations.of(context)!
                              .offNotificationConversation,
                          style: TextStyle(
                              color: context.theme.text2Color, fontSize: 14))
                      : Text(
                          AppLocalizations.of(context)!
                              .onNotificationConversation,
                          style: TextStyle(
                              color: context.theme.text2Color, fontSize: 14));
                })),
            onTap: () async {
              await ChatRepo()
                  .changeNotificationStatus(conversationId: conversationId);
              _isOnNotifications.value = !_isOnNotifications.value;
              // await chatConversationCubit.changeNotifyChat(
              //     conversationId: widget.chatItemModel.conversationId);
              _chatConversationBloc.loadData(countLoaded: 0, reset: true);
            },
          ),
          PopupMenuItem(
            height: 32,
            child: rowItemChat(
                AppLocalizations.of(context)!.autoDeletedMessage, context),
            onTap: () {},
          ),
          PopupMenuItem(
            height: 32,
            child: Text(AppLocalizations.of(context)!.deleteConversation,
                style:
                    TextStyle(color: context.theme.text2Color, fontSize: 14)),
            onTap: () async {
              await chatConversationCubit.deleteConversation(
                  conversationId: widget.chatItemModel.conversationId);
              _chatConversationBloc.loadData(countLoaded: 0, reset: true);
            },
          ),
        ]);
  }

  TextStyle getTextStyle(BuildContext context, bool isConversationRead) {
    return context.theme.messageTextStyle.copyWith(
      fontWeight:
          isRead.value == false&&_lastSenderId.value != _currentUserId
              ? FontWeight.w700
              : FontWeight.w400,
      color: context.theme.text2Color,
      fontSize: 13.25,
      letterSpacing: -0.15,
      wordSpacing: -0.75);

  }

  void addToUnreadCount(int conversationId, int amount) {
    ConversationModel? model = ChatRepo().getConversationModelSync(conversationId);
    if (model != null) {
      model.unReader += amount;
      ChatRepo().setConversationModel(model);
    }
  }

  void resetUnreadCount(int conversationId) {
    ConversationModel? model = ChatRepo().getConversationModelSync(conversationId);
    if (model != null) {
      model.unReader = 0;
      ChatRepo().setConversationModel(model);
    }
  }

  @override
  void initState() {
    super.initState();
    // TL 6/1/2024: Lắng nghe sự kiện tin nhắn đến/thu hồi/xóa để sửa dòng tóm tắt tin nhắn
    _chatRepoSub = ChatRepo().stream.listen((event) async {
      if (event is ChatEventOnReceivedMessage) {
        if (conversationId == event.msg.conversationId) {
          var msg = event.msg;
          displayMsg.value = msg.message ?? displayMsg.value;
          _lastMessageId = event.msg.messageId;
          messageTypeNotifier.value = msg.type ?? messageTypeNotifier.value;
          if (event.msg.senderId != _currentUserId &&
            widget.indexColor.value != widget.conversationBasicInfo.conversationId) {
            isRead.value = false;
            addToUnreadCount(conversationId, 1);
          }
        }
      } else if (event is ChatEventOnDeleteMessage &&
          event.conversationId == conversationId) {
        /// TL 9/1/2024 Copy code ben tren
        var msg = await ChatRepo()
            .loadMessages(conversationId: conversationId, range: 1);

        if (msg.isEmpty) {
          displayMsg.value = "";
          messageTypeNotifier.value = null;
        } else {
          _lastMessageId = msg.first.messageId;
          displayMsg.value = msg.first.message ?? displayMsg.value;
          messageTypeNotifier.value =
              msg.first.type ?? messageTypeNotifier.value;
        }
      } else if (event is ChatEventOnChangeNotification &&
          event.conversationId == conversationId) {
        _isOnNotifications.value = event.isNotification;
      }
    });

    chatConversationCubit = context.read<ChatConversationCubit>();
    groupType = '';
    _chatConversationBloc = context.read<ChatConversationBloc>();
    _isDraft = widget.isDraft;
    _lastMessageId = widget.lastMessageId;
    _theme = context.theme;
    conversationId = widget.conversationBasicInfo.conversationId;
    isRead.value = (ChatRepo().getConversationModelSync(conversationId)?.unReader??0) == 0;
    _typingDetectorBloc = _chatConversationBloc.typingBlocs[conversationId] ??
        TypingDetectorBloc(conversationId);
    _userInfoBloc = widget.userInfoBloc;
    _chatBloc = context.read<ChatBloc>();
    _currentUserId = context.userInfo().id;
    _lastMessageId = widget.lastMessageId;
    _usersNotifier = ValueNotifier([...widget.users]);

    displayMsg = ValueNotifier(widget.message);
    messageTypeNotifier = ValueNotifier(widget.messageType);
    _lastSenderId =
        ValueNotifier(widget.conversationBasicInfo.groupLastSenderId)
          ..addListener(() async {
            if (_lastSenderId.value != null) {
              await UserInfoRepo().getUserInfo(_lastSenderId.value!);
              _getSenderAvatar(_lastSenderId.value!);
            }
          });

    if (widget.chatType == ChatType.GROUP &&
        widget.conversationBasicInfo.groupLastSenderId != null) {
      senderAvatar =
          _getSenderAvatar(widget.conversationBasicInfo.groupLastSenderId!);
    }
    _setup();
    appLayoutCubit = context.read<AppLayoutCubit>();
    // TL 14/12/2023: Tạo ChatDetailBloc ở đây luôn, vì có nhiều thứ phải dùng
    // đến nó khi build
    _chatDetailBloc = ChatDetailBloc(
        conversationId: conversationId,
        senderId: context.userInfo().id,
        isGroup: widget.chatType == ChatType.GROUP,
        initMemberHasNickname:
            widget.chatType == ChatType.GROUP ? [] : [_userInfoBloc.userInfo],
        messageDisplay: widget.messageDisplay,
        chatItemModel: widget.chatItemModel,
        unreadMessageCounterCubit: UnreadMessageCounterCubit(
          conversationId: conversationId,
          countUnreadMessage: 0,
        ),
        deleteTime: widget.chatItemModel?.deleteTime ??
            int.tryParse(deleteTime ?? '-1') ??
            -1,
        otherDeleteTime: widget.chatItemModel
                ?.firstOtherMember(context.userInfo().id)
                .deleteTime ??
            -1,
        myDeleteTime:
            // widget.chatItemModel?.memberList
            //         .firstWhere((e) => e.id == _currentUserId)
            //         .deleteTime ??
            -1,
        messageId: '',
        typeGroup: groupType ?? widget.chatItemModel.typeGroup);
  isRead.addListener(() {
      logger.log("${widget.chatItemModel.conversationId}: ${isRead.value}", name: "IsRead");
  });
  }

  @override
  void didUpdateWidget(covariant ConversationItem oldWidget) {
    // TL Note 25/12/2023: Có phải mình tạo ra bloc này đâu mà close?
    // _userInfoBloc.close();
    // _userInfoBloc = widget.userInfoBloc;
    _lastSenderId.value = widget.conversationBasicInfo.groupLastSenderId;
    _lastMessageId = widget.lastMessageId;
    displayMsg.value = widget.message;
    if (messageTypeNotifier.value != widget.messageType) {
      messageTypeNotifier.value = widget.messageType;
    }
    _setup();
    super.didUpdateWidget(oldWidget);
  }

  DateTime now = DateTime.now();

  @override
  void dispose() {
    // TL Note 25/12/2023: Có phải mình tạo ra bloc này đâu mà close?
    //_userInfoBloc.close();
    widget.totalMessage?.dispose();
    widget.userInfoBloc.close();
    _chatRepoSub.cancel();

    super.dispose();
  }

  _setup() {
    _isOnNotifications =
        ValueNotifier<bool>(widget.chatItemModel.isNotification);
    _isDraft = widget.isDraft;
    _unreadMessageIndicator = BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return SizedBoxExt.shrink;
      },
    );
    _displayMsgText = BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {

        return ValueListenableBuilder(
            valueListenable: changeTheme,
            builder: (BuildContext context, dynamic value, Widget? child) =>
                ValueListenableBuilder(
                  valueListenable: isRead,
                  builder: (_, __, ___) {
  
                      return BlocListener<ChatBloc, ChatState>(
                          listener: (context, state) {
                            if (state is ChatStateReceiveMessage) {
                              if (conversationId ==
                                  state.msg.conversationId) {
                                displayMsg.value =
                                    state.msg.message ?? displayMsg.value;
                                messageTypeNotifier.value = state.msg.type ??
                                    messageTypeNotifier.value;
                              }
                            }
                          },
                          child: AnimatedBuilder(
                              key: Key(widget
                                  .conversationBasicInfo.conversationId
                                  .toString()),
                              animation: Listenable.merge([
                                displayMsg,
                                messageTypeNotifier,
                                _usersNotifier
                              ]),
                              builder: (context, child) {
                                if (messageTypeNotifier
                                        .value?.isNotification ==
                                    true) {
                                  return NotificationMessageDisplay(
                                    message: displayMsg.value,
                                    conversationId: conversationId,
                                    textBuilder: (_, text) {
                                      // logger.log(text, name: 'Notification text: ');
                                      return EllipsizedText(
                                        text,
                                        style: getTextStyle(context, isRead.value),
                                      );
                                    },
                                    listUserInfos: Map.fromIterable(
                                      users,
                                      key: (key) => (key as IUserInfo).id,
                                      value: (value) => UserInfoBloc(
                                        (value as IUserInfo),
                                      ),
                                    ),
                                    onGetUnknownUserIdsFound: (blocs) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) =>
                                              _usersNotifier.value = [
                                                ...users,
                                                ...blocs
                                                    .map((e) => e.userInfo)
                                              ]);
                                      blocs.forEach((bloc) {
                                        // var index = _chatConversationBloc.chats.indexWhere(
                                        //   (e) => e.conversationId == conversationId,
                                        // );

                                        StreamSubscription? stream;
                                        stream = bloc.stream.listen((state) {
                                          var members =
                                              widget.chatItemModel.memberList;
                                          var info = state.userInfo;
                                          if (!members
                                              .map((e) => e.id)
                                              .contains(info.id)) {
                                            stream?.cancel();
                                          } else if (!RegExp(
                                                  r'Người dùng \d+')
                                              .hasMatch(info.name)) {
                                            widget.chatItemModel.memberList =
                                                [
                                              ChatMemberModel(
                                                id: info.id,
                                                name: info.name,
                                                avatar: info.avatar ?? '',
                                                unReader: widget.totalMessage
                                                        ?.value ??
                                                    0,
                                              ),
                                              ...members,
                                            ];
                                            stream?.cancel();
                                          }
                                        });
                                      });
                                    },
                                  );
                                }
                                if (messageTypeNotifier.value?.isSticker ==
                                    true) {
                                  return EllipsizedText(
                                    'Sticker',
                                    style: getTextStyle(context, isRead.value),
                                  );
                                }
                                if (messageTypeNotifier.value?.isreminder ==
                                    true) {
                                  return EllipsizedText(
                                    'Nhắc hẹn',
                                    style: getTextStyle(context, isRead.value),
                                  );
                                }
                                if (messageTypeNotifier.value?.isVote ==
                                    true) {
                                  return EllipsizedText(
                                    'Cuộc bình chọn',
                                    style: getTextStyle(context, isRead.value),
                                  );
                                }
                                if (messageTypeNotifier
                                        .value?.isreminderNoti ==
                                    true) {
                                  return EllipsizedText(
                                    jsonDecode(displayMsg.value)['message'],
                                    style: getTextStyle(context, isRead.value),
                                  );
                                }
                                if (messageTypeNotifier
                                        .value?.isnotificationGroup ==
                                    true) {
                                  return EllipsizedText(
                                    jsonDecode(displayMsg.value)['message'],
                                    style: getTextStyle(context, isRead.value),
                                  );
                                }
                                String messagePreview = displayMsg.value;
                                if ([
                                    MessageType.adsCC,
                                    MessageType.adsCV,
                                    MessageType.adsNews,
                                  ].contains(widget.chatItemModel.messageType)) {
                                    Map<String, dynamic> jsonData = jsonDecode(messagePreview);
                                    messagePreview = jsonData['main_ads']?['title']??"Tin quảng cáo";
                                }
                                return EllipsizedText(
                                  widget.chatItemModel.senderId == _currentUserId
                                    ? "Bạn: $messagePreview"
                                    : messagePreview,
                                  style: getTextStyle(context, isRead.value),
                                  maxLines: 1,
                                  // overflow: TextOverflow.ellipsis,
                                  // softWrap: false,
                                );
                              }));
                    },
                  
                ));
      },
    );

    _msgWidget = BlocBuilder<TypingDetectorBloc, TypingDetectorState>(
      bloc: _typingDetectorBloc,
      builder: (context, typingState) {
        if (typingState.typingUserIds.isNotEmpty) {
          return TypingDetector(
            conversationId: widget.conversationBasicInfo.conversationId,
          );
        }
        return _displayMsgText;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    String getDayOfWeek(int day) {
      switch (day) {
        case 1:
          return 'T2';
        case 2:
          return 'T3';
        case 3:
          return 'T4';
        case 4:
          return 'T5';
        case 5:
          return 'T6';
        case 6:
          return 'T7';
        case 7:
          return 'CN';
        default:
          return '';
      }
    }

    // check 2 ngày có cùng tuần không
    int getWeekNumber(DateTime date) {
      DateTime jan1 = DateTime(date.year, 1, 1);
      int days = date.difference(jan1).inDays;
      return ((days + jan1.weekday - 1) / 7).floor() + 1;
    }

    final ThemeData theme = Theme.of(context);
    int dayOfWeek = widget.createdAt.weekday;
    var time = ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) => ValueListenableBuilder(
        valueListenable: isRead,
        builder: (_, __, ___) {
          // print('cuctac${widget.createdAt.hour} ${widget.createdAt.minute} ');
          if (_lastMessageId == null) {
            return SizedBox();
          }

          var createdAt = ChatRepo()
              .getMessage(
                  conversationId: conversationId, messageId: _lastMessageId!)
              ?.createAt;

          if (createdAt == null) {
            return SizedBox();
          }

          return Text(
              // widget.unreadMessageCubit.hasUnreadMessage == true
              //     ? (DateTime(now.year, now.month, now.day) ==
              //             DateTime(widget.createdAt.year,
              //                 widget.createdAt.month, widget.createdAt.day)
              //         ? widget.createdAt.hour + 7 > 12
              //             ? '${widget.createdAt.hour }:${widget.createdAt.minute.toString().padLeft(2, '0')} PM'
              //             : '${widget.createdAt.hour + 7}:${widget.createdAt.minute.toString().padLeft(2, '0')} AM'
              //         : getWeekNumber(now) == getWeekNumber(widget.createdAt)
              //             ? getDayOfWeek(dayOfWeek)
              //             : DateFormat('dd/MM/yyyy').format(widget.createdAt))
              //     :
              (DateTime(now.year, now.month, now.day) ==
                      DateTime(createdAt.year, createdAt.month, createdAt.day)
                  ? createdAt.hour
                          // +7
                          >
                          12
                      ? '${createdAt.hour
                          // +7
                          }:${createdAt.minute.toString().padLeft(2, '0')} PM'
                      : '${createdAt.hour
                      // +7
                      }:${createdAt.minute.toString().padLeft(2, '0')} AM'
                  : getWeekNumber(now) == getWeekNumber(createdAt)
                      ? getDayOfWeek(dayOfWeek)
                      : DateFormat('dd/MM/yyyy').format(createdAt)),
              style: AppTextStyles.text(context).copyWith(
                fontSize: 13,
                color: context.theme.text2Color,
                fontWeight:
                        isRead.value == false&&_lastSenderId.value != _currentUserId
                    ? FontWeight.w700
                    : FontWeight.w400,
              ));
        },
      ),
    );

    var draft = Text(
      'Chưa gửi',
      style: theme.textTheme.bodyLarge!.copyWith(color: AppColors.red),
    );
    // ảnh đại diện và trạng thái hoạt động
    var displayImage = BlocBuilder<UserInfoBloc, UserInfoState>(
      bloc: _userInfoBloc,
      builder: (context, state) {
        return DisplayImageWithStatusBadge(
          isSecret: (widget.chatItemModel.typeGroup) == 'Secret',
          isGroup: widget.chatType == ChatType.GROUP,
          model: widget.conversationBasicInfo,
          userStatus: widget.conversationBasicInfo.userStatus,
          enable: false,
          size: 40,
          badgeSize: 15,
          badge: widget.chatType == ChatType.GROUP
              ? BlocBuilder<ChatBloc, ChatState>(
                  buildWhen: (_, current) =>
                      current is ChatStateReceiveMessage &&
                      current.msg.conversationId ==
                          widget.conversationBasicInfo.conversationId,
                  builder: (_, chatState) {
                    if (chatState is ChatStateReceiveMessage &&
                        chatState.msg.conversationId ==
                            widget.conversationBasicInfo.conversationId) {
                      senderAvatar = _getSenderAvatar(chatState.msg.senderId);
                    }

                    return CircleAvatar(
                      radius: (17 + 1.5) / 2,
                      backgroundColor: AppColors.white,
                      child: CircleAvatar(
                        radius: 17 / 2,
                        backgroundColor: Colors.transparent,
                        backgroundImage:
                            const AssetImage(Images.img_non_avatar),
                        foregroundImage: CachedNetworkImageProvider(
                          senderAvatar,
                        ),
                      ),
                    );
                  },
                )
              : TimeBadge(
                  lastOnlineTime: state.userInfo.lastActive,
                  onlineWidget:
                      state.userInfo.userStatus.getStatusBadge(context),
                ),
        );
      },
    );
    var nameWidget = BlocBuilder<UserInfoBloc, UserInfoState>(
      bloc: _userInfoBloc,
      builder: (context, userState) {
        return ValueListenableBuilder(
          valueListenable: changeTheme,
          builder: (context, value, child) => ValueListenableBuilder(
            valueListenable: isRead,
            builder: (_, __, ___) => Text(
              // hiển thị biệt danh
              conversationName,
              style: TextStyle(
                wordSpacing: -0.5,
                // fontWeight: widget.chatItemModel.numberOfUnreadMessage == 0 ? FontWeight.w400 : FontWeight.w700,
                height: 20 / 18,
                color: context.theme.textColor,
                // chưa xử lý hết
                fontWeight: FontWeight.w600,
                fontSize: 15,
                // height: 20 / 18,
                // color: _theme.isDarkTheme ? AppColors.white : AppColors.black,
              ),
              maxLines: 1,
            ),
          ),
        );
      },
    );
    return ValueListenableBuilder(
      valueListenable: isRead,
      builder: (_, __, ___) => MultiBlocProvider(
        providers: [
          BlocProvider<UserInfoBloc>.value(
            value: _userInfoBloc,
          ),
          BlocProvider<TypingDetectorBloc>.value(
            value: _typingDetectorBloc,
          ),
        ],
        child: ValueListenableBuilder(
          valueListenable: widget.indexColor,
          builder: (_, __, ___) => ValueListenableBuilder(
            valueListenable: isHidden,
            builder: (context, value, child) => isHidden.value == 0
                ? const SizedBox()
                : InkWell(
                    onSecondaryTapUp: (TapUpDetails details) {
                      // Gọi hàm hiển thị menu tại vị trí được nhấn
                      _showPopupMenu(context, details.globalPosition);
                    },
                    onTap: () async {
                      ChatRepo().markReadMessage(conversationId: conversationId);
                      resetUnreadCount(conversationId);
                      isRead.value = true;
                      widget.indexColor.value =
                          widget.conversationBasicInfo.conversationId;
                      _chatDetailBloc = ChatDetailBloc(
                          conversationId:
                              widget.conversationBasicInfo.conversationId,
                          senderId: context.userInfo().id,
                          isGroup: widget.chatType == ChatType.GROUP,
                          initMemberHasNickname:
                              widget.chatType == ChatType.GROUP
                                  ? []
                                  : [_userInfoBloc.userInfo],
                          messageDisplay: widget.messageDisplay,
                          chatItemModel: widget.chatItemModel,
                          unreadMessageCounterCubit: UnreadMessageCounterCubit(
                            conversationId: conversationId,
                            countUnreadMessage: 0,
                          ),
                          deleteTime: widget.chatItemModel?.deleteTime ??
                              int.tryParse(deleteTime ?? '-1') ??
                              -1,
                          otherDeleteTime: widget.chatItemModel
                                  ?.firstOtherMember(context.userInfo().id)
                                  .deleteTime ??
                              -1,
                          // myDeleteTime: widget.chatItemModel?.memberList
                          //         .firstWhere((e) => e.id == _currentUserId)
                          //         .deleteTime ??
                          //     -1,
                          messageId: '',
                          typeGroup:
                              groupType ?? widget.chatItemModel.typeGroup)
                        ..add(const ChatDetailEventLoadConversationDetail())
                        // TL 2/1/2024: Bỏ thử đi xem có gì đặc sắc không
                        // Đây là lấy thông tin ứng viên các thứ mà
                        //..getDetailInfo(uInfo: _userInfoBloc.userInfo)
                        ..conversationName.value = conversationName;

                      ///
                      appLayoutCubit
                          .toMainLayout(AppMainPages.chatScreen, providers: [
                        BlocProvider<UserInfoBloc>.value(value: _userInfoBloc),
                        BlocProvider<ChatDetailBloc>.value(
                            value: _chatDetailBloc),

                        // TL Note 23/12/2023: Theo luồng tạo ConversationItem, cả hai
                        // bloc này đều được lấy từ ChatConversationBloc. Vì thế nên hãy để
                        // ChatScreen tự giác lấy từ ChatConversationBloc, đừng truyền cho
                        // nó ở đây. Luồng lòng vòng ra.
                        BlocProvider<TypingDetectorBloc>.value(
                            value: _typingDetectorBloc),
                        // BlocProvider(create: (context) => TransVoiceToTextCubit()),
                        // BlocProvider(create: (context) => PollCubit()),
                        BlocProvider(
                            create: (context) => ProfileCubit(
                                widget.conversationBasicInfo.conversationId,
                                isGroup: widget.chatType == ChatType.GROUP))
                      ], agruments: {
                        'chatType': widget.chatType,
                        'conversationId':
                            widget.conversationBasicInfo.conversationId,
                        'senderId': context.userInfo().id,
                        'chatItemModel': widget.chatItemModel,
                        'name': conversationName,
                        'chatDetailBloc': _chatDetailBloc,
                      });
                      chatConversationCubit
                          .markAsRead(widget.chatItemModel.conversationId);
                    },
                    child: BlocListener<ChatBloc, ChatState>(
                      listenWhen: (_, current) =>
                          (_lastMessageId != null &&
                              current is ChatMessageState &&
                              current.messageId == _lastMessageId) ||
                          current
                              is ChatStateNotificationConversationStatusChanged,
                      listener: (context, state) {
                        if (state is ChatStateEditMessageSuccess) {
                          displayMsg.value = state.newMessage;
                        } else if (state is ChatStateDeleteMessageSuccess) {
                          if (state.messageBelow != null) {
                            var newMessage = state.messageBelow;
                            displayMsg.value =
                                (newMessage!.type)?.displayMessageType(
                                      newMessage.message,
                                      isSentByCurrentUser:
                                          newMessage.senderId ==
                                              _currentUserId,
                                    ) ??
                                    StringConst.canNotDisplayMessage;
                            _lastMessageId = newMessage.messageId;
                            _lastSenderId.value = newMessage.senderId;
                          } else {
                            _lastSenderId.value = null;

                            displayMsg.value = StringConst.recallMessage;
                            _lastMessageId = null;
                            widget.chatItemModel.lastMessages?.removeWhere(
                                (e) => e.messageId == state.messageId);
                            _chatConversationBloc
                                .chatsMap[state.conversationId]?.lastMessages
                                ?.removeWhere(
                                    (e) => e.messageId == state.messageId);
                          }
                        } else if (state
                            is ChatStateNotificationConversationStatusChanged) {
                          if (state.conversationId == conversationId) {
                            _isOnNotifications.value = state.isOnNotification;
                          }
                        }
                        else if (state is ChatStateOnTapMemberInEmotionShowDialogLoaded) {
                          widget.indexColor.value = state.conversationId;
                        }
                      },
                      child: ValueListenableBuilder(
                        valueListenable: changeTheme,
                        builder: (context, value, child) {
                          return Container(
                            padding: const EdgeInsets.only(
                                top: 10, left: 0, bottom: 10, right: 10),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              color: widget.indexColor.value ==
                                      widget
                                          .conversationBasicInfo.conversationId
                                  ? context.theme.backgroundSelectChat
                                  : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBoxExt.w10,
                                displayImage,
                                SizedBoxExt.w5,
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        nameWidget,
                                        SizedBoxExt.h3,
                                        _msgWidget,
                                      ],
                                    ),
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: _isOnNotifications,
                                  builder: (BuildContext context, value,
                                      Widget? child) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        _isDraft ? draft : time,
                                        _isOnNotifications.value
                                            ? _unreadMessageIndicator
                                            : SvgPicture.asset(
                                                Images.ic_notifications_off,
                                                color: context.theme
                                                    .hitnTextColorInputBar,
                                              ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

Widget iconStatusGroup(
  String image,
) {
  return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage(image)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.white, width: 2)));
}

Widget buttonWhite(
    String text, double width, Function() onTap, BuildContext context) {
  return UnicornOutlineButton(
    onPressed: onTap,
    gradient: context.theme.gradient,
    strokeWidth: 2,
    radius: 30,
    child: Container(
      width: width,
      height: 20,
      alignment: Alignment.center,
      child: GradientText(
        text,
        gradient: context.theme.gradient,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
  );
}

Widget buttonBlue(
    String text, double width, Function() onTap, BuildContext context) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: width,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: context.theme.gradient),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.white, fontSize: 16),
      ),
    ),
  );
}

Widget rowItemChat(String text, BuildContext context) {
  return SizedBox(
    height: 20,
    // width: 150,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: context.theme.text2Color,
        ),
      ),
      const Spacer(),
      SvgPicture.asset(Images.ic_arrow_right),
    ]),
  );
}
