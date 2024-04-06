import 'dart:convert';

import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_hidden.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_model.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_unread.dart';
import 'package:app_chat365_pc/modules/chat_conversations/repos/chat_conversation_repo.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatConversationCubit extends Cubit<ChatConversationState> {
  ChatConversationCubit() : super(InitialChatState());
  ChatConversationRepo repo = ChatConversationRepo();

  // danh sach cuoc tro chuyen
  List<ConversationModel> listConversation = [];

  Future<void> takeListConnversation({required int countLoaded}) async {
    emit(InitialAddFavouriteChatState());
    try {
      final response = await repo.getListConversation(countLoaded: countLoaded);
      if (!response.hasError) {
        var data = json.decode(response.data);
        emit(LoadingChatState());
        listConversation = List.from(data['data']['listCoversation'])
            .map((e) => ConversationModel.fromApiJson(e))
            .toList();
        emit(LoadedChatState(listConversation));
      } else {
        emit(ErrorChatState(response.error.toString()));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorChatState(e.toString()));
    }
  }

  // them, xoa vao danh sach yeu thich
  // TL 18/1/2024: DEPRECATED: Dùng ChatRepo().changeFavoriteStatus() nhé
  // Future<void> addFavouriteChat({
  //   required int conversationId,
  //   required int favorite,
  // }) async {
  //   emit(InitialAddFavouriteChatState());
  //   try {
  //     final response = await repo.addFavouriteList(
  //         conversationId: conversationId,
  //         userId: AuthRepo().userInfo!.id,
  //         favorite: favorite);
  //     if (!response.hasError) {
  //       emit(LoadingAddFavouriteChatState());
  //       emit(LoadedAddFavouriteChatState());
  //     } else {
  //       emit(ErrorAddFavouriteChatState(response.error.toString()));
  //     }
  //   } catch (e, s) {
  //     logger.logError('$e $s');
  //     emit(ErrorAddFavouriteChatState(e.toString()));
  //   }
  // }

  // bật, tắt thông báo tin nhắn
  @Deprecated("Dùng ChatRepo().changeNotificationStatus() nhé")
  Future<void> changeNotifyChat({
    required int conversationId,
  }) async {
    emit(InitialChangeNotifyChatState());
    try {
      final response = await repo.changeNotify(
        conversationId: conversationId,
        userId: AuthRepo().userInfo!.id,
      );
      if (!response.hasError) {
        emit(LoadingChangeNotifyChatState());
        emit(LoadedChangeNotifyChatState());
      } else {
        emit(ErrorChangeNotifyChatState(response.error.toString()));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorChangeNotifyChatState(e.toString()));
    }
  }

  // xoá cuộc trò chuyện
  Future<void> deleteConversation({
    required int conversationId,
  }) async {
    emit(InitialDeleteConversationChatState());
    try {
      final response = await repo.deleteConversation(
        conversationId: conversationId,
        senderId: AuthRepo().userInfo!.id,
      );
      if (!response.hasError) {
        emit(LoadingDeleteConversationChatState());
        listConversation
            .removeWhere((element) => element.conversationId == conversationId);
        emit(LoadedChatState(listConversation));
      } else {
        emit(ErrorDeleteConversationChatState(response.error.toString()));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorDeleteConversationChatState(e.toString()));
    }
  }

  // danh sách cuộc trò chuyện bị ẩn
  List<ConversationHidden> listHiddenConversation = [];

  Future<void> takeListHiddenConversation() async {
    emit(InitialHiddenConversationState());
    try {
      final response = await repo.listHiddenConversation(
        userId: AuthRepo().userInfo!.id,
      );
      var data = json.decode(response.data);
      if (!response.hasError) {
        emit(LoadingHiddenConversationState());
        listHiddenConversation = List.from(data['data']['conversation'])
            .map((e) => ConversationHidden.fromJson(e))
            .toList();
        emit(LoadedHiddenConversationState(listHiddenConversation));
      } else {
        emit(ErrorDeleteConversationChatState(response.error.toString()));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorHiddenConversationState(e.toString()));
    }
  }

  String pinCode = '';

  // lấy mã PIN code
  Future<void> takePINcode() async {
    try {
      final response = await repo.getPinCode(
        userId: AuthRepo().userInfo!.id,
      );
      var data = json.decode(response.data);
      pinCode = data['data']['pin'];
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorHiddenConversationState(e.toString()));
    }
  }

  // ẩn cuộc trò chuyện
  Future<void> hiddenConversation({
    required int conversationId,
    required int isHidden,
  }) async {
    try {
      emit(BeforeHiddenState());
      final response = await repo.hiddenConversation(
        userId: AuthRepo().userInfo!.id,
        conversationId: conversationId,
        isHidden: isHidden,
      );
      if (!response.hasError) {
        if (isHidden == 1) {
          emit(SuccessHiddenState());
          listConversation.removeWhere(
              (element) => element.conversationId == conversationId);
          emit(LoadedChatState(listConversation));
        } else {
          emit(SuccessHiddenState());
          listHiddenConversation.removeWhere(
              (element) => element.conversationId == conversationId);
          emit(LoadedHiddenConversationState(listHiddenConversation));
        }
      } else {
        emit(ErrorChatState(response.error.toString()));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorChatState(e.toString()));
    }
  }

  // cập nhật mã PIN CODE
  Future<void> updatePINCode(String pin) async {
    try {
      await repo.updatePinCode(userId: AuthRepo().userInfo!.id, pin: pin);
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorHiddenConversationState(e.toString()));
    }
  }

  //  đánh dấu đã đọc tin nhắn
  Future<void> markAsRead(int conversationId) async {
    try {
      await repo.markAsRead(conversationId);
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorHiddenConversationState(e.toString()));
    }
  }

  // danh sách cuộc trò chuyện chưa đọc
  List<ConversationModel> listConversationUnRead = [];

  Future<void> getListConversationUnRead() async {
    try {
      emit(BeforeHiddenState());
      final response = await repo.getListConversationUnRead();
      if (!response.hasError) {
        var data = json.decode(response.data);
        emit(LoadingUnReadConversationState());
        listConversationUnRead = List.from(data['data']['listCoversation'])
            .map((e) => ConversationModel.fromApiJson(e))
            .toList();

        emit(LoadedUnReadConversationState(listConversationUnRead));
      } else {
        emit(ErrorUnReadConversationState(response.error.toString()));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorUnReadConversationState(e.toString()));
    }
  }
}
