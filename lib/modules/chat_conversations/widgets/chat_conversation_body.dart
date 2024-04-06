import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/network_cubit/network_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/repos/chat_conversations_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/common/widgets/refresh_button.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/conversation_item.dart';
import 'package:app_chat365_pc/utils/data/clients/unified_realtime_data_source.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ChatConversationBody extends StatefulWidget {
  const ChatConversationBody(
      {super.key,
      required this.chatConversationBloc,
      required this.scrollLoading,
      required this.scrollController});

  final ScrollController scrollController;
  final Widget scrollLoading;
  final ChatConversationBloc chatConversationBloc;

  @override
  State<ChatConversationBody> createState() => ChatConversationBodyState();
}

class ChatConversationBodyState extends State<ChatConversationBody>
    with AutomaticKeepAliveClientMixin<ChatConversationBody> {
  List<ChatItemModel> conversations = [];
  late ChatConversationsRepo _chatConversationRepo;
  late final ChatConversationBloc _chatConversationBloc;

  late final UserInfoRepo userInfoRepo;
  late final NetworkCubit _networkCubit;
  ValueNotifier<int> indexColor = ValueNotifier(-1);
  bool _canStopFetchToFillViewPort = false;

  initData() {
    _chatConversationRepo = context.read<ChatConversationsRepo>();
    userInfoRepo = context.read<UserInfoRepo>();
    _networkCubit = context.read<NetworkCubit>();
  }

  //

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initData());
    _chatConversationBloc = widget.chatConversationBloc;
    _chatConversationRepo = context.read<ChatConversationsRepo>();

    // TL 17/2/2024: Lắng nghe ChatRepo thay vì trực tiếp nghe socket (ChatClient)
    // Load lại danh sách CTC khi có sự kiện ảnh hưởng tới thứ tự sắp xếp CTC
    ChatRepo().stream.listen((event) {
      if (event is ChatEventOnReceivedMessage ||
              event is ChatEventAddFriend ||
              event is ChatEventEmitNewConversationCreated ||
              event is ChatEventOnDeleteMessage ||
              event is ChatEventOnMessageEditted ||
              event is ChatEventOnUpdateStatusMessageSupport ||
              event is ChatEventOnDeleteConversation
          // TL 17/2/2024: Thiếu sự kiện nào thì cứ thêm vào đây
          ) {
        // logger.log("Load lai", name: "ChatConversationBody");
        // if (event is ChatEventOnUpdateStatusMessageSupport) {
        //   logger.log("Reload do livechat", name: "ChatConversationBody");
        // }
        _chatConversationBloc.loadData(countLoaded: 0, reset: true);
      }
    });
  }

  ScrollableState? get _scrollState => Scrollable.maybeOf(context);

  @override
  Widget build(BuildContext context) {
    // TL 17/2/2024: super.build của AutomaticKeepAliveClientMixin
    super.build(context);
    return BlocConsumer<ChatConversationBloc, ChatConversationState>(
      bloc: _chatConversationBloc,
      listener: (BuildContext context, ChatConversationState state) {
        if (!_chatConversationBloc.isShowOfflineData) BotToast.cleanAll();
    
        if (state is ChatConversationStateError) {
          if (!state.markNeedBuild) {
            if (_canStopFetchToFillViewPort &&
                state.error.toString() != 'User không có cuộc trò chuyện nào') {
              BotToast.showText(text: state.error.toString());
            } else if (state.error.toString() ==
                'User không có cuộc trò chuyện nào')
              _canStopFetchToFillViewPort = true;
          }
          if (state.error.isNetworkException) {
            try {
              AppDialogs.openWifiDialog(context);
            } catch (e, s) {
              logger.logError(e, s);
            }
          }
        } else if (state is ChatConversationStateLoadDone) {
          var length = _chatConversationBloc.chatsMap.length;
          if (length >= _chatConversationRepo.totalRecords) {
            _canStopFetchToFillViewPort = true;
            _chatConversationRepo.totalRecords = length;
          }
        }
      },
      buildWhen: (prev, current) =>
          current is ChatConversationStateLoadDone ||
          (current is ChatConversationStateLoading && current.markNeedBuild) ||
          (current is ChatConversationStateError && current.markNeedBuild) ||
          current is ChatConversationAddFavoriteSuccessState ||
          current is ChatConversationRemoveFavoriteSuccessState,
      builder: (context, state) {
        if (state is ChatConversationStateLoadDone) {
          // conversations = state.chatItems;
          conversations = List.from(
              state.chatItems.where((element) => element.isHidden == false));
          conversations.sort((a, b) => (b
                      .conversationBasicInfo.lastConversationMessageTime ??
                  DateTime(0))
              .compareTo(a.conversationBasicInfo.lastConversationMessageTime ??
                  DateTime(0)));
          // hiddenConversation = List.from(conversations.where((element) => element.is))
          var listFavourite = List<ChatItemModel>.from(
              conversations.where((element) => element.isFavorite));
          var listNonFavourite =
              List.from(conversations.where((element) => !element.isFavorite));
          int listViewLength =
              listNonFavourite.length + listFavourite.length + 2;
          // +2 là bao gồm 2 text yêu thích và cuộc trò chuyện gần đây
          return LayoutBuilder(
            builder: (context, c) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                _loadDataWhenScrolledToBottom();
              });
              return BlocBuilder<ChatConversationBloc, ChatConversationState>(
                  bloc: _chatConversationBloc,
                  buildWhen: (_, current) =>
                      current is ChatConversationStateLoadDone,
                  builder: (BuildContext context, state) {
                    return ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: ListView.builder(
                          itemCount: listViewLength,
                          controller: widget.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          addRepaintBoundaries: true,
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          addAutomaticKeepAlives: true,
                          cacheExtent: 700,
                          itemBuilder: (context, index) {
                            // load lại cuộc trò chuyện
                            if (index == listViewLength - 1) {
                              return widget.scrollLoading;
                            }
                            if (index == 0) {
                              return listFavourite.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Text(
                                        AppLocalizations.of(context)!.favourite,
                                        style: AppTextStyles.text(context)
                                            .copyWith(
                                                fontWeight: FontWeight.w500),
                                      ),
                                    )
                                  : const SizedBox();
                            }
                            if (index <= listFavourite.length) {
                              var conversationItem = listFavourite[index - 1];
                              var userInfoBloc = UserInfoBloc.fromConversation(
                                conversationItem.conversationBasicInfo,
                                status: conversationItem.status,
                              );
                              var totalMessageListenable = ValueNotifier(
                                  conversationItem.totalNumberOfMessages);
                              totalMessageListenable.addListener(
                                () => conversationItem.totalNumberOfMessages =
                                    totalMessageListenable.value,
                              );
                              return ConversationItem(
                                index: index,
                                indexColor: indexColor,
                                key: Key(
                                  conversationItem.conversationId.toString(),
                                ),
                                messageType: conversationItem.messageType,
                                message: conversationItem.message,
                                conversationBasicInfo:
                                    conversationItem.conversationBasicInfo,
                                chatItemModel: conversationItem,
                                chatType: conversationItem.isGroup
                                    ? ChatType.GROUP
                                    : ChatType.SOLO,
                                userInfoBloc: userInfoBloc,
                                createdAt: conversationItem.createAt,
                                users: conversationItem.memberList,
                                lastMessageId: conversationItem
                                    .conversationBasicInfo.lastMessasgeId,
                                messageDisplay: conversationItem.messageDisplay,
                                unreadMessageCubit: _chatConversationBloc
                                        .unreadMessageCounterCubits[
                                    conversationItem.conversationId]!,
                              );
                            }
                            if (index == listFavourite.length + 1) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  AppLocalizations.of(context)!.recentConversation,
                                  style: AppTextStyles.text(context).copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: context.theme.textColor),
                                ),
                              );
                            }
                            if (index > listFavourite.length + 1) {
                              var conversationItem = listNonFavourite[
                                  index - 2 - listFavourite.length];
                              var userInfoBloc = UserInfoBloc.fromConversation(
                                conversationItem.conversationBasicInfo,
                                status: conversationItem.status,
                              );
                              var totalMessageListenable = ValueNotifier(
                                  conversationItem.totalNumberOfMessages);
                              totalMessageListenable.addListener(
                                () => conversationItem.totalNumberOfMessages =
                                    totalMessageListenable.value,
                              );
                              return ConversationItem(
                                index: index,
                                indexColor: indexColor,
                                key: Key(
                                  conversationItem.conversationId.toString(),
                                ),
                                messageType: conversationItem.messageType,
                                message: conversationItem.message,
                                conversationBasicInfo:
                                    conversationItem.conversationBasicInfo,
                                chatItemModel: conversationItem,
                                chatType: conversationItem.isGroup
                                    ? ChatType.GROUP
                                    : ChatType.SOLO,
                                userInfoBloc: userInfoBloc,
                                createdAt: conversationItem.createAt,
                                users: conversationItem.memberList,
                                lastMessageId: conversationItem
                                    .conversationBasicInfo.lastMessasgeId,
                                messageDisplay: conversationItem.messageDisplay,
                                unreadMessageCubit: _chatConversationBloc
                                        .unreadMessageCounterCubits[
                                    conversationItem.conversationId]!,
                              );
                            }
                          }),
                    );
                  });
            },
          );
        }
        return WidgetUtils.centerLoadingCircle(context);
      },
    );
  }

  // NOTE: I refactored this method, with its meaning guessed in my mind
  // The name might not match its purpose
  void _loadDataWhenScrolledToBottom() async {
    await Future.delayed(const Duration(milliseconds: 300));
    var isScrollable = _scrollState != null
        ? _scrollState!.position.maxScrollExtent > 0
        : true;
    if (!isScrollable &&
        !_canStopFetchToFillViewPort &&
        _networkCubit.state.hasInternet &&
        _chatConversationBloc.state is ChatConversationStateLoadDone &&
        _chatConversationBloc.canLoadMore) {
      _chatConversationBloc.loadData();
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
