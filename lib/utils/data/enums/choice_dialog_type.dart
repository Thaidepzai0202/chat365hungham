import 'dart:io';

import 'package:app_chat365_pc/common/components/choice_dialog_item.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sp_util/sp_util.dart';

/// Các type cần [chatInputBarKey] để trigger mode (reply, edit) tương ứng của [ChatInputBar]
class ChoiceDialogTypes {
  // static selectMultiMessage(
  //   BuildContext context, {
  //   required SocketSentMessageModel message,
  //   required VoidCallback ontap,
  //   String? name,
  // }) =>
  //     ChoiceDialogItem(
  //       iconPath: Images.message_tick_msg,
  //       value: StringConst.selectMultiMessage,
  //       onTap: ontap,
  //       color: Color(0xff401baa),
  //     );
  // static copyImage(
  //   BuildContext context, {
  //   required ApiFileModel? content,
  //   String text = 'Sao chép ảnh',
  // }) =>
  //     ChoiceDialogItem(
  //       iconPath: Images.copy_msg,
  //       value: text,
  //       onTap: () {
  //         if (content != null) {
  //           ApiFileModel image = ApiFileModel(
  //               fileName: content.fileName,
  //               fileType: MessageType.image,
  //               fileSize: content.fileSize,
  //               displayFileSize: content.displayFileSize,
  //               filePath: content.filePath,
  //               height: content.height,
  //               imageSource: content.imageSource,
  //               resolvedFileName: content.resolvedFileName,
  //               uploaded: content.uploaded,
  //               width: content.width);
  //           messagePaste = SocketSentMessageGetPasteModel(
  //               type: MessageType.image, file: image);
  //           Clipboard.setData(ClipboardData(text: ''));
  //         }
  //         BotToast.showText(text:'Sao chép thành công');
  //       },
  //     );
  //
  // static copy(
  //   BuildContext context, {
  //   required String? content,
  //   String text = StringConst.copy,
  // }) =>
  //     ChoiceDialogItem(
  //       iconPath: Images.copy_msg,
  //       value: text,
  //       onTap: () {
  //         if (content != null) {
  //           messagePaste = SocketSentMessageGetPasteModel(
  //               type: MessageType.text, message: content);
  //           Clipboard.setData(ClipboardData(text: content));
  //         }
  //         BotToast.showText(text:'Sao chép thành công');
  //       },
  //     );
  //
  static reply(
    BuildContext context, {
    required ApiReplyMessageModel replyModel,
    // required GlobalKey<ChatInputBarState> chatInputBarKey,
  }) =>
      ChoiceDialogItem(
        iconPath: Images.reply_msg,
        value: StringConst.reply,
        onTap: () {
          // chatInputBarKey.currentState?.replyMessage(replyModel);
        },
      );
//
// static edit(
//   BuildContext context, {
//   required SocketSentMessageModel message,
//   required GlobalKey<ChatInputBarState> chatInputBarKey,
// }) =>
//     ChoiceDialogItem(
//       iconPath: Images.edit_linear_msg,
//       value: StringConst.edit,
//       onTap: () => chatInputBarKey.currentState?.editMessage(message),
//     );
//
// static editImage(
//   BuildContext context, {
//   required SocketSentMessageModel message,
// }) {
//   return ChoiceDialogItem(
//     iconPath: Images.edit_linear_msg,
//     value: StringConst.edit,
//     onTap: () async {
//       Navigator.of(context).push(MaterialPageRoute(
//           builder: (context) => ImageEditorInMessage(
//               image: message.files!.first.fullFilePath)));
//     },
//   );
// }
//
// static delete(
//   BuildContext context, {
//   required ApiMessageModel message,
//   required List<int> members,
//   bool sentByCurrentUser = true,
// }) {
//   return ChoiceDialogItem(
//     iconPath: Images.trash_msg,
//     value: StringConst.delete,
//     onTap: () {
//       // if (!sentByCurrentUser) {
//       //   AppDialogs.showDeleteMsgDialog(context, onConfirm: () {
//       //     AppRouter.back(context);
//       //     context.read<ChatBloc>().add(
//       //       ChatEventEmitDeleteMessage(
//       //         message,
//       //         members,
//       //       ),
//       //     );
//       //     // AppRouter.back(context);
//       //   });
//       // } else
//       showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//                 title: Text('Xóa tin nhắn ở phía bạn?'),
//                 content: Text(
//                   '''Xóa tin nhắn ở phía bạn.\nNhững người khác trong đoạn chat vẫn có thể xem được.''',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 actions: [
//                   TextButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: Text(
//                         'Hủy',
//                         style: TextStyle(fontSize: 16, color: Colors.grey),
//                       )),
//                   TextButton(
//                       onPressed: () {
//                         context.read<ChatBloc>().add(
//                               ChatEventEmitDeleteMessage(
//                                 message,
//                                 members,
//                               ),
//                             );
//                         Navigator.of(context).pop();
//                         Fluttertoast.showToast(
//                             msg: 'Xóa tin nhắn thành công');
//                       },
//                       child: Text(
//                         'Xóa',
//                         style: TextStyle(fontSize: 16, color: Colors.red),
//                       ))
//                 ],
//               ));
//     },
//   );
// }
//
// static deleteErrorMessage(
//   BuildContext context, {
//   required ApiMessageModel message,
// }) {
//   return ChoiceDialogItem(
//     iconPath: Images.trash_msg,
//     value: 'Xóa',
//     onTap: () {
//       errorMessage.removeWhere(
//         (element) => element.contains('${message.messageId}'),
//       );
//       SpUtil.remove(LocalStorageKey.message_error);
//       SpUtil.putStringList(LocalStorageKey.message_error, errorMessage);
//       context.read<ChatBloc>().add(ChatEventEmitDeleteMessageFake(message));
//     },
//   );
// }
//
// static recall(
//   BuildContext context, {
//   required ApiMessageModel message,
//   required List<int> members,
// }) =>
//     ChoiceDialogItem(
//       iconPath: Images.recall_msg,
//       value: 'Thu hồi',
//       onTap: () {
//         context.read<ChatBloc>().add(
//               ChatEventEmitRecallMessage(
//                 message,
//                 members,
//               ),
//             );
//       },
//     );
//
// static shareText(
//   BuildContext context, {
//   required SocketSentMessageModel message,
// }) =>
//     ChoiceDialogItem(
//       iconPath: Images.share_msg,
//       value: 'Chia sẻ',
//       onTap: () {
//         Share.share(message.message != '' ? message.message ?? ' ' : ' ');
//       },
//       boldText: true,
//     );
// static shareBusinessCard(
//   BuildContext context, {
//   required SocketSentMessageModel message,
//   // required ApiFileModel file,
//   required File file,
// }) =>
//     ChoiceDialogItem(
//         iconPath: Images.share_msg,
//         value: 'Chia sẻ',
//         onTap: () async {
//           RenderBox? box = context.findRenderObject() as RenderBox?;
//           await Future.delayed(Duration.zero, () async {
//             await Share.shareXFiles([XFile(file.absolute.path)],
//                 sharePositionOrigin:
//                     box!.localToGlobal(Offset.zero) & box.size);
//           });
//         });
//
// static shareFile(
//   BuildContext context, {
//   required SocketSentMessageModel message,
//   // required ApiFileModel file,
//   required List<ApiFileModel> listFiles,
// }) =>
//     ChoiceDialogItem(
//       iconPath: Images.share_msg,
//       value: 'Chia sẻ',
//       onTap: () async {
//         int totalSize = 0;
//         for (var file in listFiles) {
//           totalSize += file.fileSize;
//         }
//         AppDialogs.showLoadingCircle(context);
//         var dir = await getTemporaryDirectory();
//         try {
//           var savePath = dir.absolute
//               .path /*await SystemUtils.prepareSaveDir(isImage: message.type!.isImage)*/;
//           if (savePath == null)
//             return BotToast.showText(text:
//               'Tạo đường dẫn tải file thất bại',
//             );
//           final files = <XFile>[];
//
//           for (var file in listFiles) {
//             String filePath = savePath + path.separator + file.fileName;
//             if (!File(filePath).existsSync())
//               await Dio()
//                   .download(file.downloadPath, filePath
//                       /*SystemUtils.downloadFile(file.downloadPath, savePath, fileName: FileUtils.getUniqueFile(savePath, file.fileName), messageId: message.messageId),*/
//                       )
//                   .then((value) => debugPrint('downloading...'))
//                   .whenComplete(() => debugPrint('downloaded'));
//             // else
//             //int count = listFiles!.length;
//             files.add(XFile(
//               filePath,
//             ));
//           }
//           AppDialogs.hideLoadingCircle(context);
//           RenderBox? box = context.findRenderObject() as RenderBox?;
//           await Future.delayed(Duration.zero, () async {
//             await Share.shareXFiles(files,
//                 sharePositionOrigin:
//                     box!.localToGlobal(Offset.zero) & box.size);
//           });
//         } catch (e) {
//           print(e.toString());
//           BotToast.showText(text:'Đã có lỗi xảy ra');
//         }
//         // await dir.delete(recursive: true).then((value) => print('deleting...')).whenComplete(() => print('deleted'));
//         // return;
//       },
//     );

// static forward(
//   BuildContext context, {
//   required SocketSentMessageModel message,
//   required IUserInfo senderInfo,
//   String? name,
// }) =>
//     ChoiceDialogItem(
//       iconPath: Images.forward_msg,
//       value: StringConst.forward + (name ?? ''),
//       onTap: () => AppRouterHelper.toForwardMessagePage(
//         context,
//         message: message,
//         senderInfo: senderInfo,
//       ),
//
//     );

// static addConversationToFavorite(
//   BuildContext context, {
//   required int conversationId,
//   required ChatConversationBloc chatConversationBloc,
//   bool isReversed = false,
// }) =>
//     ChoiceDialogItem(
//       value: StringConst.addToFavorite,
//       onTap: () {
//         AppDialogs.showConfirmDialog(
//           context,
//           title: 'Thêm cuộc trò chuyện vào danh sách yêu thích ?',
//           nameFunction: 'Thêm',
//           onFunction: (_) => chatConversationBloc.changeFavoriteConversation(
//             conversationId,
//             favorite: 1,
//           ),
//           isReversed: false,
//           successMessage: 'Thêm vào yêu thích thành công',
//         );
//         ;
//       },
//     );
//
// static hiddenConversation(
//   BuildContext context, {
//   required int conversationId,
//   required ChatConversationBloc chatConversationBloc,
// }) =>
//     ChoiceDialogItem(
//       value: 'Ẩn cuộc trò chuyện',
//       onTap: () async {
//         if (pinCode!.isBlank) {
//           await AppRouter.toPage(context, AppPages.ChangeNewPinCodeScreen,
//               arguments: {
//                 'isNewPinCode': true,
//                 'conversationId': conversationId,
//                 'isHidden': false,
//                 'isHomeScreen': true,
//               });
//         } else {
//           await AppRouter.toPage(context, AppPages.InputPinCodeScreen,
//               arguments: {
//                 'conversationId': conversationId,
//                 'isHidden': false,
//                 'isHomeScreen': true,
//               });
//         }
//       },
//     );

// static leaveGroupConversation(
//   BuildContext context, {
//   required int conversationId,
//   required ChatConversationBloc chatConversationBloc,
//   required IUserInfo userInfo,
//   required ChatDetailBloc chatDetailBloc,
//   required ProfileCubit profileCubit,
// }) =>
//     ChoiceDialogItem(
//       value: 'Rời khỏi nhóm',
//       onTap: () {
//         AppDialogs.showConfirmDialog(
//           context,
//           title: 'Rời khỏi cuộc trò chuyện',
//           onFunction: (_) async {
//             return await profileCubit.deleteMember(
//               AuthRepo().userInfo ?? context.userInfo(),
//               chatDetailBloc.listUserInfoBlocs.keys.toList(),
//             );
//           },
//           onSuccess: () {
//             var conversationId = chatDetailBloc.conversationId;
//             chatConversationBloc.onOutGroup(
//               conversationId,
//               AuthRepo().userId ?? -1,
//             );
//             AppRouter.backToPage(context, AppPages.Navigation);
//           },
//           content: Padding(
//             padding: AppPadding.paddingVertical20,
//             child: Text(
//               'Bạn có chắn chắn muốn rời khỏi cuộc trò chuyện này ?',
//               textAlign: TextAlign.center,
//               style: AppTextStyles.regularW400(context, size: 14),
//             ),
//           ),
//           successMessage: 'Rời khỏi cuộc trò chuyện thành công',
//           nameFunction: 'Đồng ý',
//         );
//       },
//     );
//
// static removeConversationToFavorite(
//   BuildContext context, {
//   required int conversationId,
//   required ChatConversationBloc chatConversationBloc,
// }) =>
//     ChoiceDialogItem(
//       value: StringConst.removeFromFavorite,
//       onTap: () {
//         AppDialogs.showConfirmDeleteDialog(
//           context,
//           title: 'Xóa cuộc trò chuyện khỏi danh sách yêu thích',
//           onDelete: (_) => chatConversationBloc.changeFavoriteConversation(
//             conversationId,
//             favorite: 0,
//           ),
//           successMessage: 'Xóa thành công',
//         );
//         ;
//       },
//     );
//
// static deleteConversation(
//   BuildContext context, {
//   required int conversationId,
//   required ChatConversationBloc chatConversationBloc,
//   required String conversationName,
// }) =>
//     ChoiceDialogItem(
//         value: StringConst.deleteConversation,
//         onTap: () {
//           var style = AppTextStyles.regularW500(context,
//               size: 14, color: AppColors.red);
//           AppDialogs.deleteConversation(context,
//               conversationId: conversationId,
//               chatConversationBloc: chatConversationBloc,
//               style: style,
//               conversationName: conversationName);
//         });
//
// static markReadAllMessage(
//   BuildContext context, {
//   required int conversationId,
//   required List<int> members,
// }) =>
//     ChoiceDialogItem(
//       value: StringConst.markAsRead,
//       onTap: () => context.read<ChatBloc>().markReadMessages(
//             senderId: context.userInfo().id,
//             conversationId: conversationId,
//             memebers: members,
//           ),
//     );
//
// static pinMessage(
//   BuildContext context, {
//   required String messageId,
//   required String messageContent,
// }) =>
//     ChoiceDialogItem(
//       iconPath: Images.pin_msg,
//       value: StringConst.pinMessage,
//       onTap: () {
//         context.read<ChatDetailBloc>().pinMessage(
//               messageId,
//               messageContent,
//             );
//       },
//     );

//bookmark message
// static bookmarkMessage(
//   BuildContext context, {
//   required String messageId,
//   // required String messageContent,
//   required int conversationId,
//   required int isFavorite,
// }) {
//   return ChoiceDialogItem(
//     iconPath:
//         isFavorite == 1 ? Images.star_slash_message_mark : Images.star_msg,
//     value: isFavorite == 1 ? 'Bỏ tin nhắn đánh dấu' : 'Đánh dấu tin nhắn',
//     onTap: () {
//       if (isFavorite == 0) {
//         context
//             .read<BookMarkMessageCubit>()
//             .setBookMarkMessage(
//               conversationId,
//               messageId,
//             )
//             .whenComplete(() =>
//                 Fluttertoast.showToast(msg: 'Đánh dấu tin nhắn thành công'));
//       } else {
//         context
//             .read<BookMarkMessageCubit>()
//             .removeBookMarkMessage(
//               conversationId,
//               messageId,
//             )
//             .whenComplete(() => Fluttertoast.showToast(
//                 msg: 'Bỏ đánh dấu tin nhắn thành công'));
//       }
//     },
//   );
// }
//
// //info message text
// static detailMessage(BuildContext context, SocketSentMessageModel model,
//         List<IUserInfo>? avatar) =>
//     ChoiceDialogItem(
//       iconPath: Images.detail_message,
//       value: 'Thông tin chi tiết',
//       onTap: () {
//         AppRouter.toPage(context, AppPages.Detail_Message,
//             arguments: {'model': model, 'avatar': avatar});
//       },
//     );
//
// static deleteContact(BuildContext context, int contact) {
//   var friendCubit = context.read<FriendCubit>();
//   return ChoiceDialogItem(
//     value: StringConst.deleteContact,
//     onTap: () {
//       AppDialogs.showConfirmDialog(
//         context,
//         title: 'Xóa liên hệ',
//         nameFunction: 'Xóa',
//         onFunction: (_) => friendCubit.deleteContact(contact),
//         successMessage: 'Xóa liên hệ thành công',
//         content: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text('Bạn có chắc muốn xóa liên hệ này ?'),
//         ),
//       );
//     },
//   );
// }
//
// static save(
//   BuildContext context, {
//   required List<ApiFileModel> files,
//   String? messageId,
//   bool isImage = false,
// }) {
//   return ChoiceDialogItem(
//     iconPath: Images.ic_download,
//     value: StringConst.save,
//     onTap: isImage
//         ? () async {
//             // for (var file in files) {
//             await SystemUtils.downloadImage(
//                 files.map<String>((e) => e.downloadPath).toList());
//             // }
//           }
//         : () async {
//             var downloaderCubit = DownloaderCubit();
//             final ValueNotifier<String?> taskIdNotifier =
//                 ValueNotifier(downloaderCubit.tasks[messageId]?.taskId);
//             try {
//               print("_downloadFunction");
//               var savePath =
//                   await SystemUtils.prepareSaveDir(isImage: isImage);
//               if (savePath == null) {
//                 return BotToast.showText(text:'Tạo đường dẫn download thất bại');
//               }
//               for (var file in files) {
//                 await SystemUtils.downloadFile(
//                   file.downloadPath,
//                   savePath,
//                   fileName: FileUtils.getUniqueFile(savePath, file.fileName),
//                   messageId: messageId,
//                 );
//               }
//             } catch (e, s) {
//               logger.logError(e, s);
//               BotToast.showText(text:
//                 'Lỗi khi tải file\n$e',
//                 toast: Toast.LENGTH_SHORT,
//               );
//             }
//           },
//   );
// }

// static changeNoti(
//   BuildContext context, {
//   required int conversationId,
//   required List<int> members,
//   required ChatConversationBloc chatConversationBloc,
//   required bool isOnNotifications,
// }) =>
//     ChoiceDialogItem(
//         value: isOnNotifications
//             ? 'Tắt thông báo cuộc trò chuyện'
//             : 'Bật thông báo cuộc trò chuyện',
//         onTap: () {
//           context.read<ChatConversationBloc>().changeNotificationStatus(
//                 conversationId: conversationId,
//                 membersIds: members,
//                 userId: userInfo?.id ?? -1,
//               );
//         });
}
