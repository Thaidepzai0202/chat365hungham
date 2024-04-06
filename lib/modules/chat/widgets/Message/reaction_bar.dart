import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/reaction_cubit/reaction_cubit.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/utils/data/enums/emoji.dart';
import 'package:app_chat365_pc/utils/ui/app_decoration.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';

class ReactionBar extends StatelessWidget {
  ReactionBar({
    Key? key,
    // required this.emojies,
    // this.onTapEmoji,
    this.remain = 0,
    this.remainIndex,
    required this.emotions,
    required this.chatDetailBloc,
    required this.appLayoutCubit,
    required this.isSentByCurrentUser,
    required this.reactionCubit,
    required this.chatBloc,
  }) : super(key: key);

  // final ValueChanged<Emoji>? onTapEmoji;
  // final List<Emotion> emojies;
  final int remain;
  final int? remainIndex;
  Map<Emoji, Emotion> emotions;
  final ChatDetailBloc chatDetailBloc;
  final AppLayoutCubit appLayoutCubit;
  final bool isSentByCurrentUser;
  final ReactionCubit reactionCubit;
  final ChatBloc chatBloc;

  int maxEmojiOnBar = AppConst.maxEmotionInBarUnderMessageBox;
  int maxNumberOfEmoji = AppConst.maxNumberOfEmoji;
  String numberOfEmojiToString(int value) {
    String number = '';
    if (value > 0 && value < maxNumberOfEmoji) {
      number = value.toString();
    }
    else {
      number = "$maxNumberOfEmoji+";
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    List<ChatMemberModel> chatMembers = [];
    Future.delayed(const Duration(seconds: 0), () async => chatMembers = await chatDetailBloc.chatRepo.getAllChatMembers(conversationId: chatDetailBloc.conversationId),);
    try {emotions.removeWhere((key, value) => value.listUserId.isEmpty);} catch (e) {}
    List<Emotion> filterEmotions = emotions.values.where((element) => element.listUserId.isNotEmpty).toList();
    List<Widget> emojiWithNumbers = filterEmotions.map((e) {
      return InkWell(
        onTap: () async {
          await AppDialogs.showReactionDetailDialog(
            context,
            onTapEmotion: e,
            reactions: emotions,
            chatMembers: chatMembers,
            reactionCubit: reactionCubit,
            chatBloc: chatBloc,
          );
        },
        child: Container(
          decoration: AppDecoration.emojiDecoration,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
          child: Row(
            children: [
              Image.asset(
                e.type.assetPath,
                width: 26,
                height: 26,
              ),
              Text(
                numberOfEmojiToString(e.listUserId.length).toString(),
                style: AppTextStyles.regularW400(
                  context,
                  size: 12,
                  color: AppColors.lightThemeTextColor,
                ),
              ),
              SizedBoxExt.w5
            ],
          ),
        ),
      );
    }).toList();
    Widget remainWidget = filterEmotions.length > maxEmojiOnBar
        ? InkWell(
            onTap: () async {
              await AppDialogs.showReactionDetailDialog(
                context,
                onTapEmotion: filterEmotions.first,
                reactions: emotions,
                chatMembers: chatMembers,
                reactionCubit: reactionCubit,
                chatBloc: chatBloc,
              );
            },
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 26,
              width: 26,
              alignment: Alignment.center,
              decoration: AppDecoration.emojiDecoration,
              child: Text(
                '+${emojiWithNumbers.length - maxEmojiOnBar}',
                style: AppTextStyles.regularW400(
                  context,
                  size: 12,
                  color: AppColors.tundora,
                ),
              ),
            ),
        )
        : Container();
    return Row(
      children: isSentByCurrentUser
          ? [...(emojiWithNumbers.take(maxEmojiOnBar)), remainWidget]
          : [remainWidget, ...(emojiWithNumbers.take(maxEmojiOnBar))],
    );
  }
}
