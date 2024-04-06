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
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_cubit.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_model.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_unread.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_cubit.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../layout/pages/sub_pages/phone_book/widget_custom/form_user.dart';

class UnreadConversationItem extends StatefulWidget {
  const UnreadConversationItem({super.key, required this.conversationUnRead});

  final ConversationModel conversationUnRead;

  @override
  State<UnreadConversationItem> createState() => _UnreadConversationItemState();
}

class _UnreadConversationItemState extends State<UnreadConversationItem> {
  late ChatConversationCubit chatConversationCubit;
  late AppLayoutCubit _appLayoutCubit;
  late ChatDetailBloc _chatDetailBloc;
  late TypingDetectorBloc _typingDetectorBloc;
  late ChatConversationBloc _chatConversationBloc;
  late UserInfoRepo userInfoRepo;
  late ChatRepo chatRepo;
  ValueNotifier<bool> isRead = ValueNotifier(false);
  late final ProfileCubit _profileCubit;

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
    String getDayOfWeek(int day) {
      switch (day) {
        case 1:
          return 'T2';
        case 2:
          return 'T3';
        case 3:
          return 'T4';
        case 4:
          return 'T5';
        case 5:
          return 'T6';
        case 6:
          return 'T7';
        case 7:
          return 'CN';
        default:
          return '';
      }
    }

    // check 2 ngày có cùng tuần không
    int getWeekNumber(DateTime date) {
      DateTime jan1 = DateTime(date.year, 1, 1);
      int days = date.difference(jan1).inDays;
      return ((days + jan1.weekday - 1) / 7).floor() + 1;
    }

    DateTime now = DateTime.now();
    final ThemeData theme = Theme.of(context);
    int dayOfWeek = widget.conversationUnRead.createAt.weekday;
    return ValueListenableBuilder(
      valueListenable: isRead,
      builder: (context, value, child) => InkWell(
          onTap: () async {
            isRead.value = true;
            ChatRepo().markReadMessage(
                conversationId: widget.conversationUnRead.conversationId);
            ConversationModel? model = ChatRepo().getConversationModelSync(widget.conversationUnRead.conversationId);
            if (model != null) {
              model.unReader = 0;
              ChatRepo().setConversationModel(model);
            }
            var chatItemModel = await ChatRepo()
                .getChatItemModel(widget.conversationUnRead.conversationId);
            // _profileCubit = ProfileCubit(
            //   widget.conversationUnRead.conversationId,
            //   isGroup: ChatType.GROUP : ChatType.SOLO,
            // );
            var userInfoBloc = UserInfoBloc.fromConversation(
              chatItemModel!.conversationBasicInfo,
              status: chatItemModel.status,
            );
            _typingDetectorBloc = _chatConversationBloc
                    .typingBlocs[widget.conversationUnRead.conversationId] ??
                TypingDetectorBloc(widget.conversationUnRead.conversationId);
            _chatDetailBloc = ChatDetailBloc(
                conversationId: widget.conversationUnRead.conversationId,
                senderId: AuthRepo().userInfo!.id,
                isGroup: false,
                initMemberHasNickname: [userInfoBloc.userInfo],
                messageDisplay: -1,
                chatItemModel: chatItemModel,
                unreadMessageCounterCubit: UnreadMessageCounterCubit(
                  conversationId: widget.conversationUnRead.conversationId,
                  countUnreadMessage: 0,
                ),
                deleteTime: -1,
                otherDeleteTime: chatItemModel
                        .firstOtherMember(AuthRepo().userInfo!.id)
                        .deleteTime ??
                    -1,
                myDeleteTime: -1,
                messageId: '',
                typeGroup: chatItemModel.typeGroup)
              ..add(const ChatDetailEventLoadConversationDetail())
              //..getDetailInfo(uInfo: userInfoBloc.userInfo)
              ..conversationName.value =
                  chatItemModel.conversationBasicInfo.name;

            _appLayoutCubit.toMainLayout(
              AppMainPages.chatScreen,
              providers: [
                BlocProvider<UserInfoBloc>(create: (context) => userInfoBloc),
                BlocProvider<TypingDetectorBloc>.value(
                    value: _typingDetectorBloc),
                BlocProvider<UnreadMessageCounterCubit>.value(
                    value: _chatConversationBloc.unreadMessageCounterCubits[
                        widget.conversationUnRead.conversationId]!),
              ],
              agruments: {
                'chatType': chatItemModel.isGroup == true
                    ? ChatType.GROUP
                    : ChatType.SOLO,
                'conversationId': widget.conversationUnRead.conversationId,
                'senderId': AuthRepo().userInfo!.id,
                'chatItemModel': chatItemModel,
                'name': chatItemModel.conversationBasicInfo.name,
                'chatDetailBloc': _chatDetailBloc,
                'messageDisplay': -1,
              },
            );
          },
          child: ValueListenableBuilder(
              valueListenable: changeTheme,
              builder: (context, value, child) => Padding(
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
                                  image: NetworkImage(widget
                                      .conversationUnRead.avatarConversation),
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
                                  widget.conversationUnRead.conversationName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: context.theme.textColor,
                                    fontWeight:
                                        widget.conversationUnRead.unReader ==
                                                    1 &&
                                                isRead.value == false
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  widget.conversationUnRead.message,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: context.theme.textColor,
                                    fontWeight:
                                        widget.conversationUnRead.unReader ==
                                                    1 &&
                                                isRead.value == false
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Text(
                            DateTime(now.year, now.month, now.day) ==
                                    DateTime(
                                        widget.conversationUnRead.createAt.year,
                                        widget
                                            .conversationUnRead.createAt.month,
                                        widget.conversationUnRead.createAt.day)
                                ? widget.conversationUnRead.createAt.hour > 12
                                    ? '${widget.conversationUnRead.createAt.hour - 12}:${widget.conversationUnRead.createAt.minute} PM'
                                    : '${widget.conversationUnRead.createAt.hour}:${widget.conversationUnRead.createAt.minute} AM'
                                : getWeekNumber(now) ==
                                        getWeekNumber(
                                            widget.conversationUnRead.createAt)
                                    ? getDayOfWeek(dayOfWeek)
                                    : DateFormat('dd/MM/yyyy').format(
                                        widget.conversationUnRead.createAt),
                            style: AppTextStyles.text(context).copyWith(
                              fontSize: 13,
                              fontWeight:
                                  widget.conversationUnRead.unReader == 1 &&
                                          isRead.value == false
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                            )),
                      ],
                    ),
                  ))),
    );
  }
}
