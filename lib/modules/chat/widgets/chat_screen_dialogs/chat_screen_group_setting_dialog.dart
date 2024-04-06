import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/modules/chat/widgets/appbar_chat.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/chat_screen_dialog.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/member_moderation_dialog.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/profile/repo/group_profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Màn dialog được gọi ra khi bấm Avatar trò chuyện nhóm -> Quản lý nhóm
class ChatScreenGroupSettingDialog extends StatefulWidget {
  /// Context chính của app mà có cả tỷ bloc để read()
  final BuildContext mainContext;
  final int conversationId;
  /// Kích cỡ màn dialog
  final Size size;

  const ChatScreenGroupSettingDialog(
      {super.key, required this.mainContext, this.size = const Size(400, 450),required this.conversationId});

  @override
  State<ChatScreenGroupSettingDialog> createState() =>
      _ChatScreenGroupSettingDialogState();
}

class _ChatScreenGroupSettingDialogState
    extends State<ChatScreenGroupSettingDialog> {
  bool memberApprovalMode = false;
  bool markAdminsMessages = false;
  bool allowNewMemberReadLatestMessages = false;
  bool allowJoinViaLink = false;
  bool allowNotification = false;
  bool addToFavourite = false;

  late GroupProfileRepo groupProfileRepo;
  late ChatDetailBloc chatDetailBloc;
  late ChatConversationBloc chatConversationBloc;

  @override
  void initState() {
    super.initState();
    _asyncInitState();

    ChatRepo().stream.listen((event) {
      if (event is ChatEventOnChangeFavoriteStatus &&
          event.conversationId == widget.conversationId) {
        setState(() {
          addToFavourite = event.isChangeToFavorite;
        });
      }
    });
  }

  void _asyncInitState() async {
    groupProfileRepo = widget.mainContext.read<GroupProfileRepo>();
    chatDetailBloc = widget.mainContext.read<ChatDetailBloc>();
    chatConversationBloc = widget.mainContext.read<ChatConversationBloc>();

    memberApprovalMode = (await groupProfileRepo.getMemberApproval()) == 1;
    addToFavourite = chatConversationBloc.favoriteConversations
        .containsKey(chatDetailBloc.conversationId);

    // TODO: Sửa trạng thái thông báo
    // chatConversationBloc.changeNotificationStatus(conversationId: conversationId, userId: userId, membersIds: membersIds)
    //chatConversationBloc.changeNotificationStatus(conversationId: conversationId, userId: userId, membersIds: membersIds)

    // TODO: Sửa trạng thái yêu thích
    // (await chatConversationBloc.changeFavoriteConversation(chatDetailBloc.conversationId, favorite: favorite));

    // TODO:
    //markAdminsMessages = await groupProfileRepo.get
    //allowNotification =
    //allowNewMemberReadLatestMessages = (await groupProfileRepo.get)
    //allowJoinViaLink = (await groupProfileRepo.get)
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChatScreenSettingDialog(
      title: "Thông tin nhóm",
      size: widget.size,
      children: [
        // TL Note 25/12/2023: Tuấn Anh bảo bỏ chức năng phê duyệt đi
        // chatScreenSwitchOption(
        //     description: "Chế độ phê duyệt thành viên mới",
        //     onPressed: () async {
        //       // Nếu gọi API không ra lỗi gì, thì lật trạng thái
        //       memberApprovalMode =
        //           (await groupProfileRepo.updateMemberApproval()) == null
        //               ? !memberApprovalMode
        //               : memberApprovalMode;
        //       setState(() {});
        //     },
        //     isOn: memberApprovalMode),
        chatScreenSwitchOption(
            description: "Đánh dấu tin nhắn từ trưởng, phó nhóm",
            onPressed: () {},
            isOn: markAdminsMessages),
        chatScreenSwitchOption(
            description: "Cho phép thành viên mới đọc tin nhắn gần nhất",
            onPressed: () {},
            isOn: allowNewMemberReadLatestMessages),
        chatScreenSwitchOption(
            description: "Cho phép dùng link tham gia nhóm",
            onPressed: () {},
            isOn: allowJoinViaLink),
        chatScreenSwitchOption(
            description: "Thông báo",
            onPressed: () {},
            isOn: allowNotification),
        chatScreenSwitchOption(
            description:
                "${addToFavourite ? "Xóa khỏi" : "Thêm vào"} mục yêu thích",
            onPressed: () async {
              ChatRepo().changeFavoriteStatus(
                  conversationId: chatDetailBloc.conversationId,
                  favorite: !addToFavourite);
            },
            isOn: addToFavourite),
        SizedBox(
          height: 40,
          child: TextButton(
            style: ButtonStyle(alignment: Alignment.centerLeft),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return setupAutoDeleteMessage();
                  });
            },
            child: const Text("Cài đặt tin nhắn tự xóa"),
          ),
        ),

        //chatScreenIconPrefixedButton(description: "Chặn khỏi nhóm", onPressed: (){}, iconPath: iconPath),

        // Màn quản trị thành viên
        SizedBox(
          height: 40,
          child: TextButton(
            style: const ButtonStyle(alignment: Alignment.centerLeft),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return MemberModerationDialog(
                        mainContext: widget.mainContext);
                  });
            },
            child: const Text(
              "Quản trị thành viên",
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ],
    );
  }

  // TODO: Ghép API để sửa cái này
  // TODO: ApiPath.setupDeleteTime
  Widget setupAutoDeleteMessage() {
    return ChatScreenSettingDialog(
      title: "Cài đặt tin nhắn tự xóa",
      children: [
        chatScreenCheckboxOption(
            description: "Không bao giờ", onPressed: () {}, checked: false),
        chatScreenCheckboxOption(
            description: "10 giây", onPressed: () {}, checked: true),
        chatScreenCheckboxOption(
            description: "1 phút", onPressed: () {}, checked: false),
        chatScreenCheckboxOption(
            description: "1 giờ", onPressed: () {}, checked: false),
        chatScreenCheckboxOption(
            description: "1 ngày", onPressed: () {}, checked: true),
        chatScreenCheckboxOption(
            description: "1 tuần", onPressed: () {}, checked: false),
        chatScreenCheckboxOption(
            description: "30 ngày", onPressed: () {}, checked: true),
      ],
    );
  }

  // TODO: Mỗi lần bấm thì gọi API hay là làm gì đó
  Widget chatScreenCheckboxOption(
      {required String description,
      required Function() onPressed,
      required bool checked}) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        children: [
          SvgPicture.asset(
            checked
                ? Images.ic_info_dialog_checkbox_on
                : Images.ic_info_dialog_checkbox_off,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 5),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}
