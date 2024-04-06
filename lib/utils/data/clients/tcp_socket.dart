/* TL 22/2/2024: Thí nghiệm làm socket thất bại

import "dart:io";
import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/auto_delete_message_time_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/enums/emoji.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:http/http.dart';

/// TL 22/2/2024: Một chiếc socket thử nghiệm, để xem có sửa được lỗi
/// ChatClient không bắt được event "SendMessage" không
class TcpSocket365 {
  static TcpSocket365? _instance;
  factory TcpSocket365() => _instance ??= TcpSocket365._();

  late final Socket _socket;

  TcpSocket365._() {
    try {
      logger.log("Connecting", name: "$runtimeType");

      Socket.connect(
              InternetAddress("43.239.223.142", type: InternetAddressType.IPv4),
              3000,
              timeout: Duration(seconds: 5))
          .then((socket) {
        logger.log("Connected", name: "$runtimeType");
        _socket = socket;
        _bindPacketParser();
        SocketSentMessageModel socketMsg = SocketSentMessageModel(
            isCheck: false,
            conversationId: 0,
            message: "leuleu",
            messageId: "-1",
            senderId: -1,
            createAt: DateTime.now(),
            autoDeleteMessageTimeModel:
                AutoDeleteMessageTimeModel(deleteType: -1, deleteTime: -1));

        Request httpRequest = Request("GET", Uri.parse(ChatSocketEvent.sendMessage));
        // Debug. Nhét thử tí data xem có ra gì không
        emit(ChatSocketEvent.messageSent, httpRequest);
      });
    } catch (err, stack) {
      logger.logError("Không kết nối được server: $err", null, "$runtimeType");
    }
    // IO.io(
    //   'http://43.239.223.142:3000/',
    //   IO.OptionBuilder()
    //       .setTransports(['websocket'])
    //       .enableAutoConnect()
    //       .setReconnectionDelay(500)
    //       .setReconnectionDelayMax(1000)
    //       .setReconnectionAttempts(5)
    //       .setRandomizationFactor(0)
    //       .enableReconnection()
    //       .setTimeout(30000)
    //       .setExtraHeaders({
    //         'Connection': 'Upgrade',
    //         'Upgrade': 'websocket',
    //         'secure': true,
    //       })
    //       .build(),

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
  }

  /// TL 6/1/2024 note: Emit event cho tất cả những người khác (trừ mình!!!)
  emit(String event, [dynamic data]) {
    //if(event!=ChatSocketEvent.login&&event!=ChatSocketEvent.login_v2) {
    logger.log('${event}: ${data.toString()}',
        color: StrColor.emitSocket, name: '$runtimeType.emit');
    return _socket.add(
      utf8.encode(event),
      // TODO
    );
    //}
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
  // emit(String event, [dynamic data]) {
  //   //if(event!=ChatSocketEvent.login&&event!=ChatSocketEvent.login_v2) {
  //   logger.log('${event}: ${data.toString()}',
  //       color: StrColor.emitSocket, name: '$runtimeType.emit');
  //   return _socket.emit(
  //     event,
  //     data is List ? Iterable.generate(data.length, (i) => data[i]) : data,
  //   );
  //   //}
  // }

  StreamController<ChatEvent> _controller = StreamController.broadcast();

  /// NOTE: Chưa hỗ trợ tất cả mọi loại event.
  Stream<ChatEvent> get stream => _controller.stream;

  void _bindPacketParser() {
    _socket.listen((event) {
      SocketSentMessageModel socketMsg = SocketSentMessageModel(
          isCheck: false,
          conversationId: 0,
          message: String.fromCharCodes(event),
          messageId: "-1",
          senderId: -1,
          createAt: DateTime.now(),
          autoDeleteMessageTimeModel:
              AutoDeleteMessageTimeModel(deleteType: -1, deleteTime: -1));
      logger.log("${socketMsg.message}", name: "$runtimeType");

      _controller.add(ChatEventOnReceivedMessage(socketMsg));
    });
    // _socket
    //   ..on(
    //     ChatSocketEvent.messageSent,
    //     (receivedMsg) async {
    //       logger.log("Nhận tin nhắn.", name: "$runtimeType");
    //       var socketSentMessageModel =
    //           SocketSentMessageModel.fromMapOfSocket(receivedMsg);

    //       if (((socketSentMessageModel.type?.isLink == true ||
    //               socketSentMessageModel.type?.isMap == true) &&
    //           socketSentMessageModel.infoLink == null)) return;

    //       logger.log("Nhận tin nhắn: ${socketSentMessageModel.message}",
    //           name: "$runtimeType");
    //       _emitChatEvent(ChatEventOnReceivedMessage(socketSentMessageModel));

    //       if (RegExp(r'\d+ was add friend to \d+')
    //           .hasMatch(socketSentMessageModel.message ?? '')) {
    //         var ids = socketSentMessageModel.message!.getListIntFromThis();
    //         var requestId = ids[1];
    //         var receiveId = ids[0];
    //         if (ids[0] != AuthRepo().userId!) {
    //           _emitChatEvent(ChatEventOnFriendStatusChanged(
    //             requestId,
    //             receiveId,
    //             FriendStatus.request,
    //           ));
    //         }
    //       }
    //     },
    //   )

    //   // Live chẹt :]
    //   //
    //   // Event này xuất hiện khi mình bấm vào tin nhắn livechat (bắt livechat).
    //   // Khi ấy, cả tin nhắn và CTC sẽ bị xóa.
    //   //
    //   // NOTE: Nếu có tin nhắn hai nhà tuyển dụng, bắt một cái thì cái kia và CTC
    //   // vẫn phải còn chứ. Đúng không?
    //   ..on(ChatSocketEvent.updateStatusMessageSupport, (res) {
    //     InfoSupport infoSupport = InfoSupport.fromMap(json.decode(res[2]));
    //     var conversationId = int.tryParse(res[0].toString()) ?? res[0];
    //     String messageId = res[1].toString();
    //     _emitChatEvent(ChatEventOnUpdateStatusMessageSupport(
    //         conversationId: conversationId,
    //         messageId: messageId,
    //         infoSupport: infoSupport));
    //   })
    //   ..on(ChatSocketEvent.tagUser, (res) {
    //     // TODO. Không biết tagUser này để làm gì?
    //   })
    //   ..on(
    //     ChatSocketEvent.markReadAllMessage,
    //     (res) async {
    //       var senderId = res[0];
    //       var conversationId = res[1];
    //       _emitChatEvent(ChatEventOnMarkReadAllMessages(
    //           senderId: senderId, conversationId: conversationId));
    //     },
    //   )
    //   ..on(
    //     ChatSocketEvent.typing,
    //     (res) {
    //       var senderId = int.parse(res[0].toString());
    //       var conversationId = int.parse(res[1].toString());
    //       _emitChatEvent(ChatEventOnTyping(
    //         senderId: senderId,
    //         conversationId: conversationId,
    //       ));
    //     },
    //   )
    //   ..on(
    //     ChatSocketEvent.stopTyping,
    //     (res) {
    //       var senderId = res[0];
    //       var conversationId = res[1];
    //       _emitChatEvent(ChatEventOnStopTyping(
    //         senderId: int.parse(senderId.toString()),
    //         conversationId: int.parse(conversationId.toString()),
    //       ));
    //     },
    //   )
    //   ..on(ChatSocketEvent.recievedEmotionMessage, (res) {
    //     _emitChatEvent(
    //       ChatEventOnRecievedEmotionMessage(
    //         senderId: res[0],
    //         messageId: res[1],
    //         conversationId: res[2],
    //         emoji: Emoji.fromId(int.parse(res[3].toString())),
    //         checked: res[5],
    //         messageType: MessageTypeExt.valueOf(res[6]),
    //         message: res[7],
    //       ),
    //     );
    //   })
    //   ..on(ChatSocketEvent.messageEdited, (res) {
    //     _emitChatEvent(
    //       ChatEventOnMessageEditted(
    //         int.tryParse(res[0].toString()),
    //         res[1],
    //         res[2] ?? 'Tin nhắn đã được thu hồi',
    //       ),
    //     );
    //   })
    //   ..on(ChatSocketEvent.newConversationAdded, (res) {
    //     _emitChatEvent(ChatEventOnReceivedMessage(
    //       SocketSentMessageModel(
    //         conversationId: int.parse(res.toString()),
    //         createAt: DateTime.now().toLocal(),
    //         messageId: '',
    //         // TL 16/1/2024: Có khi nào đây là thủ phạm hay khiến getChatItemModel()
    //         // báo lỗi ID 0?
    //         senderId: -1,
    //         type: MessageType.text,
    //         autoDeleteMessageTimeModel: AutoDeleteMessageTimeModel.defaultModel,
    //         isCheck: false,
    //       ),
    //     ));
    //   })
    //   ..on(ChatSocketEvent.newMemberAddedToGroup, (res) async {
    //     var conversationId = int.parse(res[0].toString());
    //     var memberIds =
    //         List<int>.from(res[1].map((e) => int.parse(e.toString())));
    //     var users = await UserInfoRepo().getUserInfos(memberIds);
    //     _emitChatEvent(ChatEventOnNewMemberAddedToGroup(
    //       conversationId,
    //       users.toList(),
    //     ));
    //   })
    //   ..on(ChatSocketEvent.requestAddFriend, (res) {
    //     logger.log(res, name: ChatSocketEvent.requestAddFriend);
    //     res = (res as List).flattenDeep;
    //     var requestId = res[0];
    //     var receiveId = res[1];
    //     _emitChatEvent(ChatEventOnFriendStatusChanged(
    //       requestId,
    //       receiveId,
    //       FriendStatus.request,
    //     ));
    //   })
    //   ..on(ChatSocketEvent.acceptRequestAddFriend, (res) {
    //     res = (res as List).flattenDeep;
    //     var senderId = res[1];
    //     var responseUserId = res[0];
    //     _emitChatEvent(ChatEventOnFriendStatusChanged(
    //       senderId,
    //       responseUserId,
    //       FriendStatus.accept,
    //     ));
    //   })
    //   ..on(ChatSocketEvent.declineRequestAddFriend, (res) {
    //     res = (res as List).flattenDeep;
    //     var senderId = res[1];
    //     var declineUserId = res[0];
    //     _emitChatEvent(ChatEventOnFriendStatusChanged(
    //       senderId,
    //       declineUserId,
    //       FriendStatus.decline,
    //     ));
    //   })
    //   ..on(ChatSocketEvent.nickNameChanged, (res) {
    //     var newNickname = res[1];
    //     var userId = int.parse(res[0].toString());
    //     _emitChatEvent(
    //         ChatEventOnNickNameChanged(name: newNickname, userId: userId));
    //   })
    //   ..on(ChatSocketEvent.pinMessage, (res) async {
    //     var conversationId = res[0];
    //     var messageId = res[1];
    //     _emitChatEvent(ChatEventOnPinMessage(conversationId, messageId));
    //   })
    //   ..on(ChatSocketEvent.unPinMessage, (res) async {
    //     int conversationId = res;
    //     _emitChatEvent(ChatEventOnUnpinMessage(conversationId));
    //   })
    //   ..on(ChatSocketEvent.messageDeleted, (res) {
    //     var newRes = (res as List).flattenDeep;
    //     var conversationId = newRes[0];
    //     var msgId = newRes[1];
    //     _emitChatEvent(ChatEventOnDeleteMessage(conversationId, msgId));
    //   })
    //   ..on(ChatSocketEvent.deleteContact, (res) {
    //     var newRes = (res as List).flattenDeep;
    //     var userId = newRes[0];
    //     var chatId = newRes[1];
    //     _emitChatEvent(ChatEventOnDeleteContact(userId, chatId));
    //   })
    //   ..on(ChatSocketEvent.changeFavoriteConversationStatus, (res) async {
    //     var newRes = (res as List).flattenDeep;
    //     var conversationId = newRes[0];
    //     var isChangeToFavorite = newRes[1] == 1;
    //     _emitChatEvent(ChatEventOnChangeFavoriteStatus(
    //       conversationId,
    //       isChangeToFavorite,
    //     ));
    //   })
    //   ..on(ChatSocketEvent.outGroup, (res) async {
    //     var newRes = (res as List).flattenDeep;
    //     var conversationId = newRes[0];
    //     var deletedMemberId = newRes[1];
    //     var newAdminId = newRes[2];
    //     _emitChatEvent(ChatEventOnOutGroup(
    //       conversationId,
    //       deletedMemberId,
    //       newAdminId,
    //     ));
    //   })
    //   ..on(ChatSocketEvent.disbandGroup, (res) {
    //     int conversationId = int.tryParse(res[0]) ?? -1;
    //     _emitChatEvent(ChatEventOnOutGroup(
    //       conversationId,
    //       AuthRepo().userId ?? -1,
    //       -1,
    //     ));
    //   })
    //   ..on(ChatSocketEvent.checkNotification, (res) async {
    //     logger.log(res, name: ChatSocketEvent.checkNotification);
    //     var conversationId = int.tryParse(res[0]) ?? -1;
    //     // 0 là đang tắt 1 là bật
    //     var notification = res[1];
    //     var isOnNotification = (notification == 1);
    //     _emitChatEvent(ChatEventOnChangeNotification(
    //       conversationId,
    //       isOnNotification,
    //     ));
    //   })
    //   ..on(ChatSocketEvent.createSecretConversation, (res) async {
    //     int conversationId = res[0];
    //     String typeGroup = res[1];
    //     _emitChatEvent(
    //         ChatEventOnCreateSecretConversation(conversationId, typeGroup));
    //   })
    //   ..on(ChatSocketEvent.updateDeleteTime, (res) async {
    //     var conversationId = res[0];
    //     List<dynamic> senderId =
    //         res[1].map((e) => int.tryParse(e.toString())).toList();
    //     var deleteTime = res[2];
    //     _emitChatEvent(
    //         ChatEventOnUpdateDeleteTime(conversationId, senderId, deleteTime));
    //   })
    //   ..on(ChatSocketEvent.logoutStrangeDevice, (res) {
    //     var idDevice = res;
    //     _emitChatEvent(ChatEventLogOutStrangeDevice(
    //       idDevice,
    //     ));
    //   })
    //   ..on(ChatSocketEvent.logoutAllDevice, (res) {
    //     _emitChatEvent(ChatEventLogOutAllDevice());
    //   })
    //   ..on(ChatSocketEvent.groupNameChanged, (res) {
    //     var name = res[1];
    //     var conversationId = int.parse(res[0].toString());
    //     _emitChatEvent(ChatEventOnGroupNameChanged(
    //         name: name, conversationId: conversationId));
    //   });

    // TL 18/2/2024: Còn một lô một lốc event nữa cơ
    //
    // TODO
    //
    // ..on(ChatSocketEvent.nickNameChanged, _onNicknameChangedHandler)
    // ..on(ChatSocketEvent.changeAvatarUser, _onAvatarChangedHandler)
    // ..on(ChatSocketEvent.changeGroupAvatar, _onAvatarGroupChangedHandler)
    // ..on(ChatSocketEvent.userDisplayNameChanged, _onUserNameChangedHandler)
    // ..on(ChatSocketEvent.presenceStatusChanged, _onUserStatusChangedHandler)
    // ..on(ChatSocketEvent.moodMessageChanged, _onStatusChangedHandler)
    // ..on(ChatSocketEvent.login, _onLoggedInChangedHander)
    // ..on(ChatSocketEvent.logout, _onLoggedOutChangedHandler);
  }

  void _emitChatEvent(ChatEvent event) {
    _controller.add(event);
  }
}
*/