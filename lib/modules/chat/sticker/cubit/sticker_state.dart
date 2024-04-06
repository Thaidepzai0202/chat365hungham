part of 'sticker_cubit.dart'; 


class StickerState extends Equatable{
  @override
  List<Object> get props =>[];
}

class StickerInitState extends StickerState{}

class StickerLoadingState extends StickerState{}

class StickerLoadedState extends StickerState{
  List<ModelSticker> listSticker;
  StickerLoadedState(this.listSticker);
}

class StickerLoadError extends StickerState{
  final String error;
  StickerLoadError(this.error);
}