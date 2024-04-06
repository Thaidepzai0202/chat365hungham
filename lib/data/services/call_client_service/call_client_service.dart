import 'dart:async';

import 'package:app_chat365_pc/data/services/call_client_service/call_client_events.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_client_repo.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_payload.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_protocol.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_session_service.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_state.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_type.dart';
import 'package:app_chat365_pc/utils/data/clients/interceptors/call_client.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/material.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';

import '../../../utils/ui/app_dialogs.dart';

class CallClientService {
  static CallClientService? _instance;

  factory CallClientService() => _instance ??= CallClientService._();

  CallClientService._() {
    registerEvents();
  }

  CallClient socket = callClient;

  ValueNotifier<int> callState = ValueNotifier(CallState.NONE);
  bool isLoggedIn = false;
  Completer loginCompleter = Completer();

  Map<String, dynamic> user = {};
  CallPayload? activePayload = null;
  bool videoStatus = true;
  bool audioStatus = true;
  bool incomingCallAccepted = false;
  CallSessionService? csService;
  StreamController<CallPayload> callController = StreamController.broadcast();
  CallSwitchState? currentSwitchState = null;
  StreamController<CallSwitchState> callSwitchController =
      StreamController.broadcast();
  Stream<CallPayload> get incomingCallStream => callController.stream;
  Stream<CallSwitchState> get switchToVideoStream =>
      callSwitchController.stream;
  StreamController<MediaStream> rStreamController =
      StreamController.broadcast();
  Stream<MediaStream> get rStream => rStreamController.stream;
  StreamController<MediaStream> lStreamController =
      StreamController.broadcast();
  Stream<MediaStream> get lStream => lStreamController.stream;
  StreamController<void> stopKeepaliveController = StreamController.broadcast();
  Stream get stopKeepaliveEvent => stopKeepaliveController.stream;

  Transport? sendTransport;
  Transport? recvTransport;

  Timer? keepAliveTimer;

  void registerEvents() {
    print("events registered");
    // this.socket.onAny((event, data) {
    //   print("SocketEvents: $event");
    // });
    this.socket.on(CallClientEvents.USER_LOGGEDIN, this.onLoggedIn);
    this.socket.on(CallClientEvents.CALL_ACCEPTED, this.onCallAccepted);
    this.socket.on(CallClientEvents.CALL_REJECTED, this.onCallRejected);
    this.socket.on(CallClientEvents.CALL_TIMEDOUT, this.onCallTimedOut);
    this.socket.on(CallClientEvents.CALL_BUSY, this.onCallBusy);
    this.socket.on(CallClientEvents.CALL_ONGOING, this.onCallOngoing);
    this.socket.on(CallClientEvents.CALL_ENDED, this.onCallEnded);
    this.socket.on(CallClientEvents.CALL_RECEIVE_OFFER, this.onReceiveOffer);
    this.socket.on(CallClientEvents.CALL_RECEIVE_ANSWER, this.onReceiveAnswer);
    this.socket.on(CallClientEvents.CALL_WEBRTC_READY, this.onCallReady);
    this
        .socket
        .on(CallClientEvents.CALL_RECEIVE_CANDIDATE, this.onReceiveCandidate);
    this.socket.on(CallClientEvents.SOCKET_RECONNECTED, this.onReconnect);
    this.socket.on(CallClientEvents.CALL_SWITCH_TO_VIDEO_REQUESTED,
        this.onSwitchToVideoRequest);
    this.socket.on(CallClientEvents.CALL_SWITCH_TO_VIDEO_ACCEPTED,
        this.onSwitchToVideoAccept);
    this.socket.on(CallClientEvents.CALL_SWITCH_TO_VIDEO_REJECTED,
        this.onSwitchToVideoReject);

    this.socket.on(CallClientEvents.SFU_NEW_PRODUCER, this.onNewProducer);
  }

  Future<void> waitForLoggedIn() async {
    return loginCompleter.future;
  }

  Future<Map<String, dynamic>> asyncEmit(
      String event, Map<String, dynamic> data,
      {bool hasReturnValue = true}) {
    Completer<Map<String, dynamic>> _emitCompleter = Completer();
    logger.log(data, name: "emit $event");
    if (hasReturnValue) {
      this.socket.socket.emitWithAck(event, data, ack: (response) {
        logger.log(response, name: "ack $event");
        _emitCompleter.complete(response);
      });
    } else {
      this.socket.socket.emitWithAck(event, data, ack: () {
        logger.log("callback", name: "ack $event");
        _emitCompleter.complete({});
      });
    }

    return _emitCompleter.future;
  }

  onLoggedIn(dynamic data) {
    this.isLoggedIn = true;
    if (!this.loginCompleter.isCompleted) this.loginCompleter.complete();
  }

  createSession() async {
    if (csService != null) {
      await csService?.clearSessions();
    }
    csService = CallSessionService();
    csService?.candidateStream.listen((event) {
      sendCandidate({
        'sdpMLineIndex': event.sdpMLineIndex,
        'sdpMid': event.sdpMid,
        'candidate': event.candidate,
      });
    });
    csService?.isCallReady.addListener(() {
      markCallAsReady();
    });
    csService?.localStream.addListener(() {
      MediaStream? stream = csService?.localStream.value;
      if (stream != null) {
        this.lStreamController.sink.add(stream);
      }
    });
    csService?.remoteStream.addListener(() {
      MediaStream? stream = csService?.remoteStream.value;
      if (stream != null) {
        this.rStreamController.sink.add(stream);
      }
    });
  }

  clearSession() async {
    if (csService != null) {
      CallSessionService? _csRef = csService;
      csService = null;
      _csRef?.localStream.dispose();
      _csRef?.remoteStream.dispose();
      _csRef?.candidateController.close();
      _csRef?.isCallReady.dispose();
      await _csRef?.clearSessions();
      currentSwitchState = null;
    }
  }

  dynamic onCallIncoming(dynamic payload) async {
    await createSession();
    CallPayload _payload = CallPayload(
        roomId: payload['roomId'],
        roomCode: payload['roomCode'],
        roomUrl: payload['roomUrl'],
        callerId: payload['callerId'],
        callerName: payload['callerName'] ?? "",
        callerAvatar: payload['callerAvatar'] ?? "",
        calleeId: payload['calleeId'],
        calleeName: payload['calleeName'],
        calleeAvatar: payload['calleeAvatar'] ?? "",
        callType: payload['callType'] ?? 1,
        callProtocol: payload['callProtocol'] ?? CallProtocol.PEERS);
    logger.log(_payload.callProtocol, name: "callProtocol11");
    this.callState.value = CallState.RINGING;
    this.activePayload = _payload;
    // callController.sink.add(_payload);
    // if (incomingCallAccepted) {
    //   this.acceptCall();
    //   this.incomingCallAccepted = false;
    // }
  }

  onCallAccepted(dynamic data) async {
    if (csService == null) return;
    this.callState.value = CallState.CONNECTING;
    if (this.activePayload?.callProtocol == CallProtocol.SFU) {
      logger.log("SFU CALL");
      connectSFUCall();
    } else {
      csService?.createOffer().then((offer) {
        if (offer != null)
          this.sendOffer({'sdp': offer.sdp, 'type': offer.type});
        logger.log(offer, name: "OFFERRRRR");
      });
    }
  }

  onCallRejected(dynamic data) {
    this.callState.value = CallState.REJECTED;
    this.activePayload = null;
    this.stopKeepalive();
  }

  onCallTimedOut(dynamic data) {
    this.callState.value = CallState.TIMEDOUT;
    this.activePayload = null;
    this.stopKeepalive();
  }

  onCallBusy(dynamic data) {
    this.callState.value = CallState.BUSY;
    this.activePayload = null;
    this.stopKeepalive();
  }

  onCallOngoing(dynamic data) {
    this.callState.value = CallState.ONGOING;
    this.activePayload = null;
    this.stopKeepalive();
  }

  onCallEnded(dynamic data) async {
    if (csService == null) return;
    this.callState.value = CallState.ENDED;
    this.activePayload = null;
    this.stopKeepalive();
    await clearSession();
  }

  onReceiveOffer(dynamic data) {
    if (csService == null) return;
    RTCSessionDescription offer =
        new RTCSessionDescription(data["sdp"], data["type"]);
    csService?.createAnswer(offer).then((answer) {
      if (answer != null)
        this.sendAnswer({'sdp': answer.sdp, 'type': answer.type});
      logger.log(answer, name: "ANSWERRRRR");
    });
  }

  onReceiveAnswer(dynamic data) {
    if (csService == null) return;
    RTCSessionDescription answer =
        new RTCSessionDescription(data["sdp"], data["type"]);
    csService?.onReceiveAnswer(answer);
  }

  onReceiveCandidate(dynamic data) {
    if (csService == null) return;
    RTCIceCandidate candidate = RTCIceCandidate(
        data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
    csService?.addIceCandidate(candidate);
  }

  onCallReady(dynamic data) {
    this.callState.value = CallState.CALLING;
  }

  onReconnect(dynamic data) {
    if (this.user['userId'] != null)
      this.login(
          this.user["userId"], this.user["userName"], this.user["avatar"]);
  }

  onSwitchToVideoRequest(dynamic data) {
    callSwitchController.sink.add(CallSwitchState.request);
    currentSwitchState = CallSwitchState.request;
  }

  onSwitchToVideoAccept(dynamic data) {
    callSwitchController.sink.add(CallSwitchState.accept);
    currentSwitchState = CallSwitchState.accept;
  }

  onSwitchToVideoReject(dynamic data) {
    callSwitchController.sink.add(CallSwitchState.reject);
    currentSwitchState = CallSwitchState.reject;
  }

  requestSwitchToVideo() {
    this.socket.emit(CallClientEvents.CALL_SWITCH_TO_VIDEO);
  }

  acceptSwitchToVideo() {
    this.socket.emit(CallClientEvents.CALL_SWITCH_TO_VIDEO_ACCEPT);
  }

  rejectSwitchToVideo() {
    this.socket.emit(CallClientEvents.CALL_SWITCH_TO_VIDEO_REJECT);
  }

  login(userId, userName, avatar) {
    if (avatar.runtimeType != String) avatar = "";
    this.user = {
      'userId': userId.toString(),
      'userName': userName.toString(),
      'userAvatar': avatar.toString()
    };
    this.socket.emit(CallClientEvents.USER_LOGIN, userId.toString());
  }

  // createCall(Map<String, dynamic> callee, int callType) async {
  //   await createSession();
  //   if (csService == null) return;
  //   await csService?.newSession();
  //   CallPayload payload = CallPayload(
  //       roomId: user['userId'],
  //       roomCode: user['userId'],
  //       roomUrl: "",
  //       callerId: user['userId'],
  //       callerName: user['userId'],
  //       calleeId: callee['userId'],
  //       calleeName: callee['userName'],
  //       calleeAvatar: callee['userAvatar'],
  //       callType: callType);
  //   this.socket.emit(CallClientEvents.CALL_START, payload.toMap());
  //   this.activePayload = new CallPayload(
  //       roomId: user['userId'],
  //       roomCode: user['userId'],
  //       roomUrl: "",
  //       callerId: user['userId'],
  //       callerName: user['userId'],
  //       calleeId: callee['userId'],
  //       calleeName: callee['userName'],
  //       callType: callType);
  //   this.callState.value = CallState.RINGING;
  //   this.setCallType(callType);
  // }

  createCall(String calleeId, String calleeName, String calleeAvt,
      int callType) async {
    await createSession();
    if (csService == null) return;
    await csService?.newSession();
    this.sendTransport?.close();
    this.recvTransport?.close();
    this.sendTransport = null;
    this.recvTransport = null;

    bool isSFUAvailable = await CallClientRepo().getServiceStatus();

    logger.log(isSFUAvailable, name: "isSFUAvailable");

    CallPayload payload = CallPayload(
        roomId: user['userId'],
        roomCode: user['userId'],
        roomUrl: "",
        callerId: user['userId'],
        callerName: user['userName'],
        callerAvatar: user['userAvatar'],
        calleeId: calleeId,
        calleeName: calleeName,
        calleeAvatar: calleeAvt,
        callType: callType,
        callProtocol: isSFUAvailable ? CallProtocol.SFU : CallProtocol.PEERS);
    this.socket.emit(CallClientEvents.CALL_START, payload.toMap());
    this.activePayload = payload;
    this.callState.value = CallState.RINGING;
    this.setCallType(callType);
    this.startKeepalive();
  }

  acceptCall() async {
    if (csService == null) return;
    if (this.activePayload != null) {
      await csService?.newSession();
      this.sendTransport?.close();
      this.recvTransport?.close();
      this.sendTransport = null;
      this.recvTransport = null;
      this
          .socket
          .emit(CallClientEvents.CALL_ACCEPT, this.activePayload?.toMap());
      this.callState.value = CallState.CONNECTING;
      this.setCallType(this.activePayload?.callType);
      this.startKeepalive();
      if (this.activePayload?.callProtocol == CallProtocol.SFU) {
        connectSFUCall();
      }
    }
  }

  acceptNextCall() {
    this.incomingCallAccepted = true;
  }

  rejectCall() async {
    if (this.activePayload != null) {
      this
          .socket
          .emit(CallClientEvents.CALL_REJECT, this.activePayload?.toMap());
      this.callState.value = CallState.REJECTED;
    }
    this.activePayload = null;
    await clearSession();
  }

  endCall() async {
    if (this.activePayload != null) {
      this.socket.emit(CallClientEvents.CALL_END, this.activePayload?.toMap());
      this.callState.value = CallState.ENDED;
    }
    this.activePayload = null;
    this.stopKeepalive();
    await clearSession();
  }

  sendOffer(webrtcOffer) {
    this.socket.emit(CallClientEvents.CALL_SEND_OFFER, webrtcOffer);
  }

  sendAnswer(webrtcAnswer) {
    this.socket.emit(CallClientEvents.CALL_SEND_ANSWER, webrtcAnswer);
  }

  sendCandidate(iceCandidate) {
    this.socket.emit(CallClientEvents.CALL_SEND_CANDIDATE, iceCandidate);
  }

  Future<Map<String, dynamic>> getRouterCapabilities() {
    return this.asyncEmit(CallClientEvents.SFU_GET_RTP_CAPABILITIES, {});
  }

  connectSFUCall() async {
    // AppDialogs.toast("Bạn đang sử dụng cuộc gọi tốc độ cao");
    while (this.csService?.device == null) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    this.sendTransport = await createSendTransport(
        this.csService?.device?.rtpCapabilities.toMap());
    this
        .csService
        ?.publish(this.sendTransport!, this.csService!.localStream.value!);
  }

  Future<Transport?> createSendTransport(Map? rtpCapabilities) async {
    Map pTransportData =
        await asyncEmit(CallClientEvents.SFU_PTRANSPORT_CREATE, {
      'forceTcp': false,
      'rtpCapabilities': rtpCapabilities,
    });
    Transport? _sendTransport =
        await this.csService?.createSendTransport(pTransportData['params']);

    logger.log(_sendTransport?.id, name: "sendTransportCreated");

    _sendTransport?.on('connect', (Map event) async {
      await this.asyncEmit(CallClientEvents.SFU_PTRANSPORT_CONNECT,
          {'dtlsParameters': event['dtlsParameters'].toMap()},
          hasReturnValue: false);
      event['callback']();
    });

    _sendTransport?.on('produce', (Map event) async {
      Map pcdata = await this.asyncEmit(CallClientEvents.SFU_PRODUCE, {
        'transportId': _sendTransport.id,
        'kind': event['kind'],
        'rtpParameters': event['rtpParameters'].toMap()
      });
      event['callback'](pcdata['id']);
    });

    _sendTransport?.on('connectionstatechange', (Map event) {
      dynamic state = event["connectionState"];
      logger.log("sendTransport: $state");
      switch (state) {
        case 'connecting':
          break;

        case 'connected':
          break;

        case 'failed':
          _sendTransport.close();
          break;

        default:
          return;
      }
    });
    return _sendTransport;
  }

  Future<Transport?> createRecvTransport() async {
    Map cTransportData =
        await this.asyncEmit(CallClientEvents.SFU_CTRANSPORT_CREATE, {});

    Transport? _recvTransport =
        await this.csService?.createRecvTransport(cTransportData['params']);

    _recvTransport?.on('connect', (Map event) async {
      logger.log("recvTransportConnected $event");
      await this.asyncEmit(
          CallClientEvents.SFU_CTRANSPORT_CONNECT,
          {
            'transportId': _recvTransport.id,
            'dtlsParameters': event['dtlsParameters'].toMap()
          },
          hasReturnValue: false);
      event['callback']();
    });

    _recvTransport?.on('connectionstatechange', (Map event) {
      dynamic state = event["connectionState"];
      logger.log(event, name: "recvTransportEvent");
      switch (state) {
        case 'connecting':
          break;

        case 'connected':
          break;

        case 'failed':
          _recvTransport.close();
          break;

        default:
          return;
      }
    });

    return _recvTransport;
  }

  onNewProducer(data) async {
    while (this.csService?.device == null) {
      await Future.delayed(Duration(milliseconds: 100));
      logger.log("waiting for device");
    }
    logger.log("onNewProducer $data");
    if (this.recvTransport == null)
      this.recvTransport = await this.createRecvTransport();

    String userId = data["id"];
    String kind = data["kind"];
    Map rtpCapabilities = this.csService!.device!.rtpCapabilities.toMap();
    Map<String, dynamic> params = await this.asyncEmit(
        CallClientEvents.SFU_CONSUME,
        {'rtpCapabilities': rtpCapabilities, 'userId': userId, 'kind': kind});
    this.csService?.subscribe(this.recvTransport!, params, userId, kind);
    while (this.recvTransport?.connectionState != "connected") {
      await Future.delayed(Duration(milliseconds: 100));
    }
    this.socket.emit(CallClientEvents.SFU_RESUME, kind);
  }

  markCallAsReady() {
    this.socket.emit(CallClientEvents.CALL_CLIENT_READY);
  }

  changeMicStatus(audioStatus) {
    if (csService == null) return;
    this.audioStatus = audioStatus;
    csService?.changeMicStatus(audioStatus);
    this.socket.emit(CallClientEvents.CALL_CHANGE_MEDIA_DEVICES, {
      'userId': this.user['userId'],
      'audio': this.audioStatus,
      'video': this.videoStatus
    });
  }

  emitMicStatus(audioStatus) {
    this.audioStatus = audioStatus;
    this.socket.emit(CallClientEvents.CALL_CHANGE_MEDIA_DEVICES, {
      'userId': this.user['userId'],
      'audio': this.audioStatus,
      'video': this.videoStatus
    });
  }

  changeCameraStatus(videoStatus) {
    if (csService == null) return;
    this.videoStatus = videoStatus;
    csService?.changeCameraStatus(videoStatus);
    this.socket.emit(CallClientEvents.CALL_CHANGE_MEDIA_DEVICES, {
      'userId': this.user['userId'],
      'audio': this.audioStatus,
      'video': this.videoStatus
    });
  }

  setCallType(type) {
    if (type == CallType.VIDEO) {
      this.changeCameraStatus(true);
    } else if (type == CallType.AUDIO) {
      this.changeCameraStatus(false);
    }
  }

  startKeepalive() {
    this.socket.emit(CallClientEvents.CALL_KEEPALIVE);
    logger.log("Started", name: "keepalive");
    if (this.keepAliveTimer != null) {
      this.keepAliveTimer?.cancel();
    }
    this.keepAliveTimer = Timer.periodic(Duration(milliseconds: 2000), (timer) {
      if (this.callState.value == CallState.CONNECTING ||
          this.callState.value == CallState.CALLING ||
          this.callState.value == CallState.RINGING) {
        this.socket.emit(CallClientEvents.CALL_KEEPALIVE);
      } else {
        this.stopKeepalive();
      }
    });
  }

  stopKeepalive() {
    logger.log("Stopped", name: "keepalive");
    if (this.keepAliveTimer != null) {
      this.keepAliveTimer?.cancel();
    }
    this.keepAliveTimer = null;
    stopKeepaliveController.sink.add(null);
  }
}

enum CallSwitchState { request, accept, reject, none }
