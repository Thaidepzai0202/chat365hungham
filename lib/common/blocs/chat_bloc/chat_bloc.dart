import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app_chat365_pc/common/Widgets/live_chat/timer_repo.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/models/group_conversation_creation_kind.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat/notification/notificationChat.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_model.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/clients/unified_realtime_data_source.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/zalo/models/conversation_item_model.dart';
import 'package:app_chat365_pc/zalo/models/friend_zalo_model.dart';
import 'package:app_chat365_pc/zalo/models/user_model_zalo.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bloc/bloc.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/generator_service.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_service.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_status.dart';
import 'package:app_chat365_pc/utils/data/enums/chat_feature_action.dart';
import 'package:app_chat365_pc/utils/data/enums/emoji.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/enums/process_message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/date_time_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:sp_util/sp_util.dart';

part 'chat_event.dart';

part 'chat_state.dart';

/// TL 20/2/2024: Bật true để in ra console thay vì gọi API bắn tin nhắn vào nhóm "Đăng kí NTD"
bool livechatDebugging = true;

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._chatRepo) : super(ChatInitial()) {
    ChatRepo().stream.listen(add);

    on<ChatEventOnReceivedMessage>(_onReceiveMessage);

    /// Event khi gửi tin nhắn
    on<ChatEventEmitSendMessage>(_onSendMessageEvent);

    on<ChatEventEmitTypingChanged>((event, emit) {
      _chatRepo.changeCurrentUserTypingState(
        event.isTyping,
        conversationId: event.conversationId,
        listMemeber: event.listMembers,
        userId: event.userId,
      );
    });

    on<ChatEventRaiseSendMessageError>((event, emit) {
      // sendingMessage.removeMessage(event.message);
      // errorMessage.putIfAbsent(event.message, () => event.error);
      emit(ChatStateSendMessageError(
        event.error,
        message: event.message,
      ));
    });

    on<ChatEventToEmitDeleteMessageWithMessageIndexInConversation>((ev, em) {
      logger.log(ev.toString(), name: 'Delete log');
      em(ChatStateDeleteMessageSuccess(
        ev.messageId,
        ev.conversationId,
        messageIndex: ev.messageIndex,
        messageAbove: ev.aboveMessage,
        messageBelow: ev.belowMessage,
      ));
    });

    on<ChatEventAddProcessingMessage>((event, emit) {
      // sendingMessage[event.message] = event.processingType;
      // errorMessage.removeMessage(event.message);
      emit(ChatStateInProcessingMessage(event.message));
    });

    on<ChatEventEmitEditMessage>(_onEditMessageEvent);

    on<ChatEventOnMessageEditted>(
      (event, emit) => emit(
        ChatStateEditMessageSuccess(
          event.conversationId,
          event.messageId,
          event.newMessage,
          editType: event.newMessage == 'Tin nhắn đã được thu hồi' ? 2 : 1,
        ),
      ),
    );

    on<ChatEventEmitDeleteMessage>(_onDeleteMessageEvent);
    on<ChatEventEmitDeleteMessageFake>(_onDeleteMessageFakeEvent);
    on<ChatEventEmitDeleteMultiMessage>(_onDeleteMessageMultiEvent);

    on<ChatEventEmitRecallMessage>(_onRecallMessageEvent);
    on<ChatEventEmitRecallMultiMessage>(_onRecallMultiMessageEvent);

    // on<ChatEventLogOutAllDevice>(_onLogOutAllDevice);
    // on<ChatEventLogOutStrangeDevice>(_onLogOutStrangeDevice);

    on<ChatEventOnNewMemberAddedToGroup>((event, emit) => emit(
        ChatStateNewMemberAddedToGroup(event.conversationId, event.members)));

    on<ChatEventOnDeleteMessage>(_onEventOnDeleteMessage);

    on<ChatEventResendMessage>(_onEventResendMessage);

    on<ChatEventOnChangeFavoriteStatus>(
        (event, emit) => emit(ChatStateFavoriteConversationStatusChanged(
              event.conversationId,
              event.isChangeToFavorite,
            )));
    on<ChatEventOnChangeNotification>(
        (event, emit) => emit(ChatStateNotificationConversationStatusChanged(
              event.conversationId,
              event.isNotification,
            )));
    on<ChatEventOnCreateSecretConversation>(
        (event, emit) => emit(ChatStateCreateSecretConversation(
              event.conversationId,
              event.typeGroup,
            )));
    on<ChatEventOnUpdateDeleteTime>((event, emit) => emit(
        ChatStateUpdateDeleteTime(
            event.conversationId, event.senderId, event.deletedTime)));
    on<ChatEventOnOutGroup>((event, emit) => emit(ChatStateOutGroup(
          event.conversationId,
          event.deletedMemberId,
          event.newAdminId,
        )));
    on<ChatEventOnRecievedEmotionMessage>(_onReceivedEmotionMessage);
  }

  final ChatRepo _chatRepo;

  Future<void> onTapMemberInEmotionShowDialog({
    required BuildContext parentContext,
    required ChatDetailBloc chatDetailBloc,
    required TypingDetectorBloc typingDetectorBloc,
    required ChatConversationBloc chatConversationBloc,
    required AppLayoutCubit appLayoutCubit,
    required UserInfoBloc userInfoBloc,
    required ChatItemModel chatItemModel,
    required int conversationId,
  }) async {
    // await AppRouter.back(parentContext);
    try {
      // emit(ReactionStateOnTapMemberInEmotionShowDialogLoading());
      appLayoutCubit.toMainLayout(
          AppMainPages.chatScreen,
          providers: [
            BlocProvider<UserInfoBloc>(
                create: (context) =>
                userInfoBloc),
            BlocProvider<TypingDetectorBloc>.value(
                value: typingDetectorBloc),
          ],
          agruments: {
            'chatType': ChatType.SOLO,
            'conversationId': conversationId,
            'senderId': parentContext.userInfo().id,
            'chatItemModel': chatItemModel,
            'name': chatItemModel
                .conversationBasicInfo.name,
            'chatDetailBloc': chatDetailBloc,
            'messageDisplay': -1,
          });
      emit(ChatStateOnTapMemberInEmotionShowDialogLoaded(conversationId: conversationId));
      await chatConversationBloc.refresh();
      // chatDetailBloc.refreshListMessages;
    } catch (e) {
      print(e);
      // emit(ReactionStateOnTapMemberInEmotionShowDialogError(error: e.toString()));
    }
  }

  void _onReceivedEmotionMessage(ChatEventOnRecievedEmotionMessage event, Emitter emit) {
    logger.log("_onReceivedEmotionMessage(ChatEventOnReceivedEmotionMessage = ${event.messageId}, Emitter = $emit)");
    emit(ChatStateOnReceivedEmotionMessage(
      event.messageId,
      senderId: event.senderId,
      // messageId: event.messageId,
      conversationId: event.conversationId,
      emoji: event.emoji,
      checked: event.checked,
      messageType: event.messageType,
      message: event.message,
    ));
  }

  void _onReceiveMessage(ChatEventOnReceivedMessage event, Emitter emit) {
    logger.log(event.msg, name: 'dkmmm', maxLength: 5000);
    if (!_isDuplicatedMessage(event.msg.messageId)) {
      if (event.msg.senderId != navigatorKey.currentContext!.userInfo().id) {
        _showNotification(event.msg);
      }
    }

    if (event.msg.liveChat == null) {
      return;
    }

    // check TH tin nhắn live chat
    // Trường hợp nhà tuyển dụng đăng nhập trên web timviec365
    if (event.msg.conversationId != event.msg.liveChat!.fromConversation &&
        event.msg.liveChat!.fromConversation != null) {
      timerRepo
          .startLivechatMessageTimer(event.msg)
          .finished
          .listen((timeElapsed) {
        logger.log("Đã miss tin nhắn${event.msg.messageId}", name: "Timer");
        updateStatusLivechatMissed(
            event.msg.conversationId,
            event.msg.messageId,
            [],
            event.msg.infoSupport,
            event.msg.senderId,
            event.msg.liveChat,
            AuthRepo().userInfo!.id);
        var message = ApiMessageModel(
            messageId: event.msg.messageId,
            conversationId: event.msg.liveChat!.fromConversation!,
            type: event.msg.type ?? MessageType.text,
            senderId: event.msg.senderId,
            infoSupport: event.msg.infoSupport,
            liveChat: event.msg.liveChat,
            message: event.msg.message);
        sendMissMessageLiveChat(message, recieveIds: []);
      });
    }

    /// TL 20/2/2024: Tin nhắn khi NTD nhắn tin cho chuyên viên
    else if (event.msg.senderName == 'Hỗ trợ khách hàng') {
      /// TL 20/2/2024: Viết lại code mới với TimerRepo mới
      /// TL 23/2/2024 TODO: Cái livechat timer này chưa có chỗ stop() đâu nhé.
      timerRepo
          .startLivechatConversationTimer(event.msg.conversationId)
          .finished
          .listen((timeElapsed) async {
        logger.log("Đã miss tin nhắn CTC ${event.msg.conversationId}",
            name: "Timer");
        await _chatRepo.leaveGroupChat(
            event.msg.conversationId, AuthRepo().userInfo!.id);
        try {
          updateStatusLivechatMissed(
              event.msg.conversationId,
              event.msg.messageId,
              [],
              event.msg.infoSupport,
              event.msg.senderId,
              event.msg.liveChat,
              AuthRepo().userInfo!.id);
          var missMesssage = ApiMessageModel(
              messageId: event.msg.messageId,
              conversationId: event.msg.liveChat!.fromConversation!,
              type: event.msg.type ?? MessageType.text,
              senderId: event.msg.senderId,
              infoSupport: event.msg.infoSupport,
              liveChat: event.msg.liveChat,
              message: event.msg.message);
          logger.log(event.msg.toMap(),
              name: 'ChatBloc._onReceiveMessage', maxLength: 50000);
          // sendDeleteMissedMessageLiveChat(message, recieveIds: [], userId: AuthRepo().userInfo!.id);
          sendMissMessageLiveChat(missMesssage, recieveIds: []);
        } catch (e, s) {
          logger.log("$e $s", name: "ChatBloc._onReceiveMessage");
        }
      });
    }
    emit(ChatStateReceiveMessage(event.msg));
  }

  // Map<ApiMessageModel, ProcessMessageType> sendingMessage = {};
  // Map<ApiMessageModel, ExceptionError> errorMessage = {};
  Map<String, ValueNotifier<double>> fileProgressListener = {};
  Map<String, String> uploadedFilePathCache = {};

  /// [messageId] và [ApiFileModel] đã chọn tương ứng khi vừa chọn file, thay thế placeholder
  Map<String, List<ApiFileModel>?> cachedMessageImageFile = {};

  FutureOr<void> _onEditMessageEvent(
      ChatEventEmitEditMessage event, emit) async {
    var message = event.message;
    add(ChatEventAddProcessingMessage(message));
    // await Future.delayed(const Duration(seconds: 2));
    try {
      await _chatRepo.editMessage(
        conversationId: message.conversationId,
        messageId: message.messageId,
        newMessage: message.message ?? '',
        // TL 13/1/2024: Deprecated
        //members: event.memebers,
      );
      HiveService().updateMessageFromChatConversationBox(
        message.messageId,
        message.conversationId,
        message.message ?? '',
      );

      emit(
        ChatStateEditMessageSuccess(
          message.conversationId,
          message.messageId,
          message.message ?? '',
        ),
      );
    } on CustomException catch (e) {
      emit(ChatStateWarningMessageError(message.messageId, e.error));
    } finally {
      // sendingMessage.removeMessage(message);
    }
  }

  _onSendMessageEvent(
    ChatEventEmitSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    logger.log(event.message.messageId, name: 'Sending messageID: ');
    add(ChatEventAddProcessingMessage(event.message));
    // return add(
    //   ChatEventRaiseSendMessageError(
    //     ExceptionError.unknown(),
    //     messageId: event.message.messageId,
    //   ),
    // );
    try {
      await _sendMessage(
        event.message,
        recieveIds: event.recieveIds,
        conversationBasicInfo: event.conversationBasicInfo,
        onlineUsers: event.onlineUsers,
        isSecret: event.isSecret,
      );
      // sendingMessage.removeMessage(event.message);
      // errorMessage.removeMessage(event.message);
      emit(ChatStateSendMessageSuccess(event.message.messageId));

      // FilePicker.platform.clearTemporaryFiles();
    } on CustomException catch (e) {
      // errorMessage.add(event.message);
      add(
        ChatEventRaiseSendMessageError(
          e.error,
          message: event.message,
        ),
      );
      // gửi lại tin nhắn khi mất mạng, gửi mà lỗi sẽ vào đây
      // if (event.message.type == MessageType.text) {
      var map = event.message.toMap();
      var encodedRecieveIds = json.encode(event.recieveIds);
      var encodedOnlineUsers = json.encode(event.onlineUsers);
      map.addAll({
        'ListMember': encodedRecieveIds,
        'ConversationName': event.conversationBasicInfo?.name,
        'IsOnline': encodedOnlineUsers,
        'IsGroup': (event.conversationBasicInfo?.isGroup ?? false) ? 1 : 0,
      });
      errorMessage = [...errorMessage, json.encode(map)];
      //errorMessage.add(json.encode(map));
      logger.logError(errorMessage.toString());
      SpUtil.putStringList(LocalStorageKey.message_error, errorMessage);
      // }
    }
  }

  bool _isDuplicatedMessage(String id) {
    if (latestMsgIds.contains(id)) return true;
    latestMsgIds.add(id);
    if (latestMsgIds.length > 1000) {
      latestMsgIds.remove(latestMsgIds.last);
    }
    return false;
  }

  Future<String> _getUserName(String userId) async {
    String? userName = userNameMap[userId];
    if (userName != null) return userName;
    RequestResponse res = await ApiClient().fetch(ApiPath.getUserName,
        data: {'ID': userId}, method: RequestMethod.post);
    if (res.hasError) return "Tin nhắn mới";
    userName = jsonDecode(res.data)?['data']?['userName'];
    if (userName == null) return "Tin nhắn mới";
    userNameMap.addAll({userId: userName});
    return userName;
  }

   Future<void> _showNotification(SocketSentMessageModel message) async {
    String userName = await _getUserName(message.senderId.toString());
    // LocalNotification notification = LocalNotification(
    //   title: userName,
    //   body: message.message,
    // );

    // final List<ApiFileModel> files = message.files ?? [];

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String senderID = stringToBase64.encode(message.senderId.toString());
    String myID = stringToBase64.encode(AuthRepo().userId.toString());
    String conversationID =
        stringToBase64.encode(message.conversationId.toString());
    ConversationModel? groupInfo =
        await ChatRepo().getConversationModel(message.conversationId);
    String linkOpenApp = 'chat365pc:/$myID/$senderID/0/$conversationID';
    print(
        '----------------groupInfo----${message.toString()}--------------');

    if (message.type == MessageType.sticker) {
      showWithLargeImage(
          message.message!, groupInfo!.conversationName, userName, linkOpenApp);
    } else if (message.type == MessageType.image) {
      // showWithLargeImage(message.infoLink.toString(), userName, linkOpenApp);
      showWithSmallImage(
          userName, userName, message.message.toString(), linkOpenApp);
    }
    // else if(message.type == MessageType.adsCV){

    // }
    else {
      showWithSmallImage(groupInfo!.conversationName, userName,
          message.message ?? "Đã gửi tin nhán cho bạn", linkOpenApp);
    }
  }

  Future _sendMessage(
    ApiMessageModel message, {
    required List<int> recieveIds,
    ConversationBasicInfo? conversationBasicInfo,
    List<int>? onlineUsers,
    int? isSecret,
  }) async {
    var res = await _chatRepo.sendMessage(
      message,
      recieveIds: recieveIds,
      conversationBasicInfo: conversationBasicInfo,
      onlineUsers: onlineUsers,
      progress: fileProgressListener[message.messageId],
      isSecret: isSecret,
    );

    if (res.hasError) throw CustomException(res.error);

    fileProgressListener.remove(message.messageId);
    return true;
  }

  /// cái này viết ra chưa thấy dùng con mẹ gì cả đụ má
  Future sendDeleteMissedMessageLiveChat(
    ApiMessageModel message, {
    required List<int> recieveIds,
    ConversationBasicInfo? conversationBasicInfo,
    List<int>? onlineUsers,
    required int userId,
  }) async {
    await sendMissMessageLiveChat(message, recieveIds: recieveIds);
    await updateStatusLivechatMissed(
        message.conversationId,
        message.messageId,
        recieveIds,
        message.infoSupport,
        message.senderId,
        message.liveChat,
        userId);
  }

  /// dùng sau đăng nhập
  Future sendMissMessageLiveChat(
    ApiMessageModel message, {
    required List<int> recieveIds,
    ConversationBasicInfo? conversationBasicInfo,
    List<int>? onlineUsers,
  }) async {
    var res = await _chatRepo.sendMissMessageLiveChat(
      message,
      recieveIds: recieveIds,
      conversationBasicInfo: conversationBasicInfo,
      onlineUsers: onlineUsers,
    );

    if (res.hasError) throw CustomException(res.error);
    fileProgressListener.remove(message.messageId);
    return true;
  }

  _onDeleteMessageEvent(ChatEventEmitDeleteMessage event, Emitter emit) async {
    try {
      add(
        ChatEventAddProcessingMessage(
          event.message,
          processingType: ProcessMessageType.deleting,
        ),
      );
      await _deleteMessage(event.message, members: event.members);
      emit(ChatStateDeleteMessageSuccess(
        event.message.messageId,
        event.message.conversationId,
      ));
      HiveService().deleteMessageFromChatConversationBox(
          event.message.messageId, event.message.conversationId);
    } on CustomException catch (e) {
      emit(ChatStateWarningMessageError(event.message.messageId, e.error));
    } finally {
      // sendingMessage.removeMessage(event.message);
    }
  }

  _onDeleteMessageFakeEvent(
      ChatEventEmitDeleteMessageFake event, Emitter emit) async {
    try {
      add(
        ChatEventAddProcessingMessage(
          event.message,
          processingType: ProcessMessageType.deleting,
        ),
      );
      emit(ChatStateDeleteMessageSuccess(
        event.message.messageId,
        event.message.conversationId,
      ));
    } on CustomException catch (e) {
      emit(ChatStateWarningMessageError(event.message.messageId, e.error));
    } finally {}
  }

  _onDeleteMessageMultiEvent(
      ChatEventEmitDeleteMultiMessage event, Emitter emit) async {
    final messages = event.messages;
    for (ApiMessageModel message in messages) {
      try {
        add(ChatEventAddProcessingMessage(
          message,
          processingType: ProcessMessageType.deleting,
        ));
        await _deleteMessage(message, members: event.members);
        HiveService().deleteMessageFromChatConversationBox(
            message.messageId, message.conversationId);
        emit(ChatStateDeleteMessageSuccess(
          message.messageId,
          message.conversationId,
        ));
        log("delete message success ${message.message}");
      } on CustomException catch (ex) {
        log("delete message error $ex");
        emit(ChatStateWarningMessageError(message.messageId, ex.error));
      }
    }
    emit(ChatStateDeleteMultiMessageSuccess());
  }

  _onRecallMessageEvent(ChatEventEmitRecallMessage event, Emitter emit) async {
    try {
      // add(
      //   ChatEventAddProcessingMessage(
      //     event.message,
      //     processingType: ProcessMessageType.recalling,
      //   ),
      // );
      bool res = await _recallMessage(event.message, members: event.members);
      if (res) {
        emit(ChatStateEditMessageSuccess(
          event.message.conversationId,
          event.message.messageId,
          'Tin nhắn đã được thu hồi',
          editType: 2,
        ));
      }
    } on CustomException catch (e) {
      emit(ChatStateWarningMessageError(event.message.messageId, e.error));
    } finally {}
  }

  _onRecallMultiMessageEvent(
      ChatEventEmitRecallMultiMessage event, Emitter emit) async {
    try {
      final listMessage = event.message;
      for (ApiMessageModel message in listMessage) {
        try {
          bool result = await _recallMessage(message, members: event.members);
          log('_recallMessage status $result');
        } catch (ex) {
          //TODO handler error here
          log('Error recall Message ${ex}');
        }
      }
      //TODO check list result success
      emit(ChatStateEditMultiMessageSuccess());
    } on CustomException {
      // emit(ChatStateWarningMessageError(event.message.messageId, e.error));
    } finally {}
  }

  // TL 16/1/2024: Chức năng này nên ở AuthRepo chứ
  // Future<void> _onLogOutAllDevice(
  //     ChatEventLogOutAllDevice, Emitter emit) async {
  //   try {
  //     emit(ChatStateLogOutAllDevice());
  //     // print('Đăng xuất xong 123');
  //   } catch (e) {
  //     print('Error: ${e.toString()}');
  //   }
  // }

  // TL 16/1/2024: Chức năng này nên ở AuthRepo chứ
  // Future<void> _onLogOutStrangeDevice(
  //     ChatEventLogOutStrangeDevice event, Emitter emit) async {
  //   if (event.deviceId == SpUtil.getString(LocalStorageKey.idDevice))
  //     try {
  //       emit(ChatStateLogOutAllDevice());
  //     } catch (e) {
  //       print('Error: ${e.toString()}');
  //     }
  // }

  markUnreaderNotification({required String notiId}) async {
    await _chatRepo.markUnreaderNotification(notiId: notiId);
  }

  sendAvatar({
    required int conversationId,
    required int userId,
    required int senderId,
  }) {
    return _chatRepo.sendAvatar(
      conversationId: conversationId,
      userId: userId,
      senderId: senderId,
    );
  }

  @Deprecated("Dùng ChatRepo().deleteMessage() nhé")
  _deleteMessage(
    ApiMessageModel message, {
    required List<int> members,
  }) {
    return _chatRepo.deleteMessage(
      message,
      members: members,
    );
  }

  @Deprecated("Dùng ChatRepo().recallMessage() nhé")
  Future<bool> _recallMessage(
    ApiMessageModel message, {
    required List<int> members,
  }) {
    return _chatRepo.recallMessage(
      messageId: message.messageId,
      conversationId: message.conversationId,
    );
  }

  /// [generateMessageId] = null => markRead tất cả tên nhắn
  @Deprecated("Dùng ChatRepo().markReadMessages() nhé")
  markReadMessages({
    List<int>? messageIds,
    required int senderId,
    required int conversationId,
    required List<int> memebers,
  }) {
    _chatRepo.markReadMessage(
      conversationId: conversationId,
      senderId: senderId,
      memebers: memebers,
      messageIds: messageIds,
    );
  }

  sendMessage(
    ApiMessageModel message, {
    required List<int> memberIds,
    int? conversationId,
    ConversationBasicInfo? conversationBasicInfo,
    List<int>? onlineUsers,
    int? isSecret,
  }) {
    if (!message.files.isBlank) {
      fileProgressListener[message.messageId] = ValueNotifier<double>(0);
    }
    cachedMessageImageFile[message.messageId] = message.files;
    add(
      ChatEventEmitSendMessage(
        message,
        recieveIds: memberIds,
        conversationBasicInfo: conversationBasicInfo,
        onlineUsers: onlineUsers,
        isSecret: isSecret,
      ),
    );
    if (conversationId != null) {
      add(
        ChatEventEmitTypingChanged(
          false,
          userId: navigatorKey.currentContext!.userInfo().id,
          conversationId: conversationId,
          listMembers: memberIds,
        ),
      );

      /// TL 23/2/2024: Dừng bộ đếm giờ của livechat cho CTC này.
      timerRepo.stopLivechatConversationTimer(conversationId);
    }
  }

  reSendMessage(Map<String, dynamic> errorMessage) async {
    if (!(errorMessage['File'] ?? '').toString().isBlank) {
      fileProgressListener[errorMessage['MessageID']] =
          ValueNotifier<double>(0);
    }
    await _chatRepo.resendMessage(
        errorMessage, fileProgressListener[errorMessage['MessageID']]);
    emit(ChatStateSendMessageSuccess(errorMessage['MessageID']));
  }

  /// cập nhật trạng thái livechat và tạo cuộc trò chuyện Trước đăng nhập
  int? conversationIdLiveChatBeforeLogin;

  updateStatusMessageSupportBeForeLogin(
      int conversationId,
      String messageId,
      List<int>? listmembers,
      InfoSupport? infoSupports,
      int senderId,
      LiveChat? liveChat,
      int userId,
      Future<void> Function() goToChatScreen,
      ChatBloc? chatBloc) async {
    String clientId = liveChat?.clientId ?? '';
    String fromWeb = liveChat?.fromWeb ?? '';
    String clientName = liveChat?.clientName ?? '';
    String name = userInfo?.name ?? '';
    String? conversationName = '$name $clientName ($fromWeb)';
    int? fromconversationId =
        liveChat?.fromConversation == 0 || liveChat?.fromConversation == null
            ? conversationId
            : liveChat?.fromConversation;
    int status = clientId.contains('liveChatV2') ? 0 : 1;

    try {
      print(
          'Milo \n $senderId \n $userId \n $clientId \n $clientName \n $conversationName \n $fromWeb \n $fromconversationId \n $status \n ${infoSupports!.status} ');

      RequestResponse res = await _chatRepo.createLiveChatConversation(
          senderId,
          userId,
          clientId,
          clientName,
          conversationName,
          fromWeb,
          fromconversationId,
          status);

      if (!res.hasError) {
        conversationIdLiveChatBeforeLogin = json.decode(res.data)['data']
            ['conversation_info']['conversationId'];
        String createSuccessLivechat = json.decode(res.data)['data']['message'];

        if (createSuccessLivechat == "Tạo nhóm thành công") {
          print(
              'Tạo nhóm livechat trước đăng nhập thành công $conversationIdLiveChatBeforeLogin');
          goToChatScreen();
        }

        /// api
        await _chatRepo.updateStatusMessageLivechatApi(
            userId, clientId, conversationId);

        /// sóc kẹt
        _chatRepo.updateStatusMessageLivechatSocket(conversationId, messageId,
            listmembers, infoSupports, senderId, liveChat,
            chatBloc: chatBloc);

        // ChatConversationBloc(_chatRepo)..loadData();
      }
    } catch (e, s) {
      logger.logError('$e , $s');
    }
  }

  /// live chat sau dang nhap
  int? conversationIdLiveChat;

  updateStatusMessageSupport({
    required int conversationId,
    required String messageId,
    required List<int>? listmembers,
    required InfoSupport? infoSupports,
    required int senderId,
    required LiveChat? liveChat,
    required int userId,
  }) async {
    String clientId = liveChat?.clientId ?? '';
    String fromWeb = liveChat?.fromWeb ?? '';
    String clientName = liveChat?.clientName ?? '';
    String name = userInfo?.name ?? '';
    String? conversationName = '$name $clientName ($fromWeb)';
    int? fromconversationId = liveChat?.fromConversation == 0
        ? conversationId
        : liveChat?.fromConversation;
    int status = clientId.contains('liveChatV2') ? 0 : 1;
    _chatRepo.updateStatusMessageLivechatApi2(
        userId, clientId, conversationId, 1);
    RequestResponse res = await _chatRepo.createLiveChatConversation(
        senderId,
        userId,
        clientId,
        clientName,
        conversationName,
        fromWeb,
        fromconversationId,
        status);
    conversationIdLiveChat =
        json.decode(res.data)['data']['conversation_info']['conversationId'];
    // await _chatRepo.updateStatusMessageLivechatApi(
    //     userId, clientId, conversationId);
    // tryToChatScreen(
    //     chatInfo: userInfo,
    //     conversationId: conversationIdLiveChat,
    //     action: ChatFeatureAction.focus,
    //     groupType: clientId.contains('liveChatV2') ? 'LiveChatV2' : 'Normal');
  }

  /// trạng thái live chat nếu nhỡ
  updateStatusLivechatMissed(
    int conversationId,
    String messageId,
    List<int>? listmembers,
    InfoSupport? infoSupports,
    int senderId,
    LiveChat? liveChat,
    int userId,
  ) async {
    String clientId = liveChat?.clientId ?? '';

    /// api
    await _chatRepo.updateStatusMessageLivechatApi(
        userId, clientId, conversationId);

    /// sóc kẹt
    await _chatRepo.updateStatusMessageLivechatSocket(conversationId, messageId,
        listmembers, infoSupports, senderId, liveChat);
  }

  /// @groupKind:
  /// - GroupConversationCreationKind.public với nhóm thường
  /// - GroupConversationCreationKind.needModeration với nhóm kiểm duyệt
  ///
  /// @name: Tên cuộc trò chuyện
  ///
  /// @selectedContacts: IUserInfo của tất cả những người trong cuộc trò chuyện
  /// (bao gồm cả người tạo) (selectedContacts.size() phải >= 2) (Đừng để người
  /// tạo ở cuối list nhé. Bug đấy :))) )
  ///
  /// Trả về conversationId khi tạo thành công bên server
  Future<int> createGroup(
      {required List<IUserInfo> selectedContacts,
      required String conversationName,
      GroupConversationCreationKind conversationType =
          GroupConversationCreationKind.public,
      int memberApproval = 2}) async {
    if (selectedContacts.length < 2) {
      throw ExceptionError("Nhóm phải có ít nhất từ 2 thành viên trở lên");
    }
    return await chatRepo.createGroup(
        groupKind: conversationType,
        name: conversationName,
        memberIds: selectedContacts.map((e) => e.id).toList(),
        memberApproval: memberApproval);
  }

  /// return [chatId]
  ///
  /// Nếu chưa có cuộc trò chuyện [chatId] được tạo mới
  ///
  /// Nếu không trả về [chatId] cuộc trò chuyện đó
  /// TL 11/1/2024:
  /// @otherPersonId: ID của người mà mình muốn chat cùng
  /// @return: ConversationId của CTC giữa mình và @otherPersonId, hoặc null nếu không thể tạo được
  /// NOTE: Nếu chưa có cuộc trò chuyện [chatId] được tạo mới trên server
  @Deprecated("Dùng ChatRepo().getConversationId() nhé")
  Future<int> getConversationId(int senderId, int chatId) async {
    return (await ChatRepo().getConversationId(chatId))!;
  }

  // @override
  // void onEvent(ChatEvent event) {
  //   super.onEvent(event);
  //   if (event is ChatEventOnReceivedMessage) {
  //     emit(state)
  //   }
  // }
  // emit state xóa thành công - nhưng có vẻ
  // FutureOr<void> _onEventOnDeleteMessage(
  //   emit(ChatStateDeleteMessageSuccess(event.messageId, event.conversationId));
  // }

  _onEventOnDeleteMessage(ChatEventOnDeleteMessage event, Emitter emit) async {
    emit(ChatStateDeleteMessageSuccess(event.messageId, event.conversationId));
  }

  FutureOr<void> _onEventResendMessage(
      ChatEventResendMessage event, Emitter<ChatState> emit) async {
    var currentTick = DateTimeExt.currentTicks;

    for (var i = 0; i < event.messages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      var message = event.messages.elementAt(i);

      emit(ChatStateDeleteMessageSuccess(
        message.messageId,
        event.conversationId,
      ));

      await Future.delayed(const Duration(milliseconds: 100));

      var newMessage = message.copyWith(
        messageId: GeneratorService.generateMessageId(
          message.senderId,
          currentTick + i,
        ),
        message: message.message,
      );

      event.onResend?.call(newMessage);

      sendMessage(
        newMessage,
        memberIds: event.members,
      );
    }
  }

  // tạo nhắc hẹn
  createCalendar({
    required int senderId,
    required int conversationId,
    required String title,
    required String createTime,
    required String type,
    String? typeDate,
    int? emotion,
  }) {
    return _chatRepo.createCalendar(
      senderId: senderId,
      conversationId: conversationId,
      title: title,
      createTime: createTime,
      type: type,
      typeDate: typeDate ?? 'solarCalendar',
      emotion: emotion,
    );
  }

  // bình chọn tham gia
  handleParticipantCalendar({
    required String Id,
    required int userId,
    required String type,
  }) {
    return _chatRepo.handleParticipantCalendar(
      Id: Id,
      userId: userId,
      type: type,
    );
  }

  // chỉnh sửa tạo lịch hẹn
  editCalendar({
    required String idMess,
    required String title,
    required String type,
    String? typeDate,
    int? emotion,
    required String createTime,
  }) {
    return _chatRepo.editCalendar(
      idMess: idMess,
      title: title,
      type: type,
      createTime: createTime,
      emotion: emotion ?? 1,
      typeDate: typeDate ?? 'solarCalendar',
    );
  }

// // lấy chi tiết lịch hẹn
// Future<Reminder> getDetailCalendar(String id) async {
//   var res = await _chatRepo.getDetailCalendar(id: id);
//   return res.onCallBack(
//     (_) => Reminder.fromJson(json.decode(res.data)['data']['result']),
//   );
// }

// // xóa lịch hẹn
// deleteCalendar({required String id}) {
//   return _chatRepo.deleteCalendar(id: id);
// }

// // lấy lịch hẹn của một người trong nhóm
// Future<List<Reminder>> getAllCalendarOfConv(int conversationId) async {
//   var res =
//       await _chatRepo.getAllCalendarOfConv(conversationId: conversationId);

//   return res;
// }
}
