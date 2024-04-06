import 'dart:io';

import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/extensions/num_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

class VideoDisplay extends StatefulWidget {
  const VideoDisplay(
      {Key? key,
      required this.msgModel,
      required this.isSentByCurrentUser,
      this.cachedFile})
      : super(key: key);

  final isSentByCurrentUser;
  final SocketSentMessageModel msgModel;
  final ApiFileModel? cachedFile;

  @override
  State<VideoDisplay> createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  late VideoPlayerController _controller;
  bool turnOnVolume = false;
  bool playing = false;
  int duration = 0;
  bool buffered = false;
  bool autoResume = false;

  @override
  void initState() {
    logger.log('${widget.msgModel.files!.first.fullFilePath}');
    _initVideo();
    // getDuration();
    super.initState();
  }

  @override
  dispose() {
    _controller.dispose().then(
        (value) => logger.log('Video Controller Disposed', name: 'Video Log'));
    super.dispose();
  }

  int retryInit = 0;

  _initVideo() async {
    try {
      logger.log('${widget.cachedFile.toString()}');
      _controller = widget.cachedFile == null
          ? VideoPlayerController.network(
              widget.msgModel.files!.first.fullFilePath)
          : VideoPlayerController.file(File(widget.cachedFile!.filePath!));
      await _controller.initialize().then((value) => setState(() {
            duration = _controller.value.duration.inSeconds;
            buffered = true;
          }));
    } catch (e) {}
    if (!_controller.value.isInitialized) {
      if (retryInit < 5) {
        retryInit++;
        logger.log('retry init video',
            name: 'Video Log', color: StrColor.green);
        return _initVideo();
      }
      return;
    } else {
      retryInit = 0;
      _controller
        ..setVolume(0)
        // ..play()
        ..setLooping(false)
        ..addListener(() async {
          logger.log(
              '${DateTime.now().toString()} playing: ${_controller.value.isPlaying}');
          if (_controller.value.isBuffering) {
            if (!buffered) {
              buffered = true;
              setPause();
              // _controller.value.
              logger
                  .log('${DateTime.now().toString()} buffering: ${!buffered}');
            }
          } else {
            if (buffered) {
              buffered = false;
              if (autoResume)
                setResume();
              else
                setState(() {});
            }
          }
        });
    }
  }

  setPause() {
    playing = false;
    _controller.pause();
    setState(() {});
  }

  setResume() async {
    if (!_controller.value.isInitialized) await _initVideo();
    autoResume ? null : autoResume = true;
    playing = true;
    _controller.play();
    setState(() {});
  }

  setVolume() {
    turnOnVolume = !turnOnVolume;
    _controller.setVolume(turnOnVolume ? 100 : 0);
    setState(() {});
  }

  getDuration() async {
    try {
      Duration? duration = await _controller.value.duration;
      logger.log('Duration: $duration');
    } catch (e) {
      logger.logError('Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // logger.log('${duration}', name: 'Video log');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            // width: 180,
            // height: 300,
            child: InkWell(
              onTap: () {},
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 240,
                  maxHeight: 450,
                ),
                // padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.only(
                      topRight: widget.isSentByCurrentUser
                          ? Radius.circular(0)
                          : Radius.circular(12),
                      topLeft: widget.isSentByCurrentUser
                          ? Radius.circular(12)
                          : Radius.circular(0),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    )),
                width: _controller.value.isInitialized
                    ? _controller.value.size.width
                    : 240,
                // height: _controller.value.isInitialized ? _controller.value.size.height : 240,
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(
                          _controller,
                        ),
                      )
                    : ShimmerLoading(),
              ),
            ),
          ),
          if (_controller.value.isInitialized)
            Positioned(
              bottom: 5,
              right: 5,
              child: InkWell(
                onTap: () {
                  setVolume();
                },
                child: Container(
                    width: 30,
                    height: 30,
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.black,
                    ),
                    child: SvgPicture.asset(
                      turnOnVolume ? Images.ic_speaker : Images.ic_speaker_off,
                      fit: BoxFit.cover,
                    )),
              ),
            ),
          Container(
            width: 50, height: 50,
            // padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.greyCACA.withOpacity(0.6),
            ),
            child: InkWell(
              onTap: () async {
                if (_controller.value.isInitialized)
                  playing ? setPause() : setResume();
                else {
                  await _initVideo();
                  if (_controller.value.isInitialized) _controller.play();
                }
              },
              child: _controller.value.isBuffering
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Icon(playing ? Icons.pause : Icons.play_arrow),
            ),
          ),
          if (_controller.value.isInitialized)
            Positioned(
                bottom: 5,
                left: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.greyCACA.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(4),
                  child: Text(duration.toDurationString()),
                )),
          Positioned(
              bottom: 0,
              child: Container(
                height: 8,
                width: 240,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    backgroundColor: AppColors.white,
                    playedColor: AppColors.red,
                    bufferedColor: AppColors.primary.withOpacity(0.3),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
