// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
// import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
// import 'package:app_chat365_pc/common/repos/auth_repo.dart';
// import 'package:app_chat365_pc/common/repos/chat_repo.dart';
// import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
// import 'package:app_chat365_pc/utils/helpers/logger.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
//
// List<SocketSentMessageModel> _listReceivedMessage = [];
//
// class MqttClient {
//   static const String connectUrl = '43.239.223.157';
//
//   String generateRandomString(int len) {
//     final random = Random();
//     final result = String.fromCharCodes(
//         List.generate(len, (index) => random.nextInt(33) + 89));
//     return result;
//   }
//
//   final ChatRepo _chatRepo = chatRepo;
//   final String? userId = AuthRepo().userInfo!.id.toString();
//
//   late String clientId =
//       "mqtt_" + generateRandomString(10) + '_' + (userId ?? '') + '_app';
//   late final client = MqttServerClient(connectUrl, clientId);
//   var pongCount = 0;
//
//   Future<MqttServerClient> connectMqttClient() async {
//     client.logging(on: false);
//     client.keepAlivePeriod = 60;
//     client.onDisconnected = onDisconnected;
//     client.onConnected = onConnected;
//     client.onSubscribed = onSubscribed;
//     client.pongCallback = pong;
//     //client.autoReconnect = true;
//
//     final connMess = MqttConnectMessage()
//         .withClientIdentifier(clientId)
//         .withWillTopic('willtopic')
//         .withWillMessage('My Will message')
//         .startClean()
//         .withWillQos(MqttQos.atLeastOnce);
//     print('Client connecting....');
//     client.connectionMessage = connMess;
//
//     try {
//       await client.connect('admin', 'Tuananh050901');
//     } on NoConnectionException catch (e) {
//       print('Client exception: $e');
//       client.disconnect();
//     } on SocketException catch (e) {
//       print('Socket exception: $e');
//       client.disconnect();
//     }
//
//     if (client.connectionStatus!.state == MqttConnectionState.connected) {
//       print('Client connected');
//     } else {
//       print(
//           'Client connection failed - disconnecting, status is ${client.connectionStatus}');
//       client.disconnect();
//       //exit(-1);
//     }
//     client.published!.listen((MqttPublishMessage message) {
//       print(
//           'Published topic: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
//     });
//     if (userId != null) {
//       String subTopic = (userId ?? '') + '_sendMessage';
//       print('Subscribing to the $subTopic topic');
//       client.subscribe(subTopic, MqttQos.atMostOnce);
//     }
//
//     // cái này có vẻ để nghe
//     try {
//       client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
//         final recMess = c![0].payload as MqttPublishMessage;
//         // check nghe topic ở đây vậy
//         if (c[0].topic == (userId ?? '') + '_sendMessage') {
//           var payload = utf8.decode(recMess.payload.message);
//           final pt =
//           MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
//           var socketSentMessageModel =
//           SocketSentMessageModel.fromMapOfSocket(json.decode(payload));
//           if (_listReceivedMessage.contains(socketSentMessageModel)) {
//             // Fluttertoast.showToast(msg: 'Đã nhận được tin nhắn ${socketSentMessageModel.messageId} rồi');
//             return;
//           }
//           _listReceivedMessage.add(socketSentMessageModel);
//           if ((socketSentMessageModel.type?.isLink == true ||
//               socketSentMessageModel.type?.isMap == true) &&
//               socketSentMessageModel.infoLink == null) return;
//           _chatRepo.streamController.sink
//               .add(ChatEventOnReceivedMessage(socketSentMessageModel));
//           //log quá nhiều
//           logger.log(socketSentMessageModel,
//               name: 'ChatRepopayload_${this.hashCode}');
//         } else if (c[0].topic == 'DeleteMessage_${userId}') {
//           var payload = utf8.decode(recMess.payload.message);
//           print(payload);
//           var newRes = json.decode(payload).cast<String>().toList();
//           var conversationId = int.tryParse(newRes[0]) ?? 0;
//           var msgId = newRes[1];
//
//           _chatRepo.streamController.sink
//               .add(ChatEventOnDeleteMessage(conversationId, msgId));
//           return;
//         } else if (c[0].topic == 'EditMessage_${userId}') {
//           var payload = utf8.decode(recMess.payload.message);
//           print(payload);
//           var newRes = json.decode(payload).cast<String>().toList();
//           var conversationId = int.tryParse(newRes[0]) ?? 0;
//           var msgId = newRes[1];
//           _chatRepo.streamController.sink
//               .add(ChatEventOnMessageEditted(conversationId, msgId, newRes[2]));
//           return;
//         }
//       });
//     } catch (e) {
//       print('Error: ${e.toString()}');
//     }
//
//     print('Sleeping....');
//     await MqttUtilities.asyncSleep(80);
//
//     // print('Unsubscribing');
//     // client.unsubscribe(subTopic);
//     // client.unsubscribe(pubTopic);
//
//     // await MqttUtilities.asyncSleep(2);
//     // print('Disconnecting');
//     // client.disconnect();
//
//     return client;
//   }
//
//   publishMessage(String pubTopic, String data) {
//     // cái này có vẻ để bắn
//     final builder = MqttClientPayloadBuilder();
//     builder.addString(data);
//
//     print('Subscribing to the $pubTopic topic');
//     client.subscribe(pubTopic, MqttQos.exactlyOnce);
//     print('Publishing our topic');
//     client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);
//   }
//
//   /// The subscribed callback
//   void onSubscribed(String topic) {
//     print('Subscription confirmed for topic $topic');
//   }
//
//   /// The unsolicited disconnect callback
//   void onDisconnected() {
//     print('OnDisconnected client callback - Client disconnection');
//     if (client.connectionStatus!.disconnectionOrigin ==
//         MqttDisconnectionOrigin.solicited) {
//       print('OnDisconnected callback is solicited, this is correct');
//     }
//     //exit(-1);
//   }
//
//   /// The successful connect callback
//   void onConnected() {
//     print('OnConnected client callback - Client connection was sucessful');
//   }
//
//   /// Pong callback
//   void pong() {
//     print('Ping response client callback invoked');
//   }
// }
//
// final MqttClient mqttClient = MqttClient();
