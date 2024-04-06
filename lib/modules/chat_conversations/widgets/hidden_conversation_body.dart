import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_cubit.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_hidden.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/hidden_conversation_item.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HiddenConversationBody extends StatefulWidget {
  HiddenConversationBody({
    super.key,
  });

  @override
  State<HiddenConversationBody> createState() => HiddenConversationBodyState();
}

class HiddenConversationBodyState extends State<HiddenConversationBody> {
  late ChatConversationCubit chatConversationCubit;
  @override
  void initState() {
    chatConversationCubit = context.read<ChatConversationCubit>();
    chatConversationCubit.takeListHiddenConversation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: BlocBuilder(
        bloc: chatConversationCubit,
        builder: (context, state) {
          var conversations = chatConversationCubit.listHiddenConversation;
          if (state is LoadedHiddenConversationState) {
            return ListView(
              children: [
                Text(
                  'Cuộc trò chuyện',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: context.theme.textColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: conversations
                        .map((e) => HiddenConversationItem(
                              conversation: e,
                            ))
                        .toList(),
                  ),
                ),
              ],
            );
          } else {
            return Center(
                child: CircularProgressIndicator(
                    backgroundColor: context.theme.backgroundListChat,
                    valueColor: AlwaysStoppedAnimation(
                        context.theme.colorPirimaryNoDarkLight)));
          }
        },
      ),
    );
  }
}
