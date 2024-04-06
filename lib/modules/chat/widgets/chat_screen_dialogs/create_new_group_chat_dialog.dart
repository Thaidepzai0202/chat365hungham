import 'dart:io';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/chat_screen_dialog.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/modules/contact/cubit/contact_list_cubit.dart';
import 'package:app_chat365_pc/modules/contact/cubit/contact_list_state.dart';
import 'package:app_chat365_pc/modules/contact/model/filter_contact_by.dart';
import 'package:app_chat365_pc/modules/contact/repo/contact_list_repo.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_cubit.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Dialog tạo cuộc trò chuyện nhóm
/// Hiện lên khi chuột phải vào một ConversationItem, rồi chọn "Tạo cuộc trò chuyện nhóm với..."
/// TODO: Khi tạo xong thì conversation list phải focus vào cuôc trò chuyện tương ứng
class CreateNewGroupChatDialog extends StatefulWidget {
  const CreateNewGroupChatDialog(
      {super.key, required this.originContext, this.initialUser});

  // The user that was pressed from ConversationItem to create group conversation
  final IUserInfo? initialUser;

  /// The context where this dialog was called from
  /// Used to lookup cubits and blocs
  final BuildContext originContext;

  @override
  State<CreateNewGroupChatDialog> createState() =>
      _CreateNewGroupChatDialogState();
}

class _CreateNewGroupChatDialogState extends State<CreateNewGroupChatDialog> {
  TextEditingController groupName = TextEditingController(text: "");
  TextEditingController searchText = TextEditingController(text: "");

  List<IUserInfo> suggestedPeople = [];
  List<IUserInfo> chosenPeople = [];
  String? imagePath;

  /// Nếu true, biến nút "Tạo" thành vòng xoay loading, và ngăn tạo nhóm
  ValueNotifier<bool> is_creating_group = ValueNotifier(false);

  late final ContactListCubit contactListCubit;

  @override
  void initState() {
    super.initState();
    chosenPeople = [if (widget.initialUser != null) widget.initialUser!];

    contactListCubit = ContactListCubit(
        ContactListRepo(AuthRepo().userId ?? 0,
            companyId:
                10013446), //AuthRepo().userInfo?.companyId ??), // TODO: Sửa thành com id của AuthRepo
        initFilter: null);

    // Make an initial search.
    // It should return a lot of contacts for suggestions
    contactListCubit.searchAll(searchText.text);
  }

  @override
  Widget build(BuildContext context) {
    return ChatScreenSettingDialog(
      title: AppLocalizations.of(context)!.createNewChat,
      size: const Size(400, 450),
      children: [
        Row(
          children: [
            IconButton(
              iconSize: 50,
              icon: imagePath == null
                  ? SvgPicture.asset(
                      Images.ic_upload_image,
                    )
                  : Image.file(File.fromUri(Uri(path: imagePath))),
              // TODO: Làm theme cho dialog, và kiểm tra định dạng ảnh
              onPressed: () async {
                imagePath = await FilesystemPicker.openDialog(
                    title: "Chọn ảnh nhóm",
                    rootDirectory: Directory.fromUri(Uri(path: "/")),
                    allowedExtensions: [".jpg"],
                    context: widget.originContext,
                    fsType: FilesystemType.file);
                setState(() {});
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: groupName,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.groupName,
                        constraints: BoxConstraints.tightFor(height: 32)),
                  ),
                  Container(
                    height: 1,
                    color: AppColors.E0Gray,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 8,
            ),
          ],
        ),
        // Thanh tìm kiếm
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: searchText,
            style: TextStyle(color: context.theme.text2Color),
            decoration: InputDecoration(
              fillColor: context.theme.backgroundOnForward,
              hintText: AppLocalizations.of(context)!.search,
              hintStyle: context.theme.hintStyle,
              constraints: const BoxConstraints.tightFor(height: 40),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
            onSubmitted: (value) {
              contactListCubit.searchAll(searchText.text);
            },
          ),
        ),

        // Hai cột chọn người dùng
        Container(
          height: 300 - 85,
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
                }
                return Row(
                  children: [
                    // Danh sách liên hệ được đề xuất
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.recommended,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: context.theme.text2Color),
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
                                          e.id == suggestedPeople[index].id) !=
                                      -1) {
                                    return const SizedBox();
                                  }
                                  // Build the person
                                  return contactEntryAddable(
                                      context: context,
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
                            Text(
                            AppLocalizations.of(context)!.selected,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14,color: context.theme.text2Color),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: context.theme.backgroundOnForward,
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
                      side:
                           BorderSide(color: context.theme.colorPirimaryNoDarkLight, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: GradientText(
                  AppLocalizations.of(context)!.cancel,
                  gradient: context.theme.gradient,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            // Nút "Tạo"
            SizedBox(
              width: 110,
              child: InkWell(


                onTap: () async {
                  // Vô hiệu hóa tạo nhóm khi không chọn ai
                  if (chosenPeople.isEmpty) {
                    return;
                  }

                  // Khi đã bấm tạo nhóm một lần, thì những lần bấm sau không gọi API nữa
                  if (is_creating_group.value) {
                    return;
                  }

                  is_creating_group.value = true;

                  var chatConversationBloc =
                      widget.originContext.read<ChatConversationBloc>();

                  var appLayoutCubit =
                      widget.originContext.read<AppLayoutCubit>();

                  var chatMembers = [AuthRepo().userInfo!, ...chosenPeople];
                  var convName = groupName.text.trim();
                  if (convName == "") {
                    convName = defaultGroupName(chatMembers);
                  }
                  var chatBloc = widget.originContext.read<ChatBloc>();
                  var conversationId = await chatBloc.createGroup(
                      selectedContacts: chatMembers,
                      conversationName: convName);

                  if (imagePath != null) {
                    try {
                      var file = File.fromUri(Uri(path: imagePath));
                      // logger.log("$runtimeType get group image: $file");
                      await ProfileCubit(conversationId, isGroup: true)
                          .changeAvatar(
                              idConversation: conversationId,
                              fileAvatar: file,
                              members: chatMembers.map((e) => e.id).toList());
                    } catch (e) {
                      // logger.log("$runtimeType ERR group image ${e.toString()}");
                    }
                  }

                  // TL 9/1/2024: App PC không còn luồng nhảy qua chatscreen từ ChatBloc nữa
                  //chatBloc.toChatScreenFromConversationId(conversationId);
                  var chatItemModel =
                      (await ChatRepo().getChatItemModel(conversationId))!;

                  // logger.log(
                  //     "$runtimeType new group chat name: ${chatItemModel!.conversationBasicInfo.name}");

                  var chatDetailBloc = ChatDetailBloc(
                      senderId: AuthRepo().userInfo!.id,
                      conversationId: conversationId,
                      isGroup: true,
                      unreadMessageCounterCubit: UnreadMessageCounterCubit(
                          conversationId: conversationId,
                          countUnreadMessage:
                              chatItemModel.numberOfUnreadMessage),
                      chatItemModel: chatItemModel);

                  chatDetailBloc.add(
                      const ChatDetailEventLoadConversationDetail(
                          loadMessage: true));
                  chatDetailBloc.conversationName =
                      ValueNotifier(chatItemModel.conversationBasicInfo.name);

                  /// Note: EventAddData để đảm bảo sinh ra typing detector bloc

                  chatConversationBloc
                      .add(ChatConversationEventAddData([chatItemModel]));

                  // var convBasicInfo = (await ChatRepo().getChatItemModel(conversationId))!.conversationBasicInfo;
                  // var uinfo = await UserInfoRepo().getUserInfo(userId);

                  appLayoutCubit
                      .toMainLayout(AppMainPages.chatScreen, providers: [
                    // TL 6/1/2024 note: Hình như không cần tạo UserInfoBloc cho CTC nhóm
                    //BlocProvider<UserInfoBloc>(create: (context) => UserInfoBloc(convBasicInfo, u)),
                    BlocProvider<TypingDetectorBloc>.value(
                        value:
                            TypingDetectorBloc(conversationId)),
                    BlocProvider<UnreadMessageCounterCubit>.value(
                      value: UnreadMessageCounterCubit(
                        conversationId: conversationId,
                        countUnreadMessage: 0,
                      ),
                    ),
                  ], agruments: {
                    'chatType': ChatType.GROUP,
                    'conversationId': conversationId,
                    'senderId': AuthRepo().userId!,
                    'name': chatItemModel.conversationBasicInfo.name,
                    'chatDetailBloc': chatDetailBloc,
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 20,height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: context.theme.gradient
                  ),
                  alignment: Alignment.center,
                  child: ValueListenableBuilder(
                      valueListenable: is_creating_group,
                      builder: (context, value, child) {
                        if (is_creating_group.value) {
                          return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: AppColors.white));
                        }
                        return  Text(AppLocalizations.of(context)!.create,style: TextStyle(fontSize: 14,color: AppColors.white,fontWeight: FontWeight.w500),);
                      }),
                ),
              ),
            ),

            // Right padding for the buttons
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        // Bottom padding

      ],
    );
  }

  // Các liên hệ mà người dùng có thể thêm vào chat nhóm
  Widget contactEntryAddable(
      {required Function() onTap,
      required IUserInfo userInfo,
      BuildContext? context}) {
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
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context!.theme.text2Color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Các liên hệ mà người dùng có thể thêm vào chat nhóm
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
                     TextStyle(fontSize: 14, fontWeight: FontWeight.w600,color: context.theme.text2Color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Theo mẫu: An, Bình và 3 người khác
  String defaultGroupName(List<IUserInfo> members) {
    return "${members[0].name}, ${members[1].name}${members.length == 2 ? "" : ", và ${members.length - 2} người khác"}";
  }
}
