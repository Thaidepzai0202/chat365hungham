import 'dart:math';

import 'package:app_chat365_pc/common/Widgets/display_message_content.dart';
import 'package:app_chat365_pc/common/Widgets/live_chat/timer_repo.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/data/enums/message_type.dart';

class LiveChatDisplay extends StatefulWidget {
  const LiveChatDisplay({
    Key? key,
    required this.isSentByCurrentUser,
    required this.message,
    required this.messageModel,
    this.listUsers,
    this.sentTime,
    this.listUserInfoBlocs,
    this.senderInfo,
  }) : super(key: key);
  final SocketSentMessageModel messageModel;
  final bool isSentByCurrentUser;
  final String? message;
  final DateTime? sentTime;
  final List<String>? listUsers;
  final Map<int, UserInfoBloc>? listUserInfoBlocs;
  final IUserInfo? senderInfo;


  @override
  State<LiveChatDisplay> createState() => _LiveChatDisplayState();
}

class _LiveChatDisplayState extends State<LiveChatDisplay> {
  late ChatBloc _chatBloc;

  @override
  void initState() {
    _chatBloc = context.read<ChatBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      bool isMiss = widget.messageModel.infoSupport?.status == 2;
      var themeData = context.theme;
      String text = isMiss
          ? (ChatRepo()
                  .getChatMemberSync(
                      conversationId: widget.messageModel.conversationId,
                      chatMemberId:
                          widget.messageModel.infoSupport?.userId ?? 0)
                  ?.name ??
              "")
          : '';
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isMiss ? const Color(0xffFFF5EA) : const Color(0xffFFEDED),
          gradient: widget.isSentByCurrentUser ? themeData.gradient : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.messageModel.infoSupport!.title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Text(
                widget.messageModel.infoSupport != null
                    ? widget.messageModel.infoSupport!.message
                    : '',
                style: const TextStyle(fontSize: 13, color: Colors.black)),
            DisplayMessageContent(
              messageModel: widget.messageModel,
              senderInfo: widget.senderInfo,
              listUserInfoBlocs: widget.listUserInfoBlocs,
              onTapImageMessage: (image) {},
              emotionBarSize: ValueNotifier(0),
            ),
            const Divider(
              color: Colors.black,
              thickness: 1,
            ),
            Row(
              children: [
                Text(
                  isMiss ? '$text chưa trả lời' : 'Chưa trả lời',
                  style: TextStyle(color: isMiss ? Colors.orange : Colors.red),
                ),
                const Spacer(),
                widget.messageModel.liveChat!.clientId
                            ?.contains('liveChatV2') ??
                        false
                    ? (widget.messageModel.conversationId ==
                            widget.messageModel.liveChat!.fromConversation!)
                        ? const SizedBox()
                        : Row(
                            children: [
                              Text(
                                'chuyển vào nhóm sau:',
                                style: AppTextStyles.text(context),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              StreamBuilder(
                                  stream: timerRepo
                                      .getLivechatMessageTimer(
                                          widget.messageModel.messageId)!
                                      .tick,
                                  builder: (context, snapshot) {
                                    // TL 20/2/2024:
                                    // Việc gọi api khi hết thời gian đã được listen()
                                    // ở ChatBloc. Ở đây chỉ thuần túy build UI thôi.
                                    //
                                    // if ((snapshot.data ?? 0) <= Duration.zero) {
                                    //   // timerRepo.livechatExpired.close();
                                    //   print(
                                    //       '______________${widget.messageModel.message}');
                                    //   _chatBloc.updateStatusLivechatMissed(
                                    //       widget.messageModel.conversationId,
                                    //       widget.messageModel.messageId,
                                    //       widget.listUserInfoBlocs?.keys
                                    //           .toList(),
                                    //       widget.messageModel.infoSupport,
                                    //       widget.messageModel.senderId,
                                    //       widget.messageModel.liveChat,
                                    //       AuthRepo().userInfo!.id);
                                    //   var message = ApiMessageModel(
                                    //       messageId:
                                    //           widget.messageModel.messageId,
                                    //       conversationId: widget.messageModel
                                    //           .liveChat!.fromConversation!,
                                    //       type: widget.messageModel.type ??
                                    //           MessageType.text,
                                    //       senderId:
                                    //           widget.messageModel.senderId,
                                    //       infoSupport:
                                    //           widget.messageModel.infoSupport,
                                    //       liveChat:
                                    //           widget.messageModel.liveChat,
                                    //       message: widget.messageModel.message);
                                    //   _chatBloc.sendMissMessageLiveChat(message,
                                    //       recieveIds: widget
                                    //           .listUserInfoBlocs!.keys
                                    //           .toList());
                                    // }
                                    var timeLeft =
                                        max(snapshot.data?.inSeconds ?? 30, 0);
                                    return Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        '${timeLeft}',
                                        style: AppTextStyles.text(context),
                                      ),
                                    );
                                  })
                            ],
                          )
                    : const SizedBox()
              ],
            )
          ],
        ),
      );
    }
    // TL 20/2/2024: Thỉnh thoảng cứ có cái khỉ gì đấy bị null.
    // Nên phải bắt exception chỗ này để còn biết
    catch (err, stack) {
      logger.logError(
          "Lỗi: $err. ${widget.messageModel.liveChat}, ${widget.messageModel.liveChat?.clientId}",
          stack,
          "$runtimeType.build");
    }
    return SizedBox.shrink();
  }
}
