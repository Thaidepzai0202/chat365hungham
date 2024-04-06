import 'dart:convert';
import 'dart:io';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<SentMessageState>{
  ChatCubit(): super(InitialSentMessageState());
  final ChatRepo _repos = ChatRepo();
  List<String> listLinkFile = [];
  Future< void> getLinkFile(
      File file,
      ValueNotifier<double>? progress
      )async{
    emit(InitialSentMessageState());
    try {
      final response = await _repos.getLinkFile(file,progress);
      if (!response.hasError) {
        var data = json.decode(response.data);
        listLinkFile = List.from(data['data']['listNameFile']);
    }}catch (e, s) {
      logger.logError('$e $s');
    }
  }
}

