import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_client_events.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_client_service.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_session_service.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_state.dart';
import 'package:app_chat365_pc/modules/call/phone_call/model/device_model.dart';
import 'package:app_chat365_pc/modules/call/phone_call/widget/circle_button.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/clients/interceptors/call_client.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/overlay_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../../common/widgets/painter/percent_indicator.dart';
import '../../../../main.dart';

class CallScreen extends StatefulWidget {
  CallScreen({
    Key? key,
    required this.userInfo,
    required this.idCaller,
    required this.idCallee,
    required this.idConversation,
    required this.idRoom,
    required this.avatarAnother,
    required this.checkCall,
    required this.checkCallee,
    required this.initialized,
    this.accepted = false,
    this.nameAnother = '',
    // this.scale,
    this.startedAt,
    this.scale,
    // required this.window
  }) : super(key: key);
  // final WindowController window;
  final IUserInfo userInfo;
  final String idCaller;
  final String idCallee;
  final String idConversation;
  final String idRoom;
  final dynamic avatarAnother;
  final String? nameAnother;
  // final ValueNotifier<bool>? scale;

  //check là người gọi hay người nhận, true->người nhận
  final bool checkCallee;

  // check nếu = true thì là được chấp nhận từ thông báo (callKit)
  final bool accepted;

  //check là videoCall hay voiceCall, true ->videoCall
  final bool checkCall;

  final bool initialized;

  final ValueNotifier<bool>? scale;

  DateTime? startedAt;

  static final String arugUserInfo = 'userInfo';
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  CallClientService callService = CallClientService();
  CallSessionService? get sessionService => callService.csService;

  ValueNotifier<bool> incalling = ValueNotifier(false);

  ValueNotifier<bool> speaker = ValueNotifier(false);
  ValueNotifier<bool> mic = ValueNotifier(true);
  ValueNotifier<bool> micCallee = ValueNotifier(true);
  ValueNotifier<bool> camera = ValueNotifier(true);
  ValueNotifier<bool> cameraCallee = ValueNotifier(true);

  final audioPlay = AudioPlayer();

  ValueNotifier<bool> splitScreen = ValueNotifier(false);

  Timer? waitingTimer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // waitingTimer = Timer(Duration(seconds: 30), () => _endCall());

    _connect();
    calleeMicCam();
    callEnded();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.checkCallee) {
        playAudio();
      }
    });

    if (_localRenderer.srcObject == null &&
        sessionService!.localStream.value != null) {
      _localRenderer.initialize().then((_) {
        setState(() {
          _localRenderer.srcObject = sessionService!.localStream.value;
        });
      });
    }

    if (_remoteRenderer.srcObject == null &&
        sessionService!.remoteStream.value != null) {
      _remoteRenderer.initialize().then((_) {
        setState(() {
          _remoteRenderer.srcObject = sessionService!.remoteStream.value;
        });
      });
    }
  }

  @override
  deactivate() {
    logger.log("STREAM DEACTIVATE");
    audioPlay.dispose();
    ccService.callState.removeListener(_callEventListener);
    super.deactivate();
    callService.stopKeepalive();
    _localRenderer.dispose();

    if (Platform.isMacOS) {
      _remoteRenderer.dispose();
    }
  }

  void playAudio() async {
    audioPlay.play(AssetSource('audios/nhacho.mp3'));
  }

  void pauseAudio() async {
    await audioPlay.pause();
  }

  Future<void> _connect() async {
    String userAvatar = "";
    if (widget.userInfo.avatar.runtimeType == String) {
      userAvatar = widget.userInfo.avatar!;
    }
    if (!widget.checkCallee) {
      if (widget.checkCall) {
        callService.createCall(
            widget.idCallee, widget.nameAnother!, userAvatar, 1);
      } else {
        callService.createCall(
            widget.idCallee, widget.nameAnother!, userAvatar, 2);
      }
    }
    callService.callState.addListener(_callEventListener);

    callService.lStream.listen((stream) {
      logger.log("LOCAL STREAM ${stream.id}");
      _localRenderer.initialize().then((_) {
        setState(() {
          _localRenderer.srcObject = stream;
        });
      });
    });

    callService.rStream.listen((stream) {
      logger.log("REMOTE STREAM ${stream.id}");
      _remoteRenderer.initialize().then((_) {
        setState(() {
          _remoteRenderer.srcObject = stream;
        });
      });
    });

    if (widget.accepted) {
      incalling.value = true;
      _accept();
    }
  }

  _callEventListener() {
    int state = callService.callState.value;
    print('State-----------------$state');
    logger.log("STREAM STATE: $state");
    switch (state) {
      case CallState.NONE:
        break;
      case CallState.RINGING:
        break;
      case CallState.CONNECTING:
        break;
      case CallState.CALLING:
        pauseAudio();
        incalling.value = true;
        speaker.value = true;
        csService.setSpeaker(true);
        _startTimer();
        break;
      case CallState.ENDED:
        incalling.value = false;
        break;
      case CallState.REJECTED:
        _endCall();
        break;
      case CallState.TIMEDOUT:
        break;
      case CallState.BUSY:
        break;
      case CallState.ONGOING:
        break;
    }
  }

  _endCall() {
    waitingTimer?.cancel();
    callService.endCall();
    if (overlayState == null) {
      AppRouter.back(context);
    } else {
      try {
        callEntry?.remove();
      } catch (e) {}
      callEntry = null;
    }
  }

  calleeMicCam() {
    callClient.on(CallClientEvents.CALL_UPDATE_MEDIA_DEVICES_STATUS,
        (response) {
      micCallee.value = response['audio'];
      cameraCallee.value = response['video'];
    });
  }

  Timer? _timer;
  ValueNotifier<Duration> _time = ValueNotifier(Duration.zero);
  void _startTimer() {
    waitingTimer?.cancel();
    if (_timer == null) {
      if (widget.startedAt != null) {
        _time.value = DateTime.now().difference(widget.startedAt!);
      } else {
        _time.value = Duration.zero;
      }
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          _time.value = Duration(seconds: _time.value.inSeconds + 1);
        }
      });
    }
  }

  callEnded() {
    callClient.on(CallClientEvents.CALL_ENDED, (response) {
      _endCall();
      pauseAudio();
    });
  }

  _accept() {
    callService.acceptCall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.checkCall ? videoCall() : voiceCall(),
      bottomNavigationBar: bottomBarCall(),
    );
  }

  Widget videoCall() {
    return ValueListenableBuilder(
        valueListenable: splitScreen,
        builder: (context, value, _) {
          return splitScreen.value
              ? SplitScreen()
              : Stack(
                  children: [
                    //chưa vào cuộc gọi sẽ hiện thị cam local, vào cuộc gọi hiển thị cam remote
                    ValueListenableBuilder(
                        valueListenable: incalling,
                        builder: (context, value, _) {
                          return !incalling.value
                              ? displayLocalCamera(_localRenderer)
                              : Stack(
                                  children: [
                                    displayRemoteCamera(_remoteRenderer),
                                    Positioned(
                                        top: 0,
                                        right: 0,
                                        child: displayLocalCameraCalling(
                                            _localRenderer))
                                  ],
                                );
                        }),

                    //hiển thị avatar, vào cuộc gọi k hiển thị avatar
                    ValueListenableBuilder(
                        valueListenable: incalling,
                        builder: (context, value, _) {
                          return incalling.value
                              ? SizedBox()
                              : widget.avatarAnother != null
                                  ? displayAvatar(widget.avatarAnother, true)
                                  : Image.asset(
                                      fit: BoxFit.contain,
                                      Images.img_non_avatar,
                                    );
                        }),

                    Positioned(
                        top: 10,
                        left: 10,
                        child: InkWell(
                          onTap: () {
                            widget.scale!.value = true;
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: AppColors.black.withOpacity(0.5)),
                            child: Center(
                              child: SvgPicture.asset(
                                Images.ic_arrow_left,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ))
                  ],
                );
        });
  }

  Widget voiceCall() {
    return Stack(
      children: [
        // hiển thị phông nền
        Container(
          width: context.mediaQuerySize.width,
          height: context.mediaQuerySize.height,
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.1),
          ),
          child: widget.avatarAnother != null
              ? CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.avatarAnother,
                  errorWidget: (_, __, ___) {
                    return Image.asset(Images.img_chat365);
                  },
                )
              : Image.asset(
                  fit: BoxFit.contain,
                  Images.img_non_avatar,
                ),
        ),

        //hiển thị avatar
        ValueListenableBuilder(
            valueListenable: incalling,
            builder: (context, value, _) {
              return incalling.value
                  ? SizedBox()
                  : widget.avatarAnother != null
                      ? displayAvatar(widget.avatarAnother, true)
                      : Image.asset(
                          fit: BoxFit.contain,
                          Images.img_non_avatar,
                        );
            }),

        // hiển thị bộ đếm giờ
        ValueListenableBuilder(
            valueListenable: incalling,
            builder: (context, value, _) {
              return incalling.value ? timer() : SizedBox();
            }),

        //hiển thị tên callee
        ValueListenableBuilder(
            valueListenable: incalling,
            builder: (context, value, _) {
              return incalling.value
                  ? name(widget.nameAnother!, true)
                  : SizedBox();
            }),

        Positioned(
            top: 10,
            left: 10,
            child: InkWell(
              onTap: () {
                widget.scale!.value = true;
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: AppColors.black.withOpacity(0.5)),
                child: Center(
                  child: SvgPicture.asset(
                    Images.ic_arrow_left,
                    color: AppColors.white,
                  ),
                ),
              ),
            ))
      ],
    );
  }

  Widget displayAvatar(String pathImage, bool check) {
    return Container(
      padding: EdgeInsets.only(top: 100),
      height: context.mediaQuerySize.height,
      width: context.mediaQuerySize.width,
      alignment: Alignment.topCenter,
      child: CircularPercentIndicator(
        radius: 60,
        lineWidth: check ? 5 : 0,
        percent: 1,
        center: Container(
            height: check ? 110 : 120,
            width: check ? 110 : 120,
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: widget.avatarAnother,
              errorWidget: (_, __, ___) {
                return Image.asset(Images.img_chat365);
              },
            )),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: AppColors.dustyGray,
        backgroundColor: AppColors.grayCCCCCC1,
        animation: check ? true : false,
        animationDuration: 30000,
      ),
    );
  }

  Widget displayLocalCamera(RTCVideoRenderer localRenderer) {
    return Container(
      child: RTCVideoView(
        localRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        mirror: true,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  Widget displayLocalCameraCalling(RTCVideoRenderer localRenderer) {
    return Stack(
      children: [
        ValueListenableBuilder(
            valueListenable: camera,
            builder: (context, value, _) {
              return camera.value
                  ? Container(
                      height: context.mediaQuerySize.height * 0.25,
                      width: context.mediaQuerySize.width * 0.2,
                      child: RTCVideoView(
                        localRenderer,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        mirror: true,
                        filterQuality: FilterQuality.medium,
                      ),
                    )
                  : Container(
                      height: 200,
                      width: 300,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: AuthRepo().userInfo!.avatar!,
                        errorWidget: (_, __, ___) {
                          return Image.asset(Images.img_chat365);
                        },
                      ));
            }),
        Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.only(left: 7, right: 7, bottom: 4, top: 4),
              color: AppColors.black.withOpacity(0.2),
              child: Row(
                children: [
                  Text(
                    "${AuthRepo().userInfo!.name}",
                    style: TextStyle(color: AppColors.white, fontSize: 18),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  ValueListenableBuilder(
                      valueListenable: mic,
                      builder: (context, value, _) {
                        return mic.value
                            ? SizedBox()
                            : SvgPicture.asset(
                                Images.ic_mic_off,
                                color: AppColors.white,
                              );
                      })
                ],
              ),
            ))
      ],
    );
  }

  Widget displayRemoteCamera(RTCVideoRenderer remoteRenderer) {
    return Stack(
      children: [
        ValueListenableBuilder(
            valueListenable: cameraCallee,
            builder: (context, value, _) {
              return cameraCallee.value
                  ? Container(
                      color: AppColors.black51,
                      child: RTCVideoView(
                        remoteRenderer,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                        mirror: true,
                        filterQuality: FilterQuality.medium,
                      ),
                    )
                  : widget.avatarAnother != null
                      ? Container(
                          width: context.mediaQuerySize.width,
                          height: context.mediaQuerySize.height,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: widget.avatarAnother,
                            errorWidget: (_, __, ___) {
                              return Image.asset(Images.img_chat365);
                            },
                          ))
                      : Container(
                          child: Image.asset(
                            fit: BoxFit.cover,
                            Images.img_non_avatar,
                          ),
                        );
            }),
        timer(),
        name(widget.nameAnother!, true),
      ],
    );
  }

  Widget bottomBarCall() {
    return Container(
      width: context.mediaQuerySize.width,
      height: 50,
      color: AppColors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // nút share màn nè
          Container(
            padding: EdgeInsets.only(left: 10),
            child: SvgPicture.asset(
              Images.ic_share_screen,
              height: 30,
              width: 30,
              color: AppColors.white,
            ),
          ),

          // nút bật tắt camera, mic, kết thúc cuộc gọi
          Container(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.checkCall
                    ? Container(
                        // check là voiceCall thì làm mở nút bật tắt camera
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border:
                                Border.all(color: AppColors.white, width: 1)),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            ValueListenableBuilder(
                                valueListenable: camera,
                                builder: (context, value, _) {
                                  return InkWell(
                                    onTap: () {
                                      camera.value = !camera.value;
                                      callService
                                          .changeCameraStatus(camera.value);
                                    },
                                    child: camera.value
                                        ? SvgPicture.asset(
                                            Images.ic_video_call,
                                            color: AppColors.white,
                                          )
                                        : SvgPicture.asset(
                                            Images.ic_video_off,
                                            color: AppColors.white,
                                          ),
                                  );
                                }),
                            SizedBox(
                              width: 10,
                            ),
                            SvgPicture.asset(
                              Images.ic_arrow_up,
                              color: AppColors.white,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: AppColors.grayC4C4C4.withOpacity(0.2),
                              width: 1),
                          color: AppColors.grayC4C4C4.withOpacity(0.2),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            SvgPicture.asset(
                              Images.ic_video_call,
                              color: AppColors.grayC4C4C4.withOpacity(0.2),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            SvgPicture.asset(
                              Images.ic_arrow_up,
                              color: AppColors.grayC4C4C4.withOpacity(0.2),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ),
                SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () {
                    _endCall();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 8, right: 5, left: 5),
                        child: SvgPicture.asset(Images.ic_hang_up,
                            color: AppColors.white),
                      )),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.white, width: 1)),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      ValueListenableBuilder(
                          valueListenable: mic,
                          builder: (context, value, _) {
                            return InkWell(
                              onTap: () {
                                mic.value = !mic.value;
                                callService.changeMicStatus(mic.value);
                              },
                              child: mic.value
                                  ? SvgPicture.asset(
                                      Images.ic_mic,
                                      color: AppColors.white,
                                    )
                                  : SvgPicture.asset(
                                      Images.ic_mic_off,
                                      color: AppColors.white,
                                    ),
                            );
                          }),
                      SizedBox(
                        width: 10,
                      ),
                      SvgPicture.asset(
                        Images.ic_arrow_up,
                        color: AppColors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // nút split màn, setting
          Container(
            padding: EdgeInsets.only(right: 10),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    splitScreen.value = !splitScreen.value;
                  },
                  child: SvgPicture.asset(
                    Images.ic_split_screen,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () async {
                    // var devices = await mediaDevices.getSources();

                    // List<String> audioInputDevices = [];
                    // List<String> audioOutputDevices = [];
                    // List<String> videoInputDevices = [];

                    // devices.forEach((element) {
                    //   if (element['kind'] == 'audioinput') {
                    //     audioInputDevices.add(element['label']);
                    //   }
                    //   if (element['kind'] == 'audiooutput') {
                    //     audioOutputDevices.add(element['label']);
                    //   }
                    //   if (element['kind'] == 'videoinput') {
                    //     videoInputDevices.add(element['label']);
                    //   }
                    // });

                    // final window =
                    //     await DesktopMultiWindow.createWindow(jsonEncode({
                    //   'args': 'setting',
                    // }));

                    // window
                    //   ..setFrame(const Offset(0, 0) & const Size(800, 1000))
                    //   ..center()
                    //   ..setTitle('Setting')
                    //   ..show();

                    // var windowId = window.windowId;

                    // await DesktopMultiWindow.invokeMethod(
                    //     windowId, 'setting_call', {
                    //   'input_audio': audioInputDevices.join('*'),
                    //   'output_audio': audioOutputDevices.join("*"),
                    //   'input_video': videoInputDevices.join("*")
                    // });
                  },
                  child: SvgPicture.asset(
                    Images.ic_setting,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget timer() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(left: 7, right: 7, bottom: 4, top: 4),
        color: AppColors.black.withOpacity(0.3),
        child: ValueListenableBuilder<Duration>(
            valueListenable: _time,
            builder: (context, t, child) {
              return Text(
                '${t.inHours.toString().padLeft(2, '0')}:${(t.inMinutes % 60).toString().padLeft(2, '0')}:${(t.inSeconds % 60).toString().padLeft(2, '0')}',
                style: AppTextStyles.regularW400(context,
                    size: 25, color: AppColors.green30),
              );
            }),
      ),
    );
  }

  Widget name(String name, bool check) {
    // check = true nghe sự kiện bật tắt mic của Callee, false của Caller
    return Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          padding: EdgeInsets.only(left: 7, right: 7, bottom: 4, top: 4),
          color: AppColors.black.withOpacity(0.2),
          child: Row(
            children: [
              Text(
                "${name}",
                style: TextStyle(color: AppColors.white, fontSize: 18),
              ),
              SizedBox(
                width: 5,
              ),
              ValueListenableBuilder(
                  valueListenable: check ? micCallee : mic,
                  builder: (context, value, _) {
                    return value
                        ? SizedBox()
                        : SvgPicture.asset(
                            Images.ic_mic_off,
                            color: AppColors.white,
                          );
                  })
            ],
          ),
        ));
  }

  Widget SplitScreen() {
    return Container(
      height: context.mediaQuerySize.height,
      width: context.mediaQuerySize.width,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Stack(
                children: [
                  ValueListenableBuilder(
                      valueListenable: incalling,
                      builder: (context, value, _) {
                        return incalling.value
                            ? displayRemoteCamera(_remoteRenderer)
                            : widget.avatarAnother != null
                                ? Container(
                                    height: context.mediaQuerySize.height,
                                    width:
                                        context.mediaQuerySize.width / 2 - 2.5,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: widget.avatarAnother,
                                      errorWidget: (_, __, ___) {
                                        return Image.asset(Images.img_chat365);
                                      },
                                    ))
                                : Container(
                                    child: Image.asset(
                                      fit: BoxFit.cover,
                                      Images.img_non_avatar,
                                    ),
                                  );
                      }),
                  ValueListenableBuilder(
                      valueListenable: incalling,
                      builder: (context, value, _) {
                        return incalling.value
                            ? SizedBox()
                            : name(widget.nameAnother!, true);
                      }),
                ],
              )),
          SizedBox(
            width: 5,
          ),
          Expanded(
              flex: 1,
              child: Stack(
                children: [
                  ValueListenableBuilder(
                      valueListenable: camera,
                      builder: (context, value, _) {
                        return camera.value
                            ? displayLocalCamera(_localRenderer)
                            : Container(
                                height: context.mediaQuerySize.height,
                                width: context.mediaQuerySize.width / 2 - 2.5,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: AuthRepo().userInfo!.avatar!,
                                  errorWidget: (_, __, ___) {
                                    return Image.asset(Images.img_chat365);
                                  },
                                ));
                      }),
                  name(AuthRepo().userName, false)
                ],
              )),
        ],
      ),
    );
  }

  Widget calleeRingingScreen() {
    return Container(
      child: Text(
        "Con mẹ nó",
        style: TextStyle(fontSize: 20),
      ),
    );
    //   return Container(
    //   // width: context.mediaQuerySize.height * 0.6,
    //   // height: context.mediaQuerySize.height * 0.5,
    //   color: AppColors.blueGradients1,
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       SizedBox(height: 20,),
    //       Container(
    //         // height: 70,
    //         // width: 70,
    //         decoration: BoxDecoration(
    //           borderRadius: BorderRadius.circular(70)
    //         ),
    //         child: widget.avatarAnother != null ?
    //         CachedNetworkImage(
    //           fit: BoxFit.cover,
    //           imageUrl: widget
    //               .avatarAnother,
    //           errorWidget:
    //               (_, __, ___) {
    //             return Image.asset(Images.img_chat365);
    //           },
    //         ):
    //         Image.asset(
    //           fit: BoxFit.contain, Images.img_non_avatar,
    //         ),
    //       ),
    //
    //       SizedBox(height: 10,),
    //
    //       Text(widget.nameAnother!, style: TextStyle(
    //         fontWeight: FontWeight.w500,
    //         color: AppColors.white,
    //         fontSize: 17
    //       ),),
    //
    //       SizedBox(height: 10,),
    //
    //       Text("Zalo: Cuộc gọi video đến", style: TextStyle(
    //           color: AppColors.white,
    //         fontSize: 15.5
    //       ),),
    //
    //       SizedBox(height: 30,),
    //
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //
    //           CircleButton(
    //               onTap: (){},
    //               assestIcon: Images.ic_hang_up,
    //               enable: true,
    //             backgroundColor: AppColors.red,
    //             widthIcon: 25,
    //           ),
    //
    //           SizedBox(width: 30,),
    //
    //           CircleButton(
    //             onTap: (){
    //               incalling.value = true;
    //               callService.acceptCall();
    //             },
    //             assestIcon: Images.ic_video_call,
    //             enable: true,
    //             backgroundColor: AppColors.active,
    //             widthIcon: 25,
    //           )
    //         ],
    //       ),
    //
    //
    //       SizedBox(height: 35,),
    //
    //
    //       Container(
    //         width: context.mediaQuerySize.height * 0.5,
    //         // height: 40,
    //         decoration: BoxDecoration(
    //           color: AppColors.black.withOpacity(0.1),
    //           borderRadius: BorderRadius.circular(5)
    //         ),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             SvgPicture.asset(
    //               color: AppColors.white,
    //               Images.ic_video_off
    //             ),
    //             SizedBox(width: 10,),
    //
    //             Text('Trả lời không mở camera', style: TextStyle(
    //               color: AppColors.white,
    //               fontSize: 16
    //             ),)
    //           ],
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
}
