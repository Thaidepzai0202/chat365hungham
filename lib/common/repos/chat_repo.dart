import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:app_chat365_pc/common/Widgets/live_chat/timer_repo.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/network_cubit/network_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_event.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/models/auto_delete_message_time_model.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/models/group_conversation_creation_kind.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/core/constants/status_code.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/generator_service.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_box_names.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_service.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/data/services/network_service/network_service.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_model.dart';
import 'package:app_chat365_pc/modules/chat/notification/notificationChat.dart';
import 'package:app_chat365_pc/service/app_service.dart';
import 'package:app_chat365_pc/service/injection.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/clients/interceptors/mqtt_client_5.dart';
import 'package:app_chat365_pc/utils/data/clients/mqtt_client.dart';
import 'package:app_chat365_pc/utils/data/clients/unified_realtime_data_source.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_status.dart';
import 'package:app_chat365_pc/utils/data/enums/emoji.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/object_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/data/models/error_response.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_notifier/local_notifier.dart';

/// TODO: Convert ChatItemModel thành ConversationModel

/// TL 18/1/2024:
/// Catalogue những thứ "Có thể bạn cần biết" để sử dụng ChatRepo. Hướng dẫn sử dụng
/// chưa hoàn thiện.
///
/// ChatRepo (trong tương lai sẽ) là trung tâm của mọi thứ liên quan đến nhắn tin.
///
/// Bao gồm cả livechat. Nhưng người viết docs hiện tại đây không biết luồng livechat
/// nên chỉ biết mong chờ Khương rảnh rang viết hộ thôi.
///
/// === I. Các hàm gọi API, lấy và cache thông tin ===
///
/// 1. getConversationList(): API lấy danh sách cuộc trò chuyện
///
/// 2. loadListMessage(): API lấy những tin nhắn đầu của nhiều CTC một lúc
///
/// 3. loadMessages(): API lấy danh sách tin nhắn 1 cuộc trò chuyện
///
/// 4. getConversationModel(): API lấy thông tin một cuộc trò chuyện
///
/// 5. loadMessagesSync(): Lấy danh sách tin nhắn 1 cuộc trò chuyện trong local
///
/// 6. getConversationModel(): Lấy thông tin một cuộc trò chuyện trong local
///
/// === II. Các hàm gọi API thực hiện tác vụ gì đấy ===
///
/// 1. sendMessage()
///
/// 2. resendMessage()
///
/// 3. markReadAllMessage()
///
/// 4. clickMessage() ???
///
/// 5. sendAvatar() ???
///
/// 6. changeCurrentUserTypingState() ?
///
/// --- Cài đặt CTC ---
///
/// . changeFavoriteStatus(): Thay đổi trạng thái yêu thích
///
/// . changeNotificationStatus(): Bật/tắt thông báo
///
/// ...
///
/// === III. Các event bắn ra từ socket ===
///
/// Các event này trao đổi thông tin realtime giữa người dùng với nhau.
/// Để lắng nghe, gọi:
/// ```
/// ChatRepo().stream.listen((event) {
///     if (event is ChatEventOnXXX){
///         ...code xử lí...
///     }
/// });
/// ```
///
/// Xem chi tiết các event được bắn ra ở [_handleEvent()] nhé

class ChatRepo {
  final ApiClient _client = ApiClient();
  final AppService appService = getIt.get<AppService>();

  factory ChatRepo() => _instance ??= ChatRepo._();
  static ChatRepo? _instance;

  /// TL 22/2/2024: dùng để đánh dấu đã init hoàn thành lần đầu
  bool _isReady = false;

  // TL 21/2/2024: Giới hạn số tin nhắn lưu trên máy với mỗi CTC
  // TL 22/2/2024: Nhật bảo, lưu hết tin nhắn vào máy.
  // Cơ mà vấn đề là sẽ chỉ giữ 50 tin nhắn một lúc trong cache thôi.
  //
  // static int maxLatestMessagesSaved = {
  //   /// Cho điện thoại lưu 50 tin nhắn/CTC thôi
  //   Platform.isAndroid: 50,
  //   Platform.isIOS: 50,

  //   /// Còn laptop, PC thì rộng lượng hơn tí
  //   Platform.isFuchsia: 100,
  //   Platform.isLinux: 100,
  //   Platform.isMacOS: 100,
  //   Platform.isWindows: 100,
  // }[true]!;

  ChatRepo._() {
    _chatRepoCreationTimestamp = DateTime.now();
    // TL 18/2/2024:
    UnifiedRealtimeDataSource().stream.listen(emitChatEvent);

    // TL 18/2/2024: TODO: Dọn bỏ chỗ này, thay bằng UnifiedRealtimeDataSource
    // Ở đây xử lí những event liên quan đến cuộc trò chuyện,
    // nhưng lại bị đặt ở event bên UserInfo
    UserInfoRepo().stream.listen((event) {
      if (event is UserInfoEventGroupAvatarChanged) {
        if (event.avatar == null) {
          return;
        }

        var conversationId = event.userId;
        if (!_conversationListLocal.containsKey(conversationId)) {
          return;
        }
        var conversationModel = getConversationModelSync(conversationId);
        if (conversationModel != null) {
          conversationModel.avatarConversation = event.avatar ?? "";
          setConversationModel(conversationModel);
        }
      } else if (event is UserInfoEventGroupNameChanged ||
          event is UserInfoEventNicknameChanged) {
        var conversationId = event.userId;
        var conversationModel = getConversationModelSync(conversationId);
        if (conversationModel == null) {
          return;
        }

        if (event is UserInfoEventGroupNameChanged) {
          conversationModel.conversationName = event.name;
        } else if (event is UserInfoEventNicknameChanged) {
          conversationModel.conversationName = event.newNickname;
        }

        setConversationModel(conversationModel);
      }
    });

    // Lúc mất mạng thì lưu lại hết mọi thứ vào cache và clear các flag đồng bộ
    networkCubit.networkStream.listen((NetworkState event) {
      if (!event.hasInternet || event.socketDisconnected) {
        if (_isReady) {
          saveData().then((value) {
            _conversationListCache.clear();
            _messagesCache.clear();
            _dontNeedMarkRead.clear();
            _allConversationsFetched = false;
          });
        }
      }
    });

    AuthRepo().status.listen((event) {
      if (event == AuthStatus.unauthenticated) {
        if (_isReady) {
          saveData().then((value) {
            _messagesCache.clear();
            _messagesLocal.clear();
            _conversationListLocal.clear();
            _conversationListCache.clear();
            _dontNeedMarkRead.clear();
            _allConversationsFetched = false;
          });
        }
      } else if (event == AuthStatus.authenticated) {
        initCache();
      }
    });

    _isReady = true;
  }

  /// Bấm giờ để thỉnh thoảng lại lưu data vào local.
  ///
  /// Mặc định là 60s một lần. Init trong initCache
  // NOTE: Tạm thời bỏ đi. Vì nhỡ nếu init sai mà lại lưu do cái timer này thì mất hết data
  //late Timer saveToLocalTimer;

  /// Nếu đặt ở ngay trong constructor, khi khởi tạo lần đầu sẽ bị exception do
  /// vẫn đang await HiveService.init(), nhưng một số class khác đã cần dùng ChatRepo rồi
  ///
  /// TODO: Do anh Việt Hùng bảo cần clear cache khi đăng xuất, nên mình cần init nó lại ở đâu đó chưa nghĩ ra
  void initCache() {
    // saveToLocalTimer = Timer.periodic(Duration(milliseconds: 60000), (timer) {
    //   saveData();
    // });

    // Danh sách CTC
    try {
      var convList = jsonDecode(
          HiveService().conversationListBox?.get(AuthRepo().userInfo?.id) ??
              "[]") as List<dynamic>;
      for (final conv in convList) {
        var data = conv;
        if (conv is String) {
          data = jsonDecode(conv);
        }
        var conversationModel = ConversationModel.fromJson(data);
        _conversationListLocal[conversationModel.conversationId] =
            conversationModel;
      }
    } catch (err, stack) {
      logger.logError("Khởi tạo conversationListBox bị lỗi: ${err}", stack,
          "$runtimeType.initCache");
    }

    logger.log("Init cache, lấy được ${_conversationListLocal.keys.length} CTC",
        name: "$runtimeType.initCache");

    // Danh sách tin nhắn. Chỉ lấy theo những CTC có trong danh sách vừa lấy ở cache bên trên
    var msgBox = HiveService().locallySavedMessages!;
    var userConversationIds = msgBox.keys.toList();
    userConversationIds
        .retainWhere((element) => _conversationListLocal.containsKey(element));

    for (final conversationId in userConversationIds) {
      _messagesLocal[conversationId] = SplayTreeSet.from(
          (jsonDecode(msgBox.get(conversationId)!) as List<dynamic>)
              .map((e) => SocketSentMessageModel.fromHiveObjectMap(e)),
          _localMessageOrder);
    }

    logger.log(
        "Đã khởi tạo xong các cuộc trò chuyện trong cache (CTC, số tin nhắn, số thành viên):",
        name: "$runtimeType.initCache");

    for (final conversationId in _messagesLocal.keys) {
      logger.log(
          "(${conversationId}, ${_messagesLocal[conversationId]?.length ?? 0}, ${getAllChatMembersSync(conversationId: conversationId).length})",
          name: "$runtimeType.initCache");
    }
  }

  /// TL 16/2/2024:
  ///
  /// Sử dụng đầu mối này để làm luồng xử lí event chung cho cả Socket lẫn MQTT
  ///
  /// Nếu không dùng cái này mà gọi add(ChatSocketEventXXX) luôn,
  /// thì cache sẽ bị bỏ qua bước cập nhật
  ///
  /// Sau khi xử lí xong các thứ liên quan đến ChatRepo, event này sẽ được relay lại qua stream
  void emitChatEvent(ChatEvent event) async {
    if (!_handleEvent(event)) {
      return;
    }

    if (event is ChatEventOnReceivedMessage) {
      // logger.log("Nhận tin nhắn: ${event.msg.toString()}", name: "ChatRepo");
      var msg = event.msg;
      // DateTime lastMsgTimestamp = getConversationModelSync(msg.conversationId)?.timeLastMessage??DateTime(1970);
      // if (!lastMsgTimestamp.difference(msg.createAt).isNegative) {
      //   logger.log(msg, name: "DuplicatedEvent");
      //   return;
      // }
      _dontNeedMarkRead.remove(msg.conversationId);

      // Cập nhật thông tin ở cache ConversationModel
      await _updateLatestMessageToConversationModel(msg);

      // Cập nhật thông tin ở cache tin nhắn
      _messagesCache[msg.conversationId] ??= SplayTreeSet(_localMessageOrder);
      _messagesCache[msg.conversationId]!.add(msg);
      await saveMessagesToLocal(msg.conversationId);

      // if (msg.message ==
      //     "cong ty HH vừa đăng nhập tài khoản nhà tuyển dụng trên timviec365.vn") {
      //   logger.log(
      //       "CTC ${msg.messageId}: ${loadMessagesSync(conversationId: msg.conversationId).map((e) => e.message).toList().toString()}",
      //       name: "ChatRepo");
      // }
    } else if (event is ChatEventOnMessageEditted) {
      var conversationId = event.conversationId;
      if (conversationId != -1) {
        var messageId = event.messageId;
        var model = getConversationModelSync(conversationId);
        if (model != null) {
          model.timeLastChange = DateTime.now();
          setConversationModel(model);
        }

        var edittedMessage =
            getMessage(conversationId: conversationId, messageId: messageId);
        if (edittedMessage != null) {
          edittedMessage.message = event.newMessage;
          setMessage(edittedMessage);
        }
      }
    } else if (event is ChatEventOnDeleteMessage) {
      _messagesCache[event.conversationId]
          ?.removeWhere((msg) => msg.messageId == event.messageId);
      _messagesLocal[event.conversationId]
          ?.removeWhere((msg) => msg.messageId == event.messageId);

      // Sửa thông tin trên ConversationModel nếu nhỡ không may tin nhắn bị xóa
      // là tin nhắn mới nhất của CTC này
      var conversationModel = getConversationModelSync(event.conversationId);

      if (conversationModel != null &&
          conversationModel.messageId == event.messageId) {
        var newLatestMsg =
            loadMessagesSync(conversationId: event.conversationId, range: 1)
                .firstOrNull;
        if (newLatestMsg != null) {
          _updateLatestMessageToConversationModel(newLatestMsg);
        }
      }
      saveAllMessagesToLocal();
    } else if (event is ChatEventOnMarkReadAllMessages) {
      /// Cập nhật thông tin tin nhắn đã đọc cho thành viên
      var conversationModel =
          (await getConversationModel(event.conversationId))!;
      var memIdx = conversationModel.listMember
          .indexWhere((element) => element.id == event.senderId);
      conversationModel.listMember[memIdx].unreadMessageId =
          conversationModel.messageId;
      setConversationModel(conversationModel);
    } else if (event is ChatEventOnTyping) {
      // TODO
    } else if (event is ChatEventOnStopTyping) {
      // TODO
    } else if (event is ChatEventOnRecievedEmotionMessage) {
      var conversationId = event.conversationId;
      var messageId = event.messageId;

      var existingMsg =
          getMessage(conversationId: conversationId, messageId: messageId);
      if (existingMsg != null) {
        var emoji = event.emoji;
        // TL 22/2/2024: Đố biết event.checked để đây có đúng không đấy
        existingMsg.emotion[event.emoji] ??=
            Emotion(type: emoji, listUserId: [], isChecked: event.checked);

        existingMsg.emotion[event.emoji] = Emotion(
            type: emoji,
            listUserId:
                existingMsg.emotion[event.emoji]!.listUserId + [event.senderId],
            isChecked: event.checked);
        setMessage(existingMsg);
      }
    } else if (event is ChatEventOnUpdateStatusMessageSupport) {
      // TL 20/2/2024: Sửa luồng. Không bắn event nữa,
      // mà xóa thẳng từ lúc bấm tin nhắn luôn.
      // Xem ở [deleteLivechatMessage()]
    } else if (event is ChatEventOnNewMemberAddedToGroup) {
      // Cập nhật thêm thành viên mới
      // NOTE: Đương nhiên việc convert từ UserInfo qua ChatMemberModel sẽ
      // có mất mát dữ liệu, nhưng không sao
      // TEST: Thêm người dùng vào nhóm mà không gãy
      var conversationModel =
          (await getConversationModel(event.conversationId))!;
      conversationModel.listMember.addAll(event.members
          .map((userInfo) => ChatMemberModel.fromJson(userInfo.toJson())));
      setConversationModel(conversationModel);
    } else if (event is ChatEventOnPinMessage) {
      var conversationModel =
          (await getConversationModel(event.conversationId))!;
      conversationModel.pinMessageId = event.messageId;
      setConversationModel(conversationModel);
    } else if (event is ChatEventOnUnpinMessage) {
      var conversationModel =
          (await getConversationModel(event.conversationId))!;
      conversationModel.pinMessageId = "";
      setConversationModel(conversationModel);
    } else if (event is ChatEventOnDeleteContact) {
      // TL 22/2/2024: Mặc dù không xử lí gì, nhưng vẫn phải
      // bắn event để rebuild UI màn ChatScreen... nhỉ?
    } else if (event is ChatEventOnChangeFavoriteStatus) {
      var conversationModel =
          (await getConversationModel(event.conversationId))!;
      conversationModel.isFavorite = event.isChangeToFavorite;
      setConversationModel(conversationModel);
    } else if (event is ChatEventOnOutGroup) {
      if (event.deletedMemberId == AuthRepo().userId) {
        _conversationListLocal.remove(event.conversationId);
        _conversationListCache.remove(event.conversationId);

        /// TL: NOTE 16/2/2024: Nếu xóa message local, thì nếu
        /// hai người dùng ở trong chung một CTC, xóa ở bên người A
        /// thì sẽ bị mất bên người B.
        ///
        /// Mình có muốn thế không?
        _messagesCache.remove(event.conversationId);
        _messagesLocal.remove(event.conversationId);
      }

      var conversationModel =
          (await getConversationModel(event.conversationId));
      if (conversationModel != null) {
        conversationModel.listMember
          .removeWhere((element) => element.id == event.deletedMemberId);
        conversationModel.adminId = event.newAdminId;
        setConversationModel(conversationModel);
      }
    } else if (event is ChatEventOnChangeNotification) {
      var conversationModel =
          (await getConversationModel(event.conversationId));
      if (conversationModel != null) {
        conversationModel.notification = event.isNotification;
        setConversationModel(conversationModel);
      }
    } else if (event is ChatEventOnCreateSecretConversation) {
      var conversationModel =
          (await getConversationModel(event.conversationId));
      if (conversationModel != null) {
        /// NOTE: Không chắc cái này đâu nhoee
        conversationModel.typeGroup = event.typeGroup;
        setConversationModel(conversationModel);
      }
    } else if (event is ChatEventOnUpdateDeleteTime) {
      var conversationModel =
          (await getConversationModel(event.conversationId))!;
      for (int i = 0; i < conversationModel.listMember.length; ++i) {
        if (event.senderId.contains(conversationModel.listMember[i].id)) {
          conversationModel.listMember[i].deleteTime = event.deletedTime;
        }
      }
      setConversationModel(conversationModel);
    } else if (event is ChatEventOnNickNameChanged) {
      // Lấy cuộc trò chuyện solo của mình và người kia
      var conversationId = await getConversationId(event.userId);
      if (conversationId != null) {
        var chatMember = await getChatMember(
            conversationId: conversationId, chatMemberId: event.userId);
        if (chatMember != null) {
          chatMember.name = event.name;
          setChatMember(conversationId, chatMember);
        }
      }
    } else if (event is ChatEventOnGroupAvatarChanged) {
      var conversation = getConversationModelSync(event.conversationId);
      if (conversation != null) {
        conversation.linkAvatar = event.avatar;
        setConversationModel(conversation);
      }
    } else if (event is ChatEventOnGroupNameChanged) {
      var conversation = getConversationModelSync(event.conversationId);
      if (conversation != null) {
        conversation.conversationName = event.name;
        setConversationModel(conversation);
      }
    } else if (event is ChatEventUserActiveTimeChanged) {
      // TODO: Chả lẽ mình moi hết tất cả các CTC lên để tìm thằng userId này?
      // Hay có khi ý tưởng sẽ là mình update lastActive khi gọi getChatMember(),
      // lấy lastActive bên UserInfoRepo.

      // Khi nào sếp có yêu cầu thì mới làm
    }

    // Xử lí nội bộ xong rồi. Giờ thì truyền lại cho đứa khác.
      _controller.add(event);
    
  }

  /// Trả về `true` nếu ChatRepo xử lí loại event này
  bool _handleEvent(ChatEvent event) {
    return event is ChatEventOnReceivedMessage ||
        event is ChatEventOnMessageEditted ||
        event is ChatEventOnDeleteMessage ||
        event is ChatEventOnMarkReadAllMessages ||
        event is ChatEventOnTyping ||
        event is ChatEventOnStopTyping ||
        event is ChatEventOnRecievedEmotionMessage ||
        event is ChatEventOnUpdateStatusMessageSupport ||
        event is ChatEventOnNewMemberAddedToGroup ||
        event is ChatEventOnPinMessage ||
        event is ChatEventOnUnpinMessage ||
        event is ChatEventOnDeleteContact ||
        event is ChatEventOnChangeFavoriteStatus ||
        event is ChatEventOnOutGroup ||
        event is ChatEventOnChangeNotification ||
        event is ChatEventOnCreateSecretConversation ||
        event is ChatEventOnUpdateDeleteTime ||
        //
        event is ChatEventOnNickNameChanged ||
        event is ChatEventOnGroupAvatarChanged ||
        event is ChatEventOnDeleteConversation ||
        // TODO: ChatEventUserActiveTimeChanged
        event is ChatEventOnGroupNameChanged;
  }

  Future<void> saveData() async {
    Future.wait([saveAllMessagesToLocal(), saveConversationListToLocal()]);
  }

  /// Key - Value: ID cuộc trò chuyện - Danh sách CTC ở local.
  ///
  /// Lưu tin nhắn khi mất mạng/server xóa data.
  ///
  /// _messagesLocal[id].first là tin nhắn khởi đầu của cuộc trò chuyện.
  ///
  /// _messagesLocal[id].last là tin nhắn mới nhất của cuộc trò chuyện.
  ///
  /// Nếu _messagesLocal[id] null, tức là chưa tải cuộc trò chuyện bao giờ
  ///
  /// Nếu _messagesLocal[id] rỗng, tức là tải rồi, nhưng cuộc trò chuyện không có tin nhắn gì.
  final Map<int, SplayTreeSet<SocketSentMessageModel>> _messagesLocal = {};

  /// Key - Value: ID CTC - Danh sách tin nhắn đã tải từ API ở phiên này.
  ///
  /// Note: Xem _messageLocal để biết thông tin thứ tự của tin nhắn
  final Map<int, SplayTreeSet<SocketSentMessageModel>> _messagesCache = {};

  /// Đánh dấu những cuộc trò chuyện mà mình đã lấy được hết sạch sành sanh tất cả tin nhắn.
  ///
  /// Tránh gọi API nhiều
  final Set<int> _conversationsFetchedAllMessages = {};

  /// TODO: Có sự liên hệ giữa _conversationListLocal và _messagesLocal, thông qua
  /// ChatItemModel.lastMessages. Liên hệ này chưa được phản ánh trong code ở đây.
  ///
  /// Key - Value: ID CTC - Thông tin CTC
  ///
  /// NOTE: Mặc dù lưu là Map<int, dynamic> vào Hive, nhưng khi
  /// jsonDecode thì ra Map<String, dynamic>. Vậy nên phải có bước convert.
  final Map<int, ConversationModel> _conversationListLocal = {};

  /// Những cuộc trò chuyện đã đồng bộ thông tin với server
  final Map<int, ConversationModel> _conversationListCache = {};
    
  late final DateTime _chatRepoCreationTimestamp;
  
  final Map<int, DateTime> _conversationCacheTimestamp = {};

  final StreamController<ChatEvent> _controller = StreamController.broadcast();

  Stream<ChatEvent> get stream => _controller.stream;

  @Deprecated("Dùng emitChatEvent() nhé, để còn cập nhật cache.")
  StreamController<ChatEvent> get streamController => _controller;

  Future<RequestResponse> sendMessage(
    ApiMessageModel msg, {
    required List<int> recieveIds,
    ConversationBasicInfo? conversationBasicInfo,
    List<int>? onlineUsers,
    ValueNotifier<double>? progress,
    int? isSecret,
  }) async {
    List<String> listUploadedFileNames = [];
    ApiMessageModel? newMsg;
    if (!msg.files.isBlank) {
      if ((msg.files![0].filePath.isBlank ||
              msg.files![0].filePath!.contains('https')) &&
          msg.files![0].fileType == MessageType.image) {
        for (var item in msg.files!) {
          if (item.filePath.isBlank) {
            listUploadedFileNames.add(item.resolvedFileName);
          } else {
            listUploadedFileNames.add(item.originFileName);
          }
        }
        newMsg = ApiMessageModel(
          conversationId: msg.conversationId,
          senderId: msg.senderId,
          messageId: msg.messageId,
          type: msg.type,
          files: msg.files!.asMap().keys.map(
            (index) {
              var e = msg.files![index];
              return ApiFileModel(
                fileName: e.fileName,
                fileType: e.fileType,
                fileSize: e.fileSize,
                uploaded: true,
                // fileDatas: e.fileDatas,
                resolvedFileName: listUploadedFileNames[index],
                displayFileSize: e.displayFileSize,
              );
            },
          ).toList(),
        );
      } else {
        var uploadRes = await _uploadFiles(
          msg,
          recieveIds: recieveIds,
          progress: progress,
        );
        if (uploadRes.hasError) {
          var error = uploadRes.error ??
              ErrorResponse(
                code: StatusCode.errorUnknownCode,
                message: 'Tải file thất bại',
              );
          return RequestResponse(
            '{"result":false,"code":${error.code},"error": ${json.encode(error.toJson())}}',
            false,
            error.code,
            error: error,
          );
        }
        try {
          listUploadedFileNames.addAll([
            ...msg.files!
                .where((e) => e.uploaded)
                .map((e) => e.resolvedFileName),
            ...List<String>.from(
                json.decode(uploadRes.data)["data"]['listNameFile'])
          ]);

          if (listUploadedFileNames.length != msg.files!.length) {
            var error = uploadRes.error ??
                ErrorResponse(
                  code: StatusCode.errorUnknownCode,
                  message: 'Tải file thất bại',
                );
            return RequestResponse(
              '{"result":false,"code":${error.code},"error": ${json.encode(error.toJson())}}',
              false,
              error.code,
              error: error,
            );
          }

          // _sendMessage(
          //   newMsg ?? msg,
          //   recieveIds: recieveIds,
          //   conversationBasicInfo: conversationBasicInfo,
          //   onlineUsers: onlineUsers,
          // );

          newMsg = ApiMessageModel(
            conversationId: msg.conversationId,
            senderId: msg.senderId,
            messageId: msg.messageId,
            type: msg.type,
            files: msg.files!.asMap().keys.map(
              (index) {
                var e = msg.files![index];
                return ApiFileModel(
                  fileName: e.fileName,
                  fileType: e.fileType,
                  fileSize: e.fileSize,
                  uploaded: true,
                  // fileDatas: e.fileDatas,
                  resolvedFileName: listUploadedFileNames[index],
                  displayFileSize: e.displayFileSize,
                );
              },
            ).toList(),
          );

          // return _uploadFiles(msg, recieveIds);
        } catch (e, s) {
          logger.logError(e, s);
          var error = ErrorResponse(message: e.toString());
          return RequestResponse(
            '{"result":false,"code":${error.code},"error": ${json.encode(error.toJson())}}',
            false,
            error.code,
            error: error,
          );
        }
      }
    }

    if (msg.type == MessageType.document) {
      var message = msg.message!;
      var indexOfFirstEndline = message.indexOf('\n');
      var title = message.substring(0, indexOfFirstEndline);
      var notiMessage = message.substring(indexOfFirstEndline + 1);
      var sendNotificationMessage = await _sendNotificationMessage(
        {
          'SenderId': msg.senderId,
          'Type': msg.type.databaseName,
          'Title': title,
          'Message': notiMessage,
          'Link': msg.infoLink?.link ?? msg.infoLink?.linkHome,
          'ConversationId': msg.conversationId,
        },
        messageType: msg.type,
      );

      return sendNotificationMessage;
    }

    return _sendMessage(
      newMsg ?? msg,
      recieveIds: recieveIds,
      conversationBasicInfo: conversationBasicInfo,
      onlineUsers: onlineUsers,
      isSecret: isSecret,
    );
  }

  Future<RequestResponse> resendMessage(
      Map<String, dynamic> map, ValueNotifier<double>? progress) async {
    try {
      var files = jsonDecode(map['File'])
          .map<ApiFileModel>((e) => ApiFileModel.fromMapOfSocket(e))
          .toList();
      logger.log(files.toString());
      await _uploadFiles(null, files: files, progress: progress);
    } catch (e, s) {
      logger.logError(e, s);
    }
    return _client.fetch(ApiPath.sendMessage, data: map, retryTime: 1);
  }

  Future<RequestResponse> _sendMessage(
    ApiMessageModel msg, {
    required List<int> recieveIds,
    ConversationBasicInfo? conversationBasicInfo,
    List<int>? onlineUsers,
    int? isSecret,
  }) async {
    var map = msg.toMap();
    if (conversationBasicInfo != null) {
      var encodedRecieveIds = json.encode(recieveIds);
      var encodedOnlineUsers = json.encode(onlineUsers);
      map.addAll({
        'ListMember': encodedRecieveIds,
        'ConversationName': conversationBasicInfo.name,
        'IsOnline': encodedOnlineUsers,
        'IsGroup': conversationBasicInfo.isGroup ? 1 : 0,
        'isSecret': (isSecret ?? 0).toString(),
        'deleteTime': msg.deleteTime,
        'deleteType': msg.deleteType,
        'companyIdReceive': conversationBasicInfo.companyId,
      });
      //  if(!conversationBasicInfo.isGroup)map.addAll({'companyIdReceive':conversationBasicInfo});
    }
    return _client.fetch(
      ApiPath.sendMessage,
      data: map,
      retryTime: 1,
      options: Options(
        receiveTimeout: const Duration(milliseconds: 10000),
        sendTimeout: const Duration(milliseconds: 10000),
      ),
    );
  }

  Future<RequestResponse> sendMissMessageLiveChat(
    ApiMessageModel livechatMessageModel, {
    required List<int> recieveIds,
    ConversationBasicInfo? conversationBasicInfo,
    List<int>? onlineUsers,
  }) async {
    var map = livechatMessageModel.toMap();
    if (conversationBasicInfo != null) {
      var encodedRecieveIds = json.encode(recieveIds);
      var encodedOnlineUsers = json.encode(onlineUsers);
      map.addAll({
        'ListMember': encodedRecieveIds,
        'ConversationName': conversationBasicInfo.name,
        'IsOnline': encodedOnlineUsers,
        'IsGroup': conversationBasicInfo.isGroup ? 1 : 0,
      });
    }
    return _client.fetch(
      ApiPath.sendMessage_v2,
      data: map,
      retryTime: 1,
    );
  }

  Future<RequestResponse> clickMessage(
      {required int userId,
      required int conversationId,
      required String messageId}) async {
    return _client.fetch(
      ApiPath.clickMessage,
      data: {
        'UserId': userId,
        'conversationId': conversationId,
        'messageId': messageId,
      },
    );
  }

  Future<RequestResponse> sendAvatar(
      {required int conversationId,
      required int userId,
      required int senderId}) async {
    var map = {
      'userId': userId,
      'conversationId': conversationId,
      'senderId': senderId,
    };
    return _client.fetch(
      ApiPath.shareAvatar,
      data: map,
      retryTime: 1,
    );
  }

  /// TODO:
  /// Sửa trạng thái thông báo của CTC @conversationId
  /// API khá buồn cười, không có tham số để gắn giá trị bật/tắt
  /// Nên là bây giờ phải mò thôi
  Future<void> changeNotificationStatus({
    required int conversationId,
    // TODO: Thêm tham số bật/tắt
  }) async {
    // TODO: Socket?
    //bắn socket thông báo trc quên chưa ghép
    // if (membersIds.isNotEmpty)
    //   chatClient.emit(
    //       ChatSocketEvent.checkNotification, {conversationId, 1, membersIds});
    // logger.log({conversationId, 0, membersIds},
    //     name: ChatSocketEvent.checkNotification);
    ApiClient().fetch(
      ApiPath.changeNotiChat,
      data: {
        'userId': AuthRepo().userId!,
        'conversationId': conversationId,
      },
    ).then((response) {
      if (response.hasError) {
        throw (Exception(response.error!.error));
      }
      // Note:
      // Bật thành công thì message trả "Bật thông báo cuộc trò chuyện thành công"
      // Tắt thành công thì "Tắt thông báo cuộc trò chuyện thành công"
      var newNotificationStatus =
          response.data.contains("Bật"); //jsonDecode(res.data)["data"];

      emitChatEvent(
          ChatEventOnChangeNotification(conversationId, newNotificationStatus));
    }).catchError((err) {
      logger.log("Sửa trạng thái thông báo thất bại: ${err.toString()}",
          name: "$runtimeType.changeNotificationStatus");
    });
  }

  // tin nhắn tự xóa
  Future<RequestResponse> setupDeleteTime({
    required String messageId,
    required int conversationId,
    required int deleteTime,
    required List<int> listUserId,
  }) async {
    var map = {
      'messageId': messageId,
      'conversationId': conversationId,
      'deleteTime': deleteTime,
      'listUserId': listUserId,
    };
    return _client.fetch(
      ApiPath.setupDeleteTime,
      data: map,
      retryTime: 1,
    );
  }

  Future<RequestResponse> markUnreaderNotification({
    required String notiId,
  }) async {
    var map = {
      'notiId': notiId,
    };
    return _client.fetch(
      '${ApiPath.markAsReadNoti}/$notiId',
      data: map,
      retryTime: 1,
      method: RequestMethod.get,
    );
  }

  Future<RequestResponse> _sendNotificationMessage(
    Map<String, dynamic> mapData, {
    required MessageType messageType,
  }) async {
    if (messageType == MessageType.document) {
      return _client.fetch(
        ApiPath.sendNewNotification_v2,
        data: mapData,
      );
    }
    throw CustomException(
      ExceptionError(
        'MessageType $messageType chưa hỗ trợ gửi dưới dạng notification',
      ),
    );
  }

  // tải file lên sv
  Future<RequestResponse> _uploadFiles(
    ApiMessageModel? msg, {
    List<int>? recieveIds,
    ValueNotifier<double>? progress,
    List<ApiFileModel> files = const [],
  }) async {
    var data = <MultipartFile>[];
    if (files.isEmpty) {
      data = [
        for (final file in msg!.files!)
          if (!file.uploaded)
            await MultipartFile.fromFile(
              file.filePath!,
              filename: file.fileName,
            ),
      ];
    } else {
      data = [
        for (final file in files)
          if (!file.uploaded)
            await MultipartFile.fromFile(
              file.filePath!,
              filename: file.fileName,
            )
      ];
    }
    if (data.isNotEmpty) {
      return await _client.upload(
        ApiPath.uploadFile,
        data,
        progressListener: progress,
      );
    }
    return RequestResponse(
      '{"data":{"listNameFile":[]},"result":true,"code":${StatusCode.ok}}',
      true,
      StatusCode.ok,
    );
  }

  // sendSocketMessage(
  //   ApiMessageModel msg, {
  //   required List<int> recieveIds,
  // }) {
  //   chatClient.emit(
  //     ChatSocketEvent.sendMessage,
  //     [msg.toMap(), recieveIds],
  //   );
  // }

  changeCurrentUserTypingState(
    bool isTyping, {
    required int userId,
    required int conversationId,
    required List<int> listMemeber,
  }) {
    chatClient.emit(
      isTyping ? ChatSocketEvent.typing : ChatSocketEvent.stopTyping,
      [
        userId,
        conversationId,
        listMemeber,
        userInfo!.name,
      ],
    );
    // logger.log("day la typing ${userInfo!.name}");
  }

  /// Danh sách ID những cuộc trò chuyện không cần gọi API đánh dấu đã đọc.
  /// Sau khi gọi markReadMessage, thêm ID vào đây.
  /// Sau khi nhận tin nhắn mới từ socket, bỏ ID CTC ấy đi
  final Set<int> _dontNeedMarkRead = {};

  /// NOTE:
  /// 1. Api không hỗ trợ markRead 1 message nên hiện tại messageIds luôn null
  /// 2. senderId chỉ có thể là người dùng hiện tại :)
  Future<void> markReadMessage({
    required int conversationId,
    @Deprecated(
        "Có cho cũng không dùng. Api không hỗ trợ markRead 1 message nên hiện tại messageIds luôn null")
    List<int>? messageIds,
    @Deprecated(
        "Có cho cũng không dùng. Do senderId chỉ có thể là người dùng hiện tại.")
    int? senderId,
    @Deprecated("Có cho cũng không dùng. memebers được tìm thẳng trong cache.")
    List<int>? memebers,
  }) async {
    var chatItemModel = await getChatItemModel(conversationId);

    if (chatItemModel == null) {
      logger.log("Không tồn tại CTC $conversationId để đánh dấu đã đọc.",
          name: "$runtimeType.markReadMessage");
      return;
    }

    if (_dontNeedMarkRead.contains(conversationId)) {
      // logger.log("Không cần gọi API/Socket đánh dấu đã đọc.", name: "$runtimeType");
      return;
    }

    senderId = AuthRepo().userId!;

    // logger.log("Gọi API/Socket đánh dấu đã đọc", name: "$runtimeType");
    var res = await _client.fetch(
      ApiPath.markAsRead,
      data: {
        'conversationId': conversationId,
        'senderId': senderId,
      },
    );
    if (res.error != null) {
      BotToast.showText(text: 'Đánh dấu đã đọc tin nhắn thất bại');
      return;
    }
    _dontNeedMarkRead.add(conversationId);

    var data2 = [
      senderId,
      conversationId,
      chatItemModel.memberList.map((e) => e.id).toList()
    ];
    logger.log(data2, name: 'EmitReadMessage');
    chatClient.emit(
      ChatSocketEvent.markReadAllMessage,
      data2,
    );
  }

  changeReaction(ChatEventEmitChangeReationMessage event) async {
   var data = [
      event.userId,
      event.messageId,
      event.conversationId,
      event.emoji.id,
      event.emoji.linkEmotion,
      event.allMemberIdsInConversation,
      event.isChecked,
      event.messageType.databaseName,
      event.message,
    ];
    logger.log(data, name: 'Emit ReactionMessage Data');
    logger.log("chatClient.emit(data = $data, event = ${ChatSocketEvent.changeReactionMessage})", name: "emotional damage", maxLength: 10000);
    await chatClient.emit(
      ChatSocketEvent.changeReactionMessage,
      data,
    );
    String userIds = '';
    List<int> listUserIdReactedAtEmoji = [];
    listUserIdReactedAtEmoji = event.emotion?[event.emoji]?.listUserId ?? [];
    // listUserIdReactedAtLikeEmoji.add(event.userId);
    userIds = listUserIdReactedAtEmoji.join(',');

    /// unlike
    // if (event.isChecked) {
    //   // event.memberReactThisEmoji.remove(currentUserId);
    //   userIds = event.memberReactThisEmoji.join(',');
    //   logger.log("unlike: userIds = event.memberReactThisEmoji.join(',') = ${event.memberReactThisEmoji.join(',')}", name: "emotional damage");
    // } else {
    //   /// like
    //   userIds = event.userId.toString();
    //   logger.log("like: userIds = event.userId.toString() = ${event.userId.toString()}", name: "emotional damage");
    // }

    // userIds = "${event.userId.toString()}, ${event.userId.toString()}";

    logger.log("res = await _client.fetch("
        "data = ApiPath.changeEmotionMessage = ${ApiPath.changeEmotionMessage}, "
        "date = {MessageID = event.messageId = ${event.messageId}, ListUserId = ${userIds.toString()}, Type = event.emoji.id = ${event.emoji.id}}", name: "emotional damage");
    var res = await _client.fetch(
      ApiPath.changeEmotionMessage,
      data: {
        'MessageID': event.messageId,
        'ListUserId': userIds,
        'Type': event.emoji.id,
      },
      options: Options(
        receiveTimeout: const Duration(milliseconds: 7000),
        sendTimeout: const Duration(milliseconds: 7000),
      ),
    );
    logger.log("res.onCallBack()", name: "emotional damage");
    res.onCallBack((_) {});
  }

  @Deprecated("Dùng ChatRepo().deleteMessageOneSide() nhé")
  Future<void> deleteMessage(
    ApiMessageModel message, {
    @Deprecated("Có cho cũng không dùng. @members được lấy trên cache rồi")
    List<int> members = const [], // Không dùng nữa
  }) async {
    await deleteMessageOneSide(
        messageId: message.messageId, conversationId: message.conversationId);
  }

  Future<void> deleteMessageOneSide(
      {required String messageId, required int conversationId}) async {
    var res = await _client.fetch(
      ApiPath.deleteMessageOneSide,
      data: {
        'MessageID': messageId,
        'ConversationID': conversationId,
        'userId': AuthRepo().userId,
      },
    );
    var members = (await getChatItemModel(conversationId))!
        .memberList
        .map((e) => e.id)
        .toList();

    res.onCallBack((_) {
      if (!res.hasError && res.result == true ||
          res.error?.messages == 'Tin nhắn không tồn tại') {
        // TL 6/1/2024: Xóa tin nhắn trên cache (nếu có)
        // NOTE: Nên emit cái này, hay vào UnifiedRealtimeDataSource nhỉ?
        emitChatEvent(ChatEventOnDeleteMessage(conversationId, messageId));
        // chatClient.emit(ChatSocketEvent.deleteMessage, [
        //   {
        //     'MessageID': message.messageId,
        //     'ConversationID': message.conversationId,
        //   },
        //   members,
        // ]);
        // Không dùng socket nữa mà dùng mqtt

        var data = jsonEncode([conversationId.toString(), messageId]);
        for (int i = 0; i < members.length; i++) {
          mqttClient.publishMessage('DeleteMessage_${members[i]}', data);
        }
      }
    });
  }

  /// TL 6/1/2024: Đơn giản hóa tham số gọi hàm
  Future<bool> recallMessage({
    required String messageId,
    required int conversationId,
  }) async {
    try {
      var res = await _client.fetch(
        ApiPath.recallMessage,
        data: {
          'MessageID': messageId,
          'ConversationID': conversationId,
        },
      );

      var members = (await ChatRepo().getChatItemModel(conversationId))!
          .memberList
          .map((e) => e.id)
          .toList();

      if (res.error?.code == 400) {
        BotToast.showText(text: 'Không thể xoá tin nhắn sau 24 giờ');
        return false;
      }
      if (!res.hasError && res.result == true) {
        // TL TODO: Sửa nội dung thành "Tin nhắn đã được thu hồi" liệu có ổn không?
        if (_messagesLocal.containsKey(conversationId)) {
          SocketSentMessageModel? msg;
          try {
            msg = _messagesLocal[conversationId]!
                .firstWhere((value) => value.messageId == messageId);
          } catch (e) {
            msg = null;
          }

          if (msg != null) {
            _messagesLocal[conversationId]!
                .removeWhere((element) => element.messageId == messageId);
            // msg.message = "Tin nhắn đã được thu hồi";
            // _messagesLocal[conversationId]!.add(msg);
            // logger.log("Thu hồi tin nhắn thành công", name: "$runtimeType");
          } else {
            // logger.log("Thu hồi tin nhắn thất bại", name: "$runtimeType");
          }
        }

        // Bắn tín hiệu đã xóa (vì nó khác gì thu hồi đâu) (ChatScreen bắt cái này)
        _controller.sink
            .add(ChatEventOnDeleteMessage(conversationId, messageId));

        // chatClient.emit(ChatSocketEvent.editMessage, [
        //   {
        //     'MessageID': message.messageId,
        //     'ConversationID': message.conversationId,
        //   },
        //   members,
        // ]);
        var data = jsonEncode(
            [conversationId.toString(), messageId, 'Tin nhắn đã được thu hồi']);
        for (int i = 0; i < members.length; i++) {
          mqttClient.publishMessage('EditMessage_${members[i]}', data);
        }
        return true;
      }

      return false;
    } catch (e) {
      BotToast.showText(text: 'Đã có lỗi xảy ra');
      return false;
    }
  }

  editMessage({
    required int conversationId,
    required String messageId,
    required String newMessage,
    // @Deprecated("Có cho cũng không dùng. members được tìm thẳng trong cache.")
    // List<int>? members,
  }) async {
    // throw CustomException();
    var res = await _client.fetch(
      ApiPath.editMessage,
      data: {
        'MessageID': messageId,
        'Message': newMessage,
        'ConversationID': conversationId,
      },
    );

    /// TL 23/2/2024: Chưa chắc code ở đây đã cần. Nhỡ MQTT bắn event về thì đã xử lí ở _emitChatEvent rồi
    res.onCallBack((_) {
      if (!res.hasError && res.result == true) {
        emitChatEvent(
            ChatEventOnMessageEditted(conversationId, messageId, newMessage));

        // không dùng socket nữa mà dùng mqtt
        // chatClient.emit(ChatSocketEvent.editMessage, [
        //   {
        //     "ConversationID": conversationId,
        //     "MessageID": messageId,
        //     "Message": message,
        //   },
        //   members,
        // ]);

        getConversationModel(conversationId).then((value) {
          if (value == null) {
            logger.log(
                "Không tìm thấy CTC $conversationId để bắn MQTT sửa tin nhắn.",
                name: "$runtimeType.editMessage");
            return;
          }
          var members = value.listMember.map((e) => e.id).toList();
          var data =
              jsonEncode([conversationId.toString(), messageId, newMessage]);
          for (int i = 0; i < members.length; i++) {
            mqttClient.publishMessage('EditMessage_${members[i]}', data);
          }
        });
      }
    });
  }

  // TL 16/1/2024:
  // Không cần dispose() làm gì, vì ChatRepo là Singleton. Vòng đời của nó
  // gắn liền vòng đời app. App chết thì để hệ điều hành dọn dẹp nó
  dispose() {
    _controller.close();
  }

  /// TL 11/1/2024:
  /// @chatId: ID của người mà mình muốn chat cùng
  /// @return: ConversationId của CTC giữa mình và @otherPersonId, hoặc null nếu không thể tạo được
  /// NOTE: Nếu chưa có cuộc trò chuyện [chatId] được tạo mới trên server
  Future<int?> getConversationId(int chatId) async {
    /// Mò trong local trước, xem có CTC giữa mình với họ không
    for (final conversation in _conversationListLocal.values) {
      if (conversation.isGroup == 0) {
        var otherPerson = conversation.firstMemberNot(AuthRepo().userId!);
        if (otherPerson != null && otherPerson.id == chatId) {
          return conversation.conversationId;
        }
      }
    }

    /// Nếu không thấy CTC nào với @otherPersonId ở local, thì gọi API thôi
    return ApiClient().fetch(
      ApiPath.resolveChatId,
      data: {
        'userId': AuthRepo().userId!,
        'contactId': chatId,
      },
    ).then((response) {
      if (response.hasError) {
        throw (Exception(response.error!.error));
      }
      var conversationId = int.tryParse(
          json.decode(response.data)['data']['conversationId'].toString());
      return conversationId;
    }).catchError((err, stack) {
      logger.log(
          "Không lấy được ID giữa mình và người dùng $chatId: ${err.toString()}",
          name: "$runtimeType.getConversationId");
      return null;
    });
  }

  emitAddFriend(int senderId, int chatId) =>
      chatClient.emit(ChatSocketEvent.requestAddFriend, {
        senderId,
        chatId,
      });

  /// TL 16/1/2024: Có cần phải bắn event tạo CTC mới không nhờ?
  /// tạo cuộc trò chuyện live với chả chat
  Future<RequestResponse> createLiveChatConversation(
    int senderId,
    int contactId,
    String? clientId,
    String? clientName,
    String? conversationName,
    String? fromWeb,
    int? fromConversation,
    int? status,
  ) {
    return ApiClient().fetch(
      ApiPath.createNewLivechat,
      data: {
        'senderId': senderId,
        'contactId': contactId,
        'clientId': clientId ?? 1,
        'conversationName': conversationName ?? '',
        'fromWeb': fromWeb ?? '',
        'fromConversation': fromConversation,
        'clientName': clientName,
        'Status': status,
      },
      retryTime: 2,
      options: Options(
        receiveTimeout: const Duration(milliseconds: 10000),
        sendTimeout: const Duration(milliseconds: 10000),
      ),
    );
  }

  Future<RequestResponse> updateStatusMessageLivechatApi2(
      int userId, String clientId, int conversationId, int status) {
    return ApiClient().fetch(ApiPath.updateStatusLivechat, data: {
      'userId': userId,
      'clientId': clientId,
      'status': status,
      'conversationId': conversationId,
    });
  }

  Future<RequestResponse> updateStatusMessageLivechatApi(
    int userId,
    String clientId,
    int conversationId,
  ) async {
    int status = clientId.contains('liveChatV2') ? 3 : 1;
    return ApiClient().fetch(ApiPath.updateStatusLivechat, data: {
      'userId': userId,
      'clientId': clientId,
      'status': status,
      'conversationId': conversationId,
    });
  }

  // trên web đếm s không cần đếm ở app trước đăng nhập
  // cái này không dùng gì cả luôn
  Future<RequestResponse> getTimeMissLivechat() {
    return ApiClient().fetch(ApiPath.getTimeMissLivechat);
  }

  Future<bool> responseAddFriend(
      int responseId, int requestId, FriendStatus status) async {
    // chatClient.emit(
    //   status == FriendStatus.accept
    //       ? ChatSocketEvent.acceptRequestAddFriend
    //       : ChatSocketEvent.declineRequestAddFriend,
    //   [responseId, requestId],
    // );
    // return true;
    RequestResponse? res;
    try {
      res = await _client.fetch(
        status == FriendStatus.accept
            ? ApiPath.acceptRequestAddFriend
            : ApiPath.decilineRequestAddFriend,
        data: {
          'userId': responseId,
          'contactId': requestId,
        },
      );
    } catch (e) {
      res = null;
    }
    if (res == null) return false;
    return res.onCallBack((_) {
      if (res!.result == true) {
        chatClient.emit(
          status == FriendStatus.accept
              ? ChatSocketEvent.acceptRequestAddFriend
              : ChatSocketEvent.declineRequestAddFriend,
          [responseId, requestId],
        );
      }
      return res.result == true;
    });
  }

  _onRequestAddFriend(int requestId, int receiveId) {
    var event = ChatEventOnFriendStatusChanged(
      requestId,
      receiveId,
      FriendStatus.request,
    );
    emitChatEvent(event);
  }

  void emitNameChanged(
    int id,
    String newNickName,
    bool isGroup,
    List<int> members,
  ) {
    if (isGroup) {
      chatClient.emit(
        ChatSocketEvent.changeGroupName,
        [id, newNickName, members],
      );
      ChatRepo().emitChatEvent(
          ChatEventOnGroupNameChanged(name: newNickName, conversationId: id));
    } else {
      chatClient.emit(
        ChatSocketEvent.changeNickName,
        [id, newNickName, navigatorKey.currentContext!.userInfo().id],
      );
      ChatRepo().emitChatEvent(
          ChatEventOnNickNameChanged(name: newNickName, userId: id));
    }
  }

  void emitChangeUserName(int id, String newName) {
    chatClient.emit(ChatSocketEvent.changeUserName, [id, newName]);
  }

  void emitChangeAvatarUser(
    int id,
    String avatar,
  ) {
    chatClient.emit(ChatSocketEvent.changeAvatarUser,
        [id, 'https://mess.timviec365.vn/avatarUser/$id/$avatar']);
  }

  // Remove locally saved conversation and cache for refreshing
  Future<void> refreshCachedConversations() async {
    _conversationListCache.clear();
    _conversationListLocal.clear();
    _conversationCacheTimestamp.clear();
    _allConversationsFetched = false;
    await HiveService().deleteConversationBoxes();
  }

  // Remove locally saved conversation and cache for refreshibng
  Future<void> refreshConversationMessages(int conversationId) async {
    _messagesCache.remove(conversationId);
    _messagesLocal.remove(conversationId);
    await saveAllMessagesToLocal();
  }

  /// TL 4/1/2024: Cái này phải để ở AuthRepo chứ -.-
  void logout(int id) {
    logger.log('Emit Logout: $id', name: ChatSocketEvent.logout);
    chatClient.emit(ChatSocketEvent.logout, id);
    _conversationListCache.clear();
    _conversationListLocal.clear();
    _messagesCache.clear();
    _messagesLocal.clear();
    _conversationCacheTimestamp.clear();
    _allConversationsFetched = false;
    HiveService().clearBoxToLogout();
  }

  void emitChangeAvatarGroup(
    int idConversation,
    String avatar,
    List<int> members,
  ) {
    chatClient.emit(ChatSocketEvent.changeGroupAvatar, [
      idConversation,
      'https://mess.timviec365.vn/avatarGroup/$idConversation/$avatar',
      members,
    ]);
  }

  pinMessage(
      int conversationId,
      String messageContent,
      Iterable<String> listMessageId,
      @Deprecated("Có cho cũng không dùng, do lấy members ngay trong cache")
      dynamic deprecatedArg) async {
    var allMembers = await getAllChatMembers(conversationId: conversationId);
    chatClient.emit(ChatSocketEvent.pinMessage, [
      conversationId,
      listMessageId.toString(),
      allMembers,
    ]);
    sendMessage(
      ApiMessageModel(
        messageId: GeneratorService.generateMessageId(currentUserId),
        conversationId: conversationId,
        senderId: currentUserId,
        message: '$currentUserId pinned a message: $messageContent',
        type: MessageType.notification,
      ),
      recieveIds: allMembers.map((e) => e.id).toList(),
    );

    _client.fetch(ApiPath.pinMessage, data: {
      'conversationId': conversationId,
      'listpinId': listMessageId.toString(),
    });

    /// TODO: Tìm cách bắn signal ghim tin nhắn
  }

  int get currentUserId =>
      navigatorKey.currentContext?.userInfo().id ?? userInfo!.id;

  //Bỏ ghim vẫn dùng api ghim truyền lên listmessId mới
  unPinMessage(int conversationId, String messageContent,
      Iterable<String> listMessageId, List<int> members) async {
    // chatClient.emit(
    //     ChatSocketEvent.unPinMessage, [conversationId, members, listMessageId]);
    chatClient.emit(ChatSocketEvent.unPinMessage, [
      conversationId,
      listMessageId.toString(),
      members,
    ]);
    sendMessage(
      ApiMessageModel(
        messageId: GeneratorService.generateMessageId(currentUserId),
        conversationId: conversationId,
        senderId: currentUserId,
        message: '$currentUserId unpinned a message: $messageContent',
        type: MessageType.notification,
      ),
      recieveIds: members,
    );
    _client.fetch(ApiPath.pinMessage, data: {
      'conversationId': conversationId,
      'listpinId': listMessageId.toString(),
    });

    /// TODO: Tìm cách bắn signal bỏ ghim tin nhắn
  }

  //bookmark message
  bookmarkMessage(int conversationId, String messageContent, String messageId,
      List<int> members) async {
    chatClient.emit(ChatSocketEvent.bookmarkMessage, [
      conversationId,
      messageId,
      members,
    ]);
    _client.fetch(ApiPath.bookmarkMessage, data: {
      'UserId': currentUserId,
      'ConversationId': conversationId,
      'MessageId': messageId,
    });
  }

  //unbookmark message
  unBookmarkMessage(
      int conversationId, String messageContent, List<int> members) async {
    chatClient
        .emit(ChatSocketEvent.unBookmarkMessage, [conversationId, members]);
    _client.fetch(
      ApiPath.unBookmarkMessage,
      data: {
        'conversationId': conversationId,
      },
    );
  }

  void emitDeleteMember(
    int chatId,
    int deleteMemberId,
    int adminId,
    List<int> members,
    String? deleteMemberName, [
    int? newAdminId,
  ]) {
    chatClient.emit(ChatSocketEvent.outGroup, [
      chatId, deleteMemberId, newAdminId ?? 0, members,
      // WIO.EmitAsync("OutGroup", conversationId, userId, adminId, listMember);
    ]);
    //sv chặn tin nhắn từ những người không thuộc cuộc trò chuyện
    //nên sau khi rời nhóm không thể tự bắn tin thông báo mình rời nhóm được
    // adminId đang là userId của mình
    sendMessage(
      ApiMessageModel(
        messageId: GeneratorService.generateMessageId(deleteMemberId),
        conversationId: chatId,
        senderId: (adminId != deleteMemberId)
            ? adminId
            : (members.where((e) => e != deleteMemberId)).first,
        message: adminId == deleteMemberId
            ? '$deleteMemberName đã rời khỏi cuộc trò chuyện'
            : '$adminId has removed $deleteMemberId from this conversation',
        type: MessageType.notification,
      ),
      recieveIds: members,
    );

    _controller.sink.add(ChatEventOnOutGroup(chatId, deleteMemberId, adminId));
  }

  void emitDeleteContact(int userId, int chatId) {
    chatClient.emit(
      ChatSocketEvent.deleteContact,
      {userId, chatId},
    );
  }

  void emitChangeHidenconversationStatus(
    int userId,
    int conversationId,
    int hideStatus,
  ) {
    chatClient.emit(
      ChatSocketEvent.hiddenConversation,
      [userId, conversationId, hideStatus],
    );
  }

  /// TL 18/1/2024: Bưng từ ChatConversationBloc, có chỉnh sửa, bổ sung
  ///
  /// Đổi trạng thái yêu thích của CTC.
  ///
  /// Nếu muốn bắt sự thay đổi trạng thái yêu thích, dùng ChatRepo().stream.listen() bắt event ChatEventOnChangeFavoriteStatus
  ///
  /// @conversationId: ID CTC
  ///
  /// @favourite: Trạng thái mới. Yêu thích: 1, bình thường: 0
  Future<void> changeFavoriteStatus({
    required int conversationId,
    required bool favorite,
  }) async {
    await ApiClient()
        .fetch(ApiPath.toogleFavoriteChat,
            data: {
              'conversationId': conversationId,
              'senderId': AuthRepo().userId!,
              'isFavorite': favorite ? 1 : 0,
            },
            method: RequestMethod.post)
        .then((res) async {
      if (res.hasError) {
        throw (Exception(res.error!.error));
      }

      var conversationModel = (await getConversationModel(conversationId))!;
      conversationModel.isFavorite = favorite;
      setConversationModel(conversationModel);

      /// Không hiểu sao phải emit là mình đã favourite CTC cho những người khác
      /// Nhưng oke. Code cũ thì cứ để đấy, tránh gãy
      chatClient.emit(
        ChatSocketEvent.changeFavoriteConversationStatus,
        [AuthRepo().userId!, conversationId, favorite ? 1 : 0],
      );
    }).catchError((e) {
      logger.log(
          "Sửa trạng thái yêu thích CTC $conversationId thất bại. Lỗi: ${e.toString()}",
          name: "ChatRepo");
    });
  }

  /// cập nhật trạng thái livechat bắn lên socket và bắt tin nhắn
  Future<void> updateStatusMessageLivechatSocket(
      int conversationId,
      String messageId,
      List<int>? listmembers,
      InfoSupport? infoSupports,
      int senderId,
      LiveChat? liveChat,
      {ChatBloc? chatBloc}) async {
    String clientId = liveChat?.clientId ?? '';
    infoSupports?.status = clientId.contains('liveChatV2') ? 3 : 1;

    // if (livechatDebugging) {
    //   logger.log("Đã bắn socket",
    //       name: "$runtimeType.updateStatusMessageLivechatSocket");
    // } else {
    chatClient.emit(
      ChatSocketEvent.updateStatusMessageSupport,
      [
        conversationId,
        messageId,
        listmembers,
        json.encode(infoSupports?.toMap()),
      ],
    );
    // }

    // Tự giác emit do ChatClient.emit không tự bắn tin nhắn cho chính nó
    // Event này có ý nghĩa để khiến ChatConversationBody refresh lại
    if (infoSupports != null) {
      UnifiedRealtimeDataSource().emitChatEvent(
          ChatEventOnUpdateStatusMessageSupport(
              conversationId: conversationId,
              messageId: messageId,
              infoSupport: infoSupports));
    }
  }

  void deleteLivechatMessage(SocketSentMessageModel msg) {
    var conversationId = msg.conversationId;
    var messageId = msg.messageId;

    // Nếu sau khi xóa tin nhắn mà CTC Livechat hết tin nhắn, thì xóa luôn CTC
    if (loadMessagesSync(conversationId: conversationId, range: 9999).length <=
        1) {
      logger.log("Xóa CTC", name: "ChatRepo");
      deleteConversation(conversationId);

      logger.log(
          "CTC ${conversationId}: ${loadMessagesSync(conversationId: conversationId).map((e) => e.message).toList().toString()}",
          name: "ChatRepo");
    } else {
      _messagesCache[conversationId]
          ?.removeWhere((msg) => msg.messageId == messageId);
      _messagesLocal[conversationId]
          ?.removeWhere((msg) => msg.messageId == messageId);

      logger.log(
          "Xóa tin nhắn. Còn ${loadMessagesSync(conversationId: conversationId, range: 999).length} tin nhắn",
          name: "$runtimeType.deleteLivechatMessage");

      // Sửa thông tin trên ConversationModel nếu nhỡ không may tin nhắn bị xóa
      // là tin nhắn mới nhất của CTC này
      var conversationModel = getConversationModelSync(conversationId);
      if (conversationModel != null &&
          conversationModel.messageId == messageId) {
        var newLatestMsg =
            loadMessagesSync(conversationId: conversationId, range: 1)
                .firstOrNull;
        if (newLatestMsg != null) {
          _updateLatestMessageToConversationModel(newLatestMsg);
        }
      }

      saveMessagesToLocal(conversationId);
    }
  }

  Future<Set<int>?> getUnreadConversationIds() async {
    try {
      var res = await ApiClient().fetch(
        ApiPath.unreadConversation,
        data: {
          'userId': currentUserId,
        },
      );
      return res.onCallBack(
        (_) => Set<int>.from(
            json.decode(res.data)['data']['listConversation'] ?? []),
      );
    } catch (e, s) {
      logger.logError(e, s);
      return null;
    }
  }

  /// tạo nhắc hẹn
  Future<RequestResponse> createCalendar({
    required int senderId,
    required int conversationId,
    required String title,
    required String createTime,
    required String type,
    String? typeDate,
    int? emotion,
  }) {
    return ApiClient().fetch(
      ApiPath.createCalendar,
      data: {
        'senderId': senderId,
        'conversationId': conversationId,
        'title': title,
        'createTime': createTime,
        'type': type,
        'typeDate': typeDate ?? 'solarCalendar',
        'emotion': emotion ?? 1,
      },
      retryTime: 2,
      options: Options(
        receiveTimeout: const Duration(milliseconds: 10000),
        sendTimeout: const Duration(milliseconds: 10000),
      ),
    );
  }

  /// chỉnh sửa nhắc hẹn
  Future<RequestResponse> editCalendar({
    required String idMess,
    required String title,
    required String type,
    String? typeDate,
    int? emotion,
    required String createTime,
  }) {
    return ApiClient().fetch(
      ApiPath.editCalendar,
      data: {
        '_id': idMess,
        'title': title,
        'type': type,
        'emotion': emotion ?? 1,
        'typeDate': typeDate ?? 'solarCalendar',
        'createTime': createTime,
      },
      retryTime: 2,
      options: Options(
        receiveTimeout: const Duration(milliseconds: 10000),
        sendTimeout: const Duration(milliseconds: 10000),
      ),
    );
  }

  /// xóa lịch hẹn
  Future<RequestResponse> deleteCalendar({required String id}) {
    return ApiClient()
        .fetch(ApiPath.deleteCalendar + id, method: RequestMethod.delete);
  }

  /// Lấy chi tiết lịch hẹn
  Future<RequestResponse> getDetailCalendar({required String id}) {
    return ApiClient()
        .fetch(ApiPath.getDetailCalendar + id, method: RequestMethod.get);
  }

  /// bình chọn tham gia
  Future<RequestResponse> handleParticipantCalendar({
    required String Id,
    required int userId,
    required String type,
  }) {
    return ApiClient().fetch(
      ApiPath.handleParticipantCalendar,
      data: {
        '_id': Id,
        'userId': userId,
        'type': type,
      },
      retryTime: 2,
      options: Options(
        receiveTimeout: const Duration(milliseconds: 10000),
        sendTimeout: const Duration(milliseconds: 10000),
      ),
    );
  }

  // Lấy lịch hẹn của một người trong cuộc trò chuyện

  // Future<List<Reminder>> getAllCalendarOfConv(
  //     {required int conversationId}) async {
  //   final RequestResponse res = await _client.fetch(
  //     ApiPath.getAllCalendarOfConv,
  //     data: {'conversationId': conversationId},
  //     retryTime: 4,
  //     options: Options(
  //       receiveTimeout: Duration(milliseconds: 7000),
  //     ),
  //   );
  //   if (res.hasError) return [];
  //   return (json.decode(res.data)['data']['result'] as List)
  //       .map((e) => Reminder.fromJson(e))
  //       .toList();
  // }

  //Lấy tất cả lịch hẹn của một người
  Future<RequestResponse> getAllCalendarOfUser({required int userId}) {
    return ApiClient()
        .fetch(ApiPath.getAllCalendarOfUser, data: {'userId': userId});
  }

  // cơ chế mới không tạo nhóm mới mà chỉ đổi type
  Future<RequestResponse> createNewSecretConversation(
      int chatId, String typeGroup, List<int> members) {
    chatClient.emit(ChatSocketEvent.createSecretConversation, [
      chatId,
      members,
      typeGroup,
    ]);

    return ApiClient().fetch(
      ApiPath.createNewSecretConversation,
      data: {
        'userId': navigatorKey.currentContext!.userInfo().id,
        'conversationId': chatId,
        'typeGroup': typeGroup,
      },
    );
  }

  //setup thời gian xóa
  Future<RequestResponse> updateDeleteTime(
      {required int conversationId,
      required int deleteTime,
      required List<int> userId,
      required List<int> members}) {
    chatClient.emit(ChatSocketEvent.updateDeleteTime,
        [conversationId, members, deleteTime, userId]);
    //updateDeleteTime
    return ApiClient().fetch(ApiPath.updateDeleteTime, data: {
      'UserId': jsonEncode(userId),
      'ConversationId': conversationId,
      'DeleteTime': deleteTime,
    });
  }

  Future<RequestResponse> deleteMessageSecret(
      {required int conversationId,
      required int deleteTime,
      required List<String> messageIds}) {
    return ApiClient().fetch(ApiPath.deleteMessageSecret, data: {
      'ListMessId': messageIds.toString().replaceAll(' ', ''),
      'conversationId': conversationId,
      'deleteTime': deleteTime,
    });
  }

  // lấy danh sách tài khoản phân quyền, gọi lấy luôn cho chắc chứ vừa mở app ai gọi gì check được
  Future<List<int>> takeDataUserSharePermission(int userId) async {
    var res = await ApiClient()
        .fetch(ApiPath.takeDataUserSharePermission, data: {'userId': userId});
    if (res.hasError) return [];
    List<IUserInfo> listUserInfo =
        (json.decode(res.data)['data']['listUser'] as List)
            .map((e) => IUserInfo.fromJson(e))
            .toList();
    return listUserInfo.map((e) => e.id).toList();
  }

  pushNotificationFirebase(
      {required List receiveId,
      required int convId,
      String message = '',
      required String conversationName,
      String? data,
      int? callType}) async {
    // var uId = int.tryParse(event.messageId.split('_').last);
    // if (uId == event.userId || !event.allMemberIdsInConversation.contains(uId)) return;
    var body = {
      'IdReceiver': jsonEncode(receiveId),
      'conversationId': convId,
      'sendername': AuthRepo().userName,
      'ava': (AuthRepo().userInfo?.avatar ?? 'qqq').toString(),
      'mess': message,
      'type': 'text',
      'idSender': AuthRepo().userId,
      'mask': 1,
      'conversationName': conversationName,
      'data': data,
      'callType': callType
    };

    await _client.fetch(ApiPath.PUSH_NOTIFICATION_FIREBASE,
        data: body, method: RequestMethod.post);
  }

  Future<RequestResponse> getLinkFile(
    File file,
    ValueNotifier<double>? progress,
  ) async {
    List<MultipartFile> multiFile = [];
    multiFile.add(await MultipartFile.fromFile(file.path));
    return await ApiClient().upload(
      ApiPath.uploadFile,
      multiFile,
      progressListener: progress,
    );
  }

  // rời khỏi cuộc trò chuyện
  Future<RequestResponse> leaveGroupChat(
    int conversationId,
    int senderId,
  ) async {
    logger.log("Out CTC livechat nhé", name: "$runtimeType.ChatRepo");
    return await ApiClient().fetch(ApiPath.leaveGroup, data: {
      'conversationId': conversationId,
      'senderId': senderId,
      'adminId': 0,
    });
  }

  /// @groupKind:
  /// - GroupConversationCreationKind.public với nhóm thường
  /// - GroupConversationCreationKind.needModeration với nhóm kiểm duyệt
  ///
  /// @name: Tên cuộc trò chuyện
  /// @memberIds: ID của tất cả những người trong cuộc trò chuyện (bao gồm
  /// cả người tạo) (memberIds.size() phải >= 2)
  ///
  /// @return: ID cuộc trò chuyện nhóm khi tạo thành công
  Future<int> createGroup({
    required GroupConversationCreationKind groupKind,
    required String name,
    required List<int> memberIds,
    int? memberApproval,
  }) async {
    try {
      var userId = navigatorKey.currentContext!.userInfo().id;

      final resolvedMemberIds = [...memberIds];

      final RequestResponse res = await _client.fetch(
        ApiPath.createGroupChat,
        data: {
          'senderId': userId,
          'typeGroup': groupKind.serverName,
          'conversationName': name,
          'memberList': resolvedMemberIds.toString(),
          'memberApproval': memberApproval
        },
      );

      if (res.hasError) throw res.error!.messages!;

      final id =
          json.decode(res.data)['data']['conversation_info']['conversationId'];

      return id;
    } catch (e) {
      rethrow;
    }
  }

  // VVVVVVVVVV LƯU THÔNG TIN CUỘC TRÒ CHUYỆN LOCAL DƯỚI NÀY VVVVVVVVVVVV

  /// Flag đánh dấu mình đã lấy hết sạch danh sách cuộc trò chuyện
  bool _allConversationsFetched = false;

  /// Trả về danh sách nhiều nhất [count] CTC, sắp xếp theo thứ tự ưu tiên sau, lần lượt:
  /// - Những CTC yêu thích - Những CTC thường
  /// - Thời gian tin nhắn cuối cùng từ gần nhất đến xa nhất.
  ///
  /// Mô tả:
  /// 1. Nếu có mạng và cache chưa đủ @count CTC:
  /// 1.1. Tải API
  /// 1.2. Lưu thông tin mới vào local
  /// 1.3. Gọi loadListMessage() cho những CTC mới về cache
  /// 2. Nếu không có mạng: Lục tìm local trả về
  Future<Iterable<ConversationModel>> getConversationList({
    int count = 20,
  }) async {
    logger.log("Đòi danh sách $count cuộc trò chuyện.",
        name: "$runtimeType.getConversationList");
    logger.log("${networkCubit.state.hasInternet} && ${!networkCubit.state.socketDisconnected} && ${_conversationListCache.length < count} && ${!_allConversationsFetched}",
        name: "$runtimeType.getConversationList");

    // Những CTC cần gọi loadListMessage()
    Set<int> conversationsNeedLoadListMessages = {};
    try {
      if (networkCubit.state.hasInternet &&
          !networkCubit.state.socketDisconnected &&
          _conversationListCache.length < count) {
        logger.log("Tải API danh sách CTC, đồng bộ với server",
            name: "$runtimeType.getConversationList");

        while (_conversationListCache.length < count) {
          var cacheListLengthBeforeAdd = _conversationListCache.length;

          RequestResponse response = await _getConversationList(loadedCount: _conversationListCache.length);
            try {
              if (response.hasError) {
                throw (Exception(response.error!.error));
              }
              var conversationList = _parseConversationListApiData(response.data);

              logger.log(
                  "Gọi API lấy danh sách ${conversationList.length} CTC thành công",
                  name: "$runtimeType.getConversationList");

              // Mình giả sử mình đã tải sạch các cuộc trò chuyện.
              // Rồi sẽ check xem giả sử có đúng không.
              _allConversationsFetched = true;
              for (final conversationModel in conversationList) {
                if (getConversationModelSync(conversationModel.conversationId) ==
                    null) {
                  _allConversationsFetched = false;
                }
                setConversationModel(conversationModel, saveToLocal: false);
              }
              await saveConversationListToLocal();

              conversationsNeedLoadListMessages
                  .addAll(conversationList.map((e) => e.conversationId));
            } catch (e, s) {
              logger.logError(
              "Lỗi gọi API đồng bộ danh sách CTC: ${e.toString() + s.toString()}",
              null,
              "$runtimeType.getConversationList");
            }
            

          if (_conversationListCache.length - cacheListLengthBeforeAdd == 0) {
            logger.log("Không tải thêm được CTC nào, dừng.",
                name: "$runtimeType.getConversationList");
            break;
          }
        }
      }
    } catch (err, stack) {
      logger.logError("Lỗi xảy ra khi gọi API: $err", stack,
          "$runtimeType.getConversationList");
    }

    try {
      /// 3. Gọi loadListMessage một lần duy nhất cho tất cả các CTC được thêm mới
      loadListMessage(conversationIds: conversationsNeedLoadListMessages);
    } catch (err, stack) {
      logger.logError("Lỗi xảy ra khi tải tin nhắn: $err", stack,
          "$runtimeType.getConversationList");
    }

    /// 4. Sắp xếp các CTC theo thời gian tin nhắn cuối cùng gần hiện tại nhất,
    /// trả về nhiều CTC nhất có thể, không vượt quá @count

    var conversations = _conversationListLocal.values.toList();

    var favouriteConversations =
        conversations.where((element) => element.isFavorite);

    var nonFavouriteConversations = conversations.where(
      (element) => !element.isFavorite,
    );

    var result = [
      ...sortedByLastMessagesTime(favouriteConversations),
      ...sortedByLastMessagesTime(nonFavouriteConversations)
    ].slice(end: count).map((e) => getConversationModelSync(e.conversationId)!);

    logger.log("Trả về danh sách ${result.length} CTC.",
        name: "$runtimeType.getConversationList");
    return result;
  }

  Iterable<ConversationModel> sortedByLastMessagesTime(
      Iterable<ConversationModel> conversations) {
    var convs = conversations.toList();
    convs.sort((a, b) => b.timeLastMessage.compareTo(a.timeLastMessage));
    return convs;
  }

  Future<RequestResponse> _getConversationList({int loadedCount = 0}) async {
    return await ApiClient().fetch(ApiPath.chatList, data: {
      'userId': AuthRepo().userInfo!.id,
      //'countConversation': from + count,
      'countConversationLoad': loadedCount,
      'companyId': AuthRepo().userInfo?.companyId ?? 0,
    });
  }

  /// Dùng để parse data trả về từ API GetListConversation_V3
  /// NOTE: GetListConversation_V3 là API mới, nhưng đang bị đần hóa về ChatItemModel
  /// Thực ra cũng chả biết có đần hơn hay không. Cơ mà sửa phát mệt
  Iterable<ConversationModel> _parseConversationListApiData(
      String getListConversationData) {
    return List<Map<String, dynamic>>.from(
            json.decode(getListConversationData)["data"]["listCoversation"])
        .map((e) => ConversationModel.fromApiJson(e));
  }

  /// Sửa thông tin CTC [conversation.conversationId], và lưu vào local
  void setConversationModel(ConversationModel conversation,
      {bool saveToLocal = true}) {
    _conversationListCache[conversation.conversationId] = conversation;
    if (saveToLocal) {
      saveConversationListToLocal();
    }
  }

  /// Trả về thông tin chung của cuộc trò chuyện có @conversationId
  @Deprecated(
      "Dùng getConversationModel(), để đảm bảo nguyên tắc SOLID của OOP nhé.")
  Future<ChatItemModel?> getChatItemModel(int conversationId) async {
    return (await getConversationModel(conversationId))?.toChatItemModel();
  }
  // IMPORTANT: Hàm này CHỈ lấy data có sẵn ở trong cache, để lấy data bằng API dùng getConversationModel
  ConversationModel? getConversationModelSync(int conversationId) {
    return _conversationListCache[conversationId] ??
        _conversationListLocal[conversationId];
  }

  Future<ConversationModel?> getConversationModel(int conversationId) async {
    var currentUserId = AuthRepo().userInfo!.id;
    bool isCacheStale = false;
    if (_conversationCacheTimestamp[conversationId] == null) {
      _conversationCacheTimestamp[conversationId] = _chatRepoCreationTimestamp;
    } 
    DateTime? lastUpdated = _conversationCacheTimestamp[conversationId];
    if (DateTime.now().difference(lastUpdated??_chatRepoCreationTimestamp).inMinutes > 5) {
      isCacheStale = true;
    }
    
    // Cập nhật thông tin từ server nếu chưa đồng bộ và có mạng
    if ((!_conversationListCache.containsKey(conversationId)||isCacheStale) &&
        networkCubit.state.hasInternet &&
        !networkCubit.state.socketDisconnected) {
      logger.log("Tải API đồng bộ thông tin CTC $conversationId.",
          name: "$runtimeType.getConversationModel");
      await _client.fetch(
        ApiPath.chatInfo,
        data: {
          'conversationId': conversationId,
          'senderId': currentUserId,
        },
      ).then((response) {
        if (response.hasError) {
          throw (Exception(response.error!.error));
        }
        _conversationCacheTimestamp[conversationId] = DateTime.now();
        var chatItemModel = ChatItemModel.fromConversationInfoJsonOfUser(
          currentUserId,
          conversationInfoJson: json.decode(response.data)["data"]
              ["conversation_info"],
        );

        var conversationModel =
            ConversationModel.fromChatItemModel(chatItemModel);

        // Đánh dấu lấy thông tin CTC từ API thành công
        // Cập nhật thông tin mới vào local
        setConversationModel(conversationModel);
        logger.log(
            "Cập nhật thông tin CTC $conversationId (${conversationModel.conversationName}) thành công.",
            name: "$runtimeType.getConversationModel");
      }).catchError((err) {
        logger.logError(
            "Gọi API thông tin CTC $conversationId gặp lỗi: ${err.toString()}",
            null,
            "$runtimeType.getConversationModel");
      });
    }

    var conversationModel = getConversationModelSync(conversationId);
    if (conversationModel != null) {
      logger.log(
          "Trả về thông tin CTC $conversationId (${conversationModel.conversationName})",
          name: "$runtimeType.getConversationModel");
    } else {
      logger.log("Không tìm thấy thông tin CTC $conversationId",
          name: "$runtimeType.getConversationModel");
    }
    return conversationModel;
  }

  void deleteConversation(int conversationId) {
    _conversationListCache.remove(conversationId);
    _conversationListLocal.remove(conversationId);
    _messagesCache.remove(conversationId);
    _messagesLocal.remove(conversationId);
    for (var box in [
      HiveService().conversationListBox,
      HiveService().locallySavedMessages
    ]) {
      try {
        box!.delete(conversationId);
      } catch (err, stack) {
        logger.logError("Không xóa được CTC $conversationId: $err", stack,
            "$runtimeType.deleteConversation");
      }
    }
  }

  /// Trả về ChatItemModel trong local
  // @Deprecated(
  //     "ChatItemModel nên bị deprecate thành ConversationModel để đảm bảo nguyên tắc SOLID của OOP. Dùng getConversationModelSync() nhé.")
  ChatItemModel? getChatItemModelSync(int conversationId) {
    return (_conversationListCache[conversationId] ??
            _conversationListLocal[conversationId])
        ?.toChatItemModel();
  }

  /// Lưu _conversationListLocal vào local
  Future<void> saveConversationListToLocal() async {
    // Lưu ý là Map.addAll sẽ ghi đè những thông tin từ cache lên local. Như thế là đúng.
    _conversationListLocal.addAll(_conversationListCache);

    List<String> conversationListJsons = _conversationListLocal.values
        .map((e) => jsonEncode(e.toJson()))
        .toList();

    try {
      var userId = AuthRepo().userInfo?.id;
      await HiveService()
          .conversationListBox!
          .put(userId, jsonEncode(conversationListJsons));

      logger.log("Đã xong", name: "$runtimeType.saveConversationListToLocal");
    } catch (err, stack) {
      logger.logError(
          "Lỗi: ${err}", stack, "$runtimeType.saveConversationListToLocal");
    }
  }

  /// TL 26/12/2023:
  ///
  /// Trả về danh sách [range] tin nhắn từ gần nhất -> xa nhất của CTC [conversationId] trong local.
  ///
  /// Note 1: Danh sách có thể ngắn hơn range nếu cuộc trò chuyện không dài đến thế.
  ///
  /// Note 2: Trả về tin nhắn lưu local nếu không có kết nối mạng
  Future<Iterable<SocketSentMessageModel>> loadMessages(
      {required int conversationId, int range = 15}) async {
    // Tải thêm tin nhắn API khi thỏa mãn:
    // - Chưa tải hết sạch sành sanh tin nhắn CTC
    // - Có mạng
    // - Mình chưa có đủ tin nhắn @range yêu cầu
    logger.log("$conversationId ${_messagesCache[conversationId]?.length}", name: "CacheLength");
    if (!_conversationsFetchedAllMessages.contains(conversationId) &&
        networkCubit.state.hasInternet &&
        !networkCubit.state.socketDisconnected &&
        _cleanMessages(_messagesCache[conversationId] ?? []).length < range) {
      await _loadMessagesApi(conversationId: conversationId, range: range);
    }
    var returnedMessages =
        _loadMessagesLocal(conversationId: conversationId, range: range);

    logger.log(
        "Đòi $range tin nhắn từ CTC $conversationId. Trả ${returnedMessages.length} cái.",
        name: "$runtimeType.loadMessages");

    return returnedMessages;
  }

  /// Trả về danh sách [range] tin nhắn từ gần nhất -> xa nhất của CTC [conversationId] trong local.
  Iterable<SocketSentMessageModel> _loadMessagesLocal(
      {required int conversationId, required int range}) {
    return _cleanMessages(_messagesLocal[conversationId] ?? [])
        .toList()
        .slice(end: range);
  }

  /// Đồng bộ @range tin nhắn từ gần nhất -> xa nhất từ server về local và cache.
  Future<void> _loadMessagesApi(
      {required int conversationId, required int range}) async {
    logger.log(
        "Tải API tin nhắn CTC $conversationId. Trong cache đang có: ${_messagesCache[conversationId]?.length} tin nhắn",
        name: "$runtimeType._loadMessagesApi");

    await _loadMessages(
            conversationId: conversationId,
            loadedMessages: _messagesCache[conversationId]?.length ?? 0)
        .then((apiMessages) async {
      // Đây là trường hợp cuộc trò chuyện rỗng
      if (apiMessages.isEmpty) {
        logger.log("Không tải ra tin nhắn mới. Dừng",
            name: "$runtimeType._loadMessagesApi");
        _conversationsFetchedAllMessages.add(conversationId);
        return;
      }

      if (!_messagesCache.containsKey(conversationId)) {
        _messagesCache[conversationId] = SplayTreeSet(_localMessageOrder);
      }

      var lengthBeforeAdd = _messagesCache[conversationId]!.length;
      _messagesCache[conversationId]!.removeAll(apiMessages);
      _messagesCache[conversationId]!.addAll(apiMessages);
      var lengthDiff = _messagesCache[conversationId]!.length - lengthBeforeAdd;

      logger.log("Thêm $lengthDiff tin nhắn",
          name: "$runtimeType._loadMessagesApi");
      // Đây là trường hợp đã tải hết CTC. API thay vì trả về rỗng,
      // thì vẫn trả về những tin nhắn cuối cùng của CTC
      if (lengthDiff == 0) {
        logger.log("Không tải ra tin nhắn mới. Dừng",
            name: "$runtimeType._loadMessagesApi");
        _conversationsFetchedAllMessages.add(conversationId);
        return;
      }

      // Nếu chưa đủ @range yêu cầu, và mình vẫn chưa tải hết CTC, thì mình tải tiếp
      if (!_conversationsFetchedAllMessages.contains(conversationId) &&
          _cleanMessages(_messagesCache[conversationId] ?? []).length < range) {
        await _loadMessagesApi(conversationId: conversationId, range: range);
      }
      // Nếu đã tải đủ / tải hết tin nhắn thì tiến hành đồng bộ
      else {
        saveMessagesToLocal(conversationId);
      }
    }).catchError((err) {
      logger.log("Tải CTC gặp lỗi: ${err.toString()}",
          name: "$runtimeType._loadMessagesApi");
    });
  }

  /// Giống loadMessages(), nhưng chỉ trả về danh sách tin nhắn trong local + cache.
  ///
  /// Trả về Iterable rỗng nếu không tồn tại cuộc trò chuyện trong local + cache.
  Iterable<SocketSentMessageModel> loadMessagesSync(
      {required int conversationId, int range = 15}) {
    var result = SplayTreeSet(_localMessageOrder);

    // Ưu tiên thông tin cache trước, vì thông tin cache mới hơn
    result.addAll(_messagesCache[conversationId] ?? []);
    if (result.length >= range) {
      return result.take(range);
    }

    // Sau đấy bồi thêm thông tin local cho đủ
    result.addAll((_messagesLocal[conversationId]?.toList() ?? [])
        .where((message) => !result.contains(message)));

    return result.take(range);
  }

  /// Trả về tin nhắn [messageId] ở CTC [conversationId] nếu có trong local.
  SocketSentMessageModel? getMessage(
      {required int conversationId, required String messageId}) {
    return _messagesCache[conversationId]
            ?.where((element) => element.messageId == messageId)
            .firstOrNull ??
        _messagesLocal[conversationId]
            ?.where((element) => element.messageId == messageId)
            .firstOrNull;
  }

  /// Sửa tin nhắn [newMsg] vào trong local.
  /// ID CTC và ID tin nhắn sẽ được lấy luôn trong [newMsg].
  ///
  /// Nếu không tồn tại tin nhắn được sửa ở local thì... Chả có gì xảy ra.
  void setMessage(SocketSentMessageModel newMsg) {
    var conversationId = newMsg.conversationId;
    var messageId = newMsg.messageId;
    if (getMessage(conversationId: conversationId, messageId: messageId) ==
        null) {
      return;
    }

    _messagesCache[conversationId]!
        .removeWhere((element) => element.messageId == messageId);
    _messagesCache[conversationId]!.add(newMsg);
    saveMessagesToLocal(conversationId);
  }

  Future<void> saveAllMessagesToLocal() async {
    await Future.wait(_messagesCache.keys
        .map((conversationId) => saveMessagesToLocal(conversationId)));
    logger.log("Đã xong.", name: "$runtimeType.saveAllMessagesToLocal");
  }

  Future<void> saveMessagesToLocal(int conversationId) async {
    var localMsgs = _messagesLocal[conversationId];
    var cacheMsgs = _messagesCache[conversationId];
    if (localMsgs == null) {
      _messagesLocal[conversationId] = SplayTreeSet(_localMessageOrder);
      localMsgs = _messagesLocal[conversationId];
    }
    if (cacheMsgs != null) {
      localMsgs!.addAll(cacheMsgs);
    }
    var messagesToSave = localMsgs!;
    // logger.log("Lưu ${messagesToSave.length} tin nhắn vào local.",
    //     name: "$runtimeType.saveMessagesToLocal");
    await HiveService().locallySavedMessages!.put(
        conversationId,
        jsonEncode(messagesToSave
            .map((element) => element.toHiveObjectMap())
            .toList()));
  }

  /// Sắp xếp tin nhắn local theo thời gian tạo (gần nhất -> xa nhất) và messageId.
  /// Dùng cho cache
  static int _localMessageOrder(
      SocketSentMessageModel msgA, SocketSentMessageModel msgB) {
    var orderedByTime = msgB.createAt.compareTo(msgA.createAt);
    if (orderedByTime != 0) {
      return orderedByTime;
    }
    return msgB.messageId.compareTo(msgA.messageId);
  }

  /// TL 26/12/2023:
  ///
  /// Tải tin nhắn của một cuộc trò chuyện.
  ///
  /// Đây là hàm gọi API cho loadMessages().
  /// Chắc đồng chí muốn dùng cái đấy chứ không phải cái này đâu.
  ///
  /// @conversationId: Id cuộc trò chuyện
  ///
  /// @loadedMessages: Tổng số tin nhắn đã load
  ///
  /// @totalMessages: Tổng số tin nhắn của CTC. Không biết để làm gì
  ///
  /// @adminId: Id admin CTC nhóm. Không biết để làm gì
  Future<Iterable<SocketSentMessageModel>> _loadMessages({
    required int conversationId,
    required int loadedMessages,
    int? adminId,
    int? totalMessages,
  }) async {
    return await ApiClient()
        .fetch(
      ApiPath.loadMessage,
      data: {
        "conversationId": conversationId,
        "listMess": loadedMessages,
        if (adminId != null) "adminId": adminId,
        if (totalMessages != null) "countMessage": totalMessages,
      },
      options: Options(
        receiveTimeout: const Duration(milliseconds: 9000),
      ),
    )
        .then((response) {
      if (response.hasError) {
        throw Exception(response.error!.error);
      }

      var data = jsonDecode(response.data);
      return (data["data"]["listMessages"] as List)
          .map((element) => SocketSentMessageModel.fromMap(element));
    }).catchError((err) {
      logger.logError(
          "Gặp lỗi khi gọi API tải CTC $conversationId: ${err.toString()}",
          null, // StackTrace.current,
          "$runtimeType._loadMessages");
      throw Exception(e.toString());
    });
  }

  /// TL 16/1/2023
  ///
  /// Cập nhật những tin nhắn gần nhất của nhiều cuộc trò chuyện vào cache và local.
  ///
  /// @conversationIds: Id các cuộc trò chuyện
  void loadListMessage({
    required Iterable<int> conversationIds,
  }) {
    if (conversationIds.isEmpty) {
      logger.log("Không tải/không cần tải danh sách tin nhắn nào.",
          name: "$runtimeType.loadListMessage");
      return;
    }

    logger.log("Tải ${conversationIds.length} danh sách tin nhắn",
        name: "$runtimeType.loadListMessage");

    ApiClient()
        .fetch(
      ApiPath.loadListMessage,
      data: {
        "UserId": AuthRepo().userInfo!.id,
        "ListConvId": json.encode(conversationIds.toList()),
        //"token": AuthRepo.token,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 9000),
      ),
    )
        .then((response) {
      if (response.hasError) {
        throw (Exception(response.error!.error));
      }

      logger.log("Tải thành công", name: "$runtimeType.loadListMessage");

      var conversations =
          jsonDecode(response.data)["data"]["data"] as List<dynamic>;

      // Nhét tin nhắn mới vào cache
      for (final conv in conversations) {
        int conversationId = conv["conversationId"];
        Iterable<SocketSentMessageModel> mostRecentMessages =
            (conv["listMessages"] as List).map((e) =>
                SocketSentMessageModel.fromMap(e as Map<String, dynamic>));

        // Tạo danh sách tin nhắn mới nếu chưa tồn tại
        _messagesLocal[conversationId] ??= SplayTreeSet(_localMessageOrder);
        _messagesCache[conversationId] ??= SplayTreeSet(_localMessageOrder);

        // Vì implementation của addAll không sửa element cũ thành mới
        // Vậy nên mình phải tự làm bằng cách removeAll này
        _messagesLocal[conversationId]!.removeAll(mostRecentMessages);
        _messagesLocal[conversationId]!.addAll(mostRecentMessages);
        _messagesCache[conversationId]!.removeAll(mostRecentMessages);
        _messagesCache[conversationId]!.addAll(mostRecentMessages);

        // Đánh dấu đã tải hết sạch tin nhắn của CTC
        if (_messagesCache[conversationId]!.length ==
            (conv["countMessage"] ?? -1)) {
          _conversationsFetchedAllMessages.add(conversationId);
        }
      }
      saveAllMessagesToLocal();
    }).catchError((err, stack) {
      logger.logError(
          "Lỗi: ${err.toString()}.\n", stack, "$runtimeType.loadListMessage");
    });
  }

  /// Lấy thông tin thành viên [chatMemberId] ở cuộc trò chuyện [conversationId].
  ///
  /// Sẽ gọi API để lấy thông tin CTC nếu chưa có.
  Future<ChatMemberModel?> getChatMember(
      {required int conversationId, required int chatMemberId}) async {
    var conversation = await getConversationModel(conversationId);
    if (conversation == null) {
      logger.log("Không thấy CTC", name: "$runtimeType");
      return null;
    }

    var member = conversation.listMember
        .where((element) => element.id == chatMemberId)
        .firstOrNull;
    if (member == null) {
      logger.log("Không thấy thành viên ${chatMemberId}", name: "$runtimeType");
    }
    return member;
  }

  /// Lấy thông tin tất cả thành viên [chatMemberIds] ở cuộc trò chuyện [conversationId].
  /// Nếu người dùng không tồn tại, kết quả trả về sẽ không có người dùng đó.
  Future<Iterable<ChatMemberModel>> getChatMembers(
      {required int conversationId,
      required Iterable<int> chatMemberIds}) async {
    var conversation = await getConversationModel(conversationId);
    if (conversation == null) {
      return [];
    }
    chatMemberIds = chatMemberIds.toSet();
    return conversation.listMember
        .where((element) => chatMemberIds.contains(element.id));
  }

  /// Lấy thông tin tất cả thành viên ở cuộc trò chuyện [conversationId].
  /// Nếu api không lấy được CTC, trả về local. Không có local, trả về rỗng.
  Future<List<ChatMemberModel>> getAllChatMembers(
      {required int conversationId}) async {
    var conversation = await getConversationModel(conversationId);
    if (conversation == null) {
      return [];
    }
    return conversation.listMember;
  }

  /// Lấy thông tin local tất cả thành viên ở cuộc trò chuyện [conversationId].
  /// Nếu không có CTC trong local, trả về rỗng.
  List<ChatMemberModel> getAllChatMembersSync({required int conversationId}) {
    return getConversationModelSync(conversationId)?.listMember ?? [];
  }

  /// Lấy thông tin thành viên [chatMemberId] ở cuộc trò chuyện [conversationId] ở local.
  ChatMemberModel? getChatMemberSync(
      {required int conversationId, required int chatMemberId}) {
    return getConversationModelSync(conversationId)
        ?.listMember
        .where((element) => element.id == chatMemberId)
        .firstOrNull;
  }

  /// Lấy thông tin những thành viên [chatMemberIds] ở cuộc trò chuyện [conversationId] ở local.
  /// Nếu người dùng không tồn tại, kết quả trả về sẽ không có người dùng đó.
  Iterable<ChatMemberModel> getChatMembersSync(
      {required int conversationId, required Iterable<int> chatMemberIds}) {
    var chatMemberSet = chatMemberIds.toSet();
    var conversation = getConversationModelSync(conversationId);
    if (conversation == null) {
      return [];
    }
    return conversation.listMember
        .where((member) => chatMemberSet.contains(member.id))
        .nonNulls;
  }

  /// Sửa thông tin thành viên [chatMember] ở CTC [conversationId].
  /// Nếu chưa có thông tin CTC này thì sẽ gọi API lấy về local rồi sửa.
  Future<void> setChatMember(
      int conversationId, ChatMemberModel chatMember) async {
    return getConversationModel(conversationId).then((conversation) {
      if (conversation == null) {
        return;
      }
      conversation.listMember
          .removeWhere((element) => element.id == chatMember.id);
      conversation.listMember.add(chatMember);
      setConversationModel(conversation);
    });
  }

  /// Là phiên bản giới hạn ở local của [setChatMember()]
  void setChatMemberSync(int conversationId, ChatMemberModel chatMember) {
    var conversation = getConversationModelSync(conversationId);
    if (conversation == null) {
      return;
    }
    conversation.listMember
        .removeWhere((element) => element.id == chatMember.id);
    conversation.listMember.add(chatMember);
    setConversationModel(conversation);
  }

  /// TL 6/1/2024: Là handleListMessage bưng từ ChatDetailBloc sang.
  ///
  /// Làm sạch danh sách tin nhắn như sau:
  ///
  /// 1. Chỉ để lại tin nhắn chấp nhận/lời mời kết bạn gần nhất.
  ///
  /// 2. Xóa các link của tin nhắn dạng thông báo (chưa hiểu lắm).
  ///
  /// 3. Bỏ đi những tin nhắn bị xóa (Magic lắm, không hiểu làm kiểu gì luôn (có khi là trùng mục 2?))
  Iterable<SocketSentMessageModel> _cleanMessages(
      Iterable<SocketSentMessageModel> msgs) {
    var _msgs = msgs.toSet().toList();
    try {
      List<SocketSentMessageModel> _acceptMsgs = [];
      List<SocketSentMessageModel> _requestMsgs = [];
      List<SocketSentMessageModel> removeLinkId = [];
      for (var i = 0; i < _msgs.length; i++) {
        var e = _msgs[i];

        /// check nếu là chấp nhận lời mời kết bạn
        if ((e.message ?? '').contains('đã chấp nhận lời mời kết bạn') &&
            e.type == MessageType.notification)
          _acceptMsgs.add(e);

        /// Check nếu là lời mời kết bạn
        else if (((e.message ?? '').contains('đã gửi lời mời kết bạn') ||
                (e.message ?? '').contains('was add friend to')) &&
            e.type == MessageType.notification)
          _requestMsgs.add(e);

        // TL 26/12/2023
        // Check hai tin nhắn kề nhau, mà:
        // +) id infoLink cái trước bằng id tin nhắn sau
        // +) cái so sánh sau ý nghĩa là gì thì t chịu rồi :)
        else if (i < _msgs.length - 1 &&
            e.infoLink?.messageId == _msgs[i + 1].messageId &&
            ((e.type?.isText == false || _msgs[i + 1].type?.isLink == false) &&
                (e.type?.isLink == false ||
                    _msgs[i + 1].type?.isText == false))) {
          removeLinkId.add(_msgs[i + 1]);
        }
      }
      if (_acceptMsgs.length > 1) _acceptMsgs.removeLast();
      if (_requestMsgs.length > 1) _requestMsgs.removeLast();
      _msgs.removeWhere((element) {
        /// xóa các tin nhắn thông báo chấp nhận lời mời kết bạn
        if (_acceptMsgs.contains(element)) return true;

        /// xóa các tin nhắn thông báo lời mời kết bạn
        if (_requestMsgs.contains(element)) return true;

        /// xóa các link của tin nhắn dạng thông báo
        if (removeLinkId.contains(element)) return true;

        /// ẩn các tin nhắn đã bị xóa
        if (element.listDeleteUser.isBlank
            ? false
            : element.listDeleteUser!.contains(AuthRepo().userId)) return true;
        return false;
      });
    } catch (e) {
      logger.logError(e.toString());
    }
    return _msgs;
  }

  /// Cập nhật thông tin cho tin nhắn mới nhất của CTC và cache tin nhắn
  Future<void> _updateLatestMessageToConversationModel(
      SocketSentMessageModel msg) async {
    var conversationModel = getConversationModelSync(msg.conversationId);
    //🦆: Lấy cuộc trò truyện mới từ API khi cuộc trò chuyện chưa có trong cache. (Tại sao để dính edge case này thế Lâm 😞)
    if (conversationModel == null) {
      int? conversationId = await getConversationId(msg.senderId);
      if (conversationId != null) {
        conversationModel ??= await getConversationModel(conversationId);
      }
    }

    if (conversationModel != null) {
      conversationModel.timeLastMessage = msg.createAt;
      conversationModel.messageId = msg.messageId;
      conversationModel.senderId = msg.senderId;
      conversationModel.messageId = msg.messageId;
      conversationModel.message = msg.message ?? "";
      conversationModel.messageType = msg.type ?? MessageType.unknown;

      setConversationModel(conversationModel);
    }
  }
}

final ChatRepo chatRepo = ChatRepo();
