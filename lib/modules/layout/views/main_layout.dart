import 'dart:async';

import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/login_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/common/widgets/fill_button.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/auth/linkweb/model/link_web_model.dart';
import 'package:app_chat365_pc/modules/auth/modules/login/cubit/login_cubit.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/utils/data/clients/interceptors/call_client.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../../common/blocs/chat_bloc/chat_bloc.dart';

class AppMainLayout extends StatefulWidget {
  int receiveID;
  AppMainLayout({super.key, required this.receiveID});

  @override
  State<AppMainLayout> createState() => _AppMainLayoutState();
}

class _AppMainLayoutState extends State<AppMainLayout> {
  late final AppLayoutCubit _appLayoutCubit;
  late final LoginCubit _loginCubit;
  StreamSubscription<Uri>? _linkSubscription;
  late ChatDetailBloc _chatDetailBloc;
  late ChatConversationBloc _chatConversationBloc;
  late TypingDetectorBloc _typingDetectorBloc;

  final ValueNotifier<Widget> _layout =
      ValueNotifier(AfterLoginChat(userInfo: AuthRepo().userInfo!));

  ValueNotifier<int> _receiveID = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _receiveID.value = widget.receiveID;
    if (widget.receiveID != 0) {
      getConver();
    }

    _loginCubit = context.read<LoginCubit>();
    _appLayoutCubit = context.read<AppLayoutCubit>();

    _chatConversationBloc = context.read<ChatConversationBloc>();

    _linkSubscription = appLinks.uriLinkStream.listen((uri) async {
      print('linkwebtoappapplayout : $uri');
      LinkWebModel checkweb = await makeInformationFromApp(uri.toString());
      _receiveID.value = checkweb.idEmployer;
      print(
          'onAppLinkApplyaout: ${checkweb.id} ${checkweb.idEmployer} ${checkweb.positionType} ${checkweb.idConversation} ${_receiveID.value}');
      if (checkweb.idEmployer == 0 && checkweb.idConversation == 0) return;
      if (checkweb.id != AuthRepo().userId && checkweb.id != 0) {
        await SystemUtils.logout(context);
        IUserInfo? newAccountFromWeb;
        newAccountFromWeb = await UserInfoRepo().getUserInfo(checkweb.id);
        await _loginCubit.login(UserType.customer,
            LoginModel(newAccountFromWeb!.email!, newAccountFromWeb!.password!),
            isMD5Pass: true);
      }

      var conversationId = checkweb.idConversation == 0
          ? await context
              .read<ChatBloc>()
              .getConversationId(AuthRepo().userInfo!.id, checkweb.idEmployer)
          : checkweb.idConversation;
      print("------conversationID--------------${conversationId}----");
      var chatItemModel = await ChatRepo().getChatItemModel(conversationId);
      var userInfoBloc = UserInfoBloc.fromConversation(
        chatItemModel!.conversationBasicInfo,
        status: chatItemModel.status,
      );
      _typingDetectorBloc = _chatConversationBloc.typingBlocs[conversationId] ??
          TypingDetectorBloc(conversationId);

      _chatDetailBloc = ChatDetailBloc(
          conversationId: conversationId,
          senderId: context.userInfo().id,
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
        ..conversationName.value = chatItemModel.conversationBasicInfo.name;
      _appLayoutCubit.toMainLayout(AppMainPages.chatScreen, providers: [
        BlocProvider<UserInfoBloc>(create: (context) => userInfoBloc),
        BlocProvider<TypingDetectorBloc>.value(value: _typingDetectorBloc),
      ], agruments: {
        'chatType': ChatType.SOLO,
        'conversationId': conversationId,
        'senderId': context.userInfo().id,
        'chatItemModel': chatItemModel,
        'name': chatItemModel.conversationBasicInfo.name,
        'chatDetailBloc': _chatDetailBloc,
        'messageDisplay': -1,
      });
    });
  }

  getConver() async {
    var conversationId = await context
        .read<ChatBloc>()
        .getConversationId(AuthRepo().userInfo!.id, widget.receiveID);
    var chatItemModel = await ChatRepo().getChatItemModel(conversationId);
    var userInfoBloc = UserInfoBloc.fromConversation(
      chatItemModel!.conversationBasicInfo,
      status: chatItemModel.status,
    );
    print("------conversationID(1)--------------${conversationId}----");

    _typingDetectorBloc = _chatConversationBloc.typingBlocs[conversationId] ??
        TypingDetectorBloc(conversationId);

    _chatDetailBloc = ChatDetailBloc(
        conversationId: conversationId,
        senderId: context.userInfo().id,
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
        otherDeleteTime:
            chatItemModel.firstOtherMember(context.userInfo().id).deleteTime ??
                -1,
        myDeleteTime: -1,
        messageId: '',
        typeGroup: chatItemModel!.typeGroup)
      ..add(const ChatDetailEventLoadConversationDetail())
      ..getDetailInfo(uInfo: userInfoBloc.userInfo)
      ..conversationName.value = chatItemModel.conversationBasicInfo.name;
    _appLayoutCubit.toMainLayout(AppMainPages.chatScreen, providers: [
      BlocProvider<UserInfoBloc>(create: (context) => userInfoBloc),
      BlocProvider<TypingDetectorBloc>.value(value: _typingDetectorBloc),
    ], agruments: {
      'chatType': ChatType.SOLO,
      'conversationId': conversationId,
      'senderId': context.userInfo().id,
      'chatItemModel': chatItemModel,
      'name': chatItemModel.conversationBasicInfo.name,
      'chatDetailBloc': _chatDetailBloc,
      'messageDisplay': -1,
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _receiveID,
      builder: (context, value, child) => BlocListener(
        bloc: _appLayoutCubit,
        listener: (context, state) {
          if (state is AppMainLayoutNavigation) {
            _layout.value = state.layout;
          }
        },
        child: ValueListenableBuilder(
            valueListenable: _layout, builder: (_, __, ___) => _layout.value),
      ),
    );
  }
}

// sau khi đăng nhập vào chưa hiển thị chi tiết cuộc trò chuyện
class AfterLoginChat extends StatefulWidget {
  AfterLoginChat({super.key, required this.userInfo});

  final IUserInfo userInfo;

  @override
  State<AfterLoginChat> createState() => _AfterLoginChatState();
}

class _AfterLoginChatState extends State<AfterLoginChat> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (BuildContext context, dynamic value, Widget? child) {
        return Container(
          padding: const EdgeInsets.only(top: 100, bottom: 20),
          decoration: BoxDecoration(
            color: context.theme.backgroundChatContent,
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)?.hello ?? '',
                  style: AppTextStyles.text(context).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: context.theme.textColor),
                  children: <TextSpan>[
                    TextSpan(
                      text: widget.userInfo.name,
                      style: AppTextStyles.text(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          color: context.theme.textColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 80,
              ),
              Stack(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      width: 120,
                      height: 120,
                      imageUrl: widget.userInfo.avatar.toString(),
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Image.asset(
                        Images.img_non_avatar,
                      ),
                    ),
                  ),
                  widget.userInfo.isOnline == 1
                      ? Positioned(
                          right: 5,
                          bottom: 0,
                          child: Container(
                              width: 30,
                              height: 30,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 2, color: Colors.white),
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: AppColors.lima)))
                      : SizedBoxExt.shrink
                ],
              ),
              const SizedBox(
                height: 60,
              ),
              ValueListenableBuilder(
                  valueListenable: changeTheme,
                  builder: (context, value, child) {
                    return SizedBox(
                      width: changeLanguage.value == 'vi' ? 240 : 200,
                      child: FillButton(
                        onPressed: () {
                          setState(() {});
                        },
                        title:
                            AppLocalizations.of(context)?.startConversation ??
                                '',
                        style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),

                      ),
                    );
                  }),
              const SizedBox(
                height: 50,
              ),
              Text(AppLocalizations.of(context)?.startConversationContent ?? '',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.text(context)
                      .copyWith(fontSize: 16, color: context.theme.text2Color)),
              const SizedBox(
                height: 70,
              ),
              Text(
                AppLocalizations.of(context)?.notYouAndCheckAccount ?? '',
                style: AppTextStyles.text(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.theme.text2Color),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                  AppLocalizations.of(context)?.notYouAndCheckAccountContent ??
                      '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: context.theme.textColor,
                  )),
            ],
          ),
        );
      },
    );
  }
}
