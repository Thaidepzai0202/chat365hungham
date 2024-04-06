import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/screen/chat_conversation_screen.dart';
import 'package:app_chat365_pc/modules/features/features_screen.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/features_screen/features_screen.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/notification_screen/notification_screen.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/phone_book_screen.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/user_search/screens/user_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppSubPages {
  conversationPage,
  contactPage,
  utilityPage,
  callPage,
  notificationPage,
  userSearchScreen,
  zaloScreen
}

class AppSubPagesHelper {
  static Widget getPage(AppSubPages page, Map<String, dynamic>? agruments) {
    switch (page) {
      case AppSubPages.conversationPage:
        return const     ChatConversationScreen();
      case AppSubPages.contactPage:
        return const PhoneBookScreen();
      case AppSubPages.utilityPage:
        return const Text("This is utility screen");
      case AppSubPages.callPage:
        return const Text("This is call screen");
      case AppSubPages.notificationPage:
        return const NotificationPage();
      case AppSubPages.userSearchScreen:
        return const UserSearchScreen();
      case AppSubPages.zaloScreen:
        return const Text("This is Zalo screen");
        // return ChatConversationScreenZalo();
    }
  }
}