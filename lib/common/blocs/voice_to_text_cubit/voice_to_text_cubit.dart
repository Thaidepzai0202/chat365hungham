import 'dart:convert';

import 'package:app_chat365_pc/common/repos/voice_to_text_repo.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'voice_to_text_state.dart';

class TransVoiceToTextCubit extends Cubit<TransVoiceToTextState> {
  TransVoiceToTextCubit() : super(TransVoiceToTextInitState());
  VoiceRepo _voiceRepo = VoiceRepo();

  Future<void> voiceToText(String link) async {
    try {
      emit(VoiceToTextLoadingState());
      final res = await _voiceRepo.transVoiceToText(link);
      if (!res.hasError) {
        var data = json.decode(res.data);
        String result = data['text'];

        emit(VoiceToTextLoadedState(result));
      } else {
        logger.log(res.error.toString());
        emit(VoiceToTextErrorState(res.error.toString()));
      }
    } catch (e) {
      logger.log(e.toString());
    }
  }

  Future<String> textToVoice(String txt) async {
    try {
      emit(TextToVoiceLoadingState());
      final res = await _voiceRepo.transTextToVoice(txt);
      if (!res.hasError) {
        var data = json.decode(res.data);
        String result = data['data'];
        emit(TextToVoiceLoadedState());
        return result;
      } else {
        emit(TextToVoiceErrorState());
        return '';
      }
    } catch (e) {
      emit(TextToVoiceErrorState());
      return '';
    }
  }
}
