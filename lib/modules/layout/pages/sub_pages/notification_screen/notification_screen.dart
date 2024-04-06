import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/constants/list_data.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/notification_screen/bloc/notification_bloc.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/notification_screen/bloc/notification_state.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/notification_screen/models/notification_model.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late NotificationBloc notificationBloc;
  late AppLayoutCubit _appLayoutCubit;
  late ChatDetailBloc _chatDetailBloc;
  late TypingDetectorBloc _typingDetectorBloc;
  late ChatConversationBloc _chatConversationBloc;
  ValueNotifier<String> get typeNoti => ValueNotifier(AppLocalizations.of(context)?.all??'');
  late UserInfoRepo userInfoRepo;
  late ChatRepo chatRepo;

  List<String> get listTypeNotification => <String>[
   AppLocalizations.of(context)?.all ?? '',
   AppLocalizations.of(context)?.unread ?? '',
   AppLocalizations.of(context)?.seenAll ?? '',
   AppLocalizations.of(context)?.delateAll ?? ''
];

  @override
  void initState() {
    notificationBloc = context.read<NotificationBloc>();
    notificationBloc.getListNotification();
    chatClient.on('AddFriend', (data) {
      notificationBloc.getListNotification();
    });
    chatClient.on('AcceptRequestAddFriend', (data) {
      notificationBloc.getListNotification();
    });
    _appLayoutCubit = context.read<AppLayoutCubit>();
    _chatConversationBloc = context.read<ChatConversationBloc>();
    userInfoRepo = context.read<UserInfoRepo>();
    chatRepo = context.read<ChatRepo>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) {
        return Container(
          width: 326,
          height: AppDimens.height - 170,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ValueListenableBuilder(
            valueListenable: typeNoti,
            builder: (_, __, ___) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocListener(
                  bloc: notificationBloc,
                  listener: (context, state) async {
    
    
    
                     if (state is ReadAllNotificationState) {
                      await notificationBloc.getListNotification();
                    }
                  },
                  child: PopupMenuButton(
                    color: context.theme.backgroundChatContent,
                      child: Row(
                        children: [
                          Text(
                            typeNoti.value,
                            style: AppTextStyles.text(context).copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.theme.textColor),
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            AssetPath.drop_button_down,
                            color: context.theme.text2Color,
                          )
                        ],
                      ),
                      itemBuilder: (BuildContext context) => [
                            PopupMenuItem( height:30,
                              child: Text(listTypeNotification[0],style: TextStyle(color: context.theme.text2Color),),
                              onTap: () async {
                                typeNoti.value = listTypeNotification[0];
                                await notificationBloc.getListNotification();
                              },
                            ),
                            PopupMenuItem( height:30,
                              child: Text(listTypeNotification[1],style: TextStyle(color: context.theme.text2Color),),
                              onTap: () {
                                typeNoti.value = listTypeNotification[1];
                              },
                            ),
                            PopupMenuItem( height:30,
                              child: Text(listTypeNotification[2],style: TextStyle(color: context.theme.text2Color),),
                              onTap: () async {
                                await notificationBloc.readAllNoti();
                                typeNoti.value = listTypeNotification[0];
                              },
                            ),
                            PopupMenuItem( height:30,
                              child: Text(listTypeNotification[3],style: TextStyle(color: context.theme.text2Color),),
                              onTap: () async {
                                typeNoti.value = listTypeNotification[0];
                                await notificationBloc.deleteAllNoti();
                              },
                            )
                          ]),
                ),
                const SizedBox(
                  height: 15,
                ),
                BlocBuilder(
                    bloc: notificationBloc,
                    builder: (context, state) {
                      if (state is LoadedNotificationState) {
                        List<NotificationModel> listNoti = [];
                        typeNoti.value == listTypeNotification[1]
                            ? listNoti = List.from(state.listNoti
                                .where((element) => element.isUndeader == 1))
                            : listNoti = state.listNoti;
                        return SizedBox(
                          width: 326,
                          height: AppDimens.height - 230,
                          child: listNoti.isNotEmpty
                              ? ListView.builder(
                                  itemCount: listNoti.length,
                                  itemBuilder: (context, index) {
                                    return notificationTile(
                                      context: context,
                                      notificationModel: listNoti[index],
                                      onTap: () async {
                                        await notificationBloc.readNoti(
                                            listNoti[index].idNotification);
                                        // notificationBloc.getListNotification();
                                        var chatItemModel = await ChatRepo()
                                            .getChatItemModel(
                                                listNoti[index].conversationId);
                                        print(
                                            "____________${chatItemModel!.conversationId}");
                                        var _userInfoBloc =
                                            UserInfoBloc.fromConversation(
                                          chatItemModel.conversationBasicInfo,
                                          status: chatItemModel.status,
                                        );
                                        _typingDetectorBloc =
                                            _chatConversationBloc.typingBlocs[
                                                    listNoti[index]
                                                        .conversationId] ??
                                                TypingDetectorBloc(
                                                    listNoti[index]
                                                        .conversationId);
                                        _chatDetailBloc = ChatDetailBloc(
                                            conversationId:
                                                listNoti[index].conversationId,
                                            senderId: AuthRepo().userInfo!.id,
                                            isGroup: false,
                                            initMemberHasNickname: [
                                              _userInfoBloc.userInfo
                                            ],
                                            messageDisplay: -1,
                                            chatItemModel: chatItemModel,
                                            unreadMessageCounterCubit:
                                                UnreadMessageCounterCubit(
                                              conversationId: listNoti[index]
                                                  .conversationId,
                                              countUnreadMessage: 0,
                                            ),
                                            // _unreadMessageCounterCubit,
                                            deleteTime: -1,
                                            otherDeleteTime: chatItemModel
                                                    ?.firstOtherMember(
                                                        AuthRepo().userInfo!.id)
                                                    .deleteTime ??
                                                -1,
                                            myDeleteTime: -1,
                                            messageId: '',
                                            typeGroup: chatItemModel.typeGroup)
                                          ..add(
                                              const ChatDetailEventLoadConversationDetail())
                                          ..getDetailInfo(
                                              uInfo: _userInfoBloc.userInfo)
                                          ..conversationName.value =
                                              chatItemModel
                                                  .conversationBasicInfo.name;

                                        _appLayoutCubit.toMainLayout(
                                            AppMainPages.chatScreen,
                                            providers: [
                                              BlocProvider<UserInfoBloc>(
                                                  create: (context) =>
                                                      _userInfoBloc),
                                              BlocProvider<
                                                      TypingDetectorBloc>.value(
                                                  value: _typingDetectorBloc),
                                            ],
                                            agruments: {
                                              'chatType':
                                                  chatItemModel.isGroup == true
                                                      ? ChatType.GROUP
                                                      : ChatType.SOLO,
                                              'conversationId': listNoti[index]
                                                  .conversationId,
                                              'senderId':
                                                  AuthRepo().userInfo!.id,
                                              'chatItemModel': chatItemModel,
                                              'name': chatItemModel
                                                  .conversationBasicInfo.name,
                                              'chatDetailBloc': _chatDetailBloc,
                                              'messageDisplay': -1,
                                            });
                                      },
                                    );
                                  })
                              : Center(
                                  child: Text(
                                    'Bạn không có bất kỳ thông báo nào',
                                    style: AppTextStyles.text(context)
                                        .copyWith(color: AppColors.grey666),
                                  ),
                                ),
                        );
                      } else {
                        return Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              backgroundColor: context.theme.backgroundListChat,
                              valueColor: AlwaysStoppedAnimation(context.theme.colorPirimaryNoDarkLight)
                            ),
                          ),
                        );
                      }
                    })
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget notificationView(
  BuildContext context,
  List<NotificationModel> listNotification,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 326,
        height: AppDimens.height - 230,
        child: listNotification.isNotEmpty
            ? ListView.builder(
                itemCount: listNotification.length,
                itemBuilder: (context, index) {
                  return notificationTile(
                      notificationModel: listNotification[index],
                      onTap: () {},
                      context: context);
                })
            : Center(
                child: Text(
                  'Bạn không có bất kỳ thông báo nào',
                  style: AppTextStyles.text(context)
                      .copyWith(color: AppColors.grey666),
                ),
              ),
      )
    ],
  );
}

Widget notificationTile(
    {required NotificationModel notificationModel,
    required Function() onTap,
    required BuildContext context}) {
  return ValueListenableBuilder(
    valueListenable: changeTheme,
    builder: (context, value, child) {
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    image: DecorationImage(
                        image: NetworkImage(
                            notificationModel.participant!.avatarUser),
                        fit: BoxFit.cover)),
                child: Container(
                    alignment: Alignment.bottomRight,
                    child: notificationModel.type == 'SendCandidate'
                        ? iconAvatar(
                            Images.noti_plane,
                            AppColors.violetBE2EDD,
                          )
                        : notificationModel.type == 'tag'
                            ? iconAvatar(
                                Images.noti_a,
                                AppColors.primary,
                              )
                            : iconAvatar(
                                Images.noti_money, AppColors.green22A6B3)),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notificationModel.title,
                      style: TextStyle(
                          fontWeight: notificationModel.isUndeader == 1
                              ? FontWeight.w700
                              : FontWeight.w400,
                          fontSize: 14,
                          color: context.theme.textColor),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      notificationModel.message,
                      style: TextStyle(
                          fontSize: 14, color: context.theme.textColor),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      notificationModel.time,
                      style: TextStyle(
                          fontSize: 14, color: context.theme.textColor),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

Widget iconAvatar(String icon, Color color) {
  return Container(
    height: 12,
    width: 12,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: color,
    ),
    child: SvgPicture.asset(icon),
  );
}
