// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/models/draft_model.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_conversations_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_detail_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_box_names.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_service.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_cubit.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_hidden.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_model.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_unread.dart';
import 'package:app_chat365_pc/service/app_service.dart';
import 'package:app_chat365_pc/service/injection.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/bool_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/map_extension.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sp_util/sp_util.dart';
part 'chat_conversation_event.dart';
part 'chat_conversation_state.dart';

typedef void LoadOfflineDataDoneCallback();

class ChatConversationBloc
    extends Bloc<ChatConversationEvent, ChatConversationState> {
  ChatConversationBloc(
    this._chatConversationsRepo,
  ) : super(ChatConversationInitial()) {
    on<ChatConversationEventAddData>(
      (event, emit) async {
        if (event.reset) {
          favoriteConversations.clear();
        }
        for (var item in event.list) {
          addConversationToChatsMap(item);
          typingBlocs.putIfAbsent(
            item.conversationId,
            () => TypingDetectorBloc(item.conversationId),
          );
          unreadMessageCounterCubits.update(
            item.conversationId,
            (cubit) => cubit
              ..emit(
                UnreadMessageCounterState(
                  item.numberOfUnreadMessage,
                ),
              ),
            ifAbsent: () => UnreadMessageCounterCubit(
              conversationId: item.conversationId,
              countUnreadMessage: item.numberOfUnreadMessage,
            ),
          );

          if (item.isFavorite) {
            favoriteConversations[item.conversationId] = item;
          } else {
            favoriteConversations.remove(item.conversationId);
          }
        }
        // if (event.saveToLocal) _getListLastMessages([...event.list]);
        if (event.reset) {
          if (event.list.isNotEmpty) chatsMap.clear();
        }
        chatsMap
            .addAll(Map.fromIterable(event.list, key: (e) => e.conversationId));
        SpUtil.putInt(LocalStorageKey.totalConversation, chatsMap.length);
        // tạm thời comment lại phần lưu local
        // if (event.saveToLocal) {
        //   _saveChatItemModelToLocal(chatsMap.values, reset: event.reset);
        // }

        try {
          var appService = getIt.get<AppService>();
          if (appService.countUnreadConversation == 0) {
            appService.updateUnreadConversation(
              unreadMessageCounterCubits.values
                  .where((e) =>
                      e.hasUnreadMessage &&
                      chatsMap[e.conversationId]?.isHidden != true)
                  .map((e) => e.conversationId),
            );
          }
        } catch (e) {}
        var strangers = event.listStrange;
        strangeConversations = strangers ?? [];
        var conversations = [...chats];
        if (event.insertAtTop && event.list.length == 1) {
          var topElement = event.list.single;
          conversations
            ..removeWhere(
                (dynamic e) => e.conversationId == topElement.conversationId)
            ..insert(0, event.list.single);
        }

        // var _maps = SplayTreeMap<int,ChatItemModel>.from(chatsMap,(k1, k2)=>chatsMap[k2]!.createAt.compareTo(chatsMap[k1]!.createAt));
        // chatsMap = _maps;
        emit(
            ChatConversationStateLoadDone(conversations, strangers: strangers));
      },
    );

    on<ChatConversationEventRaiseError>(
      (event, emit) {
        emit(
          ChatConversationStateError(
            event.error,
            markNeedBuild: chatsMap.isNotEmpty &&
                (event.error.isServerError ||
                    event.error.isUnknowError ||
                    !_didFetchListMessageFirstTime),
          ),
        );
      },
    );

    on<ChatConversationEventAddLoadingState>((event, emit) {
      emit(ChatConversationStateLoading(
        markNeedBuild: event.markNeedBuild ?? !_didFetchListMessageFirstTime,
      ));
    });

    on<ChatConversationEventAddFavoriteConversation>((event, emit) {
      // chatsMap[event.item.conversationId]?.isFavorite = true;
      favoriteConversations = favoriteConversations.insertAtTop(
        event.item.conversationId,
        event.item,
      );
      emit(ChatConversationAddFavoriteSuccessState(chats, event.item));
    });

    on<ChatConversationEventRemoveFavoriteConversation>((event, emit) {
      // chatsMap[event.item.conversationId]?.isFavorite = false;
      favoriteConversations.remove(event.item.conversationId);
      // emit(ChatConversationStateLoadDone(chats));
      emit(ChatConversationRemoveFavoriteSuccessState(chats, event.item));
    });

    on<ChatConversationEmitEvent>(
      (event, emit) async {
        emit(ChatConversationStateLoadDone(event.list));
      },
    );
    on<ChangeHiddenStatusEvent>(
      (event, emit) {
        print('----------$event');
        emit(ChatConversationInitial());
        emit(ChatConversationStateLoadDone(event.chatItemModel));
      },
    );

    on<ChatConversationEventChangeNotificationStatus>(
        _changeNotificationStatus);

    ChatRepo().stream.listen((event) async {
      if (event is ChatEventOnChangeFavoriteStatus) {
        final ChatItemModel detail =
            (await ChatRepo().getChatItemModel(event.conversationId))!;
        if (event.isChangeToFavorite) {
          add((ChatConversationEventAddFavoriteConversation(detail)));
        } else {
          add(ChatConversationEventRemoveFavoriteConversation(detail));
        }
      }
    });

    // on<ChatConversationEventAddHiddenConversation>(((event, emit) {
    //   if (event.item.isHidden)
    // }));
  }

  /// Check đã có dữ liệu để hiển thị trên UI
  ///
  /// Nếu true, các lần sau fetch ds conversation không cần hiển thị loading nữa
  bool _didFetchListMessageFirstTime = false;

  bool canLoadMore = true;

  /// Check đã fetch hết ds cuộc trò chuyện
  bool didExceedList = false;

  /// Check ds cuộc trò chuyện hiện tại đang show là từ Hive
  bool _isShowOfflineData = false;

  final ChatConversationsRepo _chatConversationsRepo;

  /// Check sử dụng api GetConversationList
  bool useFastApi = true;
  late bool textCheck = false;

  int page = 0;

  //danh sách cuộc trò chuyện
  @Deprecated("Dùng ChatRepo().getChatItemModel() nhé")
  Map<int, ChatItemModel> chatsMap = HashMap();

  bool _sortWithUnreadMessageCompare = false;

  /// [chatId] và [ChatItemModel] tương ứng của ds yêu thích
  Map<int, ChatItemModel> favoriteConversations = {};
  Map<int, ChatItemModel> hiddenConversations = {};
  List<ChatItemModel> strangeConversations = [];

  int get currentUserId => _chatConversationsRepo.userId;

  int get _countLoaded => chatsMap.length;

  bool get isShowOfflineData => _isShowOfflineData;

  Map<int, DraftModel> drafts = {};
  List<ChatItemModel> sameGroup = [];
  bool loadingLocalMessages = false;

  // bật tắt thông báo cuộc trò chuyện
  // Trần Lâm note 18/12/2023:
  // Sửa hàm để thay vì trả Future<RequestResponse>, nó sẽ bắn state
  void changeNotificationStatus({
    required int conversationId,
  }) {
    add(ChatConversationEventChangeNotificationStatus(conversationId));
  }

  @Deprecated("Dùng ChatRepo().changeNotificationStatus() nhé")
  void _changeNotificationStatus(
      ChatConversationEventChangeNotificationStatus event,
      Emitter<ChatConversationState> emit) async {
    emit(ChatConversationStateNotificationStatusChanging());
    chatConversationsRepo
        .changeNotificationStatus(
      conversationId: event.conversationId,
      userId: AuthRepo().userInfo!.id,
      membersIds: (await ChatRepo().getChatItemModel(event.conversationId))
              ?.memberList
              .map((e) => e.id)
              .toList() ??
          [],
    )
        .then((res) {
      if (res.hasError) {
        emit(ChatConversationStateNotificationStatusChangeError(
            errMsg: res.error!.error));
        return;
      }
      // Note:
      // Bật thành công thì message trả "Bật thông báo cuộc trò chuyện thành công"
      // Tắt thành công thì "Tắt thông báo cuộc trò chuyện thành công"
      var newNotificationStatus =
          res.data.contains("Bật"); //jsonDecode(res.data)["data"];
      emit(ChatConversationStateNotificationStatusChanged(
          conversationId: event.conversationId,
          newNotificationStatus: newNotificationStatus));
    });
  }

  addConversationToChatsMap(ChatItemModel item) => chatsMap.update(
        item.conversationId,
        (value) {
          // Nếu số lượng tin nhắn của item mới > số lượng tin nhắn của item cũ
          // thì gán tin nhắn cũ vào item mới
          if (!value.lastMessages.isBlank &&
              item.totalNumberOfMessages > value.lastMessages!.length) {
            item.lastMessages = value.lastMessages;
          }
          return item;
        },
        ifAbsent: () => item,
      );

  List<ChatItemModel> get chats =>
      !_sortWithUnreadMessageCompare ? sort() : sortWithUnreadMessageCompare();

  // ..sort(
  //   (a, b) {
  //     if (page != 0) return b.createAt.compareTo(a.createAt);
  //     final bool aCheck =
  //         unreadMessageCounterCubits[a.conversationId]!.hasUnreadMessage;
  //     final bool bCheck =
  //         unreadMessageCounterCubits[b.conversationId]!.hasUnreadMessage;
  //     return (b.createAt.compareTo(a.createAt) + bCheck.compareTo(aCheck))
  //         .clamp(-1, 1);
  //   },
  // );

  List<ChatItemModel> sortWithUnreadMessageCompare() {
    _sortWithUnreadMessageCompare = false;
    return chatsMap.values.toList()
      ..sort(
        (a, b) {
          final bool aCheck =
              unreadMessageCounterCubits[a.conversationId]!.hasUnreadMessage;
          final bool bCheck =
              unreadMessageCounterCubits[b.conversationId]!.hasUnreadMessage;
          return (b.createAt.compareTo(a.createAt) + bCheck.compareTo(aCheck))
              .clamp(-1, 1);
        },
      );
  }

  List<ChatItemModel> sort() => chatsMap.values.toList()
    ..sort(
      (a, b) => b.createAt.compareTo(a.createAt),
    );

  Future refresh({bool buildOnLoad = false}) async {
    print('reload nay');
    // chats.clear();
    _sortWithUnreadMessageCompare = false;
    page = 0;
    didExceedList = false;
    useFastApi = true;
    canLoadMore = true;
    return await loadData(countLoaded: 0, reset: true);
  }

  List<ChatItemModel> unreaderConversation = [];

  Future getUnreadConversation() async {
    emit(ShowUnreadMessageLoadingState());
    var data = await getListChatConversationUnread();
    if (!data.isBlank) {
      unreaderConversation = data;
      for (var item in unreaderConversation) {
        addConversationToChatsMap(item);
        typingBlocs.putIfAbsent(
          item.conversationId,
          () => TypingDetectorBloc(item.conversationId),
        );
        unreadMessageCounterCubits.update(
          item.conversationId,
          (cubit) => cubit
            ..emit(
              UnreadMessageCounterState(
                item.numberOfUnreadMessage,
              ),
            ),
          ifAbsent: () => UnreadMessageCounterCubit(
            conversationId: item.conversationId,
            countUnreadMessage: item.numberOfUnreadMessage,
          ),
        );
      }
      emit(ShowUnreadMessageState());
      logger.log('da lay dc');
    } else {
      if (data.isEmpty) {
        unreaderConversation = [];
        emit(ShowUnreadMessageState());
      } else {
        emit(ShowUnreaderFailState());
      }
    }
  }

  clear() {
    // chatsMap.forEach((_, v) => v.numberOfUnreadMessage.close());
    chatsMap.clear();
    page = 0;
    favoriteConversations.clear();
  }

  resetToLogout() {
    clear();
    typingBlocs
      ..values.forEach((e) => e.close())
      ..clear();
    unreadMessageCounterCubits
      ..values.forEach((e) => e.close())
      ..clear();
    drafts.clear();
    didExceedList = false;
  }

  // Map<int, List<SocketSentMessageModel>>? _localMessages;

  // 18/1/2024: DEPRECATED: Chuyển dịch qua ChatRepo
  // // lưu tin nhắn ở local
  // FutureOr<Map<int, List<SocketSentMessageModel>>?> get localMessages async {
  //   loadingLocalMessages = true;
  //   final stopwatch = Stopwatch()..start();
  //   _localMessages ??= await HiveService().messages;
  //   loadingLocalMessages = false;
  //   final elapsed = stopwatch.elapsed;
  //   // if (kDebugMode) {
  //   //   logger.log(
  //   //     'Get ${_localMessages?.values.map((e) => e.length).reduce((a, b) => a + b)} messages in $elapsed',
  //   //     name: 'Elap FetchAllLocalMessagesTime',
  //   //   );
  //   // }
  //   return _localMessages;
  // }

  // TL 28/12/2023:
  // Chuyển dịch caching qua ChatRepo
  // Future<List<ChatItemModel>> get offlineData async {
  //   Iterable<ChatItemModel> chatItemModels =
  //       await ChatRepo().getConversationList();

  //   for (var item in chatItemModels) {
  //     if (item.lastMessages.isBlank) {
  //       var localMessages =
  //           await ChatRepo().loadMessages(conversationId: item.conversationId);

  //       item.lastMessages = localMessages.toList();
  //     }
  //   }
  //   // if (chatItemModelBox == null) {
  //   //   logger.log('vao ofline 1');
  //   //   chatItemModelBox ??= HiveService().chatItemModelBox;
  //   //   chatItemModels = (chatItemModelBox?.values ?? []).toList();
  //   //   if (chatItemModels.isNotEmpty) {
  //   //     try {
  //   //       logger.log('vao 1 lan tu sap xep offline', name: 'vao day ne');
  //   //       final localMsgs = await localMessages;
  //   //       for (var item in chatItemModels) {
  //   //         if (item.lastMessages.isBlank) {
  //   //           item.lastMessages = localMsgs?[item.conversationId];
  //   //         }
  //   //         // item.lastMessages = await HiveService()
  //   //         //     .getConversationOfflineMessages(item.conversationId);
  //   //       }
  //   //     } catch (e) {
  //   //       print(e);
  //   //     }
  //   //   }
  //   // } else {
  //   //   logger.log(chatItemModelBox?.values.length);
  //   //   chatItemModels = (chatItemModelBox?.values ?? []).toList();
  //   // }

  //   return dataOff.value = [...chatItemModels];
  // }

  // TL 28/12/2023:
  // Chuyển dịch caching qua ChatRepo
  // Future<List<ChatItemModel>> get offlineDataSort async {
  //   List<ChatItemModel> chatItemModels = [];
  //   if (chatItemModelBox == null) {
  //     chatItemModelBox ??= HiveService().chatItemModelBox;
  //     chatItemModels = (chatItemModelBox?.values ?? []).toList();
  //     if (chatItemModels.isNotEmpty) {
  //       try {
  //         logger.log('vao 1 lan tu sap xep offline', name: 'vao day ne');
  //         final localMsgs = await localMessages;
  //         for (var item in chatItemModels) {
  //           if (item.lastMessages.isBlank) {
  //             item.lastMessages = localMsgs?[item.conversationId];
  //           }
  //           // item.lastMessages = await HiveService()
  //           //     .getConversationOfflineMessages(item.conversationId);
  //         }
  //       } catch (e) {
  //         print(e);
  //       }
  //     }
  //   } else {
  //     chatItemModels = (chatItemModelBox?.values ?? []).toList();
  //   }

  //   return chatItemModels
  //     ..sort(
  //       (a, b) => b.createAt.compareTo(a.createAt),
  //     );
  // }

  /// [ConversationId] và [TypingDetectorBloc] tương ứng
  Map<int, TypingDetectorBloc> typingBlocs = {};
  Map<int, UnreadMessageCounterCubit> unreadMessageCounterCubits = {};

  /// lấy danh sách cuộc trò chuyện
  @Deprecated("Dùng ChatRepo().getConversationList() nhé")
  Future<List<ConversationModel>> getListChatConversation(
      int countLoaded) async {
    return (await ChatRepo().getConversationList(count: countLoaded + 20))
        .toList();
    // var res = await _chatConversationsRepo.loadListConversation(
    //   countConversationLoad: countLoaded,
    // );

    // IUserInfo? currentUserInfo;
    // UserType? currentUserType;

    // try {
    //   final BuildContext context = navigatorKey.currentContext!;
    //   currentUserInfo = context.userInfo();
    //   currentUserType = context.userType();
    // } catch (e) {
    //   currentUserInfo = userInfo;
    //   currentUserType = userType;
    // }

    // return await res.onCallBack(
    //   (response) => compute(_computeGetListChatConversation, [
    //     response,
    //     currentUserId,
    //     currentUserInfo,
    //     currentUserType,
    //   ]),
    // );
  }

  Future<List<ChatItemModel>> getListConversationStrange() async {
    IUserInfo? currentUserInfo;
    UserType? currentUserType;

    try {
      final BuildContext context = navigatorKey.currentContext!;
      currentUserInfo = context.userInfo();
      currentUserType = context.userType();
    } catch (e) {
      currentUserInfo = userInfo;
      currentUserType = userType;
    }
    var res = await _chatConversationsRepo.getListConversationStrange(
        companyId: currentUserInfo?.companyId ?? 0);
    return await res.onCallBack(
      (response) => compute(_computeGetListChatConversation, [
        response,
        currentUserId,
        currentUserInfo,
        currentUserType,
      ]),
    );
    // return
  }

  fetchListConversationStrange() async {
    strangeConversations = await getListConversationStrange();
  }

  Future<List<ChatItemModel>> getListSameGroups({
    required int userId,
    required int contactId,
  }) async {
    IUserInfo? currentUserInfo;
    UserType? currentUserType;

    try {
      final BuildContext context = navigatorKey.currentContext!;
      currentUserInfo = context.userInfo();
      currentUserType = context.userType();
    } catch (e) {
      currentUserInfo = userInfo;
      currentUserType = userType;
    }
    var res = await _chatConversationsRepo.getCommonConversation(
        userId: userId, contactId: contactId);
    return sameGroup = await res.onCallBack(
      (response) => compute(_computeGetListChatConversation, [
        response,
        currentUserId,
        currentUserInfo,
        currentUserType,
      ]),
    );
  }

  static List<ChatItemModel> _computeGetListChatConversation(List params) {
    final RequestResponse res = params[0];
    final int currentUserId = params[1];
    var _result = List<ChatItemModel>.from(
      (json.decode(res.data)['data']['listCoversation'] as List).map(
        (e) => ChatItemModel.fromConversationInfoJsonOfUser(
          currentUserId,
          conversationInfoJson: e,
          currentUserInfo: params[2],
          currentUserType: params[3],
        ),
      ),
    )..removeWhere(
        (element) => element.isHidden || element.memberList.length < 2);
    return _result;
  }

  /////////////////////////////////

  Future<List<ChatItemModel>> getListChatConversationUnread() async {
    var res = await _chatConversationsRepo.getUnreadConversation(
        // useFastApi: countLoaded == 0 ? true : false,
        );
    logger.log(res.toString());

    IUserInfo? currentUserInfo;
    UserType? currentUserType;

    try {
      final BuildContext context = navigatorKey.currentContext!;
      currentUserInfo = context.userInfo();
      currentUserType = context.userType();
    } catch (e) {
      currentUserInfo = userInfo;
      currentUserType = userType;
    }

    return await res.onCallBack(
      (response) => compute(
        _computeGetListChatConversationUnread,
        [
          response,
          currentUserId,
          currentUserInfo,
          currentUserType,
        ],
      ),
    );

    // return
  }

  // unreadconverastion
  static List<ChatItemModel> _computeGetListChatConversationUnread(
      List params) {
    final RequestResponse res = params[0];
    logger.log((json.decode(res.data)['data']['listCoversation']));
    final int currentUserId = params[1];
    var _result = List<ChatItemModel>.from(
      (json.decode(res.data)['data']['listCoversation'] as List).map(
        (e) => ChatItemModel.fromConversationInfoJsonOfUser(
          currentUserId,
          conversationInfoJson: e,
          currentUserInfo: params[2],
          currentUserType: params[3],
        ),
      ),
    )..removeWhere(
        (element) => element.isHidden || element.memberList.length < 2);
    return _result;
  }

  @Deprecated("Dùng ChatRepo().getChatItemModel(conversationId) nhé")
  Future<ChatItemModel?> fetchSingleChatConversation(int conversationId) async {
    return ChatRepo().getChatItemModel(conversationId);

    /// TL 2/1/2024: Code thì dai dài loằng ngoằng, mà cuối cùng chả làm được bao nhiêu
    // var res = await ChatDetailRepo(_chatConversationsRepo.userId)
    //     .loadConversationDetail(conversationId);
    // try {
    //   return await res.onCallBack(
    //     (_) async {
    //       final ReceivePort receivePort = ReceivePort();

    //       final CurrentUserInfoModel currentUserInfoModel =
    //           SystemUtils.getCurrrentUserInfoAndUserType();

    //       await Isolate.spawn(_computeGetChatConversation, [
    //         res,
    //         receivePort.sendPort,
    //         currentUserId,
    //         currentUserInfoModel.userInfo,
    //         currentUserInfoModel.userType,
    //       ]);

    //       return (await receivePort.first) as ChatItemModel;
    //     },
    //   );
    // } catch (e) {}
    // return null;
  }

  // static _computeGetChatConversation(List params) {
  //   Isolate.exit(
  //     (params[1] as SendPort),
  //     ChatItemModel.fromConversationInfoJsonOfUser(
  //       params[2],
  //       conversationInfoJson: json.decode(params[0].data)["data"]
  //           ["conversation_info"],
  //     ),
  //   );
  // }

  // TL 28/12/2023:
  // Chuyển dịch caching qua ChatRepo
  Future loadData({int? countLoaded, bool reset = false}) async {
    add(ChatConversationEventAddLoadingState(markNeedBuild: chatsMap.isEmpty));
    try {
      var count = countLoaded ?? _countLoaded;
      var value = await ChatRepo().getConversationList(
          count: count + 20); //getListChatConversation(count);

      value = value.toList().slice(start: max(0, value.length - 20));
      //value = value.toSet().toList();
      add(ChatConversationEventAddData(
          value.map((e) => e.toChatItemModel()).toList(),
          saveToLocal: true,
          reset: reset,
          listStrange: listConversationStrange));
    } on CustomException catch (e) {
      if (e.error.isExceedListConversation) {
        add(ChatConversationEventRaiseError(e.error));
      }
    }
  }

  emitEventUI(List<ChatItemModel> conversations) {
    add(ChatConversationEmitEvent(conversations));
  }

  Future _getListLastMessages(List<ChatItemModel> conversations) async {
    // conversations
    //     .removeWhere((e) => !chatsMap[e.conversationId]!.lastMessages.isBlank);

    // Do api chậm nên fetch 10 cuộc trò chuyện mỗi lần

    return await _fetchListLastMessage(conversations);
    // var countTime = (conversations.length / 10).ceil();
    //
    // final List<List<ChatItemModel>> truncs = List.from(
    //   List.generate(
    //     countTime,
    //     (index) => conversations.slice(
    //       start: index * 10,
    //       end: index * 10 + 10,
    //     ),
    //   ),
    // );
    //
    // return Future.wait(
    //   truncs.map(
    //     (e) => _fetchListLastMessage(e),
    //   ),
    // );
  }

  Future _fetchListLastMessage(
    List<ChatItemModel> value,
  ) async {
    try {
      final Map<int, List<SocketSentMessageModel>> lastMessages =
          Map.fromIterable(value,
              key: (e) => e.conversationId, value: (e) => []);
      //     await _chatConversationsRepo.getListLastMessagesOfListConversations(
      //   value.map((e) => e.conversationId).toList(),
      //   value.map((e) => e.messageDisplay).toList(),
      // );
      logger.log('vafo ddeesn ddaay rooif');
      // lưu map tất cả cuộc trò chuyện kèm tin nhắn ở local
      // mỗi lần lưu => gọi api getlistmessagev2 => lấy được danh sách cuộc trò chuyện và tin nhắn
      // tuy nhiên khi 1 cuộc trò chuyện đã lưu được số lượng tin nhắn lớn hơn ở lastMessage thì vẫn chỉ lưu được tin nhắn ở trong lastmessage
      // giải pháp trong từng ds tin nhắn của cuộc trò chuyện ta sẽ ghép cả ds tin nhắn cũ và mới => to set
      // Map<int, List<SocketSentMessageModel>> localMess = await HiveService().messages ?? {};
      // if (localMess.isNotEmpty) {
      // localMess.forEach((conversationId, listMessages) {
      //     listMessages.addAll([...?lastMessages[conversationId]]);
      //     listMessages.sort((a, b) => a.createAt.compareTo(b.createAt));
      //     listMessages = [...listMessages.toSet().toList()];
      //     logger.log(
      //       'Set $conversationId ${listMessages.length} messages',
      //       name: 'SetOfflineMessage',
      //     );
      lastMessages.forEach((conversationId, listMessages) {
        chatsMap[conversationId]?.lastMessages = listMessages;
      });
      // });
      // }
      // lastMessages.forEach(
      //   (conversationId, listMessages) async {
      //     if (localMess[conversationId] != null) {
      //       listMessages.insertAll(0, [...?localMess[conversationId]]);
      //       listMessages.toSet().toList();
      //     }

      //     logger.log(
      //       'Set $conversationId ${listMessages.length} messages',
      //       name: 'SetOfflineMessage',
      //     );
      //     chatsMap[conversationId]?.lastMessages = listMessages;
      //   },
      // );

      // _encodeListMessage(
      //         localMess.isNotEmpty ? localMess : lastMessages);

      HiveService().saveMapConversationIdAndEncodedMessage(
          _encodeListMessage(lastMessages));
    } catch (e, s) {
      logger.logError(e, s);
    }
    return null;
  }

  static Map<int, String> _encodeListMessage(
    Map<int, List<SocketSentMessageModel>> lastMessages,
  ) =>
      lastMessages.map(
        (k, listMessages) => MapEntry(
          k,
          json.encode(
            listMessages
                .map((e) => sockeSentMessageModelToHiveObjectJson(e))
                .toList(),
          ),
        ),
      );

  // static String _encodeListConversation(List<ChatItemModel> listConversation) {
  //   return json.encode(
  //     listConversation
  //         .map((e) => sockeChatItemModeldToHiveObjectJson(e))
  //         .toList(),
  //   );
  // }

  // TL 28/12/2023:
  // Chuyển dịch caching qua ChatRepo
  // _saveChatItemModelToLocal(Iterable<ChatItemModel> value,
  //     {bool reset = false}) async {
  //   if (chatItemModelBox !=
  //       null /* && chatItemModelBox!.values.length < 100 */) {
  //     try {
  //       if (!chatItemModelBox!.isOpen) {
  //         await Hive.openBox(HiveBoxNames.chatItemModelBox);
  //       }
  //       if (reset) chatItemModelBox!.clear();
  //       chatItemModelBox!.putAll(
  //         Map.fromIterable(
  //           value,
  //           key: (e) => (e as ChatItemModel).conversationId,
  //         ),
  //       );
  //       logger.log('saved to local ${chatItemModelBox?.values.length}');
  //     } catch (e, s) {
  //       logger.logError(e, s);
  //     }
  //   }
  // }

  Future<ExceptionError?> deleteAllMessageConversation(
      int conversationId) async {
    var res = await _chatConversationsRepo
        .deleteAllMessageConversation(conversationId);
    try {
      var hasError = await res.onCallBack((_) => res.hasError);
      if (!hasError) {
        _chatConversationsRepo.totalRecords -= 1;
        chatsMap.remove(conversationId);
        loadData(reset: true);
        try {
          HiveService().listMessagesBox?.delete(conversationId);
        } catch (e, s) {
          logger.logError(e, s, 'RemoveDeletedConversationFromBoxError');
        }
        BotToast.showText(text: 'Đã xóa cuộc trò chuyện');
        return null;
      }
      return res.error;
    } on CustomException catch (e) {
      return e.error;
    }
  }

  Future<ExceptionError?> deleteFileConversation(int conversationId) async {
    var res =
        await _chatConversationsRepo.deleteFileConversation(conversationId);
    try {
      var hasError = await res.onCallBack((_) => res.hasError);
      if (!hasError) {
        await loadData(reset: true);
        // try {
        //   HiveService().listMessagesBox?.delete(conversationId);
        // } catch (e, s) {
        //   logger.logError(e, s, 'RemoveDeletedConversationFromBoxError');
        // }
        BotToast.showText(text: 'Đã xóa dữ liệu cuộc trò chuyện');
        // showDialog<String>(
        //   context: context,
        //   builder: (BuildContext context) => AlertDialog(
        //     content: const Text('Đã xóa dữ liệu cuộc trò chuyện'),
        //     actions: <Widget>[
        //       TextButton(
        //         onPressed: () => Navigator.pop(context),
        //         child: const Text('OK'),
        //       ),
        //     ],
        //   ),
        // );
        return null;
      }
      return res.error;
    } on CustomException catch (e) {
      return e.error;
    }
  }

  // @Deprecated(
  //     "Dùng ChatRepo().deleteMessageOneSide() nhé. Cái này vẫn giữ để backward compatible với code cũ. Sửa code cũ chắc ngất luôn")
  Future<ExceptionError?> deleteAllMessageOneSide(int conversationId) async {
    //ChatRepo().deleteMessageOneSide(messageId: messageId, conversationId: conversationId)
    var res =
        await _chatConversationsRepo.deleteAllMessageOneSide(conversationId);

    try {
      var hasError = await res.onCallBack((_) => res.hasError);
      if (!hasError) {
        try {
          removeConversationFromChatMap(conversationId);
          await HiveService().listMessagesBox?.delete(conversationId);
          //await HiveService().chatItemModelBox?.delete(conversationId);
        } catch (e, s) {
          logger.logError(e, s, 'RemoveDeletedConversationFromBoxError');
        }
        // await loadData(countLoaded: 0, reset: true);
        BotToast.showText(text: 'Đã xóa tất cả nội dung từ 1 phía');
        // showDialog<String>(
        //   context: context,
        //   builder: (BuildContext context) => AlertDialog(
        //     content: const Text('Đã xóa tất cả nội dung từ 1 phía'),
        //     actions: <Widget>[
        //       TextButton(
        //         onPressed: () => Navigator.pop(context),
        //         child: const Text('OK'),
        //       ),
        //     ],
        //   ),
        // );
        return null;
      }
      return res.error;
    } on CustomException catch (e) {
      return e.error;
    }
  }

  Future<ExceptionError?> changeHiddenConversation(
    int conversationId, {
    required int hidden,
  }) async {
    var res = await _chatConversationsRepo.changeHiddenConversationStatus(
      conversationId,
      hidden: hidden,
    );
    try {
      var hasError = await res.onCallBack((_) => res.hasError);
      onChangeHidden(conversationId, hidden);
      if (!hasError) {
        chatRepo.emitChangeHidenconversationStatus(
          currentUserId,
          conversationId,
          hidden,
        );
        // chatRepo.emitChangeFavoriteconversationStatus(
        //   currentUserId,
        //   conversationId,
        //   favorite,
        // );
        return null;
      }
      return res.error;
    } on CustomException catch (e) {
      return e.error;
    }
  }

  FutureOr onChangeHidden(int conversationId, int hidden) async {
    final ChatItemModel detail;
    if (hiddenConversations[conversationId] != null) {
      detail = hiddenConversations[conversationId]!;
    } else {
      detail = (await fetchSingleChatConversation(conversationId))!;
    }
    add((ChatConversationEventAddHiddenConversation(detail)));
  }

  // TL 18/1/2024: Việc thay đổi yêu thích CTC cũng đã được lắng nghe từ ChatRepo
  // @Deprecated("Dùng ChatRepo().changeFavoriteStatus() nhé")
  // Future<ExceptionError?> changeFavoriteConversation(
  //   int conversationId, {
  //   required int favorite,
  // }) async {
  //   await ChatRepo().changeFavoriteStatus(
  //       conversationId: conversationId, favorite: favorite);
  //   final ChatItemModel detail =
  //       (await ChatRepo().getChatItemModel(conversationId))!;
  //   if (favorite == 0) {
  //     add(ChatConversationEventRemoveFavoriteConversation(detail));
  //   } else {
  //     add((ChatConversationEventAddFavoriteConversation(detail)));
  //   }
  // }

  removeConversationFromChatMap(int conversationId) {
    chatsMap.remove(conversationId);
    add(ChatConversationEventAddData(
        chatsMap.entries.map((e) => e.value).toList(),
        reset: true,
        saveToLocal: true));
  }
}
