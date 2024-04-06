import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/auto_delete_message_time_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_status.dart';
import 'package:app_chat365_pc/utils/data/enums/emoji.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/enums/unauth_type.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatClient {
  static ChatClient? _instance;

  factory ChatClient() => _instance ??= ChatClient._();

  ChatClient._() {
    // logger.log("Sinh ra ở ${StackTrace.current}", name: "$runtimeType");
    _socket = IO.io(
      'https://socket.timviec365.vn',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setReconnectionDelay(500)
          .setReconnectionDelayMax(1000)
          .setReconnectionAttempts(5)
          .setRandomizationFactor(0)
          .enableReconnection()
          .setTimeout(30000)
          .setExtraHeaders({
            'Connection': 'Upgrade',
            'Upgrade': 'websocket',
            'secure': true,
          })
          .build(),

      // {
      //   'transports': ,
      //   'autoConnect': true,
      //   'reconnectionDelay': 500,
      //   'reconnectionDelayMax': 1000,
      //   'randomizationFactor': 0,
      //   'reconnection': true,
      //   'timeout': 30000,
      //   'extraHeaders': {
      //     'Connection': 'Upgrade',
      //     'Upgrade': 'websocket',
      //     'secure': true,
      //   },
      // },
    );

    _listenEvents();
  }

  late final IO.Socket _socket;

  IO.Socket get socket => _socket;

  _listenEvents() {
    // _socket.onAny((e, d) {logger.log("$e $d", name: "SocketEvents");});
    _socket.onConnect(_connectHandler);
    _socket.onConnectError(_connectErrorHandler);
    _socket.onConnectTimeout(_connectTimeoutHandler);
    _socket.onError(_errorHandler);

    _bindPacketParsers();
  }

  _stopListenEvents() {
    _socket.off('connect', _connectHandler);
    _socket.off('connect_error', _connectErrorHandler);
    _socket.off('connect_timeout', _connectTimeoutHandler);
    _socket.off('disconnect', _disconnectHandler);
    _socket.off('error', _errorHandler);
  }

  _connectHandler(dynamic value) => _log('Connected', value);

  _connectErrorHandler(dynamic value) => _log('ConnectError', value);

  _connectTimeoutHandler(dynamic value) => _log('ConnectTimeout', value);

  _disconnectHandler(dynamic value) => _log('Disconnect', value);

  _errorHandler(dynamic value) => _log('Error', value);

  _log(String type, dynamic msg) {
    log("$type: $msg", name: '$runtimeType');
  }

  /// TL 6/1/2024 note: Emit event cho tất cả những người khác (trừ mình!!!)
  emit(String event, [dynamic data]) {
    //if(event!=ChatSocketEvent.login&&event!=ChatSocketEvent.login_v2) {
    logger.log('$event: ${data.toString()}',
        color: StrColor.emitSocket, name: 'SocketEventsEmit');
    return _socket.emit(
      event,
      data is List ? Iterable.generate(data.length, (i) => data[i]) : data,
    );
    //}
  }

  // @Deprecated(
  //     "Ưu tiên dùng UnifiedRealtimeDataSource nhé. Nếu vẫn muốn dùng trực tiếp thì dùng [stream]. [stream] đã parse data thành event, dễ dùng hơn.")
  void Function(String event, dynamic Function(dynamic) handler) get on =>
      _socket.on;

  void Function(String event, [dynamic Function(dynamic) handler]) get off =>
      _socket.off;

  final StreamController<ChatEvent> _controller = StreamController.broadcast();

  /// NOTE: Chưa hỗ trợ tất cả mọi loại event.
  Stream<ChatEvent> get stream => _controller.stream;

  reconnect() {
    // _socket..connect();
    // ..reconnect();
    // _stopListenEvents();
    // _listenEvents();
  }

  // _disconnect() {
  //   _stopListenEvents();
  //   _socket.disconnect();
  //   _instance = null;
  // }

  static dispose() {
    // Memory leak issues in iOS when closing socket.
    // https://pub.dev/packages/socket_io_client#:~:text=Memory%20leak%20issues%20in%20iOS%20when%20closing%20socket.%20%23
    _instance?._socket.dispose();
  }

  void _bindPacketParsers() {
    // _socket.onAny((event, data) {
    //   logger.log('$event: ${data.toString()}',
    //       name: '$runtimeType._bindPacketParser.onAny');
    // });
    _socket
      ..on(
        ChatSocketEvent.messageSent,
        (receivedMsg) async {
          logger.log("Nhận tin nhắn.", name: "$runtimeType");
          var socketSentMessageModel =
              SocketSentMessageModel.fromMapOfSocket(receivedMsg);

          if (((socketSentMessageModel.type?.isLink == true ||
                  socketSentMessageModel.type?.isMap == true) &&
              socketSentMessageModel.infoLink == null)) return;

          logger.log("Nhận tin nhắn: ${socketSentMessageModel.message}",
              name: "$runtimeType");
          _emitChatEvent(ChatEventOnReceivedMessage(socketSentMessageModel));

          if (RegExp(r'\d+ was add friend to \d+')
              .hasMatch(socketSentMessageModel.message ?? '')) {
            var ids = socketSentMessageModel.message!.getListIntFromThis();
            var requestId = ids[1];
            var receiveId = ids[0];
            if (ids[0] != AuthRepo().userId!) {
              _emitChatEvent(ChatEventOnFriendStatusChanged(
                requestId,
                receiveId,
                FriendStatus.request,
              ));
            }
          }
        },
      )

      // Live chẹt :]
      //
      // Event này xuất hiện khi mình bấm vào tin nhắn livechat (bắt livechat).
      // Khi ấy, cả tin nhắn và CTC sẽ bị xóa.
      //
      // NOTE: Nếu có tin nhắn hai nhà tuyển dụng, bắt một cái thì cái kia và CTC
      // vẫn phải còn chứ. Đúng không?
      ..on(ChatSocketEvent.updateStatusMessageSupport, (res) {
        InfoSupport infoSupport = InfoSupport.fromMap(json.decode(res[2]));
        var conversationId = int.tryParse(res[0].toString()) ?? res[0];
        String messageId = res[1].toString();
        _emitChatEvent(ChatEventOnUpdateStatusMessageSupport(
            conversationId: conversationId,
            messageId: messageId,
            infoSupport: infoSupport));
      })
      ..on(ChatSocketEvent.tagUser, (res) {
        // TODO. Không biết tagUser này để làm gì?
      })
      ..on(
        ChatSocketEvent.markReadAllMessage,
        (res) async {
          var senderId = res[0];
          var conversationId = res[1];
          _emitChatEvent(ChatEventOnMarkReadAllMessages(
              senderId: senderId, conversationId: conversationId));
        },
      )
      ..on(
        ChatSocketEvent.typing,
        (res) {
          var senderId = int.parse(res[0].toString());
          var conversationId = int.parse(res[1].toString());
          _emitChatEvent(ChatEventOnTyping(
            senderId: senderId,
            conversationId: conversationId,
          ));
        },
      )
      ..on(
        ChatSocketEvent.stopTyping,
        (res) {
          var senderId = res[0];
          var conversationId = res[1];
          _emitChatEvent(ChatEventOnStopTyping(
            senderId: int.parse(senderId.toString()),
            conversationId: int.parse(conversationId.toString()),
          ));
        },
      )
      ..on(ChatSocketEvent.recievedEmotionMessage, (res) {
        _emitChatEvent(
          ChatEventOnRecievedEmotionMessage(
            senderId: res[0],
            messageId: res[1],
            conversationId: res[2],
            emoji: Emoji.fromId(int.parse(res[3].toString())),
            checked: res[5],
            messageType: MessageTypeExt.valueOf(res[6]),
            message: res[7],
          ),
        );
      })
      ..on(ChatSocketEvent.messageEdited, (res) {
        _emitChatEvent(
          ChatEventOnMessageEditted(
            int.tryParse(res[0].toString()) ?? -1,
            res[1],
            res[2] ?? 'Tin nhắn đã được thu hồi',
          ),
        );
      })
      ..on(ChatSocketEvent.newConversationAdded, (res) {
        _emitChatEvent(ChatEventOnReceivedMessage(
          SocketSentMessageModel(
            conversationId: int.parse(res.toString()),
            createAt: DateTime.now().toLocal(),
            messageId: '',
            // TL 16/1/2024: Có khi nào đây là thủ phạm hay khiến getChatItemModel()
            // báo lỗi ID 0?
            senderId: -1,
            type: MessageType.text,
            autoDeleteMessageTimeModel: AutoDeleteMessageTimeModel.defaultModel,
            isCheck: false,
          ),
        ));
      })
      ..on(ChatSocketEvent.newMemberAddedToGroup, (res) async {
        var conversationId = int.parse(res[0].toString());
        var memberIds =
            List<int>.from(res[1].map((e) => int.parse(e.toString())));
        var users = await UserInfoRepo().getUserInfos(memberIds);
        _emitChatEvent(ChatEventOnNewMemberAddedToGroup(
          conversationId,
          users.toList(),
        ));
      })
      ..on(ChatSocketEvent.requestAddFriend, (res) {
        logger.log(res, name: ChatSocketEvent.requestAddFriend);
        res = (res as List).flattenDeep;
        var requestId = res[0];
        var receiveId = res[1];
        _emitChatEvent(ChatEventOnFriendStatusChanged(
          requestId,
          receiveId,
          FriendStatus.request,
        ));
      })
      ..on(ChatSocketEvent.acceptRequestAddFriend, (res) {
        res = (res as List).flattenDeep;
        var senderId = res[1];
        var responseUserId = res[0];
        _emitChatEvent(ChatEventOnFriendStatusChanged(
          senderId,
          responseUserId,
          FriendStatus.accept,
        ));
      })
      ..on(ChatSocketEvent.declineRequestAddFriend, (res) {
        res = (res as List).flattenDeep;
        var senderId = res[1];
        var declineUserId = res[0];
        _emitChatEvent(ChatEventOnFriendStatusChanged(
          senderId,
          declineUserId,
          FriendStatus.decline,
        ));
      })
      ..on(ChatSocketEvent.nickNameChanged, (res) {
        var newNickname = res[1];
        var userId = int.parse(res[0].toString());
        _emitChatEvent(
            ChatEventOnNickNameChanged(name: newNickname, userId: userId));
      })
      ..on(ChatSocketEvent.pinMessage, (res) async {
        var conversationId = res[0];
        var messageId = res[1];
        _emitChatEvent(ChatEventOnPinMessage(conversationId, messageId));
      })
      ..on(ChatSocketEvent.unPinMessage, (res) async {
        int conversationId = res;
        _emitChatEvent(ChatEventOnUnpinMessage(conversationId));
      })
      ..on(ChatSocketEvent.messageDeleted, (res) {
        var newRes = (res as List).flattenDeep;
        var conversationId = newRes[0];
        var msgId = newRes[1];
        _emitChatEvent(ChatEventOnDeleteMessage(conversationId, msgId));
      })
      ..on(ChatSocketEvent.deleteContact, (res) {
        var newRes = (res as List).flattenDeep;
        var userId = newRes[0];
        var chatId = newRes[1];
        _emitChatEvent(ChatEventOnDeleteContact(userId, chatId));
      })
      ..on(ChatSocketEvent.changeFavoriteConversationStatus, (res) async {
        var newRes = (res as List).flattenDeep;
        var conversationId = newRes[0];
        var isChangeToFavorite = newRes[1] == 1;
        _emitChatEvent(ChatEventOnChangeFavoriteStatus(
          conversationId,
          isChangeToFavorite,
        ));
      })
      ..on(ChatSocketEvent.outGroup, (res) async {
        var newRes = (res as List).flattenDeep;
        var conversationId = newRes[0];
        var deletedMemberId = newRes[1];
        var newAdminId = newRes[2];
        _emitChatEvent(ChatEventOnOutGroup(
          conversationId,
          deletedMemberId,
          newAdminId,
        ));
      })
      ..on(ChatSocketEvent.disbandGroup, (res) {
        int conversationId = int.tryParse(res[0]) ?? -1;
        _emitChatEvent(ChatEventOnOutGroup(
          conversationId,
          AuthRepo().userId ?? -1,
          -1,
        ));
      })
      ..on(ChatSocketEvent.checkNotification, (res) async {
        logger.log(res, name: ChatSocketEvent.checkNotification);
        var conversationId = int.tryParse(res[0]) ?? -1;
        // 0 là đang tắt 1 là bật
        var notification = res[1];
        var isOnNotification = (notification == 1);
        _emitChatEvent(ChatEventOnChangeNotification(
          conversationId,
          isOnNotification,
        ));
      })
      ..on(ChatSocketEvent.createSecretConversation, (res) async {
        int conversationId = res[0];
        String typeGroup = res[1];
        _emitChatEvent(
            ChatEventOnCreateSecretConversation(conversationId, typeGroup));
      })
      ..on(ChatSocketEvent.updateDeleteTime, (res) async {
        var conversationId = res[0];
        List<dynamic> senderId =
            res[1].map((e) => int.tryParse(e.toString())).toList();
        var deleteTime = res[2];
        _emitChatEvent(
            ChatEventOnUpdateDeleteTime(conversationId, senderId, deleteTime));
      })
      ..on(ChatSocketEvent.logoutStrangeDevice, (res) {
        var idDevice = res;
        _emitChatEvent(ChatEventLogOutStrangeDevice(
          idDevice,
        ));
      })
      ..on(ChatSocketEvent.logoutAllDevice, (res) {
        _emitChatEvent(ChatEventLogOutAllDevice());
      })
      ..on(ChatSocketEvent.groupNameChanged, (res) {
        var name = res[1];
        var conversationId = int.parse(res[0].toString());
        _emitChatEvent(ChatEventOnGroupNameChanged(
            name: name, conversationId: conversationId));
      })
      ..on(ChatSocketEvent.nickNameChanged, (res) {
        var newNickname = res[1];
        var userId = int.parse(res[0].toString());
        _emitChatEvent(
          ChatEventOnNickNameChanged(name: newNickname, userId: userId),
        );
      })
      ..on(ChatSocketEvent.changeAvatarUser, (res) {
        var avatar = res[1] as String;
        var userId = int.parse(res[0].toString());

        _emitChatEvent(
          ChatEventOnUserAvatarChanged(
            userId: userId,
            avatar: avatar,
          ),
        );
      })
      ..on(ChatSocketEvent.changeGroupAvatar, (res) {
        var avatar = res[1] as String;
        var conversationId = int.parse(res[0].toString());
        _emitChatEvent(ChatEventOnGroupAvatarChanged(
          conversationId: conversationId,
          avatar: avatar,
        ));
      })
      ..on(ChatSocketEvent.userDisplayNameChanged, (res) {
        var name = res[1] as String;
        var userId = int.parse(res[0].toString());
        _emitChatEvent(
          ChatEventOnUserNameChanged(
            userId: userId,
            name: name,
          ),
        );
      })
      ..on(ChatSocketEvent.presenceStatusChanged, (res) {
        var newStatus = res[1];
        var userId = int.parse(res[0].toString());
        _emitChatEvent(
          ChatEventOnUserStatusChanged(
            userId: userId,
            newStatus: UserStatus.fromId(newStatus),
          ),
        );
      })
      ..on(ChatSocketEvent.moodMessageChanged, (res) {
        var userId = int.parse(res[0].toString());
        var newStatusMessage = res[1];
        _emitChatEvent(
          ChatEventOnUserStatusMessageChanged(
            userId: userId,
            newStatusMessage: newStatusMessage,
          ),
        );
      })
      ..on(ChatSocketEvent.login, (res) {
        int? userId;

        /// TL 23/2/2024: Có ông thần bắn tin nhắn kèm test ở main.dart. Chịu đấy.
        if (res is List<dynamic>) {
          logger.log("Test login packet caught: ${res}", name: "$runtimeType");
          userId = res[0]; //int.parse(res.toString());
        } else {
          userId = res;
        }
        if (userId == null) {
          return;
        }
        try {
          _emitChatEvent(
            ChatEventUserActiveTimeChanged(
              userId: userId,
              newAuthStatus: AuthStatus.authenticated,
              lastActive: null,
            ),
          );
        } catch (err, stack) {
          logger.logError(
              "packet: ${res.toString()}\nerr: ${err}", stack, "$runtimeType");
        }
      })
      ..on(ChatSocketEvent.logout, (res) {
        try {
          var params = (res as Iterable).flattenDeep;
          if (params[0] == null) return;
          var unauthType = UnauthTypeExt.fromId(params[1]);
          // userId lúc thì String lúc thì int. Chịu đấy.
          int userId = int.parse(params[0].toString());
          if (userId == -1) {
            return;
          }
          _controller.add(
            ChatEventUserActiveTimeChanged(
              userId: userId,
              newAuthStatus: AuthStatus.unauthenticated,
              lastActive: unauthType == UnauthType.disconnect
                  ? DateTime.now()
                  : DateTime.now().add(const Duration(days: 10)),
            ),
          );
        } catch (err, stack) {
          logger.logError(
              "packet: ${res.toString()}\nError: $err", stack, "$runtimeType");
        }
      })
      ..on(ChatSocketEvent.allowQRLogin, (res) {
        var params = (res as Iterable).flattenDeep;
        String base64Account = params[1].replaceAll('+', '');
        String account = utf8.decode(base64.decode(base64Account));
        String md5 = utf8.decode(base64.decode(params[2]));
        int userType = int.tryParse(params[3].toString())??0;
        int userId = int.tryParse(params[4].toString())??0;
        logger.log("$userId $userType $account $md5");
        _emitChatEvent(ChatEventOnQRLogin(userId: userId, userType: userType, account: account, md5: md5));
      });
  }

  void _emitChatEvent(ChatEvent event) {
    _controller.add(event);
  }
}

final ChatClient chatClient = ChatClient();
