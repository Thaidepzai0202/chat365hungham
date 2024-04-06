import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/reaction_cubit/reaction_cubit.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/emoji_bar.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class DetailEmotionBar extends StatelessWidget {
  final SocketSentMessageModel messageModel;
  final ChatDetailBloc chatDetailBloc;
  final ReactionCubit reactionCubit;
  const DetailEmotionBar({
      super.key,
      required this.messageModel,
      required this.chatDetailBloc,
      required this.reactionCubit,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: context.theme.backgroundColor,
      ),
      child: FittedBox(
        child: EmojiBar(
          emotion: reactionCubit.state.reactions,
          onSelected: (reactEmoji) async {
            Navigator.pop(context);
            await reactionCubit.reactedAtEmoji(
              context.userInfo().id,
              messageModel,
              chatDetailBloc.listUserInfoBlocs.keys.toList(),
              chatDetailBloc.isGroup
                  ? chatDetailBloc.conversationName.value ??
                  'Thông báo Chat365'
                  : AuthRepo().userName,
              reactedPersonId: ChatRepo().currentUserId,
              reactedEmoji: reactEmoji,
            );
          },
        ),
      ),
    );
  }
}