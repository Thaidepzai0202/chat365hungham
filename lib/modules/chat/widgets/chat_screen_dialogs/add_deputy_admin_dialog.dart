import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/chat_screen_dialog.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_cubit.dart';
import 'package:app_chat365_pc/modules/profile/repo/group_profile_repo.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Dialog thêm phó nhóm
class AddDeputyAdminDialog extends StatefulWidget {
  const AddDeputyAdminDialog({super.key, required this.originContext});

  /// The context where this dialog was called from
  /// Used to lookup cubits and blocs
  final BuildContext originContext;

  @override
  State<AddDeputyAdminDialog> createState() => _AddDeputyAdminDialogState();
}

class _AddDeputyAdminDialogState extends State<AddDeputyAdminDialog> {
  TextEditingController searchText = TextEditingController(text: "");

  List<IUserInfo> chosenPeople = [];

  /// Nếu true, biến nút "Thêm phó nhóm" thành vòng xoáy loading, ngăn gọi thêm API
  ValueNotifier<bool> isAddingDeputyAdmin = ValueNotifier(false);

  late final ProfileCubit profileCubit;

  @override
  void initState() {
    super.initState();

    profileCubit = widget.originContext.read<ProfileCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return ChatScreenSettingDialog(
      title: "Bổ nhiệm phó nhóm",
      size: const Size(400, 500),
      children: [
        SizedBoxExt.h10,
        // Thanh tìm kiếm
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: searchText,
            decoration: const InputDecoration(
              hintText: "Tìm kiếm",
              constraints: BoxConstraints.tightFor(height: 40),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onChanged: (value) {
              searchText.text = value;
            },
          ),
        ),

        // Hai cột chọn người dùng
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 1),
            child: Row(
              children: [
                // Danh sách liên hệ được đề xuất
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Được đề xuất",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: ValueListenableBuilder(
                            valueListenable: searchText,
                            builder: (context, value, child) {
                              var chatDetail = widget.originContext
                                  .read<ChatDetailBloc>()
                                  .detail!;

                              // Members eligible to be deputies are those commoners
                              // Who are neither deputy or admin
                              var allEligibleMembers = chatDetail.memberList;
                              allEligibleMembers.retainWhere((element) =>
                                  chatDetail.adminId != element.id &&
                                  !chatDetail.deputyAdminId
                                      .contains(element.id));

                              // Filter by search term
                              if (value.text.trim() != "") {
                                allEligibleMembers.retainWhere((element) =>
                                    element.name.contains(value.text));
                              }

                              // Lastly, filter out people who are already chosen
                              allEligibleMembers.removeWhere((element) =>
                                  chosenPeople.indexWhere(
                                      (chosen) => chosen.id == element.id) !=
                                  -1);

                              return ListView.builder(
                                  itemCount: allEligibleMembers.length,
                                  itemBuilder: (context, index) {
                                    // Build the person
                                    return contactEntryAddable(
                                        userInfo: allEligibleMembers[index],
                                        onTap: () {
                                          setState(() {
                                            chosenPeople
                                                .add(allEligibleMembers[index]);
                                          });
                                        });
                                  });
                            }),
                      ),
                    ],
                  ),
                ),

                // Danh sách liên hệ đã được chọn
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Đã chọn",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.grayF8,
                              borderRadius: BorderRadius.circular(10)),
                          child: ListView.builder(
                              itemCount: chosenPeople.length,
                              itemBuilder: (context, index) {
                                return contactEntryRemovable(
                                    userInfo: chosenPeople[index],
                                    onTap: () {
                                      setState(() {
                                        chosenPeople
                                            .remove(chosenPeople[index]);
                                      });
                                    });
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(
          thickness: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Nút hủy
            SizedBox(
              width: 86,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      side:
                          const BorderSide(color: AppColors.primary, width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                child: const Text("Hủy"),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            // Nút "Thêm thành viên"
            SizedBox(
              width: 180,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      chosenPeople.length > 0
                          ? AppColors.primary
                          : AppColors.gray7777777),
                  foregroundColor: MaterialStateProperty.all(AppColors.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                onPressed: () {
                  // Vô hiệu hóa thêm người khi không chọn ai
                  if (chosenPeople.length < 1) {
                    return;
                  }
                  // Khi đã bấm tạo nhóm một lần, thì những lần bấm sau không gọi API nữa
                  if (isAddingDeputyAdmin.value) {
                    return;
                  }

                  widget.originContext
                      .read<ProfileCubit>()
                      .addDeputyAdmin(chosenPeople.map((e) => e.id).toList());

                  isAddingDeputyAdmin.value = true;

                  Navigator.pop(context);
                },
                child: ValueListenableBuilder(
                    valueListenable: isAddingDeputyAdmin,
                    builder: (context, value, child) {
                      if (value) {
                        return SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: AppColors.white));
                      }
                      return Text(
                          "Thêm ${chosenPeople.length == 0 ? "" : "${chosenPeople.length} "}phó nhóm");
                    }),
              ),
            ),

            // Right padding for the buttons
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        // Bottom padding
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  // Các liên hệ mà người dùng có thể thêm vào chat nhóm
  Widget contactEntryAddable({
    required Function() onTap,
    required IUserInfo userInfo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DisplayAvatar(
              model: userInfo,
              isGroup: false,
            ),
            // CircleAvatar(
            //   foregroundImage: Image.asset(
            //     Images.img_non_avatar,
            //     width: 40,
            //     height: 40,
            //   ).image,
            // ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                userInfo.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Các liên hệ mà người dùng đã chọn để thêm vào chat nhóm
  Widget contactEntryRemovable({
    required Function() onTap,
    required IUserInfo userInfo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(alignment: Alignment.topRight, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: DisplayAvatar(
                  model: userInfo,
                  isGroup: false,
                ),
                // CircleAvatar(
                //   foregroundImage: Image.asset(
                //     Images.img_non_avatar,
                //     width: 40,
                //     height: 40,
                //   ).image,
                // ),
              ),
              SvgPicture.asset(Images.ic_x_red_bg),
            ]),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                userInfo.name,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
