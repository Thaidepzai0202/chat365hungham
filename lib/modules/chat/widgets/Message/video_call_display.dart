import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/router/app_router_helper.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sp_util/sp_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class VideoCallDisplay extends StatefulWidget {
  const VideoCallDisplay({
    Key? key,
    required this.messageModel,
  }) : super(key: key);
  final SocketSentMessageModel messageModel;

  @override
  State<VideoCallDisplay> createState() => _VideoCallDisplayState();
}

class _VideoCallDisplayState extends State<VideoCallDisplay> {
  late ChatDetailBloc _chatDetailBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatDetailBloc = context.read<ChatDetailBloc>();
  }

  @override
  Widget build(BuildContext context) {
    var isSentByCurrentUser =
        widget.messageModel.senderId == context.userInfo().id;
    var messageType = widget.messageModel.type!;
    return Container(
      color: context.theme.backgroundChatContent,
      width: 180,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: context.theme.backgroundOnForward,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                widget.messageModel.type!.displayMessageType(
                  null,
                  isSentByCurrentUser: isSentByCurrentUser,
                ),
                style: AppTextStyles.regularW700(
                  context,
                  size: 14,
                  lineHeight: 19,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SvgPicture.asset(
                    messageType.videoCallDisplayMessageIconAssetPath(
                      isSendByCurrentUser: isSentByCurrentUser,
                    ),
                    color: context.theme.text3Color,
                  ),
                  const SizedBox(width: 8),
                  if (messageType == MessageType.rejectVideoCall)
                    Text(
                      isSentByCurrentUser
                          ? 'Bạn đã từ chối'
                          : 'Người nhận từ chối',
                      style: AppTextStyles.regularW400(
                        context,
                        size: 14,
                        lineHeight: 16,
                        color: AppColors.doveGray,
                      ),
                    ),
                ],
              ),
              // const SizedBox(height: 12),
              Divider(
                color: AppColors.greyCC,
                thickness: 1,
                height: 24,
              ),
              InkWell(
                  onTap: () {
                    videoCall();
                  },
                  child: Text(
                    AppLocalizations.of(context)?.callBack ?? '',
                    style: AppTextStyles.regularW700(
                      context,
                      size: 14,
                      lineHeight: 19,
                      color: context.theme.colorPirimaryNoDarkLight,
                    ),
                  ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  videoCall() {
    // callType.value = true;
    primaryFocus?.unfocus();
    List<UserInfoBloc> listUser = _chatDetailBloc.listUserInfoBlocs.values
        .toList()
      ..removeWhere(
          (element) => element.userInfo.id == context.read<AuthRepo>().userId);
    IUserInfo? another = listUser.isNotEmpty
        ? listUser
            .singleWhere(
                (value) => value.userInfo.id != context.read<AuthRepo>().userId,
                orElse: () => listUser.first)
            .userInfo
        : context.read<AuthRepo>().userInfo;

    List<int> listId = _chatDetailBloc.listUserInfoBlocs.keys.toList()
      ..remove(context.read<AuthRepo>().userId);


    // ChatRepo().pushNotificationFirebase(
    //     receiveId: _chatDetailBloc.listUserInfoBlocs.keys.toList()
    //       ..remove(context.read<AuthRepo>().userId),
    //     convId: widget.messageModel.conversationId,
    //     conversationName: listUser.first.userInfo.name,
    //     message: 'Cuộc gọi video',
    //     data:
    //     '''{"idRoom":"${AuthRepo().userId}","idCaller":"${AuthRepo().userId}",
    //     "avatarAnother":"${AuthRepo().userInfo?.avatar}",
    //     "startTime":"${DateTime.now().add(Duration(seconds: 1)).toIso8601String()}"}''');
    AppRouterHelper.toCallScreen(
        idRoom: context.read<AuthRepo>().userId.toString(),
        idCaller: context.read<AuthRepo>().userId.toString(),
        idCallee: listId[0].toString(),
        avatarAnother: another?.avatar,
        idConversation: widget.messageModel.conversationId.toString(),
        checkCallee: false,
        nameAnother: another?.name ?? '',
        checkCall: true);

    // SpUtil.putString('id_room', context.read<AuthRepo>().userId.toString());
  }
}




// class VideoCallDisplay extends StatelessWidget {
//   const VideoCallDisplay({
//     Key? key,
//     required this.messageModel,
//   }) : super(key: key);
//   final SocketSentMessageModel messageModel;
//
//   @override
//   Widget build(BuildContext context) {
//     var isSentByCurrentUser = messageModel.senderId == context.userInfo().id;
//     var messageType = messageModel.type!;
//     return SizedBox(
//       width: 180,
//       child: Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         color: AppColors.grayE6E9FD,
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             children: [
//               Text(
//                 messageModel.type!.displayMessageType(
//                   null,
//                   isSentByCurrentUser: isSentByCurrentUser,
//                 ),
//                 style: AppTextStyles.regularW700(
//                   context,
//                   size: 14,
//                   lineHeight: 19,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   SvgPicture.asset(
//                     messageType.videoCallDisplayMessageIconAssetPath(
//                       isSendByCurrentUser: isSentByCurrentUser,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   if (messageType == MessageType.rejectVideoCall)
//                     Text(
//                       isSentByCurrentUser
//                           ? 'Bạn đã từ chối'
//                           : 'Người nhận từ chối',
//                       style: AppTextStyles.regularW400(
//                         context,
//                         size: 14,
//                         lineHeight: 16,
//                         color: AppColors.doveGray,
//                       ),
//                     ),
//                 ],
//               ),
//               // const SizedBox(height: 12),
//               Divider(
//                 color: AppColors.greyCC,
//                 thickness: 1,
//                 height: 24,
//               ),
//               InkWell(
//                 onTap: () {
//                   videoCall();
//                 },
//                 child: Text(
//                   'GỌI LẠI',
//                   style: AppTextStyles.regularW700(
//                     context,
//                     size: 14,
//                     lineHeight: 19,
//                     color: context.theme.primaryColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//   videoCall() {
//     callType.value = true;
//     primaryFocus?.unfocus();
//     List<UserInfoBloc> listUser = _chatDetailBloc.listUserInfoBlocs.values
//         .toList()
//       ..removeWhere(
//               (element) => element.userInfo.id == context.read<AuthRepo>().userId);
//     IUserInfo? another = listUser.isNotEmpty
//         ? listUser
//         .singleWhere(
//             (value) => value.userInfo.id != context.read<AuthRepo>().userId,
//         orElse: () => listUser.first)
//         .userInfo
//         : context.read<AuthRepo>().userInfo;
//     ChatRepo().pushNotificationFirebase(
//         receiveId: _chatDetailBloc.listUserInfoBlocs.keys.toList()
//           ..remove(context.read<AuthRepo>().userId),
//         convId: _conversationId,
//         conversationName: listUser.first.userInfo.name,
//         message: 'Cuộc gọi video',
//         data:
//         '''{"idRoom":"chat_${AuthRepo().userId}timviec365PS","idCaller":"chat_${AuthRepo().userId}",
//         "avatarAnother":"${AuthRepo().userInfo?.avatar}",
//         "startTime":"${DateTime.now().add(Duration(seconds: 1)).toIso8601String()}"}''');
//     AppRouterHelper.toCallScreen(context,
//         idRoom: context.read<AuthRepo>().userId.toString(),
//         idCaller: context.read<AuthRepo>().userId.toString(),
//         idCallee: _chatDetailBloc.listUserInfoBlocs.keys.toList()
//           ..remove(context.read<AuthRepo>().userId),
//         avatarAnother: another?.avatar,
//         idConversation: _conversationId.toString(),
//         checkCallee: false,
//         nameAnother: another?.name ?? '',
//         checkCall: true);
//     SpUtil.putString('id_room', context.read<AuthRepo>().userId.toString());
//   }
// }
