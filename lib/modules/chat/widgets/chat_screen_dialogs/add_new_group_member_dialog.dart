import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/chat_screen_dialog.dart';
import 'package:app_chat365_pc/modules/contact/cubit/contact_list_cubit.dart';
import 'package:app_chat365_pc/modules/contact/cubit/contact_list_state.dart';
import 'package:app_chat365_pc/modules/contact/model/filter_contact_by.dart';
import 'package:app_chat365_pc/modules/contact/repo/contact_list_repo.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_cubit.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_state.dart';
import 'package:app_chat365_pc/modules/profile/repo/group_profile_repo.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Dialog tạo cuộc trò chuyện nhóm
/// Hiện lên khi chuột phải vào một ConversationItem, rồi chọn "Tạo cuộc trò chuyện nhóm với..."
/// TODO: Khi tạo xong thì conversation list phải focus vào cuôc trò chuyện tương ứng
class AddMemberToGroupChatDialog extends StatefulWidget {
  const AddMemberToGroupChatDialog({super.key, required this.originContext});

  /// The context where this dialog was called from
  /// Used to lookup cubits and blocs
  final BuildContext originContext;

  @override
  State<AddMemberToGroupChatDialog> createState() =>
      _AddMemberToGroupChatDialogState();
}

class _AddMemberToGroupChatDialogState
    extends State<AddMemberToGroupChatDialog> {
  TextEditingController searchText = TextEditingController(text: "");

  List<IUserInfo> suggestedPeople = [];
  List<IUserInfo> chosenPeople = [];

  /// Danh sách những người đã là thành viên hoặc chờ được duyệt.
  /// Để không bị thêm vào nhóm khi đã ở trong nhóm
  List<int> alreadyMemberOrWaitingForApprovalList = [];

  /// Nếu true, biến nút "Tạo" thành vòng xoay loading, và ngăn tạo nhóm
  ValueNotifier<bool> isAddingPeopleToGroup = ValueNotifier(false);

  late final ContactListCubit contactListCubit;

  late final ProfileCubit profileCubit;

  Iterable<int> getAllMemberIds() {
    return ChatRepo().getAllChatMembersSync(conversationId: widget.originContext.read<ChatDetailBloc>().conversationId).map((e) => e.id);
  }

  @override
  void initState() {
    super.initState();
    contactListCubit = ContactListCubit(
        ContactListRepo(AuthRepo().userId ?? 0,
            companyId:
                10013446), //AuthRepo().userInfo?.companyId ??), // TODO: Sửa thành com id của AuthRepo
        initFilter: null);

    profileCubit = widget.originContext.read<ProfileCubit>();

    // alreadyMemberOrWaitingForApprovalList =
    //    groupProfileRepo.getListRequestAdminAdd();
    // Make an initial search.
    // It should return a lot of contacts for suggestions
    contactListCubit.searchAll(searchText.text);

    alreadyMemberOrWaitingForApprovalList = [
      //...profileCubit.addRequests.map((e) => e.userId),
      ...getAllMemberIds()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      bloc: profileCubit,
      listener: (context, state) {
        if (state is ProfileStateLoadedMemberApproval) {
          // Những người bị loại khỏi màn thêm thành viên:
          // Đã là thành viên hoặc đang chờ duyệt
          alreadyMemberOrWaitingForApprovalList = [
            //...profileCubit.addRequests.map((e) => e.userId),
            ...getAllMemberIds()
          ];

          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {});
          });
        }
      },
      child: ChatScreenSettingDialog(
        title: "Thêm thành viên vào nhóm",
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
              onSubmitted: (value) {
                contactListCubit.searchAll(searchText.text);
              },
            ),
          ),

          // Hai cột chọn người dùng
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 1),
              child: BlocProvider<ContactListCubit>.value(
                value: contactListCubit,
                child: BlocBuilder<ContactListCubit, ContactListState>(
                    builder: (context, state) {
                  if (state is LoadSuccessState) {
                    suggestedPeople.clear();
                    // Get all the contacts from API
                    for (final filter in [
                      FilterContactsBy.none,
                      FilterContactsBy.allInCompany,
                      FilterContactsBy.myContacts,
                    ]) {
                      suggestedPeople.addAll(state.allContact[filter] ?? []);
                      suggestedPeople.sort((a, b) => a.name.compareTo(b.name));
                    }
                    suggestedPeople.retainWhere((element) =>
                        !alreadyMemberOrWaitingForApprovalList
                            .contains(element.id) &&
                        chosenPeople.indexWhere(
                                ((cpElement) => cpElement.id == element.id)) ==
                            -1);
                  }
                  return Row(
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
                              child: ListView.builder(
                                  itemCount: suggestedPeople.length,
                                  itemBuilder: (context, index) {
                                    // Build empty element if
                                    // this person is already chosen
                                    if (chosenPeople.indexWhere((e) =>
                                            e.id ==
                                            suggestedPeople[index].id) !=
                                        -1) {
                                      return const SizedBox();
                                    }
                                    // Build the person
                                    return contactEntryAddable(
                                        userInfo: suggestedPeople[index],
                                        onTap: () {
                                          setState(() {
                                            chosenPeople
                                                .add(suggestedPeople[index]);
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
                                    color: AppColors.transparentGrey,
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
                  );
                }),
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
                        side: const BorderSide(
                            color: AppColors.primary, width: 1),
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
                    if (chosenPeople.isEmpty) {
                      return;
                    }
                    // Khi đã bấm tạo nhóm một lần, thì những lần bấm sau không gọi API nữa
                    if (isAddingPeopleToGroup.value) {
                      return;
                    }

                    // TODO: Có khi giờ sửa hết để dùng đơn nhất ChatRepo().getChatItemModel() ý chứ
                    var chatDetailBloc =
                        widget.originContext.read<ChatDetailBloc>();

                    profileCubit.addMemberToGroup(
                        chosenPeople,
                        getAllMemberIds().toList(),
                        conversationName:
                            chatDetailBloc.conversationName.value!);

                    ChatClient().emit(ChatSocketEvent.newMemberAddedToGroup, [
                      chatDetailBloc.conversationId.toString(),
                      chosenPeople.map((e) => e.id.toString()).toList(),
                    ]);

                    Navigator.pop(context);
                  },
                  child: ValueListenableBuilder(
                      valueListenable: isAddingPeopleToGroup,
                      builder: (context, value, child) {
                        if (value) {
                          return SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: AppColors.white));
                        }
                        return Text(
                            "Thêm ${chosenPeople.length == 0 ? "" : "${chosenPeople.length} "}thành viên");
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
      ),
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
