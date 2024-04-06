import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/modules/chat/screen/chat_screen.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/request_screen.dart';
import 'package:app_chat365_pc/modules/layout/views/main_layout.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/material.dart';

enum AppMainPages {
  // TL 25/12/2023 note: afterLoginChat dùng để nhảy về màn mặc định sau khi rời nhóm
  afterLoginChat,
  chatScreen,
  requestPages,
  utilityPage,
  callPage,
  notificationPage
}

class AppMainPagesHelper {
  static Widget getPage(AppMainPages page, Map<String, dynamic>? agruments) {
    switch (page) {
      case AppMainPages.afterLoginChat:
        return AfterLoginChat(userInfo: AuthRepo().userInfo!);
      case AppMainPages.chatScreen:
        print(agruments?['conversationId']);
        return ChatScreen(
          key: Key(agruments!['conversationId'].toString()),
          chatType: agruments['chatType'],
          conversationId: agruments['conversationId'],
          senderId: agruments['senderId'],
          // Trần Lâm note: Bỏ chatItemModel trong ChatScreen
          //chatItemModel: agruments['chatItemModel'],
          nickname: agruments['name'],
          chatDetailBloc: agruments['chatDetailBloc'],
        );
      case AppMainPages.requestPages:
        return const RequestScreen();
      case AppMainPages.utilityPage:
        return const Text("This is utility screen");
      case AppMainPages.callPage:
        return const Text("This is call screen");
      case AppMainPages.notificationPage:
        return const Text("This is notification screen");
    }
  }
}
