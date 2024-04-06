import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VoiceDisplay extends StatefulWidget {
  final bool isSentByCurrentUser;
  final ApiFileModel file;

  const VoiceDisplay({
    Key? key,
    required this.isSentByCurrentUser,
    required this.file,
  }) : super(key: key);

  @override
  State<VoiceDisplay> createState() => _VoiceDisplayState();
}

class _VoiceDisplayState extends State<VoiceDisplay> {
  final audioPlayer = AudioPlayer();
  ValueNotifier<bool> isPlaying = ValueNotifier(false);
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Source? source = null;
  ValueNotifier<String> time = ValueNotifier('');

  @override
  void initState() {
    source = DeviceFileSource(
        'https://mess.timviec365.vn/uploads/${widget.file.resolvedFileName}');

    audioPlayer.onPlayerComplete.listen((state) async {
      // duration = (await audioPlayer.getDuration()) ?? Duration.zero;
      time.value = formatTime(duration);
    });
    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      duration = newDuration;
      time.value = formatTime(duration);
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      position = newPosition;

      time.value = formatTime(duration - position);
    });
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    audioPlayer
        .setSourceDeviceFile(
        'https://mess.timviec365.vn/uploads/${widget.file.resolvedFileName}')
        .then((value) async =>
    duration = (await audioPlayer.getDuration()) ?? Duration.zero);
    time.value = formatTime(duration);
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      onTap: () async {
        if (isPlaying.value != true) {
          try {
            logger.log((source as DeviceFileSource).path);
            await audioPlayer.play(UrlSource(
                'https://mess.timviec365.vn/uploads/${widget.file.resolvedFileName}'));
          } catch (e) {
            logger.log(e);
          }
          logger.log(widget.file.resolvedFileName, name: 'lalalalalaaaaaaaa');
        } else {
          await audioPlayer.pause();
        }
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.isSentByCurrentUser
              ? Color(0xFFD5F1FF)
              : Color(0xFFF7F8FC),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [ 
            ValueListenableBuilder(
                valueListenable: isPlaying,
                builder: (context, check, _) {
                  return SvgPicture.asset(check == true
                      ? Images.ic_playing_voice
                      : Images.ic_play_voice);
                }),
            SizedBox(width: 6),
            SvgPicture.asset(Images.ic_wave_voice),
            SizedBox(width: 13),
            ValueListenableBuilder(
                valueListenable: time,
                builder: (context, _, __) {
                  return Text(
                    time.value,
                    style: AppTextStyles.regularW400(
                      context,
                      size: 14,
                      color: AppColors.doveGray,
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hour = twoDigits(duration.inHours);
    final minute = twoDigits(duration.inMinutes.remainder(60));
    final second = twoDigits(duration.inSeconds.remainder(60));
    return [
      if (duration.inHours > 0) hour,
      minute,
      second,
    ].join(':');
  }
}
