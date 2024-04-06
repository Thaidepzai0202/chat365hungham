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
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/user_search/model/group_model.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ListGroup extends StatelessWidget {
  ListGroup({Key? key, required this.listGroup, required this.check})
      : super(key: key);
  final List<GroupModel> listGroup;
  final bool check;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: check == false
                ? (listGroup.length <= 5 ? listGroup.length : 5)
                : listGroup.length,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () async {
                    var conversationId = listGroup[index].conversationId;

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
                        senderId: context.userInfo().id,
                        isGroup: true,
                        initMemberHasNickname: [],
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
                        typeGroup: '')
                      ..add(const ChatDetailEventLoadConversationDetail())
                      ..getDetailInfo(uInfo: userInfoBloc.userInfo)
                      ..conversationName.value =
                          chatItemModel.conversationBasicInfo.name;

                    context
                        .read<AppLayoutCubit>()
                        .toMainLayout(AppMainPages.chatScreen, providers: [
                      BlocProvider<UserInfoBloc>(
                          create: (context) => userInfoBloc),
                      BlocProvider<TypingDetectorBloc>.value(
                          value: _typingDetectorBloc),
                      BlocProvider<UnreadMessageCounterCubit>.value(
                        value: UnreadMessageCounterCubit(
                          conversationId: conversationId,
                          countUnreadMessage: 0,
                        ),
                      ),
                    ], agruments: {
                      'chatType': ChatType.GROUP,
                      'conversationId': conversationId,
                      'senderId': context.userInfo().id,
                      'chatItemModel': chatItemModel,
                      'name': chatItemModel.conversationBasicInfo.name,
                      'chatDetailBloc': _chatDetailBloc,
                      'messageDisplay': -1,
                    });
                  },
                  child: itemGroup(listGroup[index]));
            }));
  }

  Widget itemGroup(GroupModel group) {
    return ValueListenableBuilder(valueListenable: changeTheme, builder:(context, value, child) {
      return Container(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Row(
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
                  imageUrl: group.linkAvatar,
                  errorWidget: (_, __, ___) {
                    return Image.asset(Images.img_non_avatar);
                  },
                )),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 200,
                  child: Text(group.conversationName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16,color: context.theme.textColor))),
              Text(check == false
                  ? '${group.totalGroupMemebers} ${AppLocalizations.of(context)?.members ?? ''}'
                  : "${group.listMember.length} ${AppLocalizations.of(context)?.members ?? ''}",style: TextStyle(color: context.theme.text2Color),),
            ],
          )
        ],
      ),
    );
  
    },);
    }
}



