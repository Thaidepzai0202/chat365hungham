import 'dart:async';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_cubit.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_model.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/unread_conversation_item.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnReadConversationBody extends StatefulWidget {
  const UnReadConversationBody({
    super.key,
  });

  @override
  State<UnReadConversationBody> createState() =>
      UnreadConversationBodyController();
}

// TL 16/2/2024: Cho màn này bắt cả tin nhắn chưa đọc qua socket
// Kết hợp với việc phân chia theo mô hình MVC
class UnreadConversationBodyController extends State<UnReadConversationBody> {
  late ChatConversationCubit chatConversationCubit;

  List<ConversationModel> unreadConversations = [];

  late StreamSubscription<ChatEvent> chatRepoEventStream;

  @override
  void initState() {
    chatConversationCubit = context.read<ChatConversationCubit>();
    chatConversationCubit.getListConversationUnRead();

    chatRepoEventStream = ChatRepo().stream.listen((ChatEvent event) async {
      if (event is ChatEventOnReceivedMessage) {
        if (unreadConversations
            .where(
                (element) => event.msg.conversationId == element.conversationId)
            .isEmpty) {
          var conversationModel =
              (await ChatRepo().getConversationModel(event.msg.conversationId));
          if (conversationModel != null) {
            setState(() {
              unreadConversations.add(conversationModel);
            });
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    chatRepoEventStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatConversationCubit, ChatConversationState>(
      listener: (context, state) {
        if (state is LoadedUnReadConversationState) {
          setState(
            () {
              var loadedUnreads = state.listUnReadConversation;

              // Lọc đi những conversations đã có trước khi api tải về.
              unreadConversations.removeWhere((unreadConv) => loadedUnreads
                  .where((loaded) =>
                      loaded.conversationId == unreadConv.conversationId)
                  .isNotEmpty);

              unreadConversations.addAll(loadedUnreads);
            },
          );
        }
      },
      child: UnreadConversationBodyView(controller: this),
    );
  }
}

class UnreadConversationBodyView extends StatelessWidget {
  const UnreadConversationBodyView({super.key, required this.controller});

  final UnreadConversationBodyController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: ListView.builder(
        itemCount: controller.unreadConversations.length,
        itemBuilder: (context, index) {
          return UnreadConversationItem(
            conversationUnRead: controller.unreadConversations[index],
          );
        },
      ),
    );
  }
}
