import 'dart:async';
import 'dart:convert';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/modules/profile/model/member_in_group_model.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_cubit.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_state.dart';
import 'package:app_chat365_pc/modules/profile/repo/group_profile_repo.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationMessageDisplay extends StatefulWidget {
  NotificationMessageDisplay({
    Key? key,
    this.listUserInfos,
    required String? message,
    required this.conversationId,
    this.onGetUnknownUserIdsFound,
    this.textBuilder,
    this.chatDetailBloc,
    this.profileCubit,
    this.groupProfileRepo,
    this.isGroup,
    this.listMemberOfGroup,
  })  : this._message = message ?? '',
        super(key: key);

  final Map<int, UserInfoBloc>? listUserInfos;
  final String _message;
  final int conversationId;
  final ValueChanged<List<UserInfoBloc>>? onGetUnknownUserIdsFound;
  final Widget Function(BuildContext, String)? textBuilder;
  final ChatDetailBloc? chatDetailBloc;
  final ProfileCubit? profileCubit;
  final GroupProfileRepo? groupProfileRepo;
  final bool? isGroup;
  final List<ModelMemberOfGroup>? listMemberOfGroup;

  @override
  State<NotificationMessageDisplay> createState() =>
      _NotificationMessageDisplayState();
}

class _NotificationMessageDisplayState
    extends State<NotificationMessageDisplay> {
  late Map<int, UserInfoBloc> _userInfoBlocs;
  final List<ValueNotifier<String>> _userListeners = [];
  final List<StreamSubscription> _subscriptions = [];
  final List<UserInfoBloc> _unknownUserInfoBlocs = [];
  List<ModelMemberOfGroup> _listMemberOfGroup = [];
  ValueNotifier<List<ModelMemberOfGroup>> listMemberOfGroupChange =
      ValueNotifier([]);
  late final ProfileCubit _profileCubit;
  int idAdmin = 0;

  @override
  void initState() {
    super.initState();
    if (widget.profileCubit != null) {
      _profileCubit = widget.profileCubit!;
    } else {
      _profileCubit =
          ProfileCubit(widget.conversationId, isGroup: widget.isGroup ?? false);
    }
    _profileCubit.checkAdmin(conversationId: widget.conversationId);
    _userInfoBlocs = widget.listUserInfos ?? {};

    Set<int> userIdsInMessage = widget._message.getListIntFromThis().toSet();

    Map<int, UserInfoBloc> users = {};

    // chạy vòng for với mỗi số từ tin nhắn để convert từ id sang tên
    // cứ for kiểu này lại spam lại chết chat
    for (var userId in userIdsInMessage) {
      if (_userInfoBlocs[userId] != null) {
        users[userId] = _userInfoBlocs[userId]!;
      } else {
        if (userId == 0) {
          logger.log("UserInfoBloc gọi API spam với userId == 0 nè",
              name: "$runtimeType.initState");
        }
        var unknowUserInfoBloc = UserInfoBloc.unknown(userId);
        _unknownUserInfoBlocs.add(unknowUserInfoBloc);
        users[userId] = unknowUserInfoBloc;
      }

      var valueNotifier = ValueNotifier(users[userId]!.state.userInfo.name);
      _subscriptions.add(users[userId]!.stream.listen((state) {
        valueNotifier.value = state.userInfo.name;
      }));
      _userListeners.add(valueNotifier);
    }

    if (_unknownUserInfoBlocs.isNotEmpty)
      widget.onGetUnknownUserIdsFound?.call(_unknownUserInfoBlocs);

    // _setMessage(users);

    // Set<int> conversationUserIds = users.keys.toSet();

    // if (!conversationUserIds.containsAll(userIdsInMessage)) {
    //   var missingIds = userIdsInMessage.difference(conversationUserIds);
    //   Future.wait(missingIds.map((e) => _chatRepo.getUserInfo(e)))
    //       .then((value) {
    //     ChatDetailBloc? chatDetailBloc;
    //     try {
    //       chatDetailBloc = context.read<ChatDetailBloc>();
    //     } catch (e) {
    //       logger.logError('Not found ChatDetailBloc');
    //     }
    //     value.removeWhere((e) => e == null);
    //     value.forEach((e) {
    //       var userInfoBloc =
    //           UserInfoBloc(e!, userInfoRepo: context.read<UserInfoRepo>());
    //       users[e.id] = userInfoBloc;
    //       chatDetailBloc?.tempListUserInfoBlocs
    //           .putIfAbsent(e.id, () => userInfoBloc);
    //     });
    //     if (mounted)
    //       setState(() {
    //         _setMessage(users);
    //       });
    //   });
    // }
  }

  // _setMessage(Map<int, UserInfoBloc> users) {
  //   message = StringExt.getDisplayMessageFromApiMessage(
  //     widget._message,
  //     users.values.map((e) => e.userInfo.name).toList(),
  //   );
  // }

  @override
  void dispose() {
    _userListeners.forEach((e) => e.dispose());
    _subscriptions.forEach((e) => e.cancel());
    _unknownUserInfoBlocs.forEach((e) => e.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.listUserInfos == null)
    //   return Text(
    //     widget._message,
    //     style: AppTextStyles.textMessageDisplayStyle(context),
    //   );

    return AnimatedBuilder(
        animation: Listenable.merge(_userListeners),
        builder: (context, _) {
          var text = StringExt.getDisplayMessageFromApiMessage(
            widget._message,
            _userListeners.map((e) => e.value).toList(),
          );
          // if (text.contains('đã chấp nhận lời mời kết bạn'))
          //   return Container(
          //     decoration: BoxDecoration(
          //       color: Colors.grey.shade100,
          //       borderRadius: BorderRadius.circular(10),
          //       //shadow
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.grey.withOpacity(0.5),
          //           spreadRadius: 1,
          //           blurRadius: 1,
          //           offset: Offset(0, 1), // changes position of shadow
          //         ),
          //       ],
          //     ),
          //     child: Column(
          //       children: [
          //         Text(
          //           text,
          //           textAlign: TextAlign.center,
          //           style: AppTextStyles.textMessageDisplayStyle(context),
          //         ),
          //         SizedBox(height: 10),
          //         //button
          //         ElevatedButton(
          //           //onpressed send message  ,
          //           onPressed: () {},
          //           child: Text('send message'),
          //         ),
          //       ],
          //     ),
          //   );

          String txt = AuthRepo().userName + ' đã thêm';
          String txtDelete = text.split(' đã thêm ').last;
          String nameDelete = txtDelete.split(' vào cuộc ').first;
          ModelMemberOfGroup? userDelete;

          if (widget.textBuilder != null)
            return widget.textBuilder!(context, text);
          return BlocListener(
              bloc: widget.profileCubit,
              listenWhen: (previous, current) =>
                  current is GetListMemberOfGroupLoaded,
              listener: (context, state) {
                // logger.log(state, name: 'lllllllllllllllllllllllll');
                if (state is GetListMemberOfGroupLoaded) {
                  listMemberOfGroupChange.value = [...state.listMemberOfGroup];
                  for (var item in listMemberOfGroupChange.value) {
                    if (item.userName == nameDelete) {
                      userDelete = item;
                      break;
                    }
                  }
                }
              },
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: AppDimens.width,
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.textMessageDisplayStyle(context,
                          color: context.theme.hitnTextColor),
                      maxLines: 2,
                    ),
                  ),
                  ValueListenableBuilder<List<ModelMemberOfGroup>>(
                      valueListenable: listMemberOfGroupChange,
                      builder: (context, listCheck, _) {
                        return text.contains(txt) && userDelete != null
                            // &&
                            // listCheck.contains(userDelete)
                            ? InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => Container(
                                      // constraints:
                                      //     BoxConstraints(maxHeight: AppDimens.height * .5),
                                      child: notification(widget.conversationId,
                                          text, nameDelete),
                                    ),
                                  );
                                },
                                child: Text(' Thu hồi',
                                    style: AppTextStyles.regularW400(
                                      context,
                                      size: 16,
                                      lineHeight: 18.75,
                                      color: AppColors.blue3B86D4,
                                    )),
                              )
                            : Container();
                      }),
                ],
              ));
        });
  }

  Widget notification(int conversationId, String txt, String nameDelete) {
    return Builder(builder: (context) {
      return BlocListener(
        bloc: _profileCubit,
        listener: (context, state) {
          if (state is CheckAdminTrueState) {
            // isAdmin.value = true;
            idAdmin = state.adminId;
            // deputyAdminId = state.deputyAdminId;
            // memberApproval.value = state.memberApproval;
          }
          if (state is CheckAdminFalseState) {
            idAdmin = state.adminId;

            // isAdmin.value = false;
            // adminId.value = state.adminId;
            // deputyAdminId = state.deputyAdminId;
            // memberApproval.value = state.memberApproval;
          }
          if (state is GetListMemberOfGroupDifferentLoading) {
            AppDialogs.showLoadingCircle(context);
          }
          if (state is GetListMemberOfGroupFailed) {
            AppDialogs.hideLoadingCircle(context);
            AppRouter.back(context);
            BotToast.showText(text: 'Đã có lỗi xảy ra');
          }
          if (state is GetListMemberOfGroupDifferentLoaded) {
            _listMemberOfGroup.clear();
            _listMemberOfGroup = [...state.listMemberOfGroup];
            listMemberOfGroupChange.value = [...state.listMemberOfGroup];
            int idDelete = 0;

            for (var item in _listMemberOfGroup) {
              if (item.userName == nameDelete) {
                idDelete = item.id;
                break;
              }
            }
            if (idDelete == 0) {
              AppDialogs.hideLoadingCircle(context);
              AppRouter.back(context);
              BotToast.showText(text: 'Thành viên đã không còn trong nhóm');
            } else {
              print('----------${idDelete}----------${idAdmin}');
              widget.groupProfileRepo!.deleteMemberToGroup(members: [idDelete]);
              // nếu là trưởng nhóm thì xóa luôn, nếu ko thì cần chờ duyệt
              if (idAdmin == AuthRepo().userId) {
                _listMemberOfGroup
                    .removeWhere((element) => element.id == idDelete);
                listMemberOfGroupChange.value = [..._listMemberOfGroup];
                widget.chatDetailBloc!.listUserInfoBlocs.remove(idDelete);
                widget.chatDetailBloc!.countConversationMember.value =
                    widget.chatDetailBloc!.listUserInfoBlocs.length;
              }

              AppDialogs.hideLoadingCircle(context);

              AppRouter.back(context);
            }
          }
        },
        child: Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'Nếu ',
                        style: AppTextStyles.regularW400(
                          context,
                          size: 15,
                          color: AppColors.tundora,
                        )),
                    TextSpan(
                        text: 'Thu hồi',
                        style: AppTextStyles.regularW500(
                          context,
                          size: 15,
                          color: AppColors.black,
                        )),
                    TextSpan(
                        text: ', thành viên sẽ được xóa khỏi nhóm.',
                        style: AppTextStyles.regularW400(
                          context,
                          size: 15,
                          color: AppColors.tundora,
                        )),
                  ],
                ),
              ),
              SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'Bạn có chắc chắn ',
                        style: AppTextStyles.regularW400(
                          context,
                          size: 15,
                          color: AppColors.tundora,
                        )),
                    TextSpan(
                        text: 'Thu hồi',
                        style: AppTextStyles.regularW500(
                          context,
                          size: 15,
                          color: AppColors.black,
                        )),
                    TextSpan(
                        text: '?',
                        style: AppTextStyles.regularW400(
                          context,
                          size: 15,
                          color: AppColors.tundora,
                        )),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Spacer(),
                  Container(
                    height: 30,
                    width: AppDimens.width * 0.3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(255, 211, 222, 246)),
                    child: Center(
                      child: Text(
                        'Huỷ',
                        style: AppTextStyles.regularW400(
                          context,
                          size: 15,
                          color: AppColors.blue3B86D4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  InkWell(
                    onTap: () async {
                      await widget.profileCubit!
                          .checkAdmin(conversationId: conversationId);
                      await widget.profileCubit!.getListMemberOfGroup(
                          conversationId: conversationId, type: 2);

                      print('======================${idAdmin}============');
                    },
                    child: Container(
                      height: 30,
                      width: AppDimens.width * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          'Chắc chắn',
                          style: AppTextStyles.regularW400(
                            context,
                            size: 15,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
