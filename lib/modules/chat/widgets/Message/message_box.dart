import 'package:app_chat365_pc/common/Widgets/display_message_content.dart';
import 'package:app_chat365_pc/common/Widgets/live_chat/livechat_message_content.dart';
import 'package:app_chat365_pc/common/Widgets/section/display_reply_message_content.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/material.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';

class MessageBox extends StatefulWidget {
  const MessageBox({
    Key? key,
    required this.messageModel,
    required this.hasReplyMessage,
    required this.isSentByCurrentUser,
    required this.listUserInfoBlocs,
    required this.emotionBarSize,
    this.borderRadius,
    this.width,
    this.maxWidth,
    this.mesFinded,
  }) : super(key: key);

  final SocketSentMessageModel messageModel;
  final bool hasReplyMessage;
  final bool isSentByCurrentUser;
  final BorderRadius? borderRadius;
  final Map<int, UserInfoBloc> listUserInfoBlocs;
  final double? width;
  final double? maxWidth;
  final String? mesFinded;
  final ValueNotifier<double> emotionBarSize;


  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {

  late final double initialBoxMaxWidth;

  @override
  void initState() {
    super.initState();
    initialBoxMaxWidth = widget.maxWidth ?? AppConst.maxMessageBoxWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.only(right: 10, bottom: 1),
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
            child: Container(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth < initialBoxMaxWidth?constraints.maxWidth:initialBoxMaxWidth,
                ),
                color: context.theme.backgroundColor,

                // width: double.infinity,
                child: widget.hasReplyMessage && widget.messageModel.relyMessage != null
                    ? DisplayRelyMessageContent(
                        messageModel: widget.messageModel,
                        userInfoBloc: UserInfoBloc.fromChatMember(
                            widget.messageModel.relyMessage!.senderId,
                            widget.messageModel.conversationId),
                        // listUserInfoBlocs[messageModel.relyMessage!.senderId] ??
                        //     UserInfoBloc(
                        //       BasicInfo(
                        //         id: messageModel.relyMessage!.senderId,
                        //         name: messageModel.relyMessage!.senderName,
                        //         // state: messageModel.relyMessage!.
                        //       ),
                        //     ),
                      )
                    // không hiển thị tin nhắn live chat có nội dung như sau
                    : (widget.messageModel.liveChat != null &&
                            widget.messageModel.infoSupport != null &&
                            widget.messageModel.message != 'Tin nhắn đã được bắt ' &&
                            widget.messageModel.message !=
                                'Tin nhắn đã hết hạn, đã chuyển vào nhóm chung ')
                        ? LivechatMessageContent(
                            onTapImageMessage: (image) {},
                            messageModel: widget.messageModel,
                            senderInfo: widget.messageModel.type?.isMap == true
                                ? (widget.listUserInfoBlocs[widget.messageModel.senderId]
                                        ?.state
                                        .userInfo ??
                                    // TL 23/2/2024: Lấy thông tin người dùng gắn liền CTC
                                    UserInfoBloc.fromChatMember(
                                            widget.messageModel.senderId,
                                            widget.messageModel.conversationId)
                                        .state
                                        .userInfo)
                                : null,
                            listUserInfoBlocs: widget.listUserInfoBlocs,
                          )
                        : DisplayMessageContent(
                            messageModel: widget.messageModel,
                            senderInfo: widget.messageModel.type?.isMap == true
                                ? (widget.listUserInfoBlocs[widget.messageModel.senderId]
                                        ?.state
                                        .userInfo ??
                                    // TL 23/2/2024: Lấy thông tin người dùng gắn liền CTC
                                    UserInfoBloc.fromChatMember(
                                            widget.messageModel.senderId,
                                            widget.messageModel.conversationId)
                                        .state
                                        .userInfo)
                                : null,
                            listUserInfoBlocs: widget.listUserInfoBlocs,
                            mesFinded: widget.mesFinded,
                            onTapImageMessage: (image) {},
                            emotionBarSize: widget.emotionBarSize,
                          )),
          ),
        );
      }
    );
  }
}
