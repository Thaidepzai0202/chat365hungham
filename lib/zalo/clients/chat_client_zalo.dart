import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/auto_delete_message_time_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';

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
import 'package:app_chat365_pc/zalo/chat_socket_event_zalo.dart';
import 'package:app_chat365_pc/zalo/models/conversation_item_model.dart';
import 'package:app_chat365_pc/zalo/models/friend_zalo_model.dart';
import 'package:app_chat365_pc/zalo/models/user_model_zalo.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatClientZalo {
  static ChatClientZalo? _instance;

  factory ChatClientZalo() => _instance ??= ChatClientZalo._();

  ChatClientZalo._() {
    logger.log("Sinh ra zalo ở ${StackTrace.current}", name: "$runtimeType");
    _socket = IO.io(
      // 'http://103.138.113.154:2908',
      'http://43.239.223.143:2908',
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
    );

    _listenEvents();
  }

  late final IO.Socket _socket;

  IO.Socket get socket => _socket;

  _listenEvents() {
    _socket.onAny((e, d) {
      logger.log("$e $d", name: "SocketEventsZalo");
    });
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
    //if(event!=ChatSocketEventZalo.login&&event!=ChatSocketEventZalo.login_v2) {
    logger.log('$event: ${data.toString()}',
        color: StrColor.emitSocket, name: 'SocketEventsEmit123');
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
      ..on(ChatSocketEventZalo.allowQRLogin, (res) {
        // var base64 = res[0] as String;
        var base64 = res.toString();
        _emitChatEvent(ChatEventOnQRLoginZalo(base6QR: base64));
      })
      ..on(ChatSocketEventZalo.loginQRZaloSuccess, (res) {
        // print('----res----${res.toString()}');
        _emitChatEvent(ChatEventLoginSuccessZalo(
            userInfoZalo: UserInfoZalo.fromJson(res)));
      })
      // ..on(ChatSocketEventZalo.updateListZalo, (res) {
      //   // print('iszalo - - ${res['list_zalo'].length}----');
      //   List<dynamic> listFriendZalo =
      //       res['list_zalo'][0]['list_friend'].toList();
      //   List<FriendZalo> _listFriendReal = [];
      //   listFriendZalo.forEach((element) {
      //     FriendZalo friendZalo = FriendZalo.fromJson(element);
      //     _listFriendReal.add(friendZalo);
      //   });
      //   _emitChatEvent(UpdateListZalo(listFriend: _listFriendReal));
      // })
      ..on(ChatSocketEventZalo.listFriendZalo, (res) {
        List<dynamic> listFriendZalo = res['list_friend'].toList();
        List<FriendZalo> _listFriendReal = [];
        listFriendZalo.forEach((element) {
          FriendZalo friendZalo = FriendZalo.fromJson(element);
          _listFriendReal.add(friendZalo);
        });
        _emitChatEvent(UpdateListZalo(listFriend: _listFriendReal));
      })
      ..on(ChatSocketEventZalo.listChat, (res) {
        print('-----list_chat-----${res['list_chat'][0].runtimeType}');
        List<ConversationItemZaloModel> _listConversationZalo = [];
        res['list_chat'].forEach((element){
          _listConversationZalo.add(ConversationItemZaloModel.fromJson(element));
        });
        _emitChatEvent(ListConversationZalo(listConversationZalo: _listConversationZalo));
      });
  }

  void _emitChatEvent(ChatEvent event) {
    _controller.add(event);
  }
}

final ChatClientZalo chatClientZalo = ChatClientZalo();
