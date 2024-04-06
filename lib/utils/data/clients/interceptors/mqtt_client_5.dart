import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:sp_util/sp_util.dart';

List<SocketSentMessageModel> _listReceivedMessage = [];

class MqttClient {
  factory MqttClient() => _instance ??= MqttClient._();
  MqttClient._() {
    logger.log("MqttClient Created");
  }
  static MqttClient? _instance;

  static const String connectUrl = '43.239.223.157';

  bool isFirstConnectionAttempt = true;

  String generateRandomString(int len) {
    final random = Random();
    final result = String.fromCharCodes(
        List.generate(len, (index) => random.nextInt(33) + 89));
    return result;
  }

  // TL 16/2/2024: Biến MQTT thành nguồn data độc lập, không liên kết chặt chẽ với repo nào
  //final ChatRepo _chatRepo = chatRepo;
  final String? localUserId = SpUtil.getInt(LocalStorageKey.userId2)!.toString();

  late String clientId =
      "mqtt_" + generateRandomString(10) + '_' + (localUserId ?? '') + '_app';
  // TL 22/2/2024: Bên Trường An dùng port này.
  // Cũng thử xem xem có lấy được tin nhắn livechat không
  // NOTE: Thực ra default port của nó cũng là 1883 rồi
  // var port = 1883;
  // late final client = MqttServerClient.withPort(connectUrl, clientId, port);
  var port = 1883;
  MqttServerClient? client;
  var pongCount = 0;

  /// TL 16/2/2024: Sửa để MQTT là nguồn data độc lập với các repo.
  /// Repo nào muốn lấy data thì tự mà đi subscribe vào stream.
  final StreamController<ChatEvent> _controller = StreamController.broadcast();

  /// Nguồn ChatEvent từ MQTT, listen() mà lấy data.
  Stream<ChatEvent> get stream => _controller.stream;

  Future<MqttServerClient> connectMqttClient({String? userId}) async {
    if (client != null) {
      client!.disconnect();
    }
    late String clientId =
      "mqtt_${generateRandomString(10)}_${(userId ?? localUserId ?? '')}_app";
    logger.log(clientId, name: "MqttClientID");
    logger.log("$userId | $localUserId", name: "MqttUserID");
    client = MqttServerClient(connectUrl, clientId, maxConnectionAttempts: 3);
    client!.logging(on: false);
    client!.keepAlivePeriod = 20;
    client!.onDisconnected = onDisconnected;
    client!.onConnected = onConnected;
    client!.onSubscribed = onSubscribed;
    client!.pongCallback = pong;
    //client.autoReconnect = true;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('willtopic')
        // .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    logger.log('Client connecting....', name: "$runtimeType");
    client!.connectionMessage = connMess;

    try {
      await client!.connect('admin', 'Tuananh050901');
      isFirstConnectionAttempt = false;
    } on NoConnectionException catch (e) {
      logger.logError('Client exception: $e', null, "$runtimeType");
      client!.disconnect();
    } on SocketException catch (e) {
      logger.logError('Socket exception: $e', null, "$runtimeType");
      client!.disconnect();
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      logger.log('Client connected', name: "$runtimeType");
    } else {
      logger.logError(
          'Client connection failed - disconnecting, status is ${client?.connectionStatus}',
          null,
          "$runtimeType");
      client!.disconnect();
      //exit(-1);
    }
    // client.published!.listen((MqttPublishMessage message) {
    //   logger.log(
    //       'Published topic: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}',
    //       name: "$runtimeType");
    // });
    if (userId != null) {
      String subTopic = '${userId ?? ''}_sendMessage';
      logger.log('Subscribing to the $subTopic topic', name: "$runtimeType");
      client!.subscribe(subTopic, MqttQos.atMostOnce);

      client!.onSubscribeFail = ((subscription) {
        logger.log('Không subscribe được $subTopic rồi',
            name: "$runtimeType.connectMqttClient");
      });
    }

    // cái này có vẻ để nghe
    try {
      client!.updates.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        var topic = c[0].topic;

        // logger.log(
        //     "topic: ${topic}\npayload: ${utf8.decode(recMess.payload.message!)}",
        //     name: "$runtimeType",
        //     maxLength: 250);
        // check nghe topic ở đây vậy
        if (topic == '${userId ?? ''}_sendMessage') {
          var payload = utf8.decode(recMess.payload.message!);
          var socketSentMessageModel =
// <<<<<<< Updated upstream
              SocketSentMessageModel.fromMapOfSocket(json.decode(payload));
// =======
          SocketSentMessageModel.fromMapOfSocket(json.decode(payload));
          logger.log(socketSentMessageModel,name: "ạhdksahksadhka",maxLength: 5000);
// >>>>>>> Stashed changes
          if (_listReceivedMessage.contains(socketSentMessageModel)) {
            // Fluttertoast.showToast(msg: 'Đã nhận được tin nhắn ${socketSentMessageModel.messageId} rồi');
            return;
          }
          _listReceivedMessage.add(socketSentMessageModel);
          if ((socketSentMessageModel.type?.isLink == true ||
                  socketSentMessageModel.type?.isMap == true) &&
              socketSentMessageModel.infoLink == null) return;

          _controller.add(ChatEventOnReceivedMessage(socketSentMessageModel));
          //log quá nhiều
          // logger.log(socketSentMessageModel,
          //     name: 'ChatRepopayload_${this.hashCode}');
        }

        /// TL 22/2/2024: Những topic dưới đây chưa được subscribe.
        /// Comment thế thôi. Đây là code Khương, xóa đi xong gãy, Khương bẻ cổ mất.
        else if (topic == 'DeleteMessage_${userId}') {
          var payload = utf8.decode(recMess.payload.message!);
          logger.log(payload);
          var newRes = json.decode(payload).cast<String>().toList();
          var conversationId = int.tryParse(newRes[0]) ?? 0;
          var msgId = newRes[1];

          _controller.sink.add(ChatEventOnDeleteMessage(conversationId, msgId));
          return;
        } else if (topic == 'EditMessage_${userId}') {
          var payload = utf8.decode(recMess.payload.message!);
          logger.log(payload);
          var newRes = json.decode(payload).cast<String>().toList();
          var conversationId = int.tryParse(newRes[0]) ?? 0;
          var msgId = newRes[1];
          _controller
              .add(ChatEventOnMessageEditted(conversationId, msgId, newRes[2]));
          return;
        } else if (topic == '${userId}_outgroup') {
          // TL 22/2/2024: Bên Winform có cái này nữa. Không chắc là mình có dùng không.
        }
      });
    } catch (e) {
      logger.log('Error: ${e.toString()}');
    }

    logger.log('Sleeping....');
    await MqttUtilities.asyncSleep(80);

    // logger.log('Unsubscribing');
    // client.unsubscribe(subTopic);
    // client.unsubscribe(pubTopic);

    // await MqttUtilities.asyncSleep(2);
    // logger.log('Disconnecting');
    // client.disconnect();

    return client!;
  }

  disconnect() {
    client!.disconnect();
    logger.log("Client disconnected");
  }

  publishMessage(String pubTopic, String data) {
    if (client == null) return;
    // cái này có vẻ để bắn
    final builder = MqttPayloadBuilder();
    builder.addString(data);

    logger.log('Subscribing to the $pubTopic topic');
    // TL 21/2/2024: Thử xem liệu không nhận livechat có phải do packet bị mất không
    // client.subscribe(pubTopic, MqttQos.exactlyOnce);
    client!.subscribe(pubTopic, MqttQos.atLeastOnce);
    logger.log('Publishing our topic');
    client!.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(MqttSubscription topic) {
    logger.log('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    logger.log('OnDisconnected client callback - Client disconnection');
    if (client?.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      logger.log('OnDisconnected callback is solicited, this is correct');
    }
    //exit(-1);
  }
  

  /// The successful connect callback
  void onConnected() {
    logger.log('OnConnected client callback - Client connection was sucessful');
  }

  /// Pong callback
  void pong() {
    logger.log('Ping response client callback invoked');
  }
}

final MqttClient mqttClient = MqttClient();
