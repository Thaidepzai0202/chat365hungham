import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';

class ConversationModel {
  int isGroup;

  /// TL 17/2/2024: Hiện tại chỉ biết typeGroup có thể là CTC bí mật
  String typeGroup;

  /// URL avatar. "" nếu không có.
  String avatarConversation;
  int adminId;

  /// Danh sách gì đây thì chịu. Ai biết thì comment phát
  List<ChatMemberModel> browseMemberList;
  DateTime timeLastChange;
  int conversationId;
  List<int> deputyAdminId;
  int? userCreate;
  String? userNameCreate;
  String linkAvatar;
  int countMessage;
  int browseMember;

  /// Id tin nhắn được ghim. "" nếu không có
  String pinMessageId;
  String messageId;
  int unReader;
  String message;
  MessageType messageType;
  int messageDisplay;

  /// Người gửi tin nhắn cuối
  int senderId;
  int shareGroupFromLink;

  /// Trạng thái CTC yêu thích
  bool isFavorite;

  /// Trạng thái bật/tắt thông báo
  bool notification;

  /// Trạng thái ẩn
  bool isHidden;
  int deleteTime;
  int deleteType;
  int? memberApproval;
  DateTime timeLastMessage;
  DateTime createAt;
  DateTime timeLastSeener;

  /// Danh sách thành viên
  List<ChatMemberModel> listMember;
  String conversationName;

  ConversationModel({
    required this.isGroup,
    required this.typeGroup,
    required this.avatarConversation,
    required this.adminId,
    required this.browseMemberList,
    required this.timeLastChange,
    required this.conversationId,
    required this.deputyAdminId,
    this.userCreate,
    this.userNameCreate,
    required this.linkAvatar,
    required this.countMessage,
    required this.browseMember,
    required this.pinMessageId,
    required this.messageId,
    required this.unReader,
    required this.message,
    required this.messageType,
    required this.messageDisplay,
    required this.senderId,
    required this.shareGroupFromLink,
    required this.isFavorite,
    required this.notification,
    required this.isHidden,
    required this.deleteTime,
    required this.deleteType,
    this.memberApproval,
    required this.timeLastMessage,
    required this.createAt,
    required this.timeLastSeener,
    required this.listMember,
    required this.conversationName,
    // required this.classInfor,
  });

  /// Dùng cái này để parse Json từ API
  factory ConversationModel.fromApiJson(Map<String, dynamic> json) =>
      ConversationModel(
        isGroup: json["isGroup"] ?? 0,
        typeGroup: json["typeGroup"] ?? '',
        avatarConversation: json["avatarConversation"] ?? '',
        adminId: json["adminId"] ?? 0,
        browseMemberList: json["browseMemberList"] == null
            ? []
            : List<ChatMemberModel>.from(json["browseMemberList"]
                .map((x) => x == null ? null : ChatMemberModel.fromMap(x))),
        timeLastChange: json["timeLastChange"] == null
            ? DateTime(0)
            : DateTime.parse(json["timeLastChange"]),
        conversationId: json["conversationId"] ?? 0,
        deputyAdminId: json["deputyAdminId"] == null
            ? []
            : List<int>.from(json["deputyAdminId"].map((x) => x)),
        userCreate: json["userCreate"] ?? 0,
        userNameCreate: json["userNameCreate"] ?? '',
        linkAvatar: json["linkAvatar"] ?? '',
        countMessage: json["countMessage"] ?? 0,
        browseMember: json["browseMember"] ?? 0,
        pinMessageId: json["pinMessageId"] ?? '',
        messageId: json["messageId"] ?? '',
        unReader: json["unReader"] ?? 0,
        message: json["message"] ?? '',
        messageType: MessageTypeExt.valueOf(
            json["messageType"] ?? MessageType.unknown.name),
        messageDisplay: json["messageDisplay"] ?? 0,
        senderId: json["senderId"] ?? 0,
        shareGroupFromLink: json["shareGroupFromLink"] ?? 0,
        isFavorite: json["isFavorite"] == 1,
        notification: json["notification"] == 1,
        isHidden: json["isHidden"] == 1,
        deleteTime: json["deleteTime"] ?? 0,
        deleteType: json["deleteType"] ?? 0,
        memberApproval: json["memberApproval"] ?? 0,
        timeLastMessage: DateTime.parse(json["timeLastMessage"]),
        createAt: DateTime.parse(json["createAt"]),
        timeLastSeener: json["timeLastSeener"] == null
            ? DateTime(0)
            : DateTime.parse(json["timeLastSeener"]),
        listMember: json["listMember"] == null
            ? []
            : List<ChatMemberModel>.from(
                json["listMember"].map((x) => ChatMemberModel.fromMap(x))),
        conversationName: json["conversationName"] ?? '',
        // classInfor: ClassInfor.fromJson(json["classInfor"]),
      );

  /// Dùng cái này để parse JSON từ Hive
  ///
  // TODO: Hình như sửa qua ChatMemberModel bị hơi sai sai. Có một số trường CMM không có thì phải
  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        isGroup: json["isGroup"] ?? 0,
        typeGroup: json["typeGroup"] ?? '',
        avatarConversation: json["avatarConversation"] ?? '',
        adminId: json["adminId"] ?? 0,
        browseMemberList: json["browseMemberList"] == null
            ? []
            : List<ChatMemberModel>.from(json["browseMemberList"]
                .map((x) => x == null ? null : ChatMemberModel.fromJson(x))),
        timeLastChange: json["timeLastChange"] == null
            ? DateTime(0)
            : DateTime.parse(json["timeLastChange"]),
        conversationId: json["conversationId"] ?? 0,
        deputyAdminId: json["deputyAdminId"] == null
            ? []
            : List<int>.from(json["deputyAdminId"].map((x) => x)),
        userCreate: json["userCreate"] ?? 0,
        userNameCreate: json["userNameCreate"] ?? '',
        linkAvatar: json["linkAvatar"] ?? '',
        countMessage: json["countMessage"] ?? 0,
        browseMember: json["browseMember"] ?? 0,
        pinMessageId: json["pinMessageId"] ?? '',
        messageId: json["messageId"] ?? '',
        unReader: json["unReader"] ?? 0,
        message: json["message"] ?? '',
        messageType: MessageTypeExt.valueOf(
            json["messageType"] ?? MessageType.unknown.name),
        messageDisplay: json["messageDisplay"] ?? 0,
        senderId: json["senderId"] ?? 0,
        shareGroupFromLink: json["shareGroupFromLink"] ?? 0,
        isFavorite: json["isFavorite"],
        notification: json["notification"],
        isHidden: json["isHidden"],
        deleteTime: json["deleteTime"] ?? 0,
        deleteType: json["deleteType"] ?? 0,
        memberApproval: json["memberApproval"] ?? 0,
        timeLastMessage: DateTime.parse(json["timeLastMessage"]),
        createAt: DateTime.parse(json["createAt"]),
        timeLastSeener: json["timeLastSeener"] == null
            ? DateTime(0)
            : DateTime.parse(json["timeLastSeener"]),
        listMember: json["listMember"] == null
            ? []
            : List<ChatMemberModel>.from(
                json["listMember"].map((x) => ChatMemberModel.fromJson(x))),
        conversationName: json["conversationName"] ?? '',
        // classInfor: ClassInfor.fromJson(json["classInfor"]),
      );

  Map<String, dynamic> toJson() => {
        "isGroup": isGroup,
        "typeGroup": typeGroup,
        "avatarConversation": avatarConversation,
        "adminId": adminId,
        "browseMemberList": browseMemberList.map((e) => e.toJson()).toList(),
        "timeLastChange": timeLastChange.toIso8601String(),
        "conversationId": conversationId,
        "deputyAdminId": deputyAdminId,
        "userCreate": userCreate,
        "userNameCreate": userNameCreate,
        "linkAvatar": linkAvatar,
        "countMessage": countMessage,
        "browseMember": browseMember,
        "pinMessageId": pinMessageId,
        "messageId": messageId,
        "unReader": unReader,
        "message": message,
        "messageType": messageType.name,
        "messageDisplay": messageDisplay,
        "senderId": senderId,
        "shareGroupFromLink": shareGroupFromLink,
        "isFavorite": isFavorite,
        "notification": notification,
        "isHidden": isHidden,
        "deleteTime": deleteTime,
        "deleteType": deleteType,
        "memberApproval": memberApproval,
        "timeLastMessage": timeLastMessage.toIso8601String(),
        "createAt": createAt.toIso8601String(),
        "timeLastSeener": timeLastSeener.toIso8601String(),
        "listMember": listMember.map((e) => e.toJson()).toList(),
        "conversationName": conversationName,
      };

  /// TL 16/2/2024: Dùng để convert từ model cũ sang model api mới
  factory ConversationModel.fromChatItemModel(ChatItemModel c) {
    return ConversationModel(
        isGroup: c.isGroup ? 1 : 0,
        typeGroup: c.typeGroup,
        avatarConversation: c.conversationBasicInfo.avatar ?? "",
        adminId: c.adminId,
        browseMemberList: c.browerMemberList?.toList() ?? [],

        /// TL 16/2/2024: Không chắc cái này
        timeLastChange:
            c.conversationBasicInfo.lastConversationMessageTime ?? DateTime(0),
        conversationId: c.conversationId,
        deputyAdminId: c.deputyAdminId,
        linkAvatar: c.conversationBasicInfo.avatar ?? "",
        countMessage: c.totalNumberOfMessages,

        /// TL 16/2/2024: Chịu đấy. Ai biết thì điền hộ phát
        browseMember: -1,
        pinMessageId: c.conversationBasicInfo.pinMessageId ?? "",
        unReader: c.numberOfUnreadMessage,

        /// TL 16/2/2024: Chịu đấy. Ai biết thì điền hộ phát
        messageId: "",
        message: c.message,
        messageType: c.messageType ?? MessageType.unknown,
        messageDisplay: c.messageDisplay,
        senderId: c.senderId,

        /// TL 16/2/2024: Chịu đấy. Ai biết thì điền hộ phát
        shareGroupFromLink: -1,
        isFavorite: c.isFavorite,
        notification: c.isNotification,
        isHidden: c.isHidden,

        /// TL 16/2/2024: Nếu c.deleteTime null thì tương đương gì?
        deleteTime: c.deleteTime ?? -1,

        /// TL 16/2/2024: Chịu đấy. Ai biết thì điền hộ phát
        deleteType: -1,
        timeLastMessage:
            c.conversationBasicInfo.lastConversationMessageTime ?? DateTime(0),
        createAt: c.createAt,

        /// TL 16/2/2024: Chịu đấy. Ai biết thì điền hộ phát
        timeLastSeener: DateTime(0),
        listMember: c.memberList,
        conversationName: c.conversationBasicInfo.name);
  }

  /// TL 2/1/2024
  /// Dùng để port backward lại, đảm bảo code cũ chạy ngon
  /// TODO: Còn nhiều trường chưa kiểm tra hết
  ChatItemModel toChatItemModel() {
    return ChatItemModel(
      conversationId: conversationId,
      numberOfUnreadMessage: unReader, // TODO: Đoán là vậy
      isGroup: isGroup == 1,
      senderId: senderId,
      message: message,
      messageType: messageType,
      totalNumberOfMessages: countMessage, // TODO: Đoán là vậy
      messageDisplay: messageDisplay,
      typeGroup: typeGroup,
      adminId: adminId,
      memberList: listMember,
      isFavorite: isFavorite,
      isHidden: isHidden,
      createAt: createAt,
      conversationBasicInfo: ConversationBasicInfo(
        conversationId: conversationId,
        isGroup: isGroup == 1,
        userId: isGroup == 1
            ? conversationId
            : firstMemberNot(AuthRepo().userInfo!.id)?.id ?? -1,
        // TODO: TL 2/1/2024: userId nào đây? Gắn 0 vào bừa đấy
        name: conversationName,
        pinMessageId: pinMessageId,
        groupLastSenderId: senderId,
        lastConversationMessageTime: timeLastMessage,
        lastConversationMessage: message,
        countUnreadMessage: unReader, // TODO: Đoán vậy
        totalGroupMemebers: isGroup == 1 ? listMember.length : null,
        lastMessasgeId: messageId,
        id365: null, // TODO
        avatar: avatarConversation,
        userStatus: UserStatus.none, // TODO
        lastActive: null, // TODO
        companyId: null, // TODO
        email: null, // TODO
        friendStatus: null, // TODO
        fromWeb: null, // TODO
      ),
      isNotification: notification,
      deputyAdminId: deputyAdminId,
      adminName: userNameCreate, // TODO: Đoán là vậy
      browerMemberList: browseMemberList,
      status: "", // TODO
      lastMessages: [], // TODO
      deleteTime: deleteTime,
      memberApproval: memberApproval,
    );
  }

  /// Trả về thành viên đầu tiên có userId khác @id
  ChatMemberModel? firstMemberNot(int id) {
    var otherPersonIdx = listMember.indexWhere((element) => element.id != id);
    return otherPersonIdx == -1 ? null : listMember[otherPersonIdx];
  }
}

/// NOTE: Bên dưới là code cũ anh Việt Hùng. Những class này đã có class tương đương
/// ở code cũ rồi, mình dùng những class cũ ấy
class BrowseMemberList {
  final UserMember userMember;
  final int memberAddId;

  BrowseMemberList({
    required this.userMember,
    required this.memberAddId,
  });
  factory BrowseMemberList.fromJson(Map<String, dynamic> json) =>
      BrowseMemberList(
        userMember: UserMember.fromJson(json["userMember"]),
        memberAddId: json["memberAddId"] ?? 0,
      );
}

class UserMember {
  final int id;
  final String userName;
  final String avatarUser;
  final String linkAvatar;
  final DateTime lastActive;
  final int isOnline;
  UserMember({
    required this.id,
    required this.userName,
    required this.avatarUser,
    required this.linkAvatar,
    required this.lastActive,
    required this.isOnline,
  });
  factory UserMember.fromJson(Map<String, dynamic> json) => UserMember(
        id: json["_id"] ?? 0,
        userName: json["userName"] ?? '',
        avatarUser: json["avatarUser"] ?? '',
        linkAvatar: json["linkAvatar"] ?? '',
        lastActive: DateTime.parse(json["lastActive"]),
        isOnline: json["isOnline"] ?? 0,
      );
}

class ListMember {
  final int id;
  final int id365;
  final int type365;
  final String? email;
  final String password;
  final String? phone;
  final String userName;
  final String avatarUser;
  final String linkAvatar;
  final DateTime lastActive;
  final int isOnline;
  final int companyId;
  final int idTimViec;
  final String? fromWeb;
  final int createdAt;
  final int listMemberId;
  final String avatarUserSmall;
  final FriendStatus friendStatus;
  final DateTime timeLastSeenerApp;
  final int memberId;
  final String conversationName;
  final int unReader;
  final int messageDisplay;
  final int isHidden;
  final int isFavorite;
  final int notification;
  final DateTime timeLastSeener;
  final String lastMessageSeen;
  final int deleteTime;
  final int deleteType;
  final List<String> favoriteMessage;
  final dynamic liveChat;
  final int seenMessage;
  final int statusOnline;

  ListMember({
    required this.id,
    required this.id365,
    required this.type365,
    this.email,
    required this.password,
    required this.phone,
    required this.userName,
    required this.avatarUser,
    required this.linkAvatar,
    required this.lastActive,
    required this.isOnline,
    required this.companyId,
    required this.idTimViec,
    required this.fromWeb,
    required this.createdAt,
    required this.listMemberId,
    required this.avatarUserSmall,
    required this.friendStatus,
    required this.timeLastSeenerApp,
    required this.memberId,
    required this.conversationName,
    required this.unReader,
    required this.messageDisplay,
    required this.isHidden,
    required this.isFavorite,
    required this.notification,
    required this.timeLastSeener,
    required this.lastMessageSeen,
    required this.deleteTime,
    required this.deleteType,
    required this.favoriteMessage,
    required this.liveChat,
    required this.seenMessage,
    required this.statusOnline,
  });
  factory ListMember.fromJson(Map<String, dynamic> json) => ListMember(
        id: json["_id"] ?? 0,
        id365: json["id365"] ?? 0,
        type365: json["type365"] ?? 0,
        email: json["email"] ?? '',
        password: json["password"] ?? '',
        phone: json["phone"] ?? '',
        userName: json["userName"] ?? '',
        avatarUser: json["avatarUser"] ?? '',
        linkAvatar: json["linkAvatar"] ?? '',
        lastActive: DateTime.parse(json["lastActive"]),
        isOnline: json["isOnline"] ?? 0,
        companyId: json["companyId"] ?? 0,
        idTimViec: json["idTimViec"] ?? 0,
        fromWeb: json["fromWeb"] ?? '',
        createdAt: json["createdAt"] ?? 0,
        listMemberId: json["id"] ?? 0,
        avatarUserSmall: json["avatarUserSmall"] ?? '',
        friendStatus: FriendStatusExt.fromValue(json["friendStatus"])!,
        timeLastSeenerApp: DateTime.parse(json["timeLastSeenerApp"]),
        memberId: json["memberId"] ?? 0,
        conversationName: json["conversationName"] ?? '',
        unReader: json["unReader"] ?? 0,
        messageDisplay: json["messageDisplay"] ?? 0,
        isHidden: json["isHidden"] ?? 0,
        isFavorite: json["isFavorite"] ?? 0,
        notification: json["notification"] ?? 0,
        timeLastSeener: DateTime.parse(json["timeLastSeener"]),
        lastMessageSeen: json["lastMessageSeen"] ?? '',
        deleteTime: json["deleteTime"] ?? 0,
        deleteType: json["deleteType"] ?? 0,
        favoriteMessage:
            List<String>.from(json["favoriteMessage"].map((x) => x)),
        liveChat: json["liveChat"] ?? null,
        seenMessage: json["seenMessage"] ?? 0,
        statusOnline: json["statusOnline"] ?? 0,
      );
}

enum FromWeb { CC365, CHAT365, QUANLYCHUNG, TIMVIEC365, TIMVIEC365_VN, TV365 }

final fromWebValues = EnumValues({
  "cc365": FromWeb.CC365,
  "chat365": FromWeb.CHAT365,
  "quanlychung": FromWeb.QUANLYCHUNG,
  "timviec365": FromWeb.TIMVIEC365,
  "timviec365.vn": FromWeb.TIMVIEC365_VN,
  "tv365": FromWeb.TV365
});

enum TypeGroup { MORDERATE, NOMARL, NORMAL }

final typeGroupValues = EnumValues({
  "Morderate": TypeGroup.MORDERATE,
  "Nomarl": TypeGroup.NOMARL,
  "Normal": TypeGroup.NORMAL
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);
}
