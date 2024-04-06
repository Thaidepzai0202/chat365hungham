import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_state.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/user_request_bloc/user_request_bloc.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/permission_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class DisplayContact extends StatefulWidget {
  const DisplayContact({
    Key? key,
    this.contact,
    this.isSendByCurrentUser = true,
    this.message,
  }) : super(key: key);

  final IUserInfo? contact;
  final bool isSendByCurrentUser;
  final String? message;

  @override
  State<DisplayContact> createState() => _DisplayContactState();
}

class _DisplayContactState extends State<DisplayContact> {
  WidgetsToImageController _widgetImageController = WidgetsToImageController();
  GlobalKey<State> _repaintKey = GlobalKey();

  late TypingDetectorBloc _typingDetectorBloc;
  late final ChatConversationBloc _chatConversationBloc;
  late UserRequestBloc userRequestBloc;
  late AppLayoutCubit _appLayoutCubit;
  late ChatDetailBloc _chatDetailBloc;

  @override
  void initState() {
    userRequestBloc = context.read<UserRequestBloc>();
    _appLayoutCubit = context.read<AppLayoutCubit>();
    _chatConversationBloc = context.read<ChatConversationBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RegExp phoneNumberRegex = RegExp(
        r'^(0|\+84|84)(\s|\.|-)?((3[2-9])|(5[689])|(7[06-9])|(8[1-689])|(9[0-46-9]))(\d)(\s|\.|-)?(\d{3})(\s|\.|-)?(\d{3})$');
    bool isPhoneNumber = widget.contact?.email != null &&
        phoneNumberRegex.hasMatch(widget.contact!.email!);
    // ContactListCubit _contactListCubit = ContactListCubit(
    //   ContactListRepo(
    //     userInfo!.id,
    //     companyId: userInfo?.companyId ?? userInfo!.id,
    //   ),
    //   initFilter: null,
    // );
    // List<ApiContact> info = [];
    // _getinfo() async {
    //   info = await _contactListCubit.searchPhoneNumber(message ?? '');
    // }

    // ByteData byteData;
    // getImage(String userInfo) async {
    //   QrImage(
    //     backgroundColor: Colors.white,
    //     data:
    //         '{"QRType":"QRChat11","conversationName":"","conversationAvatar":"","admin":"","data":"","user_id": $userInfo}',
    //     version: QrVersions.auto,
    //     padding: EdgeInsets.all(5),
    //     size: 80,
    //     gapless: false,
    //     errorStateBuilder: (cxt, err) {
    //       return Container(
    //         child: Center(
    //           child: Text(
    //             "Đã có lỗi xảy ra...",
    //             textAlign: TextAlign.center,
    //           ),
    //         ),
    //       );
    //     },
    //   );
    //   ;
    // }

    // if (message != null) {
    //   _getinfo();
    // }
    // ;
    return BlocProvider<UserInfoBloc>(
      create: (context) => UserInfoBloc(
        UserInfo(
          id: widget.contact?.id ?? 0,
          userName: widget.contact?.name ?? '',
          avatarUser: widget.contact?.avatar ?? '',
          active: widget.contact?.userStatus ?? UserStatus.none,
          email: widget.contact?.email ?? '@',
        ),
      ),
      child: InkWell(
        onTap: () async {
          var contactCard;
          try {
            RenderRepaintBoundary? boundary = _repaintKey.currentContext
                ?.findRenderObject() as RenderRepaintBoundary?;
            ui.Image? image = await boundary?.toImage(pixelRatio: 3.0);
            ByteData? byteData =
                await image?.toByteData(format: ui.ImageByteFormat.png);
            var pngBytes = byteData?.buffer.asUint8List();
            var bs64 = base64Encode(pngBytes!);
            debugPrint(bs64.length.toString());
            // final status = await PermissionExt.downloadPermission.request();
            // if (status.isGranted) {
            //   final tempDir = await getTemporaryDirectory();
            //   contactCard =
            //   await File('${tempDir.absolute.path}/qrImage.png').create();
            //   contactCard!.writeAsBytesSync(pngBytes);
            //   logger.log('image: ${contactCard!.absolute.path}');
            //   // setState(() {});
            // } else {
            //   logger.log('access denied');
            // }
          } catch (exception) {
            logger.logError(exception.toString());
          }
          // showDialog(
          //     context: context,
          //     builder: (_) => AlertDialog(
          //           content: contactCard != null
          //               ? Image.file(contactCard)
          //               : const Text('null'),
          //         ));
        },
        child: RepaintBoundary(
          key: _repaintKey,
          child: Container(
            width: double.infinity.clamp(0, 250).toDouble(),
            //height: double.infinity.clamp(0, 198).toDouble(),
            decoration: BoxDecoration(
              color: widget.isSendByCurrentUser
                  ? null
                  : context.theme.messageBoxColor,
              gradient:
                  widget.isSendByCurrentUser ? context.theme.gradient : null,
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              image: const DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    BlocBuilder<UserInfoBloc, UserInfoState>(
                      builder: (context, state) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: CachedNetworkImageProvider(
                              state.userInfo.avatar ??
                                  'https://i.imgur.com/jbH2748.png',
                            ),
                            radius: 30,
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlocBuilder<UserInfoBloc, UserInfoState>(
                            builder: (context, state) {
                              return Text(
                                state.userInfo.name,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 22 / 16,
                                    color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                          if (isPhoneNumber)
                            BlocBuilder<UserInfoBloc, UserInfoState>(
                              builder: (context, state) {
                                return Text(
                                  (widget.contact?.email ?? '@').contains('@')
                                      ? ''
                                      : widget.contact?.email ?? '',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 22 / 16,
                                      color: Colors.white),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                //const SizedBox(height: 30),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     BlocBuilder<UserInfoBloc, UserInfoState>(
                //       builder: (context, state) {
                //         double size = 80;
                //         return InkWell(
                //             onTap: () async {
                //               Image image = await qrToImage("1");
                //               if (state.userInfo.avatar != null) {
                //                 AppRouter.toPage(
                //                   context,
                //                   AppPages.showQr,
                //                   arguments: {
                //                     'userInfo': state.userInfo,
                //                   },
                //                 );
                //               }
                //               // ShowAvatarScreen;
                //             },
                //             child: WidgetsToImage(
                //               controller: _widgetImageController,
                //               child: QrImageView(
                //                 backgroundColor: Colors.white,
                //                 data:
                //                 '{"QRType":"QRChat11","conversationName":"","conversationAvatar":"","admin":"","data":"","user_id":"${state.userInfo.id}"}',
                //                 version: QrVersions.auto,
                //                 padding: const EdgeInsets.all(5),
                //                 size: size,
                //                 // embeddedImage: AssetImage(Images.img_logo_chat365),
                //                 // embeddedImageStyle: QrEmbeddedImageStyle(
                //                 //   size: Size(80, 80),
                //                 // ),
                //                 gapless: false,
                //                 errorStateBuilder: (cxt, err) {
                //                   return Container(
                //                     child: const Center(
                //                       child: Text(
                //                         "Đã có lỗi xảy ra...",
                //                         textAlign: TextAlign.center,
                //                       ),
                //                     ),
                //                   );
                //                 },
                //               ),
                //             ));
                //         //convert QrImage to Image
                //       },
                //     ),
                //     const SizedBox(
                //       width: 5,
                //     ),
                //   ],
                // ),
                const SizedBox(height: 8),
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      // borderRadius: BorderRadius.vertical(bottom: Radius.circular(10,)),
                      border: Border.all(color: AppColors.blueGradients1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () async {
                          var conversationId = await context
                              .read<ChatBloc>()
                              .getConversationId(
                                  AuthRepo().userInfo!.id, widget.contact!.id);
                          var chatItemModel =
                              await ChatRepo().getChatItemModel(conversationId);
                          var userInfoBloc = UserInfoBloc.fromConversation(
                            chatItemModel!.conversationBasicInfo,
                            status: chatItemModel.status,
                          );
                          _typingDetectorBloc = _chatConversationBloc
                                  .typingBlocs[conversationId] ??
                              TypingDetectorBloc(conversationId);
                          _chatDetailBloc = ChatDetailBloc(
                              conversationId: conversationId,
                              senderId: context.userInfo().id,
                              isGroup: false,
                              initMemberHasNickname: [userInfoBloc.userInfo],
                              messageDisplay: -1,
                              chatItemModel: chatItemModel,
                              unreadMessageCounterCubit:
                                  UnreadMessageCounterCubit(
                                conversationId: conversationId,
                                countUnreadMessage: 0,
                              ),
                              // _unreadMessageCounterCubit,
                              deleteTime: -1,
                              otherDeleteTime: chatItemModel
                                      .firstOtherMember(context.userInfo().id)
                                      .deleteTime ??
                                  -1,
                              myDeleteTime: -1,
                              messageId: '',
                              typeGroup: chatItemModel.typeGroup)
                            ..add(const ChatDetailEventLoadConversationDetail())
                            ..getDetailInfo(uInfo: userInfoBloc.userInfo)
                            ..conversationName.value =
                                chatItemModel.conversationBasicInfo.name;
                          _appLayoutCubit.toMainLayout(AppMainPages.chatScreen,
                              providers: [
                                BlocProvider<UserInfoBloc>(
                                    create: (context) => userInfoBloc),
                                BlocProvider<TypingDetectorBloc>.value(
                                    value: _typingDetectorBloc),
                                BlocProvider<UnreadMessageCounterCubit>(
                                    create: (context) =>
                                        UnreadMessageCounterCubit(
                                            conversationId: conversationId,
                                            countUnreadMessage: 0)),
                              ],
                              agruments: {
                                'chatType': ChatType.SOLO,
                                'conversationId': conversationId,
                                'senderId': context.userInfo().id,
                                'chatItemModel': chatItemModel,
                                'name':
                                    chatItemModel.conversationBasicInfo.name,
                                'chatDetailBloc': _chatDetailBloc,
                                'messageDisplay': -1,
                              });
                        },
                        child: Text(
                          'Nhắn tin',
                          style: AppTextStyles.contactGroupName(context)
                              .copyWith(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (isPhoneNumber) ...[
                        const VerticalDivider(
                          width: 20,
                          thickness: 2,
                          indent: 5,
                          endIndent: 5,
                          color: AppColors.greyCC,
                        ),
                        InkWell(
                          onTap: () => SystemUtils.openUrlInBrowser(
                              'tel://${widget.contact?.email}'),
                          child: Text(
                            'Gọi điện',
                            style: AppTextStyles.contactGroupName(context)
                                .copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Image> qrToImage(String uid) async {
    Uint8List? byteData = await _widgetImageController.capture();
    final Image image = Image.memory(byteData!);

    return image;
  }
}
