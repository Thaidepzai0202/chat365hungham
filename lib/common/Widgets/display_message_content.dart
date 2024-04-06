import 'dart:convert';
import 'dart:io';

import 'package:app_chat365_pc/common/Widgets/display_contact.dart';
import 'package:app_chat365_pc/common/Widgets/voice_display.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/apply_message_display.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/cv_display.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/file_display.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/image_display.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/link_display.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/map_display.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/text_message_display.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/video_call_display.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/video_display.dart';
import 'package:app_chat365_pc/modules/chat/widgets/ads_message.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/ads_model.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';

import '../../modules/chat/model/result_socket_chat.dart';

/// Hiển thị message theo [MessageType] khác nhau
///
/// [files] là các file đính kèm 1 message
class DisplayMessageContent extends StatelessWidget {
  const DisplayMessageContent({
    Key? key,
    required this.onTapImageMessage,
    required this.messageModel,
    required this.emotionBarSize,
    this.senderInfo,
    this.listUserInfoBlocs,
    this.mesFinded,
  }) : super(key: key);
  final Map<int, UserInfoBloc>? listUserInfoBlocs;
  final SocketSentMessageModel messageModel;
  final IUserInfo? senderInfo;
  final String? mesFinded;
  final ValueNotifier<double> emotionBarSize;

  /// Callback navigate đến [WidgetSlider] hiển các ảnh trong conversation hiện tại
  final ValueChanged<ApiFileModel> onTapImageMessage;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    final MessageType? messageType = messageModel.type;
    final IUserInfo? contact = messageModel.contact;
    final bool isSentByCurrentUser =
        messageModel.senderId == context.userInfo().id;
    final List<ApiFileModel> files = messageModel.files ?? [];
    final String? message = messageModel.message;
    final InfoLink? infoLink = messageModel.infoLink;
    String messagePhone = (message ?? '').replaceAll(RegExp(r'[^0-9]'), '');

    if ((messageType?.isContactCard ?? false) && contact != null) {
      child = DisplayContact(
        contact: contact,
        isSendByCurrentUser: isSentByCurrentUser,
      );
    }

    else if ([MessageType.adsCC, MessageType.adsCV, MessageType.adsNews]
        .contains(messageType)) {
      //logger.log("LamTran messmodel: ${messageModel.toHiveObjectMap()}");
      var model;
      // Thỉnh thoảng .message giống .messageType, chả hiểu sao
      // Nên là mới cần try catch đoạn này, nếu không thì sẽ màn hình "Đã có lỗi xảy ra"
      try {
        model = json.decode(messageModel.message!);
      } catch (e, s) {
        logger.log(e.toString() + s.toString());
      }
      if (model == null) return SizedBox();
      return AdsMessage.fromModel(AdsModel.fromJson(model).main_ads);
    }
    /// sticker
    else if (messageType?.isSticker == true) {
      child = Container(
        color: context.theme.backgroundChatContent,
        width: 150,
        height: 150,
        child: CachedNetworkImage(
          imageUrl: messageModel.message ?? "",
          // width: 150,
          // height: 200,
          /// TL 13/1/2024: Chặn báo lỗi No host specified in URI
          errorWidget: ((context, url, error) => const SizedBox.shrink()),
        ),
      );
    }

    /// voice
    else if (messageType?.isVoice == true && files.isNotEmpty) {
      child = VoiceDisplay(
        isSentByCurrentUser: isSentByCurrentUser,
        file: files[0],
      );
    }

    /// Image
    else if (messageType?.isImage == true) {
      var imagePlaceholder = context
          .read<ChatBloc>()
          .cachedMessageImageFile[messageModel.messageId];
      child = Directionality(
        textDirection:
            isSentByCurrentUser ? TextDirection.rtl : TextDirection.ltr,
        child: files.length == 1
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: context.mediaQuerySize.height * 1 / 3,
                ),
                child: InkWell(
                  // onTap: () => onTapImageMessage(files![0]),
                  child: ImageDisplay(
                    file: files[0],
                    // placeholder: !imagePlaceholder.isBlank &&
                    //         imagePlaceholder![0].filePath != null
                    //     ? File(imagePlaceholder[0].filePath!)
                    //     : null,
                    messageModel: messageModel,
                  ),
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 1,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  mainAxisExtent: 120,
                ),
                addRepaintBoundaries: true,
                addAutomaticKeepAlives: true,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: files.length.clamp(0, 4) ?? 0,
                itemBuilder: (_, index) {
                  var e = files[index];
                  var p = imagePlaceholder?[index];
                  return ImageDisplay(
                    file: e,
                    // placeholder: p != null
                    //     ? File(p.filePath.isBlank
                    //         ? 'https://mess.timviec365.vn/uploads/' +
                    //             p.resolvedFileName
                    //         : p.filePath!)
                    //     : null,
                    fit: BoxFit.contain,
                    messageModel: messageModel.copyWith(files: [e]),
                    cachedSize: 500,
                    remain: index == 2 && files.length > 4
                        ? files.length - index - 2
                        : 0,
                  );
                },
              ),
      );
    }

    /// Cv
    else if (messageType?.isCV == true) {
      child = CvDisplay(
          isSentByCurrentUser: isSentByCurrentUser, msgModel: messageModel);
    }

    /// Video
    else if (messageType?.isVideo == true ||
        (messageType?.isFile == true &&
            messageModel.files?.first.isVideo == true)) {
      child = VideoDisplay(
        isSentByCurrentUser: isSentByCurrentUser,
        msgModel: messageModel,
        cachedFile: context
            .read<ChatBloc>()
            .cachedMessageImageFile[messageModel.messageId]
            ?.first,
      );
    }

    /// File
    else if (messageType?.isFile == true) {
      logger.log(files, name: "FilesLogger");
      if (files.isEmpty) {
        return TextDisplay(
          isSentByCurrentUser: isSentByCurrentUser,
          message: StringConst.canNotDisplayFile,
          emotionBarSize: emotionBarSize,
        );
      }

      /// Ảnh
      if (files.every((e) => e.fileType == MessageType.image)) {
        var imagePlaceholder = context
            .read<ChatBloc>()
            .cachedMessageImageFile[messageModel.messageId];

        child = Directionality(
          textDirection:
              isSentByCurrentUser ? TextDirection.rtl : TextDirection.ltr,
          child: files.length == 1
              ? ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: context.mediaQuerySize.height * 1 / 3,
                  ),
                  // width: 120,
                  // height: 150,
                  child: InkWell(
                    onTap: () => onTapImageMessage(files[0]),
                    child: ImageDisplay(
                      file: files[0],
                      placeholder: !imagePlaceholder.isBlank &&
                              imagePlaceholder![0].filePath != null
                          ? File(imagePlaceholder[0].filePath!)
                          : null,
                      messageModel: messageModel,
                    ),
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 1,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    mainAxisExtent: 120,
                  ),
                  addRepaintBoundaries: true,
                  addAutomaticKeepAlives: true,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: files.length.clamp(0, 4),
                  itemBuilder: (_, index) {
                    var e = files[index];
                    var p = imagePlaceholder?[index];
                    return ImageDisplay(
                      file: e,
                      placeholder: p != null ? File(p.filePath!) : null,
                      fit: BoxFit.contain,
                      messageModel: messageModel.copyWith(files: [e]),
                      cachedSize: 500,
                      remain: index == 2 && files.length > 4
                          ? files.length - index - 2
                          : 0,
                    );
                  },
                ),
        );
      }

      /// File
      else if (files.every((e) => e.fileType.isFile)) {
        child = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: files
              .map(
                (e) => FileDisplay(
                  file: e,
                  messageId: messageModel.messageId,
                ),
              )
              .toList(),
        );
      } else {
        child = TextDisplay(
          message: StringConst.canNotDisplayFile,
          isSentByCurrentUser: isSentByCurrentUser,
          emotionBarSize: emotionBarSize,
        );
      }
    }

    /// Text
    else if (messageType?.isText == true&& !message.isBlank) {
      child = TextDisplay(
        isSentByCurrentUser: isSentByCurrentUser,
        message: message,
        mesFinded: mesFinded,
        // đổi thành tolocal thì bị nhanh hơn 7h nhưng giờ nó lại là hợp lí
        sentTime: messageModel.createAt.toLocal(),
        emotionBarSize: emotionBarSize,
      );
    }

    /// Link
    else if ((messageType?.isLink ?? false)) {
      if (infoLink != null) {
        child = LinkDisplay(
          infoLink: infoLink,
          link: message,
        );
      } else {
        return TextDisplay(
          message: message,
          isSentByCurrentUser: isSentByCurrentUser,
          emotionBarSize: emotionBarSize,
        );
      }

      /// Map
    } else if (messageType?.isMap ?? false) {
      child = MapDisplay(
        infoLink: infoLink,
        senderInfo: senderInfo!,
      );
    }

    /// Notification
    // else if (messageType?.isNotification ?? false) {
    // child = NotificationMessageDisplay(
    //   listUserInfos: listUserInfos,
    //   message: message,
    // );
    // }
    else if (messageType?.isVideoCall == true) {
      child = VideoCallDisplay(
        messageModel: messageModel,
      );
    } else if (messageType?.isApplying == true ||
        messageType?.isOfferRecieved == true ||
        messageType?.isDocument == true) {
      child = ApplyMessageDisplay(
        link: messageModel.linkNotification,
        isSentByCurrentUser: isSentByCurrentUser,
        content: message ?? '',
        infoLink: infoLink,
        isApply: messageType?.isApplying == true,
        uscId: messageModel.uscId,
        messageModel: messageModel,
      );
    } else if (messageType?.isVote == true) {
      child = const Text('Tính năng chưa có');
      // child = PollDisplay(messageModel.message);
    }

    /// Khác, không xác định
    else {
      logger.log(messageModel.toMap(), color: StrColor.magenta);
      child = InkWell(
        onTap: () => Clipboard.setData(
                ClipboardData(text: messageModel.toString()))
            .onError((error, stackTrace) =>
                BotToast.showText(text: 'Sao chép thất bại'))
            .whenComplete(() => BotToast.showText(text: 'Sao chép thành công')),
        child: TextDisplay(
          isSentByCurrentUser: isSentByCurrentUser,
          message: StringConst.canNotDisplayMessage,
          emotionBarSize: emotionBarSize,
        ),
      );
    }
    return child;
  }
}
