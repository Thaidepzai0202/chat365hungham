import 'dart:async';

import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/notification_screen/bloc/notification_bloc.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sp_util/sp_util.dart';

class AppService {
  //
  static final AppService _instance = AppService._internal();

  AppService._internal() {
    _countUnreadNotiController = StreamController.broadcast();
    _unreadConversationController = StreamController.broadcast();
    updateCountUnreadNoti(SpUtil.getInt(
      LocalStorageKey.countUnreadNoti,
      defValue: 0,
    )!);
    // setupUnreadConversationId();
  }

  factory AppService() => _instance;

  AppService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  Set<int> _unreadConversationIds = {};
  int _countUnreadNoti = 0;

  late final StreamController<int> _countUnreadNotiController;
  late final StreamController<Set<int>> _unreadConversationController;

  Stream<int> get countUnreadNotiStream => _countUnreadNotiController.stream;
  Stream<Set<int>> get unreadConversationStream =>
      _unreadConversationController.stream;

  int get countUnreadNoti =>
      SpUtil.getInt(LocalStorageKey.countUnreadNoti, defValue: 0) ?? 0;
  int get countUnreadConversation => unreadConversationIds.length;
  Set<int> get unreadConversationIds => _unreadConversationIds;

  updateUnreadConversation(Iterable<int> conversationIds) {
    _unreadConversationIds = conversationIds.toSet();
    updateAppBadgeCount();
    _unreadConversationController.sink.add(unreadConversationIds);
    SpUtil.putString(
      LocalStorageKey.unreadConversations,
      unreadConversationIds.join(','),
    );
  }

  updateCountUnreadNoti(int value) async {
    _countUnreadNoti = value;
    updateAppBadgeCount();
    _countUnreadNotiController.sink.add(countUnreadNoti);
    await SpUtil.putInt(
      LocalStorageKey.countUnreadNoti,
      _countUnreadNoti,
    );
  }

  updateAppBadgeCount() async {
    final int value =
        [countUnreadConversation, countUnreadNoti].reduce((a, b) => a + b);
    SpUtil.putInt(LocalStorageKey.appBadger, value);
  }

  increaseUnreadNoti(int value) =>
      updateCountUnreadNoti(countUnreadNoti + value);

  decreaseUnreadNoti(int value) => updateCountUnreadNoti(
      (countUnreadNoti - value) < 0 ? 0 : countUnreadNoti - value);

  readAllUnreadNoti() => updateCountUnreadNoti(0);

  addUnreadConversation(int conversationId) {
    var newIds = [...unreadConversationIds, conversationId];
    updateUnreadConversation(newIds);
  }

  removeUnreadConversation(int conversationId) =>
      updateUnreadConversation(unreadConversationIds..remove(conversationId));

  setContext(BuildContext context) {
    // navigatorKey.currentState. = context;
  }

  reset() {
    updateCountUnreadNoti(0);
    updateUnreadConversation([]);
    logger.log('Reset count', name: 'ResetCount');
  }

  Future setupUnreadConversationId() async {
    final List<int> initConversationIds = [];
    try {
      var value = await chatRepo.getUnreadConversationIds();
      if (value == null) {
        initConversationIds.addAll(SpUtil.getString(
          LocalStorageKey.unreadConversations,
          defValue: '',
        )!
            .split(',')
            .map((e) => int.parse(e)));
      } else
        initConversationIds.addAll(value);

      updateUnreadConversation(initConversationIds);
    } catch (e, s) {
      logger.logError(e, s);
    }
  }

  dispose() {
    _countUnreadNotiController.close();
    _unreadConversationController.close();
  }
}
