import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/add_deputy_admin_dialog.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/add_new_group_member_dialog.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/chat_screen_dialog.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_cubit.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_state.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum MemberModerationDialogTab {
  allMembers,
  moderators,
  approve,
  remove,
}

/// Dialog màn Quản trị thành viên
/// Luồng: https://docs.google.com/document/d/1MpNoyyW8R1fWO0e4JKoielHS702S0p6x7ZsABgkdni4/edit
class MemberModerationDialog extends StatefulWidget {
  const MemberModerationDialog(
      {super.key,
      required this.mainContext,
      this.initialTab = MemberModerationDialogTab.allMembers});

  /// Context của luồng chính app, để có thể truy ra các bloc
  /// Context này cần chứa ChatDetailBloc của cuộc trò chuyện tương ứng
  final BuildContext mainContext;

  final MemberModerationDialogTab initialTab;

  @override
  State<MemberModerationDialog> createState() => _MemberModerationDialogState();
}

class _MemberModerationDialogState extends State<MemberModerationDialog> {
  late ValueNotifier<MemberModerationDialogTab> page =
      ValueNotifier(widget.initialTab);
  TextEditingController searchMember = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    searchMember.dispose();
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
    return ChatRepo().getConversationModelSync(widget.mainContext.read<ChatDetailBloc>().conversationId)?.adminId??0;
  }

  List<int> getDeputyAdminIds() {
    return ChatRepo().getConversationModelSync(widget.mainContext.read<ChatDetailBloc>().conversationId)?.deputyAdminId??[];
  }

  @override
  void initState() {
    super.initState();

    // Lấy danh sách chờ duyệt vào nhóm + yêu cầu xóa thành viên
    widget.mainContext.read<ProfileCubit>().getListRequestAdminAll();
  }

  @override
  Widget build(BuildContext context) {
    try {
      var chatDetBloc = widget.mainContext.read<ChatDetailBloc>();
  
      return Dialog(
        child: Container(
          width: 700,
          height: 600,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: BlocListener<ProfileCubit, ProfileState>(
            bloc: widget.mainContext.read<ProfileCubit>(),
            listener: (BuildContext context, ProfileState state) {
              if (state is RemoveMemberStateDone || state is AddMemberStateDone) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  _refreshMemberData();
                });
              }
            },
            child: Column(
              children: [
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
                    titleWidget,
                  ],
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: page,
                    builder: (context, value, child) {
                      return Column(
                        children: [
                          Row(
  
                              /// Các nút bấm ra một số mục
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                tabButton(
                                    desc: "Tất cả",
                                    onPressed: () {
                                      page.value =
                                          MemberModerationDialogTab.allMembers;
                                    },
                                    active: value ==
                                        MemberModerationDialogTab.allMembers,
                                    context: context),
                                tabButton(
                                    desc: "Quản trị viên",
                                    onPressed: () {
                                      page.value =
                                          MemberModerationDialogTab.moderators;
                                    },
                                    active: value ==
                                        MemberModerationDialogTab.moderators,
                                    context: context),
  
                                // TL 25/12/2023 Note: Tuấn Anh bảo bỏ hết mấy cái nhì nhằng kiểm duyệt đi
                                // if (checkIsModerator(
                                //     AuthRepo().userInfo!.id)) ...[
                                //   tabButton(
                                //       desc: "Duyệt thành viên",
                                //       onPressed: () {
                                //         page.value =
                                //             MemberModerationDialogTab.approve;
                                //       },
                                //       active: page.value ==
                                //           MemberModerationDialogTab.approve),
                                //   tabButton(
                                //       desc: "Xóa thành viên",
                                //       onPressed: () {
                                //         page.value =
                                //             MemberModerationDialogTab.remove;
                                //       },
                                //       active: page.value ==
                                //           MemberModerationDialogTab.remove),
                                // ],
                              ]),
                          // Phần nội dung của mục đó
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: page,
                              builder: (context, value, child) {
                                // TL 25/12/2023 Note: Tuấn Anh bảo bỏ hết mấy cái nhì nhằng kiểm duyệt đi
                                switch (value) {
                                  case MemberModerationDialogTab.allMembers:
                                    return allMemberTab();
  
                                  case MemberModerationDialogTab.moderators:
                                    return BlocBuilder<ChatDetailBloc,
                                            ChatDetailState>(
                                        bloc: widget.mainContext
                                            .read<ChatDetailBloc>(),
                                        builder: (context, state) {
                                          return moderatorTab();
                                        });
                                  // case MemberModerationDialogTab.approve:
                                  // case MemberModerationDialogTab.remove:
                                  default:
                                    return const SizedBox();
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    
    } catch (e, s) {
      logger.log("$e $s");
      return SizedBox();
    }
  }

  late var dialogExitButton = IconButton(
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

  late var titleWidget = SizedBox(
    height: 75,
    child: Row(
      children: [
        const SizedBox(
          width: 15,
        ),
        dialogExitButton,
        const SizedBox(
          width: 5,
        ),
        const Text(
          "Quản trị thành viên",
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  /// Nút "Thêm thành viên"
  late var addMemberButton = Align(
    alignment: Alignment.center,
    child: InkWell(
      onTap: () {
        // TODO: Khi bấm thì nhảy ra dialog thêm thành viên, giống dialog tạo nhóm
        showDialog(
            context: context,
            builder: (dialogContext) {
              return AddMemberToGroupChatDialog(
                  originContext: widget.mainContext);
            });
      },
      customBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Ink(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
            color: AppColors.primary,
            boxShadow: const [
              BoxShadow(offset: Offset(2, 2), color: AppColors.gray7777777)
            ],
            borderRadius: BorderRadius.circular(20)),
        child: const Align(
          alignment: Alignment.center,
          child: Text(
            "Thêm thành viên",
            style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ),
  );

  // Một bản ghi trong danh sách thành viên
  Widget memberEntry(ChatMemberModel memberInfo) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: DisplayAvatarOnly(
                avatar: memberInfo.avatar,
                userId: memberInfo.id,
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(memberInfo.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                if (getAdminId() == memberInfo.id)
                  const Text("Trưởng nhóm",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                if (getDeputyAdminIds().contains(memberInfo.id))
                  const Text("Phó nhóm",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget allMemberTab() {
    return BlocBuilder<ChatDetailBloc, ChatDetailState>(
        bloc: widget.mainContext.read<ChatDetailBloc>(),
        builder: (context, state) {
          return ValueListenableBuilder(
              valueListenable: searchMember,
              builder: (context, value, child) {
                var members = getSortedMemberListByRole();
                if (value.text.trim() != "") {
                  members.retainWhere(
                      (element) => element.name.contains(value.text));
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Chỉ hiện nút thêm thành viên với những người có quyền lực
                      if (checkIsModerator(AuthRepo().userId!)) ...[
                        SizedBoxExt.h8,
                        addMemberButton,
                        SizedBoxExt.h8,
                      ],
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(14, 0, 8, 8),
                      //   child: Text(
                      //       "Danh sách thành viên (${ChatRepo().getAllChatMembersSync(conversationId: widget.mainContext.read<ChatDetailBloc>().conversationId)})",
                      //       style: const TextStyle(
                      //           fontSize: 16, fontWeight: FontWeight.w500)),
                      // ),
                      SizedBox(
                        height: 35,
                        child: TextField(
                          controller: searchMember,
                          decoration: InputDecoration(
                            prefixIcon: SizedBox(
                              width: 10,
                              height: 10,
                              child: SvgPicture.asset(
                                Images.ic_tim_kiem,
                                fit: BoxFit.scaleDown,
                                colorFilter: const ColorFilter.mode(
                                    AppColors.E0Gray, BlendMode.modulate),
                              ),
                            ),
                            hintText: "Tìm kiếm thành viên",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onChanged: (value) {
                            searchMember.text = value;
                          },
                        ),
                      ),
                      SizedBoxExt.h8,
                      Expanded(
                          child: GridView.builder(
                        itemCount: members.length,
                        gridDelegate: gridViewGridDelegate,
                        itemBuilder: (context, index) {
                          var currentUserId = AuthRepo().userInfo!.id;
                          return Row(
                            children: [
                              Expanded(child: memberEntry(members[index])),

                              // Các trường hợp có thể xóa thành viên khỏi nhóm:
                              // 1. Là chính mình (rời nhóm)
                              // 2. Là trưởng nhóm, xóa tất
                              // 3. Là phó nhóm, chỉ xóa thành viên thường và rời nhóm
                              if (currentUserId == members[index].id ||
                                  checkIsAdmin(currentUserId) ||
                                  (checkIsModerator(currentUserId) &&
                                      !checkIsModerator(members[index].id)))
                                PopupMenuButton(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                        value: "Xóa",
                                        child: Text(
                                            currentUserId == members[index].id
                                                ? "Rời nhóm"
                                                : "Xóa",
                                            style: const TextStyle(
                                                color: AppColors.red))),
                                  ],
                                  onSelected: (String? value) {
                                    if (value == "Xóa") {
                                      showDeleteMemberDialog(members[index]);
                                    }
                                  },
                                ),
                            ],
                          );
                        },
                      )),
                    ],
                  ),
                );
              });
        });
  }

  Widget moderatorTab() {
    // Chỉ hiện trưởng, phó nhóm
    var displayedMembers = getSortedMemberListByRole();
    displayedMembers
        .retainWhere((e) => checkIsDeputyAdmin(e.id) || checkIsAdmin(e.id));

    var currentUserIsAdmin = checkIsAdmin(AuthRepo().userInfo!.id);
    List<Widget> listViewWidget = currentUserIsAdmin
        ?
        // Chỉ nhóm trưởng mới hiện nút Thêm phó nhóm, và xóa phó nhóm
        [
            addDeputyAdminButton(),
            ...displayedMembers.map((e) {
              return Row(
                children: [
                  Expanded(child: memberEntry(e)),
                  // Chỉ đặt menu xóa cho các phó nhóm để trưởng nhóm xóa
                  if (e.id != AuthRepo().userInfo!.id)
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: "Xóa",
                            child: Text("Xóa",
                                style: TextStyle(color: AppColors.red))),
                      ],
                      onSelected: (String? value) {
                        if (value == "Xóa") {
                          showDeleteDeputyDialog(e);
                        }
                      },
                    ),
                ],
              );
            }),
          ]
        // Phó nhóm thì chỉ hiện tên, ảnh những người chức sắc khác
        : [
            ...displayedMembers.map((e) => memberEntry(e)),
          ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              "Trưởng, phó nhóm có thể duyệt thành viên và thay đổi các cài đặt chung của nhóm",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBoxExt.h5,
          Expanded(
              child: GridView.builder(
            itemCount: listViewWidget.length,
            gridDelegate: gridViewGridDelegate,
            itemBuilder: (context, index) {
              return listViewWidget[index];
            },
          )),
        ],
      ),
    );
  }

  Widget addDeputyAdminButton() {
    return Ink(
      height: 70,
      child: InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (dialogContext) {
                return AddDeputyAdminDialog(
                  originContext: widget.mainContext,
                );
              });
        },
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                    10), // Chỉnh size ảnh bằng padding. Nếu không thì phải thêm Center()
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: AppColors.E0Gray,
                    borderRadius: BorderRadius.circular(30)),
                child: SvgPicture.asset(
                  Images.ic_them_pho_nhom,
                  fit: BoxFit.fitHeight,
                ),
              ),
              const Expanded(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Thêm phó nhóm",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  var gridViewGridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 4,
  );

  /// Sắp xếp theo thứ tự Trưởng nhóm > Phó nhóm > Dân thường
  List<ChatMemberModel> getSortedMemberListByRole() {
    var members = ChatRepo().getAllChatMembersSync(conversationId: widget.mainContext.read<ChatDetailBloc>().conversationId);
    // Trần Lâm 25/12/2023 note: Gãy thật
    // Một nhóm chắc chắn có admin. Thề.
    // Không thì code gãy tí vậy :v
    var adminIdx = getAdminId();

    ChatMemberModel? admin;
    if (adminIdx != -1) {
      admin = members.firstWhere((e) => e.id == adminIdx);
    } else {
      admin = null;
    }

    var deputyAdminIds = getDeputyAdminIds();
    var deputyAdmins = members.where((element) => deputyAdminIds.contains(element.id));

    // Find the lowlife members
    var remainingMembers = [...members];
    remainingMembers.remove(admin);
    remainingMembers.retainWhere((e) => !deputyAdmins.contains(e));

    List<ChatMemberModel> result = admin == null ? [] : [admin];
    result.addAll(deputyAdmins.toList());
    result.addAll(remainingMembers);

    return result;
  }

  /// Refresh thông tin sau khi thêm/xóa người thành công
  void _refreshMemberData() {
    widget.mainContext.read<ChatDetailBloc>().refreshConversationDetail();
  }

  void showDeleteMemberDialog(ChatMemberModel member) {
    var isSelf = member.id == AuthRepo().userInfo!.id;
    showDialog(
      context: context,
      builder: (context) {
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
                        var convMembers = ChatRepo()
                          .getAllChatMembersSync(conversationId: widget.mainContext.read<ChatDetailBloc>().conversationId)
                          .map((e) => e.id);

                        int? newAdmin = null;
                        // Nếu người rời nhóm là admin,
                        // chuyển quyền trưởng nhóm nếu nhóm vẫn còn người ở lại
                        if (checkIsAdmin(member.id) && convMembers.length > 1) {
                          newAdmin = convMembers.first;
                        }

                        widget.mainContext.read<ProfileCubit>().leaveGroup(
                            member, convMembers.toList(),
                            newAdminId: newAdmin);
                        if (isSelf) {
                          widget.mainContext
                              .read<AppLayoutCubit>()
                              .toMainLayout(AppMainPages.afterLoginChat);
                          // Pop thêm lần nữa để pop cả màn Quản lý nhóm
                          Navigator.pop(context);
                        }
                        Navigator.pop(context);
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

  void showDeleteDeputyDialog(ChatMemberModel member) {
    showDialog(
      context: context,
      builder: (context) {
        return ChatScreenSettingDialog(
          title: "Xóa phó nhóm",
          titleBarHeight: 50,
          size: const Size(300, 155),
          children: [
            SizedBoxExt.h20,
            Align(
              alignment: Alignment.center,
              child: Text(
                "Hủy chức phó nhóm của\n${member.name}?",
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
                        widget.mainContext
                            .read<ProfileCubit>()
                            .deleteDeputyAdmin([member.id]);
                        Navigator.pop(context);
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

Widget tabButton({
  required String desc,
  required Function() onPressed,
  required bool active,
  double underlineHeight = 5,
  required BuildContext context
}) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton(
          onPressed: onPressed,
          child: GradientText(desc, style: const TextStyle(fontSize: 16), gradient: context.theme.gradient,),
        ),
        Offstage(
          offstage: !active,
          child: Container(
            height: underlineHeight,
            decoration:  BoxDecoration(gradient: context!.theme.gradient,borderRadius: BorderRadius.circular(5)),
          ),
        ),
      ],
    ),
  );
}
