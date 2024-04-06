import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/models/detail_company_model.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_detail_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/object_extension.dart';
import 'package:bloc/bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_service.dart';
import 'package:app_chat365_pc/data/services/network_service/network_service.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/enums/auto_delete_time.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'chat_detail_event.dart';

part 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  ChatDetailBloc({
    required this.senderId,
    required this.conversationId,
    required this.isGroup,
    required this.unreadMessageCounterCubit,
    this.initMemberHasNickname = const [],
    this.messageDisplay,
    this.chatItemModel,
    this.deleteTime,
    this.typeGroup,
    this.messageId,
    this.myDeleteTime,
    this.otherDeleteTime,

    /// DEPRECATED: 2 trường này dùng singleton mà
    // this.userInfoRepo,
    // this.chatRepo,
  })  : _chatDetailRepo = ChatDetailRepo(senderId),
        super(ChatDetailInitial()) {
    on<ChatDetailEvent>((event, emit) {});

    on<ChatDetailEventLoadConversationDetail>(loadConversationDetail);

    on<ChatDetailEventFetchListMessages>(loadListMessages);

    on<ChatDetailEventRefreshListMessages>(_refreshListMessages);

    on<ChatDetailEventAddNewListMessages>((event, emit) {
      msgs.addAll(event.listMsgs);
      // logger.log(
      //     "Trước xử lí: ${msgs.map((e) => e.message?.substring(0, min(e.message?.length ?? 3, 3)) ?? "").toList().toString()}",
      //     name: "$runtimeType");
      msgs = [...handleListMessages(msgs)];
      // logger.log(
      //     "Xử lí handle: ${msgs.map((e) => e.message?.substring(0, min(e.message?.length ?? 3, 3)) ?? "").toList().toString()}",
      //     name: "$runtimeType");
      msgs = msgs.toSet().toList();
      // logger.log(
      //     "Xử lí toList: ${msgs.map((e) => e.message?.substring(0, min(e.message?.length ?? 3, 3)) ?? "").toList().toString()}",
      //     name: "$runtimeType");
      msgs.sort((a, b) => b.createAt.millisecondsSinceEpoch
          .compareTo(a.createAt.millisecondsSinceEpoch));

      // logger.log(
      //     "Sau sort: ${msgs.map((e) => e.message?.substring(0, min(e.message?.length ?? 3, 3)) ?? "").toList().toString()}",
      //     name: "$runtimeType");
      // logger.log(
      //     "Timestamp cái đầu cái cuối sau khi xử lí: ${msgs.firstOrNull?.createAt ?? 0}, ${msgs.lastOrNull?.createAt ?? 0}",
      //     name: "$runtimeType");

      // Set unreadMessageId của những người đã đọc thành lastMessageId
      if (event.listMsgs.isNotEmpty) {
        var lastMessage = event.listMsgs.last;
        var lastMessageId = lastMessage.messageId;
        if (loadedMessages != 0) {
          // var idSet = listUserInfoBlocs.keys.toSet();

          // if (lastMessage.senderId == _currentUserId &&
          //     unreadMessageUserAndMessageId[_currentUserId] != null) {
          //   idSet.remove(_currentUserId);
          //   unreadMessageUserAndMessageId.remove(_currentUserId);
          // }

          // for (var user
          //     in idSet.difference(unreadMessageUserAndMessageId.keys.toSet())) {
          //   if (newMember.contains(user)) {
          //     unreadMessageUserAndMessageId[user] = '';
          //   } else
          //     unreadMessageUserAndMessageId[user] = lastMessageId;
          // }

          // unreadMessageUserAndMessageIndex.forEach((userId, messageIndex) {
          //   /// Chỉ quan tâm đến các tin nhắn chưa đọc nhưng index của nó trong
          //   /// DS tin nhắn đã load vẫn chưa xác định (nên chưa xác định được [messageId] chưa đọc)
          //   /// Nên phải đẩy index theo độ dài DS tin nhắn vừa thêm
          //   if (unreadMessageUserAndMessageId[userId] ==
          //           unknowUnreadMessageIdPlaceholder &&
          //       messageIndex != -1)
          //     unreadMessageUserAndMessageIndex[userId] =
          //         unreadMessageUserAndMessageIndex[userId]! +
          //             event.listMsgs.length;
          // });
        } else {
          // unreadMessageUserAndMessageId = Map<int, String>.fromIterable(
          //   listUserInfoBlocs.keys,
          //   value: (_) => lastMessageId,
          // );
        }
      }

      if (!event.isTempMessage) {
        // TL 30/12/2023: danh sách trả về là từ 0 -> length-1 tin nhắn,
        // nên mình = chứ không +=.
        // totalMessages không rõ để làm gì, nên chưa đụng vào
        //loadedMessages += event.listMsgs.length;
        loadedMessages += event.listMsgs.length;
        //totalMessages += event.listMsgs.length;
        // listImageFiles.addAll(getImageFilesFromListMessages(event.listMsgs));
      }

      emit(ChatDetailStateLoadDoneListMessages(msgs.reversed.toList(),
          scrollToBottom: event.isRemoteMessage));
    });

    // on<ChatDetailEventInsertNewListMessages>((event, emit) async {
    //   // var localMess =
    //   //     await HiveService().getConversationOfflineMessages(conversationId);
    //   // msgs = [...msgs, ...?localMess];
    //   msgs.addAll(event.listMsgs);

    //   var _tempMsg = [...handleListMessages(msgs)];

    //   // Bỏ các phần tử giống nhau trong list
    //   msgs = _tempMsg; //.toSet().toList();

    //   var length = msgs.length;
    //   unreadMessageUserAndMessageIndex.forEach((userId, messageIndex) {
    //     if (unreadMessageUserAndMessageId[userId] ==
    //             unknowUnreadMessageIdPlaceholder &&
    //         messageIndex > 0 &&
    //         messageIndex - 2 <= length - 1) {
    //       if (newMember.contains(userId)) {
    //         unreadMessageUserAndMessageId[userId] = '';
    //       } else
    //         unreadMessageUserAndMessageId[userId] =
    //             msgs[(length - 1 - (messageIndex - 1)).clamp(0, length - 1)]
    //                 .messageId;
    //     }
    //   });

    //   // TL 28/12/2023: danh sách trả về là từ 0 -> length-1 tin nhắn,
    //   // nên mình = chứ không +=
    //   loadedMessages += event.listMsgs.length;
    //   //loadedMessages += event.listMsgs.length;
    //   listImageFiles.insertAll(
    //     0,
    //     getImageFilesFromListMessages(event.listMsgs),
    //   );

    //   emit(ChatDetailStateLoadDoneListMessages([...msgs],
    //       scrollToBottom: event.scrollToBottom));
    // });

    on<ChatDetailEventRaiseError>((event, emit) {
      emit(ChatDetailStateError(event.error));
    });

    on<ChatDetailEventMarkReadMessage>((event, emit) {
      var conversationModel = ChatRepo().getChatItemModelSync(conversationId);
      if (conversationModel == null) {
        return;
      }

      var memberIdx = conversationModel.memberList
          .indexWhere((member) => member.id == event.senderId);

      var latestMessage =
          ChatRepo().loadMessagesSync(conversationId: conversationId, range: 1);
      if (latestMessage.isNotEmpty) {
        conversationModel.memberList[memberIdx].unreadMessageId =
            latestMessage.first.messageId;
        conversationModel.memberList[memberIdx].readMessageTime =
            DateTime.now();
      }
      // unreadMessageUserAndMessageId.remove(reader);
      // unreadMessageUserAndMessageIndex.remove(reader);
      // readMessageTime[reader] = DateTime.now();

      emit(ChatDetailStateMarkReadMessage(conversationId, event.senderId, conversationModel.memberList));
    });
    on<ChatDetailEventAllMemberReadMessage>((event, emit) =>
        ChatDetailStateAllMemberReadMessage(conversationId, event.messageId));

    /// Tạm thời comment lại
    pinnedMessageId.addListener(_loadPinnedMessageInfo);

    _currentUserId = navigatorKey.currentContext!.userInfo().id;

    _streamSubscription = chatRepo.stream.listen((event) async {
      // TL 6/1/2024: Bắt những event mới sau khi caching chat
      if (event is ChatEventOnReceivedMessage &&
          event.msg.conversationId == conversationId) {
        loadedMessages += 1;
        add(ChatDetailEventRefreshListMessages());
      } else if ((event is ChatEventOnNewMemberAddedToGroup &&
              event.conversationId == conversationId) ||
          (event is ChatEventOnOutGroup &&
              event.conversationId == conversationId)) {
        add(const ChatDetailEventLoadConversationDetail());
      } else if (event is ChatEventOnDeleteMessage &&
          event.conversationId == conversationId) {
        add(ChatDetailEventRefreshListMessages());
      } else if (event is ChatEventOnUpdateStatusMessageSupport &&
          event.conversationId == conversationId) {
        logger.log("Refresh DS tin nhắn CTC $conversationId do bắt Livechat",
            name: "ChatDetailBloc");
        add(ChatDetailEventRefreshListMessages());
      } else if (event is ChatEventOnMarkReadAllMessages &&
          event.conversationId == conversationId) {
        add(
          ChatDetailEventMarkReadMessage(event.conversationId, event.senderId),
        );
        var listSecretMessage = [...msgs];
        listSecretMessage.removeWhere((element) => element.isSecretGroup == 0);
        List<String> mySecretMessageIds = [];
        List<String> otherSecretMessageIds = [];
        for (int current = 0; current < listSecretMessage.length; current++) {
          bool isAllReadThis = true;
          int countMemberRead = 0;
          if (readMessageTime.isNotEmpty)
            readMessageTime.forEach((key, value) {
              if (value != null &&
                  value.compareTo(listSecretMessage[current].createAt) < 0)
                countMemberRead++;
            });
          if (countMemberRead == readMessageTime.length) isAllReadThis = true;
          if ((listSecretMessage[current].isSecretGroup == 1) &&
              isAllReadThis) {
            add(
              ChatDetailEventAllMemberReadMessage(
                  event.conversationId, listSecretMessage[current].messageId),
            );
            if (listSecretMessage[current].senderId == _currentUserId &&
                (myDeleteTime ?? 0) > 0) {
              mySecretMessageIds.add(listSecretMessage[current].messageId);
            } else {
              otherSecretMessageIds.add(listSecretMessage[current].messageId);
            }
          }
        }

        if ((typeGroup ?? '') == 'Secret') {
          if (((event.senderId != _currentUserId &&
                      !mySecretMessageIds.isBlank) ||
                  isGroup) &&
              (myDeleteTime ?? 0) > 0) {
            chatRepo.deleteMessageSecret(
              conversationId: conversationId,
              deleteTime: myDeleteTime ?? 10,
              messageIds: mySecretMessageIds,
            );
            mySecretMessageIds.clear();
          }
          if (event.senderId == _currentUserId &&
              otherSecretMessageIds.isNotEmpty &&
              (otherDeleteTime ?? 0) > 0) {
            if (event.senderId == _currentUserId &&
                msgs[msgs.length - 1].senderId != _currentUserId &&
                !otherSecretMessageIds.isBlank) {
              chatRepo.deleteMessageSecret(
                conversationId: conversationId,
                deleteTime: otherDeleteTime ?? 10,
                messageIds: otherSecretMessageIds,
              );
              otherSecretMessageIds.clear();
            }
          }
        }
      } else if (event is ChatEventOnPinMessage &&
          event.conversationId == conversationId) {
            logger.log(event.toString(), name: "pinnedloggerEvent");
        pinnedMessageId.value = event.messageId;
      } else if (event is ChatEventOnUnpinMessage &&
          event.conversationId == conversationId) {
        pinnedMessageId.value = null;
      }
    });
  }

  @Deprecated(
      "Không add newMember bằng cách add thêm vào ChatDetailBloc nữa. Add vào đâu thì tính sau. Chắc là ChatRepo")
  List<int> newMember = [];

  late SocketSentMessageModel messageModel;
  List<String?> selectMultiMessages = [];

  final int senderId;
  final int conversationId;
  final ChatDetailRepo _chatDetailRepo;
  UserInfoRepo userInfoRepo = UserInfoRepo();
  ChatRepo chatRepo = ChatRepo();

  /// TL 26/12/2023:
  /// Các tin nhắn đã fetch về
  List<SocketSentMessageModel> msgs = [];

  final bool isGroup;
  final int? messageDisplay;

  @Deprecated("Dùng ChatRepo().getChatItemModel() nhé")
  final ChatItemModel? chatItemModel;

  late final int _currentUserId;
  // late Box<String>? messagesBox;
  bool _isShowOfflineMessage = true;

  @Deprecated("Dùng ChatRepo().getChatItemModel() nhé")
  ChatItemModel? detail;

  final UnreadMessageCounterCubit unreadMessageCounterCubit;
  ValueNotifier<DetailModel?> detailModel = ValueNotifier(null);
  int? deleteTime;
  String? typeGroup;
  final String? messageId;
  ValueNotifier<String?> conversationName = ValueNotifier(null);
  bool _hasDetailInfo = true;
  bool isreadMessage = false;
  int? myDeleteTime;
  int? otherDeleteTime;

  /// Nếu [AutoDeleteTime.never] là tin nhắn thường
  int autoDeleteTimeMessage = 0;

  bool isShowCheckBox = false;
  final counterNotifier = ValueNotifier<int>(0);

  bool get isShowOfflineMessage => _isShowOfflineMessage;

  /// TL 26/12/2023:
  /// Làm sạch danh sách tin nhắn như sau:
  /// 1. Chỉ để lại tin nhắn chấp nhận/lời mời kết bạn gần nhất
  /// 2. Xóa các link của tin nhắn dạng thông báo (chưa hiểu lắm)
  @Deprecated(
      "TL 6/1/2024: Hàm này đã bưng qua ChatRepo rồi. Nghĩ cách mà bỏ dùng ở đây thôi")
  List<SocketSentMessageModel> handleListMessages(
      List<SocketSentMessageModel> msgs) {
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
      for (var i = 0; i < msgs.length; i++) {
        if (msgs[i].isSecretGroup == 1 &&
            msgs[i].deleteTime != null &&
            listDeleteTime[msgs[i].messageId] == null) {
          // var deleteTimes = Duration(
          //   seconds: (msgs[i].senderId == _currentUserId
          //           ? myDeleteTime
          //           : otherDeleteTime) ??
          //       -1,
          // );
          var deleteTimes = Duration(
            seconds: (msgs[i].deleteTime) ?? -1,
          );
          listDeleteTime[msgs[i].messageId] = ValueNotifier(deleteTimes);
        }
      }
    } catch (e) {
      logger.logError(e.toString());
    }
    return _msgs;
  }

  deleteNotiMsg(String msgId, int convId) async {
    await _chatDetailRepo.deleteNotiMsg(msgId, convId);
  }

  // cơ chế mới không tạo nhóm mới mà chỉ đổi type
  createNewSecretConversation(
      int senderId, int chatId, String typeGroup, List<int> membersIds) async {
    await chatRepo.createNewSecretConversation(chatId, typeGroup, membersIds);
  }

  updateDeleteTime(
      {required int conversationId,
      required int deleteTime,
      required List<int> userId,
      required List<int> membersIds}) async {
    await chatRepo.updateDeleteTime(
        conversationId: conversationId,
        deleteTime: deleteTime,
        userId: userId,
        members: membersIds);
  }

  // Future<List<SocketSentMessageModel>?> get localMessages async {
  //   try {
  //     var str = messagesBox?.get(conversationId);
  //     if (str != null) return await compute(_decodeLocalMessage, str);
  //     return null;
  //   } catch (e, s) {
  //     logger.logError(e, s, 'Get List<SocketSentMessageModel> Error:');
  //     try {
  //       messagesBox?.delete(conversationId);
  //     } catch (e) {}
  //     return null;
  //   }
  // }

  // get conversationName => null;

  // static List<SocketSentMessageModel> _decodeLocalMessage(String str) =>
  //     (json.decode(str) as List)
  //         .map((e) => sockeSentMessageModelFromHiveObjectJson(e))
  //         .toList();

  // @Deprecated("Không tải CTC bằng bloc này nữa")
  // bool fetchListMessasgeSuccessFirstTime = false;

  /// Danh sách những thành viên có nickname, do API sau này không trả về nickname
  final List<IUserInfo> initMemberHasNickname;

  late final StreamSubscription _streamSubscription;

  /// Danh sách [senderId] và index của [message] chưa đọc khi:
  /// - fetch [loadConversationDetail]
  ///
  /// Khi [message] trong [unreadMessageUserAndMessageId] ứng với [senderId]
  /// đã xác định (khác [unknowUnreadMessageIdPlaceholder]), key [senderId] trong
  /// map này không cần quan tâm nữa
  @Deprecated("Cái này là logic của view. Đừng đặt ở đây")
  Map<int, int> unreadMessageUserAndMessageIndex = {};

  /// Danh sách [senderId] và [message] tương ứng chưa đọc
  @Deprecated(
      "Sử dụng ChatMemberModel.unreadMessageId để đánh dấu tin nhắn chưa đọc.")
  Map<int, String> unreadMessageUserAndMessageId = {};

  /// Danh sách người dùng và thời gian xem tin nhắn tương ứng
  @Deprecated(
      "Sử dụng ChatMemberModel.readMessageTime để đánh dấu tin nhắn chưa đọc.")
  Map<int, DateTime?> readMessageTime = {};

  final List<SocketSentMessageModel> listImageFiles = [];

  /// Số tin nhắn đã tải
  int loadedMessages = 0;

  @Deprecated("Dùng ChatDetailBloc.detail.totalNumberOfMessages nhé")
  int totalMessages = 0;

  final ValueNotifier<List<SocketSentMessageModel?>> pinnedMessage =
      ValueNotifier([]);

  ValueNotifier<String?> pinnedMessageId = ValueNotifier(null);

  // Set<String> deletedMessageIds = {};

  /// String để nhận biết message chưa đọc này chưa load được messageId
  static const unknowUnreadMessageIdPlaceholder = '';

  /// TL 16/2/2024: ID thành viên CTC - UserInfoBloc tương ứng của người đó
  @Deprecated(
      "Muốn lấy danh sách thành viên CTC thì gọi ChatRepo().getAllChatMembers() nhé")
  Map<int, UserInfoBloc> listUserInfoBlocs = {};

  late final ValueNotifier<int> countConversationMember = ValueNotifier(0);

  /// Những [user] không thuộc thành viên cuộc trò chuyện, nhưng cần có thông tin
  ///
  /// VD: [user] đã bị xóa khỏi cuộc trò chuyện, nhưng message xuất hiện
  @Deprecated(
      "Muốn lấy danh sách thành viên CTC thì gọi ChatRepo().getAllChatMembers() nhé")
  Map<int, UserInfoBloc> tempListUserInfoBlocs = {};

  Iterable<SocketSentMessageModel> getImageFilesFromListMessages(
      List<SocketSentMessageModel> listMsgs) {
    var res = <SocketSentMessageModel>[];
    for (var msg in listMsgs) {
      if ((msg.type?.isImage ?? false) && msg.files != null) {
        res.addAll(msg.files!.map((e) => msg.copyWith(files: [e])));
      }
    }
    return res;
  }

  @Deprecated(
      "Muốn lấy danh sách thành viên CTC thì gọi ChatRepo().getAllChatMembers() nhé")
  Map<int, UserInfoBloc> get allUserInfoBlocsAppearInConversation => {
        // ...tempListUserInfoBlocs,
        ...listUserInfoBlocs,
      };

  addMember(ChatMemberModel member) async {
    var conversationModel =
        await ChatRepo().getConversationModel(conversationId);
    if (conversationModel == null) {
      return;
    }

    conversationModel.listMember.add(member);
    ChatRepo().setConversationModel(conversationModel);

    // var name = member.name;
    // var id = member.id;

    // var index = initMemberHasNickname.indexWhere((e) => e.id == id);
    // if (index != -1) {
    //   name = initMemberHasNickname[index].name;
    // }

    // listUserInfoBlocs[member.id] = !isGroup
    //     ? UserInfoBloc.fromConversation(
    //         ConversationBasicInfo(
    //           conversationId: conversationId,
    //           name: name,
    //           userId: id,
    //           avatar: member.avatar,
    //           isGroup: false,
    //           userStatus: member.userStatus,
    //           lastActive: member.lastActive,
    //         ),
    //         status: member.status,
    //       )
    //     : UserInfoBloc(member);
  }

  _loadPinnedMessageInfo() async {
    if (!pinnedMessageId.value.isBlank) {
      String _textSelect(String str) {
        str = str.replaceAll(RegExp(r'[\[\] ]'), '');
        return str;
      }

      String? listPinMessage = _textSelect(pinnedMessageId.value ?? '');

      var listMessageIds = listPinMessage.split(',');
      pinnedMessage.value = [];
      for (var i = 0; i < (listMessageIds.length); i++) {
        var res = await _chatDetailRepo.getMessage(listMessageIds[i]);
        try {
          res.onCallBack((_) {
            pinnedMessage.value = [
              ...pinnedMessage.value,
              SocketSentMessageModel.fromMap(
                  json.decode(res.data)['data']['message_info'])
            ].toSet().toList();
          });
        } catch (e) {}
      }
    } else {
      pinnedMessage.value = [];
    }
  }

  isThisMessageUnderOther(String thisMessageId, String other) =>
      thisMessageId.tickFromMessageId >= other.tickFromMessageId;

  /// Danh sách userId chưa đọc [messageId]
  Set<int> listUserIdUnreadMessageId(String messageId) {
    Set<int> listUserIds = {};

    for (ChatMemberModel member
        in ChatRepo().getChatItemModelSync(conversationId)?.memberList ?? []) {
      if (member.unreadMessageId == null ||
          member.unreadMessageId == "" ||
          isThisMessageUnderOther(messageId, member.unreadMessageId!)) {
        listUserIds.add(member.id);
      }
    }
    return listUserIds;

    // for (var entry in unreadMessageUserAndMessageId.entries) {
    //   var userId = entry.key;
    //   var unreadMessageId = entry.value;
    //   // tin nhắn đã đọc nằm trên tin nhắn chưa đọc
    //   /// Check xem [messageId] hiện tại có nằm dưới [lastmessagesend] chưa đọc
    //   /// Nếu có nằm dưới, [userId] đang xét chưa đọc [messageId] hiện tại
    //   /// Vì tin [unreadMessageId] ở trên chưa đọc
    //   if ((unreadMessageId == unknowUnreadMessageIdPlaceholder ||
    //       isThisMessageUnderOther(messageId, unreadMessageId))) {
    //     listUserIds.add(userId);
    //   }

    //   /// Nếu [MessageId] hiện tại là [unreadMessageId] thì bỏ ra khỏi list
    //   if (messageId == unreadMessageId) listUserIds.remove(userId);
    // }
    // return listUserIds;
  }

  reset() {
    msgs.clear();
    // unreadMessageUserAndMessageIndex = {};
    // unreadMessageUserAndMessageId = {};
    // readMessageTime = {};
    listImageFiles.clear();
    loadedMessages = 0;
  }

  /// TL 16/2/2024: Cái hàm này có dùng ở đâu không vậy?
  resetUnreadMessage() async {
    var conversationModel =
        await ChatRepo().getConversationModel(conversationId);
    if (conversationModel == null) {
      return;
    }
    for (int i = 0; i < conversationModel.listMember.length; ++i) {
      conversationModel.listMember[i].unreadMessageId = "";
    }
    ChatRepo().setConversationModel(conversationModel);
    // unreadMessageUserAndMessageId =
    //     unreadMessageUserAndMessageId = Map<int, String>.fromIterable(
    //   listUserInfoBlocs.keys,
    //   value: (_) => "",
    // );
    // ;
  }

  loadConversationDetail(
      ChatDetailEventLoadConversationDetail event, emit) async {
    // logger.logError('$chatItemModel - $detail');
    // Timer? _timer;

    emit(ChatDetailStateLoading(false));
    try {
      // detail = await ChatRepo().getChatItemModel(conversationId);

      // autoDeleteTimeMessage = detail!.autoDeleteMessageTimeModel.deleteTime;
      // detail!.memberList.forEach(addMember);
      // totalMessages = detail!.totalNumberOfMessages;
      // pinnedMessageId.value = detail!.conversationBasicInfo.pinMessageId;
      // await _setUnreadMessageIdAndIndex();

      // emit(ChatDetailStateLoadDetailDone(detail!));

      var newDetail = (await ChatRepo().getChatItemModel(conversationId))!;
      countConversationMember.value = newDetail.memberList.length;
      pinnedMessageId.value = newDetail.conversationBasicInfo.pinMessageId;

      emit(ChatDetailStateLoadDetailDone(newDetail));

      if (event.loadMessage) add(ChatDetailEventFetchListMessages());
    } on CustomException catch (e) {
      add(ChatDetailEventRaiseError(e.error));
    }

    // try {
    //   if (detail == null && chatItemModel != null) {
    //     // logger.log(
    //     //   chatItemModel!.lastMessages?.length,
    //     //   name: 'BeforeGetConversationDetail',
    //     // );
    //     detail = chatItemModel;
    //     autoDeleteTimeMessage = detail!.autoDeleteMessageTimeModel.deleteTime;
    //     // logger.log(
    //     //   chatItemModel!.lastMessages?.length,
    //     //   name: 'AfterGetConversationDetail',
    //     // );
    //     detail!.memberList.forEach((e) {
    //       addMember(e);
    //       unreadMessageUserAndMessageId[e.id] =
    //           unknowUnreadMessageIdPlaceholder;
    //     });
    //     emit(ChatDetailStateLoadDetailDone(
    //       detail!,
    //       isBroadcastUpdate: false,
    //     ));
    //   } else {
    //     if (detail == null) {
    //       logger.log('vao day ne');
    //       // TL 2/1/2023: Caching thông tin CTC
    //       detail = await ChatRepo()
    //           .getChatItemModel(conversationId); // _fetchConversationDetail();
    //     }
    //   }

    // if (!fetchListMessasgeSuccessFirstTime) {
    //   // TL 28/12/2023: DEPRECATED. Chuyển dịch chức năng cache tin nhắn qua ChatRepo
    //   //final localMsgs = detail?.lastMessages ?? (await localMessages);
    //   // if (!fetchListMessasgeSuccessFirstTime && !localMsgs.isBlank) {
    //   //   _timer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
    //   //     try {
    //   //       /// Sau 1.8s, ko có dữ liệu online về và state hiện tại ko phải state lỗi,
    //   //       /// hiển thị đang cập nhật cuộc hội thoại
    //   //       if (_isShowOfflineMessage && state is! ChatDetailStateError) {
    //   //         emit(ChatDetailStateLoading(false));
    //   //         timer.cancel();
    //   //       }
    //   //     } catch (e) {}
    //   //   });
    //   //   final List<SocketSentMessageModel> preloadMsgs = localMsgs!;
    //   //   // final List<SocketSentMessageModel> lastMessages =
    //   //   //     chatItemModel?.lastMessages ?? [];
    //   //   // if (localMsgs.isBlank == false && lastMessages.isBlank == false)
    //   //   //   preloadMsgs = lastMessages.last.createAt
    //   //   //               .compareTo(localMsgs!.last.createAt) ==
    //   //   //           1
    //   //   //       ? localMsgs
    //   //   //       : lastMessages;
    //   //   // else
    //   //   // preloadMsgs = localMsgs ?? chatItemModel!.lastMessages!;
    //   //   // preloadMsgs = localMsgs!;
    //   //   // var localMess = await HiveService()
    //   //   //     .getConversationOfflineMessages(conversationId);
    //   //   // msgs = [...msgs, ...?localMess];
    //   //   msgs.addAll(preloadMsgs);
    //   //   var _tempMsg = [...handleListMessages(msgs)];
    //   //   msgs
    //   //     ..clear()
    //   //     ..addAll(_tempMsg);
    //   //   // đây à
    //   //   emit(ChatDetailStateLoadDoneListMessages(
    //   //     msgs,
    //   //   ));
    //   //   fetchListMessasgeSuccessFirstTime = true;
    //   //   await Future.delayed(const Duration(milliseconds: 200));
    //   // }
    // } else
    //   emit(ChatDetailStateLoading(!fetchListMessasgeSuccessFirstTime));

    // var detail = await _fetchConversationDetail();

    // else
    // autoDeleteTimeMessage = detail!.autoDeleteMessageTimeModel.deleteTime;
    // _timer?.cancel();

    // reset();

    // detail!.memberList.forEach(addMember);
    // totalMessages = detail!.totalNumberOfMessages;
    // pinnedMessageId.value = detail!.conversationBasicInfo.pinMessageId;

    // await _setUnreadMessageIdAndIndex();

    // emit(ChatDetailStateLoadDetailDone(detail!));
    // if (event.loadMessage) add(ChatDetailEventFetchListMessages());
    // } on CustomException catch (e) {
    //   add(ChatDetailEventRaiseError(e.error));
    // }
  }

  /// TL 23/12/2023: Dùng để tải lại detail. add(ChatDetailEventLoadConversationDetail)
  /// sẽ không tải lại nếu nó đã tải một lần rồi
  Future<void> refreshConversationDetail() async {
    try {
      emit(ChatDetailStateLoading(false));
      // TL 2/1/2023: Caching thông tin CTC
      detail = await ChatRepo()
          .getChatItemModel(conversationId); // _fetchConversationDetail();
      emit(ChatDetailStateLoadDetailDone(detail!));
    } catch (e) {
      emit(ChatDetailStateError(ExceptionError.unknown()));
    }
  }

  // _setUnreadMessageIdAndIndex() async {
  //   final List res = await compute(_computeSetUnreadMessageIdAndIndex, [
  //     detail!.memberList,
  //     unreadMessageUserAndMessageId,
  //     unreadMessageUserAndMessageIndex,
  //     readMessageTime,
  //     unreadMessageCounterCubit.countUnreadMessage,
  //     _currentUserId,
  //   ]);
  //   detail!.memberList = res[0];
  //   unreadMessageUserAndMessageId = res[1];
  //   unreadMessageUserAndMessageIndex = res[2];
  //   readMessageTime = res[3];
  // }

  // static List _computeSetUnreadMessageIdAndIndex(List params) {
  //   final List<ChatMemberModel> memberList = params[0];
  //   final Map<int, String> unreadMessageUserAndMessageId = params[1];
  //   final Map<int, int> unreadMessageUserAndMessageIndex = params[2];
  //   final Map<int, DateTime?> readMessageTime = params[3];
  //   final int countUnreadMessage = params[4];
  //   final int _currentUserId = params[5];
  //   for (var member in memberList) {
  //     var id = member.id;
  //     readMessageTime[id] = member.readMessageTime;
  //     int messageIndex;
  //     if (member.unreadMessageId != null) {
  //       unreadMessageUserAndMessageId[id] = member.unreadMessageId!;
  //     } else if (member.id == _currentUserId) {
  //       unreadMessageUserAndMessageIndex[id] = countUnreadMessage;
  //       unreadMessageUserAndMessageId[id] = unknowUnreadMessageIdPlaceholder;
  //     } else {
  //       messageIndex = member.unReader;

  //       if (member.unReader == 0) {
  //         unreadMessageUserAndMessageId.remove(id);
  //       } else if (messageIndex > 0) {
  //         unreadMessageUserAndMessageId[id] = unknowUnreadMessageIdPlaceholder;
  //         unreadMessageUserAndMessageIndex[id] = messageIndex;
  //       }
  //     }
  //   }

  //   return [
  //     memberList,
  //     unreadMessageUserAndMessageId,
  //     unreadMessageUserAndMessageIndex,
  //     readMessageTime,
  //     countUnreadMessage,
  //     _currentUserId,
  //   ];
  // }

  /// Làm mới lại danh sách CTC
  void refreshListMessages({int? range}) {
    add(ChatDetailEventRefreshListMessages(range: range));
  }

  void _refreshListMessages(ChatDetailEventRefreshListMessages event,
      Emitter<ChatDetailState> emit) async {
    logger.log(
        "Refresh CTC $conversationId. msgs.length before: ${msgs.length}",
        name: "ChatDetailBloc");

    msgs = (await ChatRepo().loadMessages(
            conversationId: conversationId, range: event.range ?? loadedMessages))
        .toList();

    loadedMessages = msgs.length;

    // logger.log("Refresh CTC $conversationId. msgs.length after: ${msgs.length}",
    //     name: "ChatDetailBloc");

    emit(ChatDetailStateLoadDoneListMessages(msgs.reversed.toList()));
  }

  loadListMessages(ChatDetailEventFetchListMessages event, emit) async {
    try {
      loadedMessages += 15;
      add(ChatDetailEventRefreshListMessages());
    } on CustomException catch (e) {
      add(ChatDetailEventRaiseError(e.error));
    }
  }

  // TL 28/12/2023: Sửa fetchListMessage để lấy thông tin cache
  Future<List<SocketSentMessageModel>> fetchListMessages(
      {int? listMess}) async {
    var listMessage = (await ChatRepo().loadMessages(
      conversationId: conversationId,
      range: listMess ?? (loadedMessages + 15),
    ))
        .toList()
        .reversed;
    listImageFiles.insertAll(
        0, getImageFilesFromListMessages(listMessage.toList()));

    return listMessage.toList();
  }

  Future<SocketSentMessageModel> _fetchListMessFinded(
      String text, String time) async {
    var res =
        await _chatDetailRepo.getListFindMessage(conversationId, text, time);
    SocketSentMessageModel result = SocketSentMessageModel.fromMap(
        json.decode(res.data)["data"]["count_results"]);
    return result;
  }

  Future<Map> getCountFindMessage(String text, String time) async {
    var res =
        await _chatDetailRepo.getListFindMessage(conversationId, text, time);
    if (res.hasError) return {};
    var result = json.decode(res.data)["data"];
    return result ?? {};
  }

  static List<SocketSentMessageModel> _computeListSocketSentMessageModel(
    List params,
  ) {
    final RequestResponse res = params[0];
    final CurrentUserInfoModel infoModel = params[1];
    return (json.decode(res.data)["data"]["listMessages"] as List)
        .map((e) => SocketSentMessageModel.fromMap(
              e,
              userInfo: infoModel.userInfo,
              userType: infoModel.userType,
            ))
        .toList();
  }

  pinMessage(String messageId, String messageContent) {
    chatRepo.pinMessage(
      conversationId,
      messageContent,
      //cần truyền lên những tin nhắn đã ghim cũ
      {...pinnedMessage.value.map((e) => e!.messageId).toList(), messageId}
          .toList(),

      /// TL 27/2/2024: TẠM BIỆT NHỮNG NGƯỜI Ở LẠI :>
      /// DEPRECATED. Cho nhưng không dùng
      listUserInfoBlocs.keys.toList(),
    );
  }

  // vẫn là dùng api ghim tin nhắn nhưng trừ đi tin muốn bỏ ghim
  unPinMessage(String messageId, String messageContent) {
    var listPinMessId = [
      ...pinnedMessage.value.map((e) => e!.messageId).toList()
    ];
    listPinMessId.removeWhere((element) => element == messageId);
    chatRepo.unPinMessage(
      conversationId,
      messageContent,
      listPinMessId,
      listUserInfoBlocs.keys.toList(),
    );
  }

  //bookmark message
  bookmarkMessage(String messageId, String messageContent) {
    chatRepo.bookmarkMessage(
      conversationId,
      messageContent,
      messageId,
      listUserInfoBlocs.keys.toList(),
    );
  }

  setupDeleteTime({
    required int conversationId,
    required String messageId,
    required int deleteTime,
    required List<int> listUserId,
  }) {
    return chatRepo.setupDeleteTime(
      conversationId: conversationId,
      deleteTime: deleteTime,
      messageId: messageId,
      listUserId: listUserId,
    );
  }

  //unbookmark message
  unBookmarkMessage(String messageContent) => chatRepo.unBookmarkMessage(
        conversationId,
        messageContent,
        listUserInfoBlocs.keys.toList(),
      );

  markReadMessages({
    List<int>? messageIds,
    required int senderId,
    required int conversationId,
    required List<int> memebers,
  }) {
    chatRepo.markReadMessage(
      conversationId: conversationId,
      senderId: senderId,
      memebers: memebers,
      messageIds: messageIds,
    );
  }

  Future _getDetailInfo(int idChat, int type, String name) async {
    /// TL 28/12/2023: Deprecate ChatRepo().getInfo()
    var res0 = isGroup
        ? (await ChatRepo().getChatItemModel(conversationId))
            ?.conversationBasicInfo
        : await UserInfoRepo().getUserInfo(idChat);
    if (res0 != null) {
      if (StringConst.fromQLC.contains(res0.fromWeb) &&
          res0.userType == UserType.company) {
        detailModel.value = DetailModel(
            username: res0.name,
            id: '${res0.id}',
            contact: res0.email,
            type: res0.userType);
        logger.log('thông tin QLC: ${detailModel.value.toString()}');
        return;
      }
    }
    var res = await _chatDetailRepo.getDetailInfo(idChat, type, name);

    var data = detailCompanyModelFromJson(res.data);

    if (data.data != null) {
      try {
        await res.onCallBack((_) {
          detailModel.value = data.data!.item;
        });
      } catch (e) {
        if (e is CustomException && (e).error.code == 404)
          _hasDetailInfo = false;
      }
    } else {
      // var res2 = await _chatDetailRepo.getRaonhanhUserInfo(idChat, type);
      // var dataRaonhanh = detailCompanyModelFromJson(res2.data);
      // try {
      //   await res2.onCallBack((_) {
      //     detailModel.value = dataRaonhanh.data!.item;
      //   });
      // } catch (e) {
      //   if (e is CustomException && (e).error.code == 404)
      //     _hasDetailInfo = false;
      // }
    }
  }

  Future<DetailModel?> getDetailInfo({IUserInfo? uInfo}) async {
    if (detailModel.value != null) return detailModel.value!;
    var chatId =
        chatItemModel?.firstOtherMember(_currentUserId).id ?? uInfo?.id;
    if (chatId == null) return null;
    // if(/*uInfo?.userType==UserType.company&&*/StringConst.fromQLC.contains(uInfo?.fromWeb)){
    //   logger.log('thông tin QLC: ${detailModel.value}');
    //   detailModel.value = DetailModel(username: uInfo!.name,id: '${uInfo.id}',contact: uInfo.email);
    //   return detailModel.value;
    // }
    var userType = (detail?.memberList[0].id ?? 0) == _currentUserId
        ? detail?.memberList[1].userType ?? uInfo?.userType ?? UserType.company
        : detail?.memberList[0].userType ?? uInfo?.userType ?? UserType.company;
    String name = (detail?.memberList[0].id ?? 0) == _currentUserId
        ? detail?.memberList[1].name ?? uInfo?.name ?? ''
        : detail?.memberList[0].name ?? uInfo?.name ?? '';
    await _getDetailInfo(chatId, userType.id, name);
    return detailModel.value;
  }

  @override
  void onChange(Change<ChatDetailState> change) {
    if (change.nextState is ChatDetailStateLoadDetailDone) {
      countConversationMember.value = listUserInfoBlocs.length;
      // userType bị null khi đó là nhóm livechatv2
      //var userType = detail!.conversationBasicInfo.userType;
      // cuộc trò chuyện chỉ có 1 người thị đang bị lỗi không lấy đc thằng thứ 2
      // var userType = (detail?.memberList[0].id ?? 0) == _currentUserId
      //     ? detail?.memberList[1].userType ?? UserType.company
      //     : detail?.memberList[0].userType ?? UserType.company;
      // if (_hasDetailInfo && detailModel.value == null) getDetailInfo();
    }
    super.onChange(change);
  }

  static List<ChatMemberModel> _updateChatItemModelOnClose(List params) {
    final List<ChatMemberModel> members = params[0];
    final Map<int, String> unreadMessageUserAndMessageId = params[1];
    final Map<int, DateTime?> readMessageTime = params[2];
    for (var member in members) {
      var unreadMessageId = unreadMessageUserAndMessageId.remove(member.id);
      member.unreadMessageId = unreadMessageId;
      if (unreadMessageId == null)
        member.readMessageTime = readMessageTime[member.id];
      // if (unreadMessageUserAndMessageId.isEmpty) break;
    }
    return members;
  }

  List<SocketSentMessageModel> get currentLastMessages => msgs.slice(
      // start: (msgs.length - AppConst.countOfflineConversationMessages)
      //     .clamp(0, msgs.length),
      );

  @override
  Future<void> close() async {
    logger.log(isShowOfflineMessage, name: "hive called");
    listUserInfoBlocs.values.forEach((e) => e.close());
    // tempListUserInfoBlocs.values.forEach((e) => e.close());
    _streamSubscription.cancel();
    var lastMessage = currentLastMessages;
    // if (chatItemModel != null) {
    //   chatItemModel!
    //     .memberList = await compute(
    //       _updateChatItemModelOnClose,
    //       [
    //         chatItemModel!.memberList,
    //         unreadMessageUserAndMessageId,
    //         readMessageTime,
    //       ],
    //     );
    // }
    // if (kDebugMode)
    //   logger.log(
    //     'ChatItemModel ${chatItemModel?.conversationId} LastMessages: ${chatItemModel?.lastMessages?.length}',
    //   );
    // lưu tin nhắn đã load trong cuộc trò chuyện này
    if (!_isShowOfflineMessage) {
      // logger.log(
      //   'ChatItemModel ${chatItemModel?.conversationId} AfterSetLastMessages: ${chatItemModel?.lastMessages?.length}',
      // );
      // var localMess = await HiveService().messages;
      // List<SocketSentMessageModel> newMsgs;
      // List<SocketSentMessageModel> sortedMsgs;

      chatItemModel?.lastMessages ??= lastMessage;
      try {
        logger.log("hive called");
        HiveService().saveListMessageToChatConversationBox(
          conversationId,
          lastMessage,
        );
      } catch (e) {}
    }
    return super.close();
  }

  List<SocketSentMessageModel> get messageChecked {
    return msgs.where((element) => element.isCheck).toList();
  }
}
