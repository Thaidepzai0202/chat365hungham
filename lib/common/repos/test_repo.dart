// import 'dart:async';
// import 'dart:developer';

// import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
// import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';

// class TestRepo {
//   StreamController _controller = StreamController();

//   get stream => _controller.stream;

//   TestRepo() {
//     _chatClient.emit(ChatSocketEvent.login, {1408});
//     _chatClient.on(
//       ChatSocketEvent.messageSent,
//       func,
//     );
//   }

//   func(msg) {
//     log(msg.toString());
//     _controller.sink.add(msg);
//   }

//   dispose() {
//     _controller.close();
//   }
// }
