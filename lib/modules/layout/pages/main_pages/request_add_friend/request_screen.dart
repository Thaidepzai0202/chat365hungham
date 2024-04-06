import 'package:app_chat365_pc/common/blocs/friend_cubit/cubit/friend_cubit.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/model/user_in_com.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/model/user_request_model.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/user_request_bloc/user_request_bloc.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/user_request_bloc/user_request_state.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/bloc/contact_bloc/contact_bloc.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {

  late UserRequestBloc userRequestBloc;
  ValueNotifier<int> isSendRequest = ValueNotifier(0);
  late ContactBloc contactBloc;

  void sendNoti() {
    chatClient.emit(
      ChatSocketEvent.requestAddFriend,
    );
  }

  @override
  void initState() {
    userRequestBloc = context.read<UserRequestBloc>();
    contactBloc = context.read<ContactBloc>();
    userRequestBloc.takeListRequest(
        AuthRepo().userInfo!.id, AuthRepo().userInfo!.companyId!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    chatClient.on('AddFriend', (data) {
      userRequestBloc.takeListRequest(
          AuthRepo().userInfo?.id ?? 0, AuthRepo().userInfo?.companyId ?? 0);
    });
    chatClient.on('DeleteRequestAddFriend', (data) {
      userRequestBloc.takeListRequest(
          AuthRepo().userInfo?.id ?? 0, AuthRepo().userInfo?.companyId ?? 0);
    });
    chatClient.on('AcceptRequestAddFriend', (data) {
      userRequestBloc.takeListRequest(
          AuthRepo().userInfo?.id ?? 0, AuthRepo().userInfo?.companyId ?? 0);
    });
    chatClient.on('DecilineRequestAddFriend', (data) {
      userRequestBloc.takeListRequest(
          AuthRepo().userInfo?.id ?? 0, AuthRepo().userInfo?.companyId ?? 0);
    });
    return ValueListenableBuilder(
        valueListenable: changeTheme,
        builder: (context, value, child) {
          return BlocBuilder(
            bloc: userRequestBloc,
            builder: (_, state) {
              if (state is LoadedRequestState) {
                return SizedBox(
                  height: AppDimens.height - 42,
                  width: AppDimens.width - 384,
                  child: Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: context.theme.backgroundListChat,
                      title: Row(
                        children: [
                          Image.asset(
                            Images.profile2UserBlue,
                            height: 36,
                            width: 36,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Lời mời kết bạn',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: context.theme.text2Color),
                          )
                        ],
                      ),
                    ),
                    body: Container(
                        color: context.theme.backgroundChatContent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 24),
                        child: ValueListenableBuilder(
                            valueListenable: isSendRequest,
                            builder: (_, __, ___) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          isSendRequest.value = 0;
                                        },
                                        child: GradientText(
                                          '${AppLocalizations.of(context)?.received ?? ''} (${userRequestBloc.listRequest.length})',
                                          gradient: isSendRequest.value == 0 ? context.theme.gradient : context.theme.swichoffgraident,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      InkWell(
                                        onTap: () {
                                          isSendRequest.value = 1;
                                        },
                                        child: GradientText(
                                          '${AppLocalizations.of(context)?.sent ??''} (${userRequestBloc.listSendRequest.length})',
                                          gradient: isSendRequest.value == 1 ? context.theme.gradient : context.theme.swichoffgraident,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  isSendRequest.value == 0
                                      ? SizedBox(
                                          height: 200,
                                          child:
                                              userRequestBloc
                                                      .listRequest.isNotEmpty
                                                  ? ListView(
                                                      children: [
                                                        ...List.generate(
                                                            userRequestBloc
                                                                .listRequest
                                                                .length,
                                                            (index) =>
                                                                requestDetail(
                                                                    context:
                                                                        context,
                                                                    userRequest:
                                                                        userRequestBloc.listRequest[
                                                                            index],
                                                                    agreeOnTap:
                                                                        () async {
                                                                      await userRequestBloc.requestAddFriend(
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .id,
                                                                          userRequestBloc
                                                                              .listRequest[index]
                                                                              .uid
                                                                              .toInt(),
                                                                          1);
                                                                      userRequestBloc.takeListRequest(
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .id,
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .companyId!);
                                                                      contactBloc
                                                                          .takeMyContact();
                                                                    },
                                                                    declineOnTap:
                                                                        () async {
                                                                      await userRequestBloc.requestAddFriend(
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .id,
                                                                          userRequestBloc
                                                                              .listRequest[index]
                                                                              .uid
                                                                              .toInt(),
                                                                          2);
                                                                      await userRequestBloc.takeListRequest(
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .id,
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .companyId!);
                                                                    }))
                                                      ],
                                                    )
                                                  : null)
                                      : SizedBox(
                                          height: 200,
                                          child:
                                              userRequestBloc.listSendRequest
                                                      .isNotEmpty
                                                  ? ListView(
                                                      children: [
                                                        ...List.generate(
                                                            userRequestBloc
                                                                .listSendRequest
                                                                .length,
                                                            (index) =>
                                                                sendRequestDetail(
                                                                    context:
                                                                        context,
                                                                    userRequest:
                                                                        userRequestBloc.listSendRequest[
                                                                            index],
                                                                    onTap:
                                                                        () async {
                                                                      await userRequestBloc.deleteRequestAddFriend(
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .id,
                                                                          userRequestBloc
                                                                              .listSendRequest[index]
                                                                              .uid
                                                                              .toInt());
                                                                      await userRequestBloc.takeListRequest(
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .id,
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .companyId!);
                                                                    }))
                                                      ],
                                                    )
                                                  : null),
                                  const SizedBox(height: 20),
                                  Text(
                                    '${AppLocalizations.of(context)!.contactWithinTheCompany} (${userRequestBloc.listUserInCom.length})',
                                    style: TextStyle(
                                        color: context.theme.text2Color),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Expanded(
                                    child: GridView.count(
                                      padding: const EdgeInsets.all(10),
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      crossAxisCount: 4,
                                      children: [
                                        ...List.generate(
                                            userRequestBloc
                                                .listUserInCom.length, (index) {
                                          var userItem = userRequestBloc
                                              .listUserInCom[index];
                                          ValueNotifier<bool> friendStatus =
                                              ValueNotifier(
                                                  userItem.friendStatus ==
                                                          'none'
                                                      ? true
                                                      : false);
                                          return contactWidget(
                                              context: context,
                                              userInCom: userItem,
                                              onTap: userItem.friendStatus ==
                                                      'accept'
                                                  ? () async {}
                                                  : () async {
                                                      friendStatus.value =
                                                          !friendStatus.value;
                                                      if (friendStatus.value ==
                                                          true) {
                                                        await userRequestBloc
                                                            .deleteRequestAddFriend(
                                                          AuthRepo()
                                                              .userInfo!
                                                              .id,
                                                          userItem.id,
                                                        );
                                                        await userRequestBloc
                                                            .takeListRequest(
                                                                AuthRepo()
                                                                    .userInfo!
                                                                    .id,
                                                                AuthRepo()
                                                                    .userInfo!
                                                                    .companyId!);
                                                      } else {
                                                        await userRequestBloc
                                                            .sendRequestAddFriend(
                                                                AuthRepo()
                                                                    .userInfo!
                                                                    .id,
                                                                userItem.id,
                                                                userItem
                                                                    .type365);
                                                        await userRequestBloc
                                                            .takeListRequest(
                                                                AuthRepo()
                                                                    .userInfo!
                                                                    .id,
                                                                AuthRepo()
                                                                    .userInfo!
                                                                    .companyId!);
                                                        // await _friendCubit.addFriend(
                                                        //     _userInfoBloc.userInfo,
                                                      }
                                                    },
                                              friendStatus: friendStatus);
                                        }).toList()
                                      ],
                                    ),
                                  )
                                ],
                              );
                            })),
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(context.theme.colorPirimaryNoDarkLight),),
                );
              }
            },
          );
        });
  }

  Widget contactWidget(
      {required UserInCom userInCom,
      required Function() onTap,
      required ValueNotifier<bool> friendStatus,
      required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: context.theme.messageBoxColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(userInCom.avatarUser),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            userInCom.userName,
            overflow: TextOverflow.ellipsis,
            style:
                AppTextStyles.text(context).copyWith(),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: onTap,
            child: userInCom.friendStatus == 'accept'
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: userInCom.friendStatus == 'accept'
                            ? AppColors.white
                            : AppColors.indigoD6D9F5,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: context.theme.colorPirimaryNoDarkLight)),
                    child:  Text(
                      AppLocalizations.of(context)?.message ??'',
                      style: TextStyle(fontSize: 13, color: context.theme.colorPirimaryNoDarkLight),
                    ),
                  )
                : ValueListenableBuilder(
                    valueListenable: friendStatus,
                    builder: (_, __, ___) => Container(
                      // alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          gradient: context.theme.gradient,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Text(
                        friendStatus.value == true ? AppLocalizations.of(context)?.addFriend ??'' : AppLocalizations.of(context)?.unfriend ??'',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.white),
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}

Widget requestDetail(
    {required UserRequest userRequest,
    required Function() agreeOnTap,
    required Function() declineOnTap,
    required BuildContext context}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
    decoration: BoxDecoration(
        color: context.theme.abcfriendBoxColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: AppColors.greyCC, width: 0.5)),
    child: Row(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              image: DecorationImage(
                  image: NetworkImage(userRequest.avatar), fit: BoxFit.cover)),
        ),
        const SizedBox(
          width: 15,
        ),
        Text(
          userRequest.name,
          style: AppTextStyles.text(context),
        ),
        const Spacer(),
        Container(
          alignment: Alignment.center,
          child: Row(
            children: [
              InkWell(
                onTap: declineOnTap,
                child: GradientText(
                  AppLocalizations.of(context)?.refuse ??'',
                  gradient: context.theme.gradient,
                  style: AppTextStyles.text(context)
                      .copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              InkWell(
                onTap: agreeOnTap,
                child: Container(
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: context.theme.gradient,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.agree ??'',
                    style: AppTextStyles.text(context)
                        .copyWith(fontSize: 14, color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget sendRequestDetail(
    {required UserRequest userRequest,
    required Function() onTap,
    required BuildContext context}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
    decoration: BoxDecoration(
        color: context.theme.abcfriendBoxColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: AppColors.greyCC, width: 0.5)),
    child: Row(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              image: DecorationImage(
                  image: NetworkImage(userRequest.avatar), fit: BoxFit.cover)),
        ),
        const SizedBox(
          width: 15,
        ),
        Text(
          userRequest.name,
          style: AppTextStyles.text(context),
        ),
        const Spacer(),
        Container(
          alignment: Alignment.center,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration:  BoxDecoration(
                color: AppColors.whiteLilac,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                border: Border.all(
                  width: 1,color: context.theme.colorPirimaryNoDarkLight
                )
              ),
              child: Text(
                AppLocalizations.of(context)?.recall ??'',
                style: AppTextStyles.text(context)
                    .copyWith(fontSize: 14, color: context.theme.colorPirimaryNoDarkLight),
              ),
            ),
          ),
        )
      ],
    ),
  );
}
