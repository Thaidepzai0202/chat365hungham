import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/data/services/sp_utils_service/sp_utils_services.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/extensions/object_extension.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/material.dart';

/// [favorite] 1: true, 0: false

class ChatConversationRepo {
  final ValueNotifier<int> _totalRecords =
      ValueNotifier(spService.totalConversation ?? 0);
  int get totalRecords => _totalRecords.value;

  // Danh sach cuoc tro chuyen
  Future<RequestResponse> getListConversation({
    required int countLoaded,
  }) async {
    var total = totalRecords.clamp(1, double.infinity).toInt();
    return await ApiClient().fetch(ApiPath.chatList, data: {
      'userId': AuthRepo().userInfo!.id,
      //'countConversation': countLoaded + 150,
      'countConversationLoad': countLoaded.clamp(0, total),
      'companyId': AuthRepo().userInfo?.companyId ?? 0,
    });
  }

  // them,xoa vao muc yeu thich
  Future<RequestResponse> addFavouriteList({
    required int conversationId,
    required int userId,
    required int favorite,
  }) async {
    return await ApiClient().fetch(ApiPath.toogleFavoriteChat,
        data: {
          'conversationId': conversationId,
          'senderId': userId,
          'isFavorite': favorite,
        },
        method: RequestMethod.post);
  }

  // bât, tắt thông báo
  Future<RequestResponse> changeNotify({
    required int userId,
    required int conversationId,
  }) async {
    return await ApiClient().fetch(ApiPath.changeNotiChat, data: {
      'conversationId': conversationId,
      'userId': userId,
    });
  }

//Xoá cuộc trò chuyện
  Future<RequestResponse> deleteConversation({
    required int senderId,
    required int conversationId,
  }) async {
    return await ApiClient().fetch(ApiPath.deleteChat, data: {
      'conversationId': conversationId,
      'senderId': senderId,
    });
  }

  // danh sach cuoc tro chuyen an
  Future<RequestResponse> listHiddenConversation({
    required int userId,
  }) async {
    return await ApiClient().fetch(ApiPath.getListHidden, data: {
      'userId': userId,
    });
  }

  // lấy mã pín message
  Future<RequestResponse> getPinCode({required int userId}) async {
    return await ApiClient().fetch(ApiPath.getPinHiddenConversation, data: {
      'userId': userId,
    });
  }

// ẩn cuộc trò chuyện
  Future<RequestResponse> hiddenConversation({
    required int userId,
    required int conversationId,
    required int isHidden,
  }) async {
    return await ApiClient().fetch(ApiPath.toogleHiddenChat, data: {
      'senderId': userId,
      'conversationId': conversationId,
      'isHidden': isHidden
    });
  }

  // Cập nhật mã PIN CODE
  Future<RequestResponse> updatePinCode(
      {required int userId, required String pin}) async {
    return await ApiClient().fetch(ApiPath.updatePinHiddenConversation,
        data: {'userId': userId, 'pin': pin});
  }

// lay danh sach cuoc tro chuyen chua doc
  Future<RequestResponse> getListConversationUnRead() async {
    return await ApiClient().fetch(ApiPath.ConversationUnreader, data: {
      'userId': AuthRepo().userInfo!.id,
    });
  }

  // danh dau da doc tin nhan
  @Deprecated("Dùng ChatRepo().markReadMessage() nhé")
  Future<void> markAsRead(int conversationId) async {
    var chatItemModel = await ChatRepo().getChatItemModel(conversationId);
    try {
      return ChatRepo().markReadMessage(
          senderId: AuthRepo().userInfo!.id,
          conversationId: conversationId,
          memebers: chatItemModel?.memberList.map((e) => e.id).toList() ?? []);
    } catch (e) {
      // logger.log("Gặp lỗi markAsRead: ${e.toErrorString()}", name: "$runtimeType");
    }
  }
}
