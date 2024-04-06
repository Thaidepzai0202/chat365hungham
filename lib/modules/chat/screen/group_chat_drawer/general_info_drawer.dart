import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_library_cubit/cubit/chat_library_cubit.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/photo_view.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat/screen/group_chat_drawer/group_chat_drawer.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/add_new_group_member_dialog.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/chat_screen_dialog.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/member_moderation_dialog.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/conversation_model.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_cubit.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_state.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Các màn sau để dialog:
// - Bình chọn
// - Rời nhóm

/// Màn chức năng của cuộc trò chuyện nhóm,
/// hiện ra khi bấm nút răng cưa ở góc màn hình
///
class GeneralInfoDrawer extends StatefulWidget {
  const GeneralInfoDrawer({super.key});

  @override
  State<GeneralInfoDrawer> createState() => _GeneralInfoDrawerState();
}

class _GeneralInfoDrawerState extends State<GeneralInfoDrawer> {
  // Tên cuộc trò chuyện
  // Dự phòng trường hợp edit xong nhưng gửi API không lên thì còn có giá trị mà sửa lại
  late String initialName = "";
  late TextEditingController groupNameEdit;
  ValueNotifier<bool> isInGroupNameEditMode = ValueNotifier(false);
  //late ChatItemModel chatItemModel;

  @override
  void initState() {
    super.initState();
    initialName = context
        .read<ChatDetailBloc>()
        .chatItemModel!
        .conversationBasicInfo
        .name;
    groupNameEdit = TextEditingController(text: initialName);
  }

  @override
  Widget build(context) {
    var convNameTextStyle = TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: context.theme.text2Color);
    var warningTextStyle = const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.red);

    var sectionDivider = ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) => Divider(
        thickness: 1,
        color: context.theme.backgroundOnForward,
      ),
    );

    return ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) {
        return Container(
          color: context.theme.backgroundColor,
          width: 500,
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 80,
                            decoration:
                                BoxDecoration(gradient: context.theme.gradient),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBoxExt.h5,
                          // const Align(
                          //     alignment: Alignment.center,
                          //     child: Text(
                          //       "Thông tin nhóm",
                          //       style: TextStyle(
                          //           fontSize: 18,
                          //           fontWeight: FontWeight.w600,
                          //           color: AppColors.white),
                          //     )),
                          SizedBoxExt.h30,
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                                // border: Border.all(
                                //     width: 1, color: context.theme.text3Color),
                                shape: BoxShape.circle),
                            child: DisplayAvatar(
                                isGroup: true,
                                size: 80,
                                model: context
                                    .watch<ChatDetailBloc>()
                                    .chatItemModel!
                                    .conversationBasicInfo),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBoxExt.h10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SizedBox để cân đối nút đổi tên
                      const SizedBox(width: 50),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: ValueListenableBuilder(
                              valueListenable: isInGroupNameEditMode,
                              builder: (context, isEditing, child) {
                                if (isEditing) {
                                  return TextField(
                                    style: convNameTextStyle,
                                    textAlign: TextAlign.center,
                                    controller: groupNameEdit,
                                    onSubmitted: (value) {
                                      isInGroupNameEditMode.value = false;
                                      // Không chấp nhận tên nhóm toàn dấu trắng
                                      if (value.trim() == "") {
                                        return;
                                      }
                                      initialName = groupNameEdit.text;
                                      var profCubit =
                                          context.read<ProfileCubit>();
                                      profCubit.changeGroupName(
                                          newName: groupNameEdit.text,
                                          members: context
                                              .read<ChatDetailBloc>()
                                              .chatItemModel!
                                              .memberList
                                              .map((e) => e.id)
                                              .toList());
                                      // logger.log("Đổi tên nhóm nè", name: "$runtimeType");
                                    },
                                  );
                                }
                                return BlocBuilder<ProfileCubit, ProfileState>(
                                    builder: (context, state) {
                                  if (state is ChangeNameStateLoading) {
                                    return const CircularProgressIndicator();
                                  }

                                  if (state is ChangeNameStateError) {
                                    // Chẳng làm gì
                                  }

                                  if (state is ChangeNameStateDone) {
                                    initialName = state.newName;
                                  }
                                  return Text(
                                    initialName,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: context.theme.text2Color),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                });
                              }),
                        ),
                      ),

                      // Nút đổi tên nhóm
                      SizedBoxExt.w15,
                      SizedBox(
                        width: 35,
                        child: IconButton(
                            onPressed: () {
                              isInGroupNameEditMode.value =
                                  !isInGroupNameEditMode.value;

                              if (isInGroupNameEditMode.value) {
                                groupNameEdit.text = initialName;
                              }
                            },
                            icon: SvgPicture.asset(
                              Images.ic_pencil,
                              color: context.theme.text2Color,
                            )),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: verticalIconButton(
                              iconPath: Images.ic_tim_kiem,
                              text: AppLocalizations.of(context)!.searchMesage,
                              onTap: () {})),

                      // Ghim hội thoại (thực ra là biến nó thành yêu thích)
                      Expanded(
                          child: BlocBuilder<ChatConversationBloc,
                                  ChatConversationState>(
                              buildWhen: (previous, current) {
                        return current
                                is ChatConversationAddFavoriteSuccessState ||
                            current
                                is ChatConversationRemoveFavoriteSuccessState;
                      }, builder: (context, state) {
                        if (state is ChatConversationAddFavoriteSuccessState) {
                          context
                              .watch<ChatDetailBloc>()
                              .chatItemModel!
                              .isFavorite = true;
                        } else if (state
                            is ChatConversationRemoveFavoriteSuccessState) {
                          context
                              .watch<ChatDetailBloc>()
                              .chatItemModel!
                              .isFavorite = false;
                        }
                        bool isFavourite = context
                            .watch<ChatDetailBloc>()
                            .chatItemModel!
                            .isFavorite;
                        return verticalIconButton(
                            iconPath: Images.ic_ghim,
                            text:
                                "${isFavourite ? AppLocalizations.of(context)!.pinConversation : AppLocalizations.of(context)!.unpinConversation}",
                            onTap: () async {
                              await ChatRepo().changeFavoriteStatus(
                                  conversationId: context
                                      .read<ChatDetailBloc>()
                                      .conversationId,
                                  // Đảo ngược trạng thái yêu thích khi thay đổi
                                  favorite: !isFavourite);
                            });
                      })),

                      /// Đổi trạng thái thông báo
                      Expanded(
                        child: BlocBuilder<ChatConversationBloc,
                                ChatConversationState>(
                            buildWhen: (prev, cur) => cur
                                is ChatConversationStateNotificationStatusChanged,
                            builder: (context, state) {
                              if (state
                                  is ChatConversationStateNotificationStatusChanged) {
                                context
                                        .read<ChatDetailBloc>()
                                        .chatItemModel!
                                        .isNotification =
                                    state.newNotificationStatus;
                              }

                              var isNotificationOn = context
                                  .watch<ChatDetailBloc>()
                                  .chatItemModel!
                                  .isNotification;
                              return verticalIconButton(
                                iconPath: isNotificationOn
                                    ? Images.ic_tat_thong_bao
                                    : Images.ic_notifications_off,
                                text:
                                    "${isNotificationOn ? AppLocalizations.of(context)!.onNotificationCon : AppLocalizations.of(context)!.offNotificationCon}",
                                onTap: () {
                                  context
                                      .read<ChatConversationBloc>()
                                      .changeNotificationStatus(
                                          conversationId: context
                                              .read<ChatDetailBloc>()
                                              .conversationId);
                                },
                              );
                            }),
                      ),
                      Expanded(
                          child: verticalIconButton(
                              iconPath: Images.ic_quan_ly_nhom,
                              text: AppLocalizations.of(context)!.groupManager,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return MemberModerationDialog(
                                      mainContext: context,
                                    );
                                  },
                                );
                              })),
                    ],
                  ),
                ],
              ),
              SizedBoxExt.h8,
              sectionDivider,

              // TODO: Cắt từ đây xuống thành một màn riêng. Có thể chuyển màn

              horizontalIconButton(
                iconPath: Images.ic_anh_file_link_da_gui,
                text: AppLocalizations.of(context)!.sentFile,
                onTap: () {
                  context
                      .read<GroupChatDrawerCubit>()
                      .emit(GroupChatDrawerScene.files);
                },
                // textStyle: TextStyle(color: context.theme.text3Color,fontSize: 14)
              ),

              // Cubit này trên ChatScreen
              // Hiện một số file đầu tiên, sau đó thì hiện dấu 3 chấm
              BlocBuilder<ChatLibraryCubit, ChatLibraryState>(
                  builder: (context, state) {
                if (state is ChatLibraryStateLoading) {
                  return const SizedBox(
                    height: 100,
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (state is ChatLibraryStateError) {
                  return const SizedBox(
                    height: 100,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Có lỗi xảy ra."),
                    ),
                  );
                }

                // Ở đây build khi ChatLibraryStateLoadSuccess

                var lib = context.watch<ChatLibraryCubit>();
                var mostRecentFiles = lib.getMostRecentFiles(amount: 5);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      ...mostRecentFiles.map(
                        (e) => SizedBox(
                            width: 90, height: 90, child: tinyFilePreview(e)),
                      ),
                      // Hiện nút ba chấm xem thêm. Bấm vào thì ra màn "Ảnh, file, liên kết đã gửi"
                      if (mostRecentFiles.length == 5)
                        SizedBox(
                            width: 90,
                            height: 90,
                            child: threeDotsToImageFileLinkScene()),
                    ],
                  ),
                );
              }),
              SizedBoxExt.h10,
              horizontalIconButton(
                  iconPath: Images.ic_lich_nhom,
                  text: AppLocalizations.of(context)!.groupCalendar,
                  onTap: () {}),
              horizontalIconButton(
                  iconPath: Images.ic_ghim,
                  text: AppLocalizations.of(context)!.pinnedMessage,
                  onTap: () {}),
              horizontalIconButton(
                  iconPath: Images.ic_binh_chon,
                  text: AppLocalizations.of(context)!.vote,
                  onTap: () {}),
              sectionDivider,
              horizontalIconButton(
                  iconPath: Images.ic_xem_thanh_vien,
                  text: AppLocalizations.of(context)!.viewMembers,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return MemberModerationDialog(
                          mainContext: context,
                        );
                      },
                    );
                  }),
              horizontalIconButton(
                  iconPath: Images.ic_duyet_thanh_vien,
                  text: AppLocalizations.of(context)!.addMembers,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AddMemberToGroupChatDialog(
                              originContext: context);
                        });
                  }),
              // TL Note 25/12/2023: Để mọi người vào luôn Member Moderation Dialog mà xóa
              // Chỉ hiện xóa với trưởng/phó
              // if (checkIsModerator(AuthRepo().userInfo!.id))
              //   horizontalIconButton(
              //       iconPath: Images.ic_xoa_thanh_vien,
              //       text: "Xóa thành viên",
              //       onTap: () {}),

              sectionDivider,

              // TODO: Vẫn chưa rõ đổi trạng thái ẩn như nào
              BlocBuilder<ChatConversationBloc, ChatConversationState>(
                  buildWhen: ((previous, current) {
                return current is ChatConversationEventAddHiddenConversation;
              }), builder: (context, state) {
                return horizontalIconButton(
                  iconPath: Images.ic_an_tro_chuyen,
                  text: AppLocalizations.of(context)!.hiddenMessage,
                  onTap: () {},
                  // trailing: SizedBox(
                  //   width: 40,
                  //   height: 40,
                  //   child: SvgPicture.asset(
                  //     isOn ? Images.switch_on_blue : Images.ic_info_dialog_switch_off,
                  //   ),
                  // ),
                );
              }),
              horizontalIconButton(
                  iconPath: Images.ic_cai_dat_ca_nhan,
                  text: AppLocalizations.of(context)!.personalSetting,
                  onTap: () {}),
              sectionDivider,
              horizontalIconButton(
                  iconPath: Images.ic_bao_xau,
                  text: AppLocalizations.of(context)!.badReport,
                  onTap: () {}),
              horizontalIconButton(
                  iconPath: Images.ic_dung_luong_tro_chuyen,
                  text: AppLocalizations.of(context)!.chatCapacity,
                  onTap: () {}),
              horizontalIconButton(
                  iconPath: Images.ic_xoa_lich_su_cuoc_tro_chuyen,
                  text: AppLocalizations.of(context)!.deleteConversationHistory,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return ChatScreenSettingDialog(
                            title:
                                "Xóa cuộc trò chuyện ${context.watch<ChatDetailBloc>().conversationName.value}?",
                            size: const Size(350, 260),
                            children: [
                              SizedBox(
                                height: 60,
                                child: TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    var err = await context
                                        .read<ChatConversationBloc>()
                                        .deleteFileConversation(context
                                            .read<ChatDetailBloc>()
                                            .conversationId);
                                    if (err == null) {
                                      // TODO: Reload lại màn chat
                                      AppDialogs.toast(
                                          "Xóa dữ liệu thành công");
                                    } else {
                                      // logger.log("Xóa dữ liệu lỗi rồi: ${err.error}",
                                      //     name: "$runtimeType");
                                      AppDialogs.toast("Đã có lỗi xảy ra");
                                    }
                                  },
                                  child: Text(
                                      "Chỉ xóa dữ liệu (ảnh, video, file,...)",
                                      style: warningTextStyle),
                                ),
                              ),
                              SizedBox(
                                height: 60,
                                child: TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    var err = await context
                                        .read<ChatConversationBloc>()
                                        .deleteAllMessageOneSide(context
                                            .read<ChatDetailBloc>()
                                            .conversationId);
                                    if (err == null) {
                                      AppDialogs.toast(
                                          "Xóa nội dung một phía thành công");
                                      // TODO: Reload lại màn chat
                                    } else {
                                      // logger.log("Xóa dữ liệu lỗi rồi: ${err.error}",
                                      //     name: "$runtimeType");
                                      AppDialogs.toast("Đã có lỗi xảy ra");
                                    }
                                  },
                                  child: Text("Xóa tất cả nội dung từ một phía",
                                      style: warningTextStyle),
                                ),
                              ),
                              SizedBox(
                                height: 60,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Hủy"),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  textStyle: warningTextStyle),
              horizontalIconButton(
                  iconPath: Images.ic_roi_nhom,
                  text: AppLocalizations.of(context)!.outGroup,
                  onTap: () {
                    showDeleteMemberDialog(
                        ChatRepo().getAllChatMembersSync(
                          conversationId: context
                          .read<ChatDetailBloc>()
                          .conversationId)
                        .firstWhere((element) =>
                            element.id == AuthRepo().userInfo!.id));
                  },
                  textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.red)),
            ],
          ),
        );
      },
    );
  }

  /// Các nút có icon ở trên, text ở dưới
  Widget verticalIconButton({
    required String iconPath,
    required String text,
    required Function() onTap,
    TextStyle textStyle =
        const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ghostWhite,
          ),
          child: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              iconPath,
              fit: BoxFit.scaleDown,
              colorFilter:
                  ColorFilter.mode(AppColors.mineShaft, BlendMode.srcIn),
            ),
          ),
        ),
        SizedBoxExt.h8,
        Text(
          text,
          textAlign: TextAlign.center,
          style: textStyle.copyWith(color: context.theme.text3Color),
        ),
      ]),
    );
  }

  /// Các nút có icon bên trái, text bên phải
  Widget horizontalIconButton({
    required String iconPath,
    required String text,
    required Function() onTap,
    TextStyle textStyle =
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    // Một cái widget đi theo sau
    Widget trailing = const SizedBox(),
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              color: context.theme.text3Color,
            ),
            SizedBoxExt.w8,
            Expanded(
              child: Text(
                text,
                style: textStyle.copyWith(color: context.theme.text2Color),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  /// Note: Do hiện tại Trần Lâm chỉ để hiện ảnh preview ở màn chính,
  /// Do đó các loại link và file chưa cần đến
  /// Các ảnh bé bé để xem trước, nằm dưới mục "Ảnh, file, link đã gửi"
  Widget tinyFilePreview(SocketSentMessageModel e) {
    switch (e.type) {
      case MessageType.image:
        return drawerImagePreview(context, e);
      case MessageType.link:
      // TODO:
      case MessageType.file:
      // TODO:
      default:
        return const SizedBox();
    }
  }

  // Nút 3 chấm trong khoang "Ảnh, file, link đã gửi".
  // Xuất hiện khi có không dưới 4 file/ảnh trong CTC
  // Khi bấm thì ra màn ImageFileLinkDrawer
  Widget threeDotsToImageFileLinkScene() {
    return InkWell(
      onTap: () {
        context.read<GroupChatDrawerCubit>().emit(GroupChatDrawerScene.files);
      },
      child: Ink(
        decoration: const BoxDecoration(color: AppColors.E0Gray),
        child: Icon(
          Icons.more_horiz,
          color: context.theme.text3Color,
        ),
      ),
    );
  }

  bool checkIsAdmin(int userId) {
    return userId == getAdminId();
  }

  bool checkIsDeputyAdmin(int userId) {
    return getDeputyAdminIds().contains(userId);
  }

  bool checkIsModerator(int userId) {
    return checkIsAdmin(userId) || checkIsDeputyAdmin(userId);
  }

  int getAdminId() {
    return ChatRepo().getConversationModelSync(context.read<ChatDetailBloc>().conversationId)?.adminId??0;
  }

  List<int> getDeputyAdminIds() {
    return ChatRepo().getConversationModelSync(context.read<ChatDetailBloc>().conversationId)?.deputyAdminId??[];
  }

  // Copied from MemberModerationDialog with minimal fix
  void showDeleteMemberDialog(ChatMemberModel member) {
    var isSelf = member.id == AuthRepo().userInfo!.id;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ChatScreenSettingDialog(
          title: isSelf ? "Rời nhóm" : "Xóa thành viên",
          titleBarHeight: 50,
          size: const Size(300, 155),
          children: [
            SizedBoxExt.h20,
            Align(
              alignment: Alignment.center,
              child: Text(
                isSelf
                    ? "Bạn có chắc muốn rời nhóm?"
                    : "Xóa ${member.name} khỏi nhóm?",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBoxExt.h20,
            Row(
              children: [
                SizedBoxExt.w10,
                Expanded(
                  child: TextButton(
                      onPressed: () {
                        var chatDetailBloc = context.read<ChatDetailBloc>();
                        var convMembers =
                            ChatRepo().getAllChatMembersSync(conversationId: chatDetailBloc.conversationId).map((e) => e.id);

                        int? newAdmin = null;
                        // Nếu người rời nhóm là admin,
                        // chuyển quyền trưởng nhóm nếu nhóm vẫn còn người ở lại
                        if (checkIsAdmin(member.id) && convMembers.length > 1) {
                          newAdmin = convMembers.first;
                        }
                        context.read<ProfileCubit>().leaveGroup(
                            member, convMembers.toList(),
                            newAdminId: newAdmin);
                        ChatRepo().leaveGroupChat(chatDetailBloc.conversationId, userInfo?.id??0);
                        ChatRepo().deleteConversation(chatDetailBloc.conversationId);
                        ChatRepo().emitChatEvent(ChatEventOnDeleteConversation(chatDetailBloc.conversationId));
                        context
                            .read<AppLayoutCubit>()
                            .toMainLayout(AppMainPages.afterLoginChat);
                        Navigator.pop(dialogContext);
                      },
                      child: const Text(
                        "Đồng ý",
                        style: TextStyle(color: AppColors.red),
                      )),
                ),
                SizedBoxExt.w10,
                Expanded(
                  child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Quay lại")),
                ),
                SizedBoxExt.w10,
              ],
            ),
            SizedBoxExt.h10,
          ],
        );
      },
    );
  }
}

// Note 21/12/2023: context dùng để nhảy qua màn xem ảnh
Widget drawerImagePreview(BuildContext context, SocketSentMessageModel msg) {
// Dùng Stack để đặt hiệu ứng InkWell lên trên top
  return Stack(
    children: [
      SizedBox.expand(
        child: CachedNetworkImage(
          key: Key(msg.messageId),
          imageUrl: msg.files![0].fullFilePath,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, _, __) =>
              const ShimmerLoading(dimension: double.infinity),
          errorWidget: (context, uri, error) {
            logger.log(
              Uri.parse(uri),
              name: 'ErrorMessageImage',
              color: StrColor.red,
            );
            return  SizedBox.expand(
              child: Center(child: Text("ERROR",style: TextStyle(color: context.theme.text3Color),)),
            );
          },
        ),
      ),
      Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            // Khi bấm ảnh, hiện ra màn quẹt ảnh
            // Các ảnh được sắp xếp theo thứ tự thời gian gần nhất -> xa nhất
            onTap: () {
              var imageFiles = context
                  .read<ChatLibraryCubit>()
                  .allFiles[MessageType.image]!
                  .files
                  .toList();
              imageFiles.sort(((a, b) => b.createAt.compareTo(a.createAt)));
              var initIndex =
                  imageFiles.indexWhere((e) => e.messageId == msg.messageId);

              AppRouter.toPage(
                context,
                AppPages.imageSlide,
                arguments: {
                  ImageMessageSliderScreen.imagesArg: imageFiles,
                  ImageMessageSliderScreen.initIndexArg: initIndex,
                },
              );
            },
          ),
        ),
      ),
    ],
  );
}
