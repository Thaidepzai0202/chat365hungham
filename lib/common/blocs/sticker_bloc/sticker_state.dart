//state
import 'package:app_chat365_pc/common/models/api_sticker_model.dart';

abstract class StickerState {}

class StickerIinitState extends StickerState {}

class LoadedState extends StickerState {
  final List<StickerModel> stickers;

  LoadedState({required this.stickers});
}

class FailureProduct extends StickerState {
  final String error;

  FailureProduct(this.error);
}

class LoadingProduct extends StickerState {}
