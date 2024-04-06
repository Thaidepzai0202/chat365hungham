import 'dart:async';
import 'dart:io';

import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/clients/interceptors/call_client.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';

class CallSession {
  CallSession({required this.sid, required this.pid});

  String pid;
  String sid;
  RTCPeerConnection? pc;
  RTCDataChannel? dc;
  List<RTCIceCandidate> remoteCandidates = [];
}

final Map<String, dynamic> _config = {
  'mandatory': {},
  'optional': [
    {'DtlsSrtpKeyAgreement': true},
  ]
};

Map<String, dynamic> _iceServers = {
  'iceServers': [
    {'url': "stun:43.239.223.10:3478"},
    {
      'urls': "turn:43.239.223.10:3478",
      'username': "Tuananh05",
      'credential': "Tuananh050901"
    }
    // {'url': 'stun:stun.l.google.com:19302'},
    // {
    //   'urls': "turn:us-0.turn.peerjs.com:3478",
    //   'username': "peerjs",
    //   'credential': "peerjsp"
    // }
  ],
};

class CallSessionService {
  CallSessionService() {}

  Map<String, CallSession> _sessions = {};
  ValueNotifier<MediaStream?> localStream = ValueNotifier(null);
  ValueNotifier<MediaStream?> remoteStream = ValueNotifier(null);

  RTCPeerConnection? pc;

  StreamController<RTCIceCandidate> candidateController =
  StreamController<RTCIceCandidate>.broadcast();
  Stream<RTCIceCandidate> get candidateStream => candidateController.stream;

  ValueNotifier<bool> isCallReady = ValueNotifier(false);

  Device? device;

  StreamController<Producer> _pStreamController = StreamController.broadcast();
  Stream<Producer> get producerStream => _pStreamController.stream;
  StreamController<Consumer> _cStreamController = StreamController.broadcast();
  Stream<Consumer> get consumerStream => _cStreamController.stream;

  void registerEvents() {
    this.pc?.onTrack = (event) {
      if (event.streams.isNotEmpty && event.track.kind == 'video') {
        remoteStream.value = event.streams[0];
        this.isCallReady.value = true;
      }
    };

    // this.pc?.onAddStream = (stream) {
    //   remoteStream.value = stream;
    //   this.ccService.markCallAsReady();
    // };

    this.pc?.onIceCandidate = (event) async {
      await Future.delayed(const Duration(milliseconds: 0), () {
        if (event.candidate != null) {
          candidateController.sink.add(event);
        }
      });
    };

    this.consumerStream.listen((Consumer consumer) async {
      if (remoteStream.value == null) {
        remoteStream.value = await createLocalMediaStream("consumer");
      }
      remoteStream.value?.addTrack(consumer.track);
      this.isCallReady.value = true;
    });
  }

  Future<MediaStream> createStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };
    MediaStream stream =
    await navigator.mediaDevices.getUserMedia(mediaConstraints);
    return stream;
  }

  Future<void> newSession() async {
    if (this.pc != null) {
      await clearSessions();
    }
    this.localStream.value = await createStream();
    this.pc = await createPeerConnection({
      "iceServers": [
        {
          "credential": "",
          "urls": ["stun:stun.l.google.com:19302"],
          "username": ""
        },
        {
          "credential": "",
          "urls": ["stun:43.239.223.10:3478"],
          "username": ""
        },
        {
          "credential": "peerjsp",
          "urls": ["turn:us-0.turn.peerjs.com:3478"],
          "username": "peerjs"
        },
        {
          'urls': ["turn:43.239.223.10:3478"],
          'credential': "Tuananh050901",
          'username': "Tuananh05",
        }
      ],
      "sdpSemantics": "unified-plan"
    });


    dynamic res = await ccService.getRouterCapabilities();
    dynamic rtpCapabilities = res['capabilities'];
    List<RtpCodecCapability> codecs = List.generate(
        rtpCapabilities["codecs"].length,
            (index) =>
            RtpCodecCapability.fromMap(rtpCapabilities["codecs"][index]));
    List<RtpHeaderExtension> headerExtensions = List.generate(
        rtpCapabilities["headerExtensions"].length,
            (index) => RtpHeaderExtension.fromMap(
            rtpCapabilities["headerExtensions"][index]));
    headerExtensions
        .removeWhere((element) => element.uri == 'urn:3gpp:video-orientation');
    await loadDevice(
        RtpCapabilities(codecs: codecs, headerExtensions: headerExtensions));
    registerEvents();
    localStream.value!.getTracks().forEach((track) {
      pc!.addTrack(track, localStream.value!);
    });
    if (Platform.isIOS) {
      localStream.value!.getAudioTracks()[0].enableSpeakerphone(true);
    }
  }

  Future<void> clearSessions() async {
    print("STREAM CLEAR SESSION");
    if (localStream.value != null) {
      await Future.forEach<MediaStreamTrack>(localStream.value!.getTracks(),
              (element) async {
            print("LOCAL STREAM REMOVED");
            await element.stop();
          });
      await localStream.value!.dispose();
    }
    if (remoteStream.value != null) {
      await Future.forEach<MediaStreamTrack>(remoteStream.value!.getTracks(),
              (element) async {
            print("REMOTE STREAM REMOVED");
            await element.stop();
          });
      try{
       await remoteStream.value!.dispose();
      }catch(e, s){
        logger.log(e, name: "Bug nè");
        logger.log(s, name: "Bug nè");
      }
     remoteStream.value = null;
    }

    _sessions.forEach((key, sess) async {
      await sess.pc?.close();
      await sess.dc?.close();
    });
    _sessions.clear();
    // check
    await pc?.close();
    await pc?.dispose();
    this.pc = null;
    callClient
      ..clearListener()
      ..addListener();
  }

  Future<RTCSessionDescription?> createOffer() async {
    try {
      if (this.pc != null) {
        RTCSessionDescription description = await this.pc!.createOffer();
        await this.pc!.setLocalDescription(description);
        return description;
      }
    } catch (e, s) {
      print(s);
      print(e.toString());
    }
    return null;
  }

  Future<RTCSessionDescription?> createAnswer(
      RTCSessionDescription offer) async {
    try {
      if (this.pc != null) {
        await this.pc!.setRemoteDescription(offer);
        RTCSessionDescription description = await this.pc!.createAnswer();
        await this.pc!.setLocalDescription(description);
        return description;
      }
    } catch (e, s) {
      print(s);
      print(e.toString());
    }
    return null;
  }

  Future<void> onReceiveAnswer(RTCSessionDescription answer) async {
    if (this.pc != null) {
      await this.pc!.setRemoteDescription(answer);
    }
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    if (this.pc != null) {
      await this.pc!.addCandidate(candidate);
    }
  }

  void changeMicStatus(bool status) {
    if (localStream.value != null) {
      localStream.value!.getAudioTracks()[0].enabled = status;
    }
  }

  void changeCameraStatus(bool status) {
    if (localStream.value != null) {
      localStream.value!.getVideoTracks()[0].enabled = status;
    }
  }

  void setSpeaker(bool enable) {
    try {
      localStream.value!.getAudioTracks()[0].enableSpeakerphone(enable);
    } catch (e) {}
  }

  void switchCamera() {
    if (localStream.value != null) {
      Helper.switchCamera(localStream.value!.getVideoTracks()[0]);
    }
  }

  loadDevice(RtpCapabilities routerRtpCapabilities) async {
    device = Device();
    await device?.load(routerRtpCapabilities: routerRtpCapabilities);
  }

  Transport? createSendTransport(params) {
    return this.device?.createSendTransport(
      id: params["id"],
      dtlsParameters: DtlsParameters.fromMap(params["dtlsParameters"]),
      iceParameters: IceParameters.fromMap(params["iceParameters"]),
      iceCandidates: List.generate(params["iceCandidates"].length,
              (index) => IceCandidate.fromMap(params["iceCandidates"][index])),
      producerCallback: (Producer producer) {
        print("Producer callback");
        _pStreamController.sink.add(producer);
      },
    );
  }

  Transport? createRecvTransport(params) {
    return this.device?.createRecvTransport(
        id: params["id"],
        dtlsParameters: DtlsParameters.fromMap(params["dtlsParameters"]),
        iceParameters: IceParameters.fromMap(params["iceParameters"]),
        iceCandidates: List.generate(params["iceCandidates"].length,
                (index) => IceCandidate.fromMap(params["iceCandidates"][index])),
        consumerCallback: (Consumer consumer, dynamic accept) {
          _cStreamController.sink.add(consumer);
        });
  }

  publish(Transport transport, MediaStream stream) {
    MediaStreamTrack videoTrack = stream.getVideoTracks()[0];
    MediaStreamTrack audioTrack = stream.getAudioTracks()[0];
    List<RtpEncodingParameters> encodings = [
      RtpEncodingParameters.fromMap({"maxBitrate": 100000}),
      RtpEncodingParameters.fromMap({"maxBitrate": 300000}),
      RtpEncodingParameters.fromMap({"maxBitrate": 900000})
    ];
    ProducerCodecOptions codecOptions =
    ProducerCodecOptions(videoGoogleStartBitrate: 1000);
    transport.produce(
      track: videoTrack,
      stream: stream,
      source: 'webcam',
      encodings: encodings,
      codecOptions: codecOptions,
    );

    transport.produce(track: audioTrack, stream: stream, source: 'microphone');
  }

  subscribe(Transport transport, Map<String, dynamic> params, String userId,
      String kind) async {
    transport.consume(
        id: params["id"],
        producerId: params["producerId"],
        peerId: userId,
        kind: kind == "video"
            ? RTCRtpMediaType.RTCRtpMediaTypeVideo
            : RTCRtpMediaType.RTCRtpMediaTypeAudio,
        rtpParameters: RtpParameters.fromMap(params["rtpParameters"]));
  }
}

CallSessionService csService = CallSessionService();
