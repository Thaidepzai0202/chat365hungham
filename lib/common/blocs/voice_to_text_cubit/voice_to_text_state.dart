part of 'voice_to_text_cubit.dart';

class TransVoiceToTextState extends Equatable {
  @override
  List<Object> get props => [];
}

class TransVoiceToTextInitState extends TransVoiceToTextState {}

class VoiceToTextLoadingState extends TransVoiceToTextState {}

class VoiceToTextLoadedState extends TransVoiceToTextState {
  final String result;
  VoiceToTextLoadedState(this.result);
}

class VoiceToTextErrorState extends TransVoiceToTextState {
  final String e;
  VoiceToTextErrorState(this.e);
}

//----------------------------------------------------------------------

class TextToVoiceLoadingState extends TransVoiceToTextState {}

class TextToVoiceLoadedState extends TransVoiceToTextState {}

class TextToVoiceErrorState extends TransVoiceToTextState {}
