import 'dart:developer' show log;

import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CallClient {
  static CallClient? _instance;
  // Function(dynamic msg)? onMessage;
  Function()? onOpen;
  Function()? onClose;

  factory CallClient() => _instance ??= CallClient._();

  CallClient._() {
    _socket = IO.io(
      'https://skvideocall.timviec365.vn',
      {
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnectionDelay': 500,
        'reconnectionDelayMax': 1000,
        'randomizationFactor': 0,
        'reconnection': true,
        'timeout': 30000,
        'extraHeaders': {
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
          'secure': true,
        },
      },
    );
    _listenEvents();
  }

  late final IO.Socket _socket;

  IO.Socket get socket => _socket;

  _listenEvents() {
    _socket.onConnect(_connectHandler);
    _socket.onConnectError(_connectErrorHandler);
    _socket.onConnectTimeout(_connectTimeoutHandler);
    _socket.onError(_errorHandler);
  }

  _stopListenEvents() {
    _socket.off('connect', _connectHandler);
    _socket.off('connect_error', _connectErrorHandler);
    _socket.off('connect_timeout', _connectTimeoutHandler);
    _socket.off('disconnect', _disconnectHandler);
    _socket.off('error', _errorHandler);
  }

  _connectHandler(dynamic value) {
    onOpen?.call();
    _log('Connection', value);
  }

  _connectErrorHandler(dynamic value) {
    onClose?.call();
    _log('ConnectionError', value);
  }

  _connectTimeoutHandler(dynamic value) => _log('ConnectTimeout', value);

  _disconnectHandler(dynamic value) => _log('Disconnect', value);

  _errorHandler(dynamic value) => _log('Error', value);

  _log(String type, dynamic msg) {
    log("$type: $msg", name: 'CallClientSocket');
  }

  emit(String event, [dynamic data]) {
    logger.log('$data', name: 'emit $event Log', color: StrColor.cyan);
    try {
      _socket.emit(
        event,
        data is List ? Iterable.generate(data.length, (i) => data[i]) : data,
      );
    } catch (e) {
      print("emit err: ${e}");
    }
  }

  void Function(String event, dynamic Function(dynamic) handler) get on =>
      _socket.on;

  void Function(String event, [dynamic Function(dynamic) handler]) get off =>
      _socket.off;

  reconnect() {
    // _socket..connect();
    // ..reconnect();
    // _stopListenEvents();
    // _listenEvents();
  }

  _disconnect() {
    _stopListenEvents();
    _socket.disconnect();
    _instance = null;
  }

  clearListener() {
    logger.log('Clear CallSocketListener', name: 'Call Socket');
    _stopListenEvents();
  }

  addListener() {
    logger.log('Add CallSocketListener', name: 'Call Socket');
    _listenEvents();
  }

  static dispose() {
    // Memory leak issues in iOS when closing socket.
    // https://pub.dev/packages/socket_io_client#:~:text=Memory%20leak%20issues%20in%20iOS%20when%20closing%20socket.%20%23
    _instance?._socket.dispose();
  }
}

final CallClient callClient = CallClient();
