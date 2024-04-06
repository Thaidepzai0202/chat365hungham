import 'dart:async';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/emoji.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../modules/chat/model/result_socket_chat.dart';
import '../../../utils/data/enums/message_type.dart';
import 'package:equatable/equatable.dart';

part 'reaction_state.dart';

class ReactionCubit extends Cubit<ReactionState> {
  ReactionCubit(
      this.messageId, {
        required ChatRepo chatRepo,
        required Map<Emoji, Emotion> initEmotions,
      })  : _chatRepo = chatRepo,
        super(ReactionState(reactions: initEmotions)) {
    _subscription = _chatRepo.stream.listen((event) {
      if (event is ChatEventOnRecievedEmotionMessage && event.messageId == messageId) {
        logger.log(
          '${event}',
          name: 'ReactionCubit_${this.hashCode}',
          color: StrColor.magenta,
        );
        // _logRection(state.reactions);
        Map<Emoji, Emotion> reactions = state.reactions;
        // if (event.checked) {
        //
        //   /// Hủy reaction
        //   reactions[event.emoji]?.listUserId.remove(event.senderId);
        // } else {
        //   reactions[event.emoji] ??= Emotion(
        //     type: event.emoji,
        //     listUserId: const [],
        //     isChecked: false,
        //   );
        //   reactions[event.emoji]?.listUserId.add(event.senderId);
        // }
        // reactions[event.emoji]?.listUserId.add(event.senderId);
        // _logRection(reactions);

        emit(
          ReactionState(
            reactions: reactions,
            lastEmoji: !event.checked ? event.emoji : null,
          ),
        );
      }
    });
  }

  _logRection(Map<Emoji, Emotion> react) => logger.log(Map.from(react.map((e, v) => MapEntry(e.id, v.listUserId.length))), name: 'CheckReaction');

  Future<void> changeReaction(ChatEventEmitChangeReationMessage event,
      // {required int reactedPersonId, required Emoji reactedEmoji}
      ) async {
    try {
      await _chatRepo.changeReaction(event);
      var uId = int.tryParse(event.messageId.split('_').last);
      if (uId == event.userId || !event.allMemberIdsInConversation.contains(uId)) return;
      await _chatRepo.pushNotificationFirebase(
        receiveId: [uId],
        convId: event.conversationId,
        message: 'Đã bày tỏ cảm xúc vào tin nhắn của bạn',
        conversationName: event.conversationName,
      );
      // emit(ReactionStateChangeReactionSuccess(reactions: event.emotion ?? <Emoji, Emotion>{}));
    } on CustomException catch (e) {
      emit(ReactionStateChangeReactionError(e.error));
    }
  }

  Future<void> reactedAtEmoji(
      int userId,
      SocketSentMessageModel messageModel,
      List<int> members,
      String conversationName, {required int reactedPersonId, required Emoji reactedEmoji}) async {
    // SocketSentMessageModel messageModel = event.messageModel;
    emit(ReactionStateChangeReactionLoading());
    emit(ReactionStateChangeReactionSuccess(messageModel: messageModel));
    chatRepo.emitChatEvent(
      ChatEventOnRecievedEmotionMessage(
        senderId: userId,
        messageId: messageModel.messageId,
        conversationId: messageModel.conversationId,
        emoji: reactedEmoji,
        checked: true,
        messageType: messageModel.type ?? MessageType.text,
        message: messageModel.message??""));
    await changeReaction(ChatEventEmitChangeReationMessage(
      userId,
      messageModel.messageId,
      messageModel.conversationId,
      // Emoji.like,
      reactedEmoji,
      false,
      messageModel.type ?? MessageType.text,
      messageModel.message ?? '',
      members,
      const [],
      conversationName,
      // map<Emoji, Emotion> de dung cho reactionBar
      emotion: messageModel.emotion,
      messageModel: messageModel,
    ),
    );
  }

  final String messageId;

  final ChatRepo _chatRepo;
  late final StreamSubscription _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  @override
  void onChange(Change<ReactionState> change) {
    logger.log('---CheckReaction---');
    _logRection(change.currentState.reactions);
    _logRection(change.nextState.reactions);
    super.onChange(change);
  }
}
