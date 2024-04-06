import 'dart:convert';

import 'package:app_chat365_pc/modules/layout/pages/sub_pages/notification_screen/bloc/notification_state.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/notification_screen/models/notification_model.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/notification_screen/repos/notification_repos.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationBloc extends Cubit<NotificationState>{
  NotificationBloc(): super(InitialNotificationState());
  final NotificationRepos _repos = NotificationRepos();
  List<NotificationModel> listNotification = [];

  //take list noti
  Future< void> getListNotification()async {
    emit(InitialNotificationState());
    try {
      final response = await _repos.takeListNoti();
      if (!response.hasError) {
        var data = json.decode(response.data);
        emit(LoadingNotificationState());
        if (data['data'] == null) {
          emit(EmptyNotificationState());
          return;
        }
        listNotification =
            List.from(data['data']['listNotification']).map((e) =>
                NotificationModel.fromJson(e)).toList();
        emit(LoadedNotificationState(listNotification));
      } else {
        emit(ErrorNotificationState(response.error.toString()));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorNotificationState(e.toString()));
    }
  }

  // read all noti
  Future< void> readAllNoti()async {
    emit(InitialNotificationState());
    try {
      final response = await _repos.readAllNoti();
      if (!response.hasError) {
        var data = json.decode(response.data);
        emit(LoadingNotificationState());
        if (data['data'] == null) {
          emit(EmptyNotificationState());
          return;
        }
        emit(ReadAllNotificationState());
      } else {
        emit(ErrorNotificationState(response.error.toString()));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorNotificationState(e.toString()));
    }
  }

  //read noti
  Future< void> readNoti(
      String notiId,
      )async {
    emit(InitialNotificationState());
    try {
      final response = await _repos.readNoti(notiId);
      if (!response.hasError) {
        var data = json.decode(response.data);
        emit(LoadingNotificationState());
        if (data['data'] == null) {
          emit(EmptyNotificationState());
          return;
        }
        emit(ReadAllNotificationState());
      } else {
        emit(ErrorNotificationState(response.error.toString()));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorNotificationState(e.toString()));
    }
  }

 // delete all noti
  Future< void> deleteAllNoti()async {
    emit(InitialNotificationState());
    try {
      final response = await _repos.deleteAllNoti();
      if (!response.hasError) {
        var data = json.decode(response.data);
        emit(LoadingNotificationState());
        if (data['data'] == null) {
          emit(EmptyNotificationState());
          return;
        }
        listNotification.clear();
        emit(LoadedNotificationState(listNotification));
      } else {
        emit(ErrorNotificationState(response.error.toString()));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorNotificationState(e.toString()));
    }
  }
}