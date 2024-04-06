import 'package:app_chat365_pc/common/Widgets/reply_message_builder.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_state.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';

class DisplayRelyMessageContent extends StatelessWidget {
  const DisplayRelyMessageContent({
    Key? key,
    required this.messageModel,
    required this.userInfoBloc,
  }) : super(key: key);

  final UserInfoBloc userInfoBloc;
  final SocketSentMessageModel messageModel;

  @override
  Widget build(BuildContext context) {
    var quoteMsg = messageModel.relyMessage!;
    var isSentByCurrentUser = messageModel.senderId == context.userInfo().id;
    // var textColor = isSentByCurrentUser
    //     ? AppColors.white
    //     : context.theme.replyOriginTextStyle.color;
    var textColor = isSentByCurrentUser ? AppColors.white : context.theme.text3Color;
    var replyInfoTextColor = isSentByCurrentUser
        ? AppColors.white
        : context.theme.text2Color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSentByCurrentUser ? null : context.theme.backgroundListChat ,
        gradient: isSentByCurrentUser ? context.theme.gradient : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<UserInfoBloc, UserInfoState>(
              bloc: userInfoBloc,
              builder: (context, state) {
                logger.log(
                    "msgId: ${messageModel.messageId}. username: ${state.userInfo.name}",
                    name: "$runtimeType");
                final replyModel = ApiReplyMessageModel(
                  senderName: state.userInfo.name,
                  message: quoteMsg.message,
                  createAt: quoteMsg.createAt,
                  messageId: quoteMsg.messageId,
                  senderId: quoteMsg.senderId,
                );
                return ReplyMessageBuilder(
                  replyModel: replyModel,
                  originMessageTextColor: textColor,
                  replyInfoTextColor: replyInfoTextColor,
                );
              }),
          if (!messageModel.message.isBlank) ...[
            Divider(
              color: replyInfoTextColor,
              height: 16,
              thickness: 1,
            ),
            if (messageModel.type?.isSticker == true)
              Container(
                width: 120,
                height: 120,
                child: CachedNetworkImage(
                  imageUrl: messageModel.message ?? "",

                  /// TL 13/1/2024: Chặn báo lỗi No host specified in URI
                  errorWidget: ((context, url, error) =>
                      const SizedBox.shrink()),
                ),
              )
            else
              Text(
                messageModel.message ?? StringConst.canNotDisplayMessage,
                style: context.theme.messageTextStyle.copyWith(
                  color: replyInfoTextColor,
                ),
              ),
          ]
        ],
      ),
    );
  }
}
