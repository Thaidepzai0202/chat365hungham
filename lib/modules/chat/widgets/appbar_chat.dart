import 'dart:convert';

import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/network_cubit/network_cubit.dart';
import 'package:app_chat365_pc/common/blocs/chat_library_cubit/cubit/chat_library_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_state.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/components/display_image_with_status_badge.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/common/widgets/refresh_button.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/add_new_group_member_dialog.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/chat_screen_group_setting_dialog.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/member_moderation_dialog.dart';
import 'package:app_chat365_pc/modules/chat/widgets/icon_bt_title_chat.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/create_new_group_chat_dialog.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_cubit.dart';
import 'package:app_chat365_pc/modules/profile/repo/group_profile_repo.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/modules/chat/widgets/icon_bt_title_chat.dart';
import 'package:app_chat365_pc/router/app_router_helper.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ChatAppBar extends AppBar {
  ChatAppBar({
    super.key,
    required this.nameConversation,
    required this.userInfoBloc,
    required this.conversationId,
    this.isGroup = false,
    this.chatDetailBloc,
  });

  final int conversationId;
  final ValueNotifier<String?> nameConversation;
  final UserInfoBloc userInfoBloc;
  final bool isGroup;
  final ChatDetailBloc? chatDetailBloc;

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  @override
  Widget build(BuildContext context) {
    final userInfoRepo = context.read<UserInfoRepo>();
    DateTime lastTimeFetchData = AppConst.defaultFirstTimeFetchSuccess;

    return LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints) {
      return BlocListener<NetworkCubit, NetworkState>(
          listener: (context, networkState) {
        try {
          if (networkState.hasInternet &&
              DateTime.now().difference(lastTimeFetchData).inMinutes >= 5) {}
        } catch (e, s) {
          logger.logError(e, s);
        }
      }, child: BlocBuilder<UserInfoBloc, UserInfoState>(
        builder: (context, state) {
          var userInfo = state.userInfo;

          return ValueListenableBuilder(
            valueListenable: changeTheme,
            builder: (context, value, child) {
              return ValueListenableBuilder<String?>(
                valueListenable: widget.nameConversation,
                builder: (context, name, __) {
                  return ValueListenableBuilder(
                    valueListenable: changeTheme,
                    builder: (context, value, child) {
                      return Container(
                        height: 70,
                        width: AppDimens.widthPC,
                        color: context.theme.backgroundListChat,
                        child: Column(
                          children: [
                            Container(
                              height: 69,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBoxExt.w24,
                                  // Bấm vào ảnh đại diện thì ra màn hình thông tin
                                  InkWell(
                                    onTap: () {
                                      //print("$runtimeType Tapped");
                                      _showProfileDialog(context);
                                    },
                                    child: widget.isGroup
                                        ? DisplayAvatar(
                                            model: userInfo,
                                            isGroup: widget.isGroup,
                                            enable: false,
                                            size: 50,
                                          )
                                        : DisplayImageWithStatusBadge(
                                            isGroup:
                                                widget.chatDetailBloc!.isGroup,
                                            model: userInfo,
                                            userStatus: userInfo.userStatus,
                                            enable: false,
                                            size: 50,
                                          ),
                                  ),
                                  SizedBoxExt.w10,
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name ?? userInfo.name,
                                          style: AppTextStyles
                                              .nameChatConversation(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          children: [

                                            iconSub(Images.ic_image_outline,context),
                                            SizedBoxExt.w5,
                                            subTitleChat(AppLocalizations.of(context)?.library ??'',context),
                                            SizedBoxExt.w5,
                                            verticalDivider(),
                                            SizedBoxExt.w5,
                                            InkWell(
                                              onTap: () {
                                                checkSearchMess.value = true;
                                              },
                                              child: Row(
                                                children: [
                                                  iconSub(Images.ic_search_proposal,context),
                                                  SizedBoxExt.w5,
                                                  subTitleChat(AppLocalizations.of(context)?.search ??'',context)
                                                ],
                                              ),
                                            ),                                           
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  constraints.maxWidth < 500
                                      ? Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: IconEndTitleChat(
                                              icon: Images.dot_menu,
                                              callback: () {}),
                                        )
                                      // Bọc builder để xử lí logic thêm nút.
                                      // Cho logic thêm nút vào luôn bên trong Row() thì
                                      // nó chả bao giờ rebuild
                                      : Builder(
                                          key: Key(widget.isGroup.toString()),
                                          builder: (context) {
                                            var buttons = [
                                              IconEndTitleChat(
                                                  icon:
                                                      Images.ic_turn_off_AI_365,
                                                  callback: () {}),
                                              IconEndTitleChat(
                                                  icon: Images.ic_video_call,
                                                  callback: () async {
                                                    var otherMember =
                                                        (await getOtherPerson())!;

                                                    AppRouterHelper
                                                        .toCallScreen(
                                                      idRoom: context
                                                          .read<AuthRepo>()
                                                          .userId
                                                          .toString(),
                                                      idCaller: context
                                                          .read<AuthRepo>()
                                                          .userId
                                                          .toString(),
                                                      idCallee: otherMember.id
                                                          .toString(),
                                                      avatarAnother:
                                                          otherMember.avatar,
                                                      idConversation: widget
                                                          .chatDetailBloc!
                                                          .conversationId
                                                          .toString(),
                                                      checkCallee: false,
                                                      nameAnother:
                                                          otherMember.name,
                                                      checkCall: true,
                                                    );
                                                  }),
                                              IconEndTitleChat(
                                                  icon: Images.ic_call,
                                                  callback: () async {
                                                    var otherMember =
                                                        (await getOtherPerson())!;

                                                    AppRouterHelper
                                                        .toCallScreen(
                                                      idRoom: context
                                                          .read<AuthRepo>()
                                                          .userId
                                                          .toString(),
                                                      idCaller: context
                                                          .read<AuthRepo>()
                                                          .userId
                                                          .toString(),
                                                      idCallee: otherMember.id
                                                          .toString(),
                                                      avatarAnother:
                                                          otherMember.avatar,
                                                      idConversation: widget
                                                          .chatDetailBloc!
                                                          .conversationId
                                                          .toString(),
                                                      checkCallee: false,
                                                      nameAnother:
                                                          otherMember.name,
                                                      checkCall: false,
                                                    );
                                                  }),
                                              if (widget.isGroup) IconEndTitleChat(
                                                  icon: Images
                                                      .ic_fluent_people_add,
                                                  callback: () {
                                                   showDialog(
                                                    context: context,
                                                    builder: (dialogContext) {
                                                      return AddMemberToGroupChatDialog(
                                                          originContext: context);
                                                    });     
                                                  }),
                                              // TL 16/12/2023: Chỉ build nút thiết lập nhóm khi là nhóm
                                              if (widget.isGroup) ...[
                                                IconEndTitleChat(
                                                    icon: Images.ic_setting,
                                                    callback: () {
                                                      Scaffold.of(context)
                                                          .openEndDrawer();
                                                      context
                                                          .read<
                                                              ChatLibraryCubit>()
                                                          .loadLibrary(
                                                              messageType:
                                                                  MessageType
                                                                      .image);
                                                      context
                                                          .read<
                                                              ChatLibraryCubit>()
                                                          .loadLibrary(
                                                              messageType:
                                                                  MessageType
                                                                      .file);
                                                    }),
                                                SizedBoxExt.w5,
                                              ],
                                              SizedBoxExt.w15
                                            ];
                                            return Row(
                                              children: buttons,
                                            );
                                          })
                                ],
                              ),
                            ),
                            Container(height: 1, color: context.theme.colorLine)
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ));
    });
  }

  /// TL 23/2/2024: Giúp Minh Đức lấy người chat kia
  Future<ChatMemberModel?> getOtherPerson() async {
    int otherPersonId = (await ChatRepo()
            .getConversationModel(widget.chatDetailBloc!.conversationId))!
        .firstMemberNot(AuthRepo().userId!)!
        .id;

    return ChatRepo().getChatMember(
        conversationId: widget.chatDetailBloc!.conversationId,
        chatMemberId: otherPersonId);
  }

  Widget iconSub(String icon, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: SvgPicture.asset(
        icon,
        width: 16,
        height: 16,
        color: context.theme.colorTextNameProfile,
      ),
    );
  }

  subTitleChat(String text, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: context.theme.colorTextNameProfile),
    );
  }

  verticalDivider() {
    return Container(
      height: 15,
      width: 1,
      color: AppColors.black47,
    );
  }

  // vvvvvvvvvvvv Hiện thông tin CTC khi bấm vào ảnh vvvvvvvvvvvvvvv

  // @mainContext: Context chính của app, chứa cả tỷ cái bloc
  void _showProfileDialog(BuildContext mainContext) {
    if (widget.isGroup) {
      _showProfileDialogGroup(context);
    } else {
      _showProfileDialogSolo(context);
    }
  }

  /// Hàn hiển thị thông tin đối phương cho cuộc trò chuyện 2 người
  // TODO: Thêm chức năng các nút
  // @mainContext: Context chính của app, chứa cả tỷ cái bloc
  void _showProfileDialogSolo(BuildContext mainContext,
      {Size size = const Size(400, 450)}) {
    var chatItemMod = widget.chatDetailBloc!.chatItemModel!;

    var conversationName = ValueListenableBuilder<String?>(
        valueListenable: widget.chatDetailBloc!.conversationName,
        key: Key(widget.chatDetailBloc!.conversationName.value ?? ""),
        builder: (context, value, child) {
          return Text(
            value ?? "",
            key: Key(value ?? ""),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          );
        });

    showDialog(
      context: context,
      builder: (context) {
        var div = const Divider(
          height: 1,
        );

        return Dialog(
          key: Key(chatItemMod.conversationId.toString()),
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                // Phần Avatar đè lên khoảng xanh một chút
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      height: 75,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        // Buộc radius ở đây phải bé hơn radius của Container bên trên
                        // Không là sẽ lòi ra khoảng trắng khó hiểu
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const SizedBox(
                          height: 35,
                        ),
                        DisplayAvatar(
                          model: chatItemMod.conversationBasicInfo,
                          size: 80,
                          isGroup: true,
                        ),
                      ],
                    ),
                    Positioned(
                      left: 15,
                      top: 17,
                      child: dialogExitButton(context),
                    ),
                  ],
                ),

                // Tên CTC
                // Hai nút gọi điện, nhắn tin
                const SizedBox(height: 5),
                conversationName,
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _infoDialogCallButton,
                    const SizedBox(width: 10),
                    _infoDialogTextButton,
                  ],
                ),

                // Các tùy chọn còn lại của dialog
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 2),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        chatScreenIconPrefixedButton(
                          description: "Nhắn tin",
                          onPressed: () {},
                          iconPath: Images.ic_info_dialog_send_msg,
                        ),
                        div,
                        ValueListenableBuilder(
                            valueListenable:
                                widget.chatDetailBloc!.conversationName,
                            builder: (context, value, child) {
                              return chatScreenIconPrefixedButton(
                                description: "Tạo nhóm với ${value}",
                                onPressed: () async {
                                  var otherUser = (await ChatRepo()
                                          .getChatItemModel(widget
                                              .chatDetailBloc!.conversationId))!
                                      .firstOtherMember(AuthRepo().userId!);
                                  await showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        // Mở ra màn tạo chat nhóm, với người mình
                                        // đang chat cùng hiện tại đã có sẵn trong dialog
                                        return CreateNewGroupChatDialog(
                                          originContext: mainContext,
                                          initialUser: otherUser,
                                        );
                                      });
                                  Navigator.pop(context);
                                },
                                iconPath: Images.ic_info_dialog_create_group,
                              );
                            }),
                        div,
                        chatScreenIconPrefixedButton(
                          description: "Chia sẻ liên hệ",
                          onPressed: () {},
                          iconPath: Images.ic_info_dialog_share_contact,
                        ),
                        div,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text("Cài đặt cuộc trò chuyện"),
                          ),
                        ),
                        div,
                        chatScreenSwitchOption(
                          description: "Chặn xem bản tin của tôi",
                          onPressed: () {},
                          isOn: true,
                        ),
                        div,
                        chatScreenSwitchOption(
                          description: "Ẩn bản tin của người này",
                          onPressed: () {},
                          isOn: true,
                        ),
                        div,
                        chatScreenSwitchOption(
                          description: "Chặn tin nhắn",
                          onPressed: () {},
                          isOn: true,
                        ),
                        div,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Hủy lời mời",
                              style: TextStyle(color: AppColors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TODO: Thêm chức năng các nút
  void _showProfileDialogGroup(BuildContext mainContext,
      {Size size = const Size(400, 450)}) {
    var chatItemMod = widget.chatDetailBloc!.chatItemModel!;

    var div = Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: const Divider(
        thickness: 2,
      ),
    );
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          key: Key(chatItemMod.conversationId.toString()),
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                // Phần Avatar đè lên khoảng xanh một chút, tên cuộc trò chuyện,
                // hai nút gọi điện, nhắn tin
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Khoảng xanh
                    Container(
                      height: 75,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        // Buộc radius ở đây phải bé hơn radius của Container bên trên
                        // Không là sẽ lòi ra khoảng trắng khó hiểu
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const SizedBox(
                          height: 35,
                        ),

                        // Avatar cuộc trò chuyện
                        DisplayAvatar(
                          model: chatItemMod.conversationBasicInfo,
                          size: 80,
                          isGroup: true,
                        ),
                        const SizedBox(height: 5),

                        // Tên cuộc trò chuyện
                        ValueListenableBuilder<String?>(
                            valueListenable:
                                widget.chatDetailBloc!.conversationName,
                            key: Key(
                                widget.chatDetailBloc!.conversationName.value ??
                                    ""),
                            builder: (context, value, child) {
                              return Text(
                                value ?? "",
                                key: Key(value ?? ""),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              );
                            }),
                        const SizedBox(height: 5),
                        // Hai nút nhắn tin, gọi điện
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _infoDialogCallButton,
                            const SizedBox(width: 10),
                            _infoDialogTextButton,
                          ],
                        )
                      ],
                    ),
                    // Nút thoát màn dialog
                    Positioned(
                      left: 15,
                      top: 17,
                      child: dialogExitButton(context),
                    ),
                  ],
                ),
                // Các tùy chọn còn lại của dialog
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 2),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        div,
                        // Hiện thành viên và ảnh
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Thành viên (${chatItemMod.memberList.length})",
                              maxLines: 1,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              width: constraints.maxWidth,
                              height: 50,
                              // Ảnh của các thành viên trong nhóm
                              child: ListView.builder(
                                itemCount: chatItemMod.memberList.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) =>
                                    DisplayAvatarOnly(
                                  avatar: chatItemMod.memberList[index].avatar,
                                  userId: chatItemMod.memberList[index].id,
                                ),
                              ),
                            );
                          },
                        ),

                        div,

                        // TODO: Hiện các ảnh đã gửi gần nhất
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  Images.ic_info_dialog_gallery,
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Hình ảnh",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // TODO: Thêm row Ảnh ở đây
                        div,
                        // Màn quản lý nhóm
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return ChatScreenGroupSettingDialog(
                                      mainContext: mainContext, conversationId: widget.chatDetailBloc?.conversationId ??
                                      -1,);
                                },
                              );
                            },
                            child: const Text("Quản lý nhóm"),
                          ),
                        ),
                        div,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Rời nhóm",
                              style: TextStyle(color: AppColors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  final _infoDialogCallButton = TextButton(
    onPressed: () {},
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
      AppColors.E0Gray,
    )),
    child: const Text("Gọi điện"),
  );

  final _infoDialogTextButton = TextButton(
    onPressed: () {},
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
      AppColors.E0Gray,
    )),
    child: const Text("Nhắn tin"),
  );

  Widget dialogExitButton(context) => IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: SvgPicture.asset(
          Images.ic_back_propose,
          colorFilter: const ColorFilter.mode(
            AppColors.white,
            BlendMode.modulate,
          ),
        ),
      );

  // Những nút bấm ở dialog thông tin CTC mà có icon ở đầu
  Widget chatScreenIconPrefixedButton(
      {required String description,
      required Function() onPressed,
      required String iconPath}) {
    return SizedBox(
      height: 40,
      child: TextButton(
        style: ButtonStyle(
          alignment: Alignment.centerLeft,
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              fit: BoxFit.fill,
            ),
            const SizedBox(width: 5),
            Text(description),
          ],
        ),
      ),
    );
  }

  /// Trả về số người trong cuộc trò chuyện nếu là group chat,
  /// Hoặc trạng thái của người chat kia nếu là solo
  Widget statusOrMemberCount() {
    var chatItemModel = widget.chatDetailBloc!.chatItemModel!;
    var textStyle = const TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
    );
    if (chatItemModel.isGroup) {
      return Text(
        "${chatItemModel.memberList.length.toString()} người",
        style: textStyle,
      );
    }

    // Không phải group thì là solo. Sau này có thể có quảng cáo nữa
    // TODO: Bỏ fix cứng
    return Text(
      "Đang hoạt động",
      style: textStyle,
    );
  }
}

// Những nút bấm ở dialog thông tin CTC mà có thanh tròn tròn bật tắt
Widget chatScreenSwitchOption(
    {required String description,
    required Function() onPressed,
    required bool isOn}) {
  return SizedBox(
    height: 40,
    child: TextButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Expanded(child: Text(description)),
          SizedBox(
            width: 40,
            height: 40,
            child: SvgPicture.asset(
              isOn ? Images.switch_on_blue : Images.ic_info_dialog_switch_off,
            ),
          ),
        ],
      ),
    ),
  );
}
