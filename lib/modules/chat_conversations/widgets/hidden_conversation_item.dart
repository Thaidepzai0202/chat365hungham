import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_cubit.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_hidden.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/pin_code_pages.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/widget_custom/form_user.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HiddenConversationItem extends StatefulWidget {
  const HiddenConversationItem({
    super.key,
    required this.conversation,
  });

  final ConversationHidden conversation;

  // final int isFavourite;

  @override
  State<HiddenConversationItem> createState() => _HiddenConversationItemState();
}

class _HiddenConversationItemState extends State<HiddenConversationItem> {
  late ChatConversationCubit chatConversationCubit;
  late AppLayoutCubit _appLayoutCubit;
  late ChatDetailBloc _chatDetailBloc;
  late TypingDetectorBloc _typingDetectorBloc;
  late ChatConversationBloc _chatConversationBloc;
  late UserInfoRepo userInfoRepo;
  late ChatRepo chatRepo;
  // ham show menu khi an chuot phai
  void _showPopupMenu(BuildContext context, Offset position) {
    showMenu(
        context: context,
        shadowColor: context.theme.text2Color,
        color: context.theme.backgroundColor,
        position: RelativeRect.fromLTRB(
            position.dx, position.dy, position.dx + 1, position.dy + 1),
        items: [
          PopupMenuItem(
            height: 32,
            child: Text(
              'Hiện cuộc trò chuyện',
              style: TextStyle(color: context.theme.text2Color, fontSize: 14),
            ),
            onTap: () async {
              await chatConversationCubit.takePINcode();
              // ignore: use_build_context_synchronously
              showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      backgroundColor: context.theme.backgroundColor,
                        child: BlocListener(
                      bloc: chatConversationCubit,
                      listener: (context, state) {
                        if (state is SuccessHiddenState) {
                          AppRouter.back(context);
                        }
                      },
                      child: Container(
                        height: 220,
                        width: 380,
                        decoration: BoxDecoration(
                            color: context.theme.backgroundColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  gradient: context.theme.gradient,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15))),
                              height: 45,
                              width: 380,
                              child: const Text(
                                'Nhập mã PIN để ẩn cuộc trò chuyện',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.white),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            PinCodePages(
                              validator: (v) {
                                if (v!.length < 6) {
                                  return "Mã pin không đúng";
                                } else if (v != chatConversationCubit.pinCode) {
                                  return "Mã pin không đúng, vui lòng kiểm tra lại!";
                                } else {
                                  return null;
                                }
                              },
                              onComplete: (v) {
                                if (v == chatConversationCubit.pinCode) {
                                  chatConversationCubit.hiddenConversation(
                                      conversationId:
                                          widget.conversation.conversationId,
                                      isHidden: 0);
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Nếu quên mã pin, bạn phải ',
                                  style: TextStyle(
                                      color: context.theme.text2Color),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Text(
                                    'Cài đặt lại mã',
                                    style: TextStyle(
                                        color: context
                                            .theme.colorPirimaryNoDarkLight,
                                        decoration: TextDecoration.underline),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ));
                  });
            },
          ),
        ]);
  }

  @override
  void initState() {
    chatConversationCubit = context.read<ChatConversationCubit>();
    _appLayoutCubit = context.read<AppLayoutCubit>();
    _chatConversationBloc = context.read<ChatConversationBloc>();
    userInfoRepo = context.read<UserInfoRepo>();
    chatRepo = context.read<ChatRepo>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dateTimeCreateAt = DateFormat("yyyy-MM-dd hh:mm:ss")
        .parse(widget.conversation.createAt.toString());
    var time = Text(
      dateTimeCreateAt.diffWith(
        showSpecialTime: true,
        showYesterdayImediately: true,
      ),
      style: AppTextStyles.text(context).copyWith(
        fontSize: 13,
        color: context.theme.text2Color,
        fontWeight: FontWeight.w400
      ),
    );

    return InkWell(
      onTap: () async {
        await chatConversationCubit.takePINcode();
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                backgroundColor: context.theme.backgroundColor,
                  child: BlocListener(
                bloc: chatConversationCubit,
                listener: (context, state) {
                  if (state is SuccessHiddenState) {
                    AppRouter.back(context);
                  }
                },
                child: Container(
                  height: 220,
                  width: 380,
                  decoration: BoxDecoration(
                      color: context.theme.backgroundColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            gradient: context.theme.gradient,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15))),
                        height: 45,
                        width: 380,
                        child: const Text(
                          'Nhập mã PIN để ẩn cuộc trò chuyện',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      PinCodePages(
                        validator: (v) {
                          if (v!.length < 6) {
                            return "Mã pin không đúng";
                          } else if (v != chatConversationCubit.pinCode) {
                            return "Mã pin không đúng, vui lòng kiểm tra lại!";
                          } else {
                            return null;
                          }
                        },
                        onComplete: (v) async {
                          if (v == chatConversationCubit.pinCode) {
                            AppRouter.back(context);
                            var chatItemModel = await ChatRepo()
                                .getChatItemModel(
                                    widget.conversation.conversationId);
                            var userInfoBloc = UserInfoBloc.fromConversation(
                              chatItemModel!.conversationBasicInfo,
                              status: chatItemModel.status,
                            );
                            _typingDetectorBloc =
                                _chatConversationBloc.typingBlocs[
                                        widget.conversation.conversationId] ??
                                    TypingDetectorBloc(
                                        widget.conversation.conversationId);
                            _chatDetailBloc = ChatDetailBloc(
                                conversationId:
                                    widget.conversation.conversationId,
                                senderId: AuthRepo().userInfo!.id,
                                isGroup: false,
                                initMemberHasNickname: [userInfoBloc.userInfo],
                                messageDisplay: -1,
                                chatItemModel: chatItemModel,
                                unreadMessageCounterCubit:
                                    UnreadMessageCounterCubit(
                                  conversationId:
                                      widget.conversation.conversationId,
                                  countUnreadMessage: 0,
                                ),
                                // _unreadMessageCounterCubit,
                                deleteTime: -1,
                                otherDeleteTime: chatItemModel
                                        .firstOtherMember(
                                            AuthRepo().userInfo!.id)
                                        .deleteTime ??
                                    -1,
                                myDeleteTime: -1,
                                messageId: '',
                                typeGroup: chatItemModel.typeGroup)
                              ..add(
                                  const ChatDetailEventLoadConversationDetail())
                              ..getDetailInfo(uInfo: userInfoBloc.userInfo)
                              ..conversationName.value =
                                  chatItemModel.conversationBasicInfo.name;

                            _appLayoutCubit.toMainLayout(
                                AppMainPages.chatScreen,
                                providers: [
                                  BlocProvider<UserInfoBloc>(
                                      create: (context) => userInfoBloc),
                                  BlocProvider<TypingDetectorBloc>.value(
                                      value: _typingDetectorBloc),
                                ],
                                agruments: {
                                  'chatType': chatItemModel.isGroup == true
                                      ? ChatType.GROUP
                                      : ChatType.SOLO,
                                  'conversationId':
                                      widget.conversation.conversationId,
                                  'senderId': AuthRepo().userInfo!.id,
                                  'chatItemModel': chatItemModel,
                                  'name':
                                      chatItemModel.conversationBasicInfo.name,
                                  'chatDetailBloc': _chatDetailBloc,
                                  'messageDisplay': -1,
                                });
                          }
                        },
                      ),
                      Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Nếu quên mã pin, bạn phải ',
                                  style: TextStyle(
                                      color: context.theme.text2Color),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Text(
                                    'Cài đặt lại mã',
                                    style: TextStyle(
                                        color: context
                                            .theme.colorPirimaryNoDarkLight,
                                        decoration: TextDecoration.underline),
                                  ),
                                )
                              ],
                            )

                    ],
                  ),
                ),
              ));
            });
      },
      onSecondaryTapUp: (TapUpDetails details) {
        // Gọi hàm hiển thị menu tại vị trí được nhấn
        _showPopupMenu(context, details.globalPosition);
      },
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  image: DecorationImage(
                      image:
                          NetworkImage(widget.conversation.avatarConversation),
                      fit: BoxFit.cover)),
              child: Container(
                  alignment: Alignment.bottomRight,
                  child: iconStatus(
                    AppColors.grey666,
                  )),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.conversation.conversationName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 16,
                          color: context.theme.text2Color,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            time,
          ],
        ),
      ),
    );
  }
}
