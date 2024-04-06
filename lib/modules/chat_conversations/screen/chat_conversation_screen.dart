import 'dart:async';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/network_cubit/network_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_event.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_cubit.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/chat_conversation_body.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/hidden_conversation_body.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/unread_conversation_body.dart';
import 'package:app_chat365_pc/service/app_service.dart';
import 'package:app_chat365_pc/service/injection.dart';
import 'package:app_chat365_pc/utils/data/clients/mqtt_client.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_status.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/date_time_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({super.key});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen>
    with WidgetsBindingObserver {
  late final ChatConversationBloc _chatConversationBloc;
  late final NetworkCubit _networkCubit;
  final ScrollController _scrollController = ScrollController();
  ValueNotifier<String> get typeOfConversation =>
      ValueNotifier(AppLocalizations.of(context)?.recentConversation??'');
  ValueNotifier<int> isUnRead = ValueNotifier(0);
  late ChatConversationCubit chatConversationCubit;
  DateTime _lastTimeFetchSuccess = AppConst.defaultFirstTimeFetchSuccess;
  late final UserInfoBloc _userInfoBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatConversationBloc = context.read<ChatConversationBloc>();
    _networkCubit = context.read<NetworkCubit>();
    _scrollController.addListener(_scrollListener);
    _userInfoBloc = context.read<UserInfoBloc>()
      ..add(UserInfoEventActiveTimeChanged(
        context.userInfo().id,
        AuthStatus.authenticated,
        lastActive: null,
      ));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // didNavigateToAppSettings = false;
      _chatConversationBloc.refresh();
    }
    super.didChangeAppLifecycleState(state);
  }

  _onInsertNewConversation(ChatItemModel? newChatItem) {
    if (newChatItem != null) {
      var conversationId = newChatItem.conversationId;
      if (newChatItem.isFavorite) {
        // ignore: avoid_single_cascade_in_expression_statements
        _chatConversationBloc
          ..favoriteConversations.update(
            conversationId,
            (_) => newChatItem,
            ifAbsent: () => newChatItem,
          );
      }
      _chatConversationBloc.add(ChatConversationEventAddData(
        [newChatItem],
        insertAtTop: true,
      ));
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  _scrollListener() {
    if (_scrollController.hasClients) {
      var maxScrollExtent = _scrollController.position.maxScrollExtent;
      var axisDirection = _scrollController.position.userScrollDirection;
      if (maxScrollExtent > 0 &&
          axisDirection == ScrollDirection.reverse &&
          _chatConversationBloc.state is! ChatConversationStateLoading &&
          !_chatConversationBloc.didExceedList &&
          _networkCubit.state.hasInternet &&
          _scrollController.offset + 500 >= maxScrollExtent &&
          _chatConversationBloc.canLoadMore &&
          _chatConversationBloc.state is! ShowUnreadMessageState) {
        _chatConversationBloc.state == _chatConversationBloc.loadData();
      }
    }
  }

  FutureOr<ChatItemModel?> _newChatItem(SocketSentMessageModel msg) async {
    var conversationId = msg.conversationId;
    var newConversation = _chatConversationBloc.chatsMap[conversationId];
    ChatItemModel? newItem;
    if (newConversation != null) {
      newItem = ChatItemModel(
        conversationId: newConversation.conversationId,
        numberOfUnreadMessage: _chatConversationBloc
            .unreadMessageCounterCubits[newConversation.conversationId]!
            .countUnreadMessage,
        isGroup: newConversation.isGroup,
        senderId: msg.senderId,
        message: msg.message,
        messageType: msg.type!,
        totalNumberOfMessages: ++newConversation.totalNumberOfMessages,
        messageDisplay: newConversation.messageDisplay,
        typeGroup: newConversation.typeGroup,
        adminId: newConversation.adminId,
        deputyAdminId: [],
        memberList: newConversation.memberList,
        isFavorite: newConversation.isFavorite,
        isNotification: newConversation.isNotification,
        isHidden: newConversation.isHidden,
        createAt: DateTimeExt.timeZoneParse(
          msg.createAt.toTimezoneFormatString(),
        ),
        conversationBasicInfo: newConversation.conversationBasicInfo,
        lastMessages: newConversation.lastMessages,
      );
      _chatConversationBloc.addConversationToChatsMap(newItem);
    } else
      newItem = await _chatConversationBloc
          .fetchSingleChatConversation(conversationId);

    return newItem
      ?..conversationBasicInfo.groupLastSenderId = msg.senderId
      ..conversationBasicInfo.lastMessasgeId = msg.messageId;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: typeOfConversation,
      builder: (context, value, child) => ValueListenableBuilder(
        valueListenable: isUnRead,
        builder: (_, __, ___) => BlocListener<NetworkCubit, NetworkState>(
          listener: (context, networkState) {
            if (networkState.hasInternet &&
                DateTime.now().difference(_lastTimeFetchSuccess).inSeconds >=
                    45) {
              _chatConversationBloc.loadData(countLoaded: 0, reset: false);
              getIt.get<AppService>().setupUnreadConversationId();
              _lastTimeFetchSuccess = DateTime.now();
            }
          },
          child: BlocListener<ChatBloc, ChatState>(
              listener: (context, chatState) async {
                if (chatState is ChatStateReceiveMessage &&
                    _chatConversationBloc.state is! ChatDetailStateLoading) {
                  var msg = chatState.msg;
                  //không so sánh với danh sách người quen nữa thay vào đó sẽ dùng trường strange socket trả về
                  // Người gửi là người quen hoặc danh sách người quen không có ai hoặc người gửi là chính mình
                  // if (listIdFamiliar.isEmpty ||
                  //     msg.senderId == widget.userInfo.id)
                  // gửi tin nhắn bằng cổng 9000 thì mới có thể nhận được strange - web và winform gửi sẽ k nhận được
                  bool isStranger = false;
                  if (msg.strange?.isNotEmpty ?? false) {
                    if (msg.strange?[0]["userId"] == AuthRepo().userId) {
                      isStranger = ((msg.strange?[1]["status"]) == 0);
                    } else {
                      isStranger = ((msg.strange?[0]["status"]) == 0);
                    }
                  }

                  if (isStranger == false)
                    _onInsertNewConversation(await _newChatItem(msg));
                } else if (chatState
                    is ChatStateFavoriteConversationStatusChanged) {
                  try {
                    // TL 18/1/2024: Chuyển dịch đổi yêu thích về ChatRepo()
                    // _chatConversationBloc.onChangeFavorite(
                    //   chatState.conversationId,
                    //   chatState.isChangeToFavorite ? 1 : 0,
                    // );
                  } catch (e, s) {
                    logger.logError(e, s);
                  }
                }
              },
              child: ValueListenableBuilder(
                valueListenable: changeTheme,
                builder: (context, value, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                        left: 10,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              PopupMenuButton(
                                  tooltip: '',
                                  color: context.theme.backgroundColor,
                                  itemBuilder: (context) => [
                                        PopupMenuItem(
                                          height: 30,
                                          onTap: () async {
                                            typeOfConversation.value =
                                                AppLocalizations.of(context)!.recentConversation ;
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)?.recentConversation ??'',
                                            style: TextStyle(
                                                color:
                                                    context.theme.text2Color),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          height: 30,
                                          onTap: () async {
                                            typeOfConversation.value =
                                              AppLocalizations.of(context)?.hiddenConversation ??'';
                                          },
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              decoration: const BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color: AppColors
                                                              .greyCACA))),
                                              child: Text(
                                                  AppLocalizations.of(context)?.hiddenConversation ??'',
                                                  style: TextStyle(
                                                      color: context
                                                          .theme.text2Color))),
                                        ),
                                        PopupMenuItem(
                                          height: 30,
                                          onTap: () {},
                                          child: Text( AppLocalizations.of(context)?.seenAll ??'',
                                              style: TextStyle(
                                                  color: context
                                                      .theme.text2Color)),
                                        ),
                                      ],
                                  child: Row(
                                    children: [
                                      Text(
                                        typeOfConversation.value,
                                        style: AppTextStyles
                                            .chosenConversationList(context),
                                      ),
                                      SvgPicture.asset(
                                          AssetPath.drop_button_down,
                                          color: context.theme.text2Color,
                                          height: 14,
                                          width: 14),
                                    ],
                                  )),
                              const Spacer(),
                              Text(
                                AppLocalizations.of(context)?.classify ??'',
                                style: AppTextStyles.chosenConversationList(
                                    context),
                              ),
                              SvgPicture.asset(
                                AssetPath.drop_button_down,
                                height: 14,
                                width: 14,
                                color: context.theme.text2Color,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          typeOfConversation.value ==
                                  AppLocalizations.of(context)?.recentConversation
                              ? ValueListenableBuilder(
                                  valueListenable: changeTheme,
                                  builder: ((context, value, child) {
                                    return Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            isUnRead.value = 0;
                                          },
                                          child: isUnRead.value == 0
                                              ? Container(
                                                  height: 30 + 1,
                                                  width: 90,
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 7),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      GradientText(AppLocalizations.of(context)!.all,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 13,
                                                          ),
                                                          gradient: context
                                                              .theme.gradient),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Container(
                                                        height: 2,
                                                        decoration:
                                                            BoxDecoration(
                                                                gradient: context
                                                                    .theme
                                                                    .gradient),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  height: 30 + 1,
                                                  width: 90,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    AppLocalizations.of(context)?.all ??'',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 13,
                                                        color: context
                                                            .theme.textColor),
                                                  ),
                                                ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            isUnRead.value = 1;
                                          },
                                          child: isUnRead.value == 1
                                              ? Container(
                                                  height: 30 + 1,
                                                  width: 90,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 7),
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      GradientText(AppLocalizations.of(context)?.unread ??'',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 13,
                                                          ),
                                                          gradient: context
                                                              .theme.gradient),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Container(
                                                        height: 2,
                                                        decoration:
                                                            BoxDecoration(
                                                                gradient: context
                                                                    .theme
                                                                    .gradient),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : Container(
                                                  height: 30 + 1,
                                                  width: 90,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    AppLocalizations.of(context)?.unread ??'',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 13,
                                                        color: context
                                                            .theme.textColor),
                                                  ),
                                                ),
                                        ),
                                      ],
                                    );
                                  }))
                              : const SizedBox()
                        ],
                      ),
                    ),
                    Container(
                      color: context.theme.colorLine,
                      height: 1,
                    ),
                    Expanded(
                        child: typeOfConversation.value ==
                                AppLocalizations.of(context)?.recentConversation
                            ? isUnRead.value == 0
                                ? ChatConversationBody(
                                    chatConversationBloc: _chatConversationBloc,
                                    scrollController: _scrollController,
                                    scrollLoading: const _LoadBuilder(),
                                  )
                                : const UnReadConversationBody()
                            : typeOfConversation.value ==
                                    AppLocalizations.of(context)?.hiddenConversation
                                ? HiddenConversationBody()
                                : const SizedBox()),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

class _LoadBuilder extends StatefulWidget {
  const _LoadBuilder({
    Key? key,
  }) : super(key: key);

  @override
  State<_LoadBuilder> createState() => _LoadBuilderState();
}

class _LoadBuilderState extends State<_LoadBuilder> {
  bool _didLoadingVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatConversationBloc, ChatConversationState>(
      listener: (context, state) {
        if (state is ChatConversationStateError && _didLoadingVisible) {
          BotToast.showText(text: state.error.error);
          _didLoadingVisible = false;
        }
      },
      buildWhen: (previous, current) {
        return current is ChatConversationStateLoading ||
            current is ChatConversationStateLoadDone ||
            current is ChatConversationStateError;
      },
      builder: (context, state) {
        if (state is ChatConversationStateLoading) {
          return VisibilityDetector(
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0.5) _didLoadingVisible = true;
            },
            key: const ValueKey('Loading'),
            child: Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.center,
              //hide the loading circle
              // child: const SizedBox.shrink(),
              child: context.read<ChatConversationBloc>().chatsMap.length < 10
                  ? const SizedBox.shrink()
                  : WidgetUtils.loadingCircle(context),
            ),
          );
        }

        return const SizedBox(
          height: 70,
          key: ValueKey('Non_loading'),
        );
      },
    );
  }
}
