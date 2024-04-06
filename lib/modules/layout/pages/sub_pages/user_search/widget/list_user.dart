import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/user_request_bloc/user_request_bloc.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/widget_custom/form_user.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/user_search/model/user_model.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ListUser extends StatelessWidget {
  ListUser(
      {Key? key,
      required this.listUser,
      required this.check,
      required this.userRequestBloc})
      : super(key: key);
  final List<UserModel> listUser;
  final bool check;
  final UserRequestBloc userRequestBloc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) {
        return Container(
          child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: check == false
                  ? (listUser.length <= 5 ? listUser.length : 5)
                  : listUser.length,
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () async {
                      var conversationId = await context
                          .read<ChatBloc>()
                          .getConversationId(
                              AuthRepo().userInfo!.id, listUser[index].id);

                      var chatItemModel =
                          await ChatRepo().getChatItemModel(conversationId);

                      var userInfoBloc = UserInfoBloc.fromConversation(
                        chatItemModel!.conversationBasicInfo,
                        status: chatItemModel.status,
                      );

                      TypingDetectorBloc _typingDetectorBloc = context
                              .read<ChatConversationBloc>()
                              .typingBlocs[conversationId] ??
                          TypingDetectorBloc(conversationId);

                      ChatDetailBloc _chatDetailBloc = ChatDetailBloc(
                          conversationId: conversationId,
                          senderId: AuthRepo().userId!,
                          isGroup: false,
                          initMemberHasNickname: [userInfoBloc.userInfo],
                          messageDisplay: -1,
                          chatItemModel: chatItemModel,
                          unreadMessageCounterCubit: UnreadMessageCounterCubit(
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
                          typeGroup: chatItemModel!.typeGroup)
                        ..add(const ChatDetailEventLoadConversationDetail())
                        ..getDetailInfo(uInfo: userInfoBloc.userInfo)
                        ..conversationName.value =
                            chatItemModel.conversationBasicInfo.name;

                      context
                          .read<AppLayoutCubit>()
                          .toMainLayout(AppMainPages.chatScreen, providers: [
                        BlocProvider<UserInfoBloc>.value(value: userInfoBloc),
                        BlocProvider<TypingDetectorBloc>.value(
                            value: _typingDetectorBloc),
                        BlocProvider<UnreadMessageCounterCubit>.value(
                          value: UnreadMessageCounterCubit(
                            conversationId: conversationId,
                            countUnreadMessage: 0,
                          ),
                        ),
                      ], agruments: {
                        'chatType': ChatType.SOLO,
                        'conversationId': conversationId,
                        'senderId': AuthRepo().userId!,
                        'chatItemModel': chatItemModel,
                        'name': chatItemModel.conversationBasicInfo.name,
                        'chatDetailBloc': _chatDetailBloc,
                        'messageDisplay': -1,
                      });
                    },
                    child: itemUser(listUser[index], context));
              }),
        );
      },
    );
  }

  Widget itemUser(UserModel user, BuildContext context) {
    // String friendStatus = user.friendStatus;
    ValueNotifier<String> friendStatus = ValueNotifier(user.friendStatus);
    return Container(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: user.avatarUser,
                      errorWidget: (_, __, ___) {
                        return Image.asset(Images.img_non_avatar);
                      },
                    )),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                    alignment: Alignment.bottomRight,
                    child: user.active == 1
                        ? iconStatus(
                            AppColors.online,
                          )
                        : user.active == 2
                            ? iconStatus(
                                AppColors.offline,
                              )
                            : user.active == 3
                                ? iconStatus(
                                    AppColors.red,
                                  )
                                : iconStatus(
                                    AppColors.grey666,
                                  )),
              )
            ],
          ),
          SizedBox(
            width: 10,
          ),
          Container(
              width: 150,
              child: Text(
                user.userName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, color: context.theme.textColor),
              )),
          Spacer(),
          ValueListenableBuilder(
              valueListenable: friendStatus,
              builder: (context, value, _) {
                return friendStatus.value == 'friend'
                    ? SizedBox()
                    : friendStatus.value == 'none'
                        ? InkWell(
                            onTap: () async {
                              friendStatus.value = 'send';
                              await userRequestBloc.sendRequestAddFriend(
                                  AuthRepo().userInfo!.id,
                                  user.id,
                                  user.type365);
                            },
                            child: Container(
                              padding: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: context.theme.gradient,
                              ),
                              child: Text(
                                AppLocalizations.of(context)?.addFriend ??'',
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        : friendStatus.value == 'request'
                            ? InkWell(
                                onTap: () async {
                                  friendStatus.value = 'friend';
                                  await userRequestBloc.requestAddFriend(
                                      AuthRepo().userInfo!.id, user.id, 1);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: context.theme.gradient,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)?.accept ??'',
                                    style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )
                            : friendStatus.value == 'send'
                                ? InkWell(
                                    onTap: () async {
                                      friendStatus.value = 'none';
                                      await userRequestBloc
                                          .deleteRequestAddFriend(
                                              AuthRepo().userInfo!.id, user.id);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: context.theme.gradient,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)?.unsendRequest ??'',
                                        style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  )
                                : SizedBox();
              }),
        ],
      ),
    );
  }
}
