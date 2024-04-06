import 'dart:async';

import 'package:app_chat365_pc/common/blocs/sticker_bloc/sticker_event.dart';
import 'package:app_chat365_pc/common/blocs/sticker_bloc/sticker_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repos/sticker_repo.dart';

class StickerBloc extends Bloc<StickerEvent, StickerState> {
  final stickerRepo = StickerRepo();
  StickerBloc() : super(StickerIinitState());
  @override
  Stream<StickerState> mapEventToState(StickerEvent event) async* {
    if (event is GetIdSticker) {
      try {
        await Future.delayed(const Duration(seconds: 2));

        final data = await stickerRepo.getSticker();

        yield LoadedState(
          stickers: data,
        );
      } catch (e) {
        yield FailureProduct(e.toString());
      }
    }
  }
}
