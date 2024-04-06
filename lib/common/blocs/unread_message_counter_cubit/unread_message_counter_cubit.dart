import 'dart:async';

// import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/service/app_service.dart';
import 'package:app_chat365_pc/service/injection.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// part 'unread_message_counter_cubit.g.dart';
part 'unread_message_counter_state.dart';

// @HiveType(typeId: HiveTypeId.unreadMessageCounterCubitHiveTypeId)
class UnreadMessageCounterCubit extends Cubit<UnreadMessageCounterState> {
  UnreadMessageCounterCubit({
    required this.conversationId,
    required this.countUnreadMessage,
  })  : userId = navigatorKey.currentContext?.userInfo().id ?? userInfo?.id,
        super(UnreadMessageCounterState(countUnreadMessage)) {
    // logger.log(
    //   'UnreadMessageCounterState $hashCode created',
    //   name: 'UnreadMessageCounterState_$conversationId',
    // );
    _subscription = chatRepo.stream.listen((event) {
      // if (conversationId == 214) logger.log('214', name: 'TestUnread');
      // if (conversationId == 214 && event is ChatEventOnMarkReadAllMessage) {
      //   logger.log(
      //     'Send: ${event.senderId} - Curr: $userId - Conv: ${event.conversationId}',
      //     name: 'TestUnread',
      //   );
      //   logger.log(event.senderId == userId, name: 'TestUnread');
      //   logger.log(this.countUnreadMessage, name: 'TestUnread');
      // }
      // đây rồi
      if (event is ChatEventOnReceivedMessage &&
          event.msg.conversationId == conversationId) {
        if (event.msg.senderId != userId) {
          emit(state.add(1));
        } else {
          emit(state.readAll());
        }
      } else if (event is ChatEventOnMarkReadAllMessages &&
          event.conversationId == conversationId &&
          // Chỉ emit những thông báo: Người dùng hiện tại đánh dấu xem hết các tin cuộc trò chuyện
          event.senderId == userId) {
        emit(state.readAll());
      }
    });
  }

  bool get hasUnreadMessage => state.counter != 0;
  final AppService appService = getIt.get<AppService>();

  /// [userId]: userId của người dùng hiện tại
  // @HiveField(0)
  final int? userId;

  // @HiveField(1)
  final int conversationId;

  // @HiveField(2)
  int countUnreadMessage;

  late final StreamSubscription _subscription;

  @override
  void onChange(Change<UnreadMessageCounterState> change) async {
    countUnreadMessage = change.nextState.counter;

    // Hiện tại không có tin nhắn chưa đọc và trạng thái tiếp theo có tin nhắn chưa đọc
    if (!hasUnreadMessage && countUnreadMessage != 0)
      appService.addUnreadConversation(conversationId);
    // Hiện tại có tin nhắn chưa đọc và trạng thái tiếp theo đã đọc hết tin nhắn
    else if (hasUnreadMessage && countUnreadMessage == 0)
      appService.removeUnreadConversation(conversationId);

    super.onChange(change);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    // logger.log(
    //   'UnreadMessageCounterCubit_$hashCode',
    //   name: 'UnreadMessageCounterCubit_$conversationId closed',
    //   color: StrColor.red,
    // );
    return super.close();
  }

  // @override
  // int get hashCode => Object.hashAllUnordered([conversationId]);

  // @override
  // bool operator ==(Object other) =>
  //     other is UnreadMessageCounterCubit &&
  //     other.runtimeType == runtimeType &&
  //     other.conversationId == conversationId;
}
