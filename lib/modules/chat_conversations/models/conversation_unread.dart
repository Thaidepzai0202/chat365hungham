@Deprecated("Đây là ConversationModel. Dùng ConversationModel nhé.")
class ConversationUnRead {
  final int conversationId;
  final int isGroup;
  final String typeGroup;
  final String avatarConversation;
  final String linkAvatar;
  final int adminId;
  final List<dynamic> browseMemberList;
  final DateTime timeLastMessage;
  final DateTime timeLastChange;
  final int countMessage;
  final int browseMember;
  final String pinMessageId;
  final String messageId;
  final int unReader;
  final String message;
  final String messageType;
  final int messageDisplay;
  final int senderId;
  final int shareGroupFromLink;
  final int isFavorite;
  final int notification;
  final int isHidden;
  final int deleteTime;
  final int deleteType;
  final DateTime createAt;
  final DateTime timeLastSeener;
  final List<ListMember> listMember;
  final String conversationName;

  ConversationUnRead({
    required this.conversationId,
    required this.isGroup,
    required this.typeGroup,
    required this.avatarConversation,
    required this.linkAvatar,
    required this.adminId,
    required this.browseMemberList,
    required this.timeLastMessage,
    required this.timeLastChange,
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
    required this.createAt,
    required this.timeLastSeener,
    required this.listMember,
    required this.conversationName,
  });

  factory ConversationUnRead.fromJson(Map<String, dynamic> json) =>
      ConversationUnRead(
        conversationId: json["conversationId"] ?? 0,
        isGroup: json["isGroup"] ?? 0,
        typeGroup: json["typeGroup"] ?? '',
        avatarConversation: json["avatarConversation"] ?? '',
        linkAvatar: json["linkAvatar"] ?? '',
        adminId: json["adminId"] ?? 0,
        browseMemberList:
            json["browseMemberList"] == null || json["browseMemberList"] == []
                ? []
                : List<dynamic>.from(json["browseMemberList"].map((x) => x)),
        timeLastMessage: DateTime.parse(json["timeLastMessage"]),
        timeLastChange: DateTime.parse(json["timeLastChange"]),
        countMessage: json["countMessage"] ?? 0,
        browseMember: json["browseMember"] ?? 0,
        pinMessageId: json["pinMessageId"] ?? '',
        messageId: json["messageId"] ?? '',
        unReader: json["unReader"] ?? 0,
        message: json["message"] ?? '',
        messageType: json["messageType"] ?? '',
        messageDisplay: json["messageDisplay"] ?? 0,
        senderId: json["senderId"] ?? 0,
        shareGroupFromLink: json["shareGroupFromLink"] ?? 0,
        isFavorite: json["isFavorite"] ?? 0,
        notification: json["notification"] ?? 0,
        isHidden: json["isHidden"] ?? 0,
        deleteTime: json["deleteTime"] ?? 0,
        deleteType: json["deleteType"] ?? 0,
        createAt: DateTime.parse(json["createAt"]),
        timeLastSeener: DateTime.parse(json["timeLastSeener"]),
        listMember: json["listMember"] == null || json["listMember"] == []
            ? []
            : List<ListMember>.from(
                json["listMember"].map((x) => ListMember.fromJson(x))),
        conversationName: json["conversationName"] ?? '',
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
  final String fromWeb;
  final int createdAt;
  final String avatarUser;
  final String linkAvatar;
  final DateTime lastActive;
  final int isOnline;
  final int companyId;
  final int listMemberId;
  final String avatarUserSmall;
  final String friendStatus;
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
  final List<dynamic> favoriteMessage;
  final dynamic liveChat;
  final int seenMessage;

  ListMember({
    required this.id,
    required this.id365,
    required this.type365,
    this.email,
    required this.password,
    required this.phone,
    required this.userName,
    required this.fromWeb,
    required this.createdAt,
    required this.avatarUser,
    required this.linkAvatar,
    required this.lastActive,
    required this.isOnline,
    required this.companyId,
    required this.listMemberId,
    required this.avatarUserSmall,
    required this.friendStatus,
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
  });

  factory ListMember.fromJson(Map<String, dynamic> json) => ListMember(
        id: json["_id"] ?? 0,
        id365: json["id365"] ?? 0,
        type365: json["type365"] ?? 0,
        email: json["email"] ?? '',
        password: json["password"] ?? '',
        phone: json["phone"] ?? '',
        userName: json["userName"] ?? '',
        fromWeb: json["fromWeb"] ?? '',
        createdAt: json["createdAt"] ?? 0,
        avatarUser: json["avatarUser"] ?? '',
        linkAvatar: json["linkAvatar"] ?? '',
        lastActive: DateTime.parse(json["lastActive"]),
        isOnline: json["isOnline"] ?? 0,
        companyId: json["companyId"] ?? 0,
        listMemberId: json["id"] ?? 0,
        avatarUserSmall: json["avatarUserSmall"] ?? '',
        friendStatus: json["friendStatus"] ?? '',
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
            json["favoriteMessage"] == null || json["favoriteMessage"] == []
                ? []
                : List<dynamic>.from(json["favoriteMessage"].map((x) => x)),
        liveChat: json["liveChat"] ?? '',
        seenMessage: json["seenMessage"] ?? 0,
      );
}
