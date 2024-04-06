import 'dart:convert';

import 'package:app_chat365_pc/common/repos/sticker_repo.dart';
import 'package:app_chat365_pc/modules/chat/sticker/model/sticker_model.dart';
import 'package:app_chat365_pc/modules/chat/sticker/repo/sticker_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sticker_state.dart';


class StickerCubit extends Cubit<StickerState>{
  StickerRepos _stickerRepos = StickerRepos();

  StickerCubit() : super(StickerInitState()){}
  List<ModelSticker> listSticker =[];

  Future<void> getAllSticker() async {
    try {
      emit(StickerInitState());
      final res  = await _stickerRepos.getAllSticker();
      if (res.data != null) {
        print('-------------------------${res.toString()}--------------');
        var data = json.decode(res.data);
        listSticker = List<ModelSticker>.from(data.map((e) => ModelSticker.fromJson(e)));
        emit(StickerLoadedState(listSticker));
      }
    } catch (e, s) {
      print("$e-------------------$s");
      emit(StickerLoadError(e.toString()));
    }
  }
}