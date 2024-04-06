class GroupModel {
  int conversationId;
  int companyId;
  String conversationName;
  int unReader;
  int isGroup;
  int senderId;
  String pinMessageId;
  String messageId;
  String message;
  String messageType;
  DateTime createdAt;
  int messageDisplay;
  int countMessage;
  String typeGroup;
  int adminId;
  int shareGroupFromLink;
  dynamic memberList;
  int browseMember;
  int isFavorite;
  int notification;
  int isHidden;
  int deleteTime;
  int deleteType;
  int listMess;
  String linkAvatar;
  String avatarConversation;
  List<ListMember> listMember;
  dynamic listMessage;
  int countMem;
  int totalGroupMemebers;

  GroupModel({
    required this.conversationId,
    required this.companyId,
    required this.conversationName,
    required this.unReader,
    required this.isGroup,
    required this.senderId,
    required this.pinMessageId,
    required this.messageId,
    required this.message,
    required this.messageType,
    required this.createdAt,
    required this.messageDisplay,
    required this.countMessage,
    required this.typeGroup,
    required this.adminId,
    required this.shareGroupFromLink,
    required this.memberList,
    required this.browseMember,
    required this.isFavorite,
    required this.notification,
    required this.isHidden,
    required this.deleteTime,
    required this.deleteType,
    required this.listMess,
    required this.linkAvatar,
    required this.avatarConversation,
    required this.listMember,
    required this.listMessage,
    required this.countMem,
    required this.totalGroupMemebers,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
    conversationId: json["conversationId"] ?? 0,
    companyId: json["companyId"] ?? 0,
    conversationName: json["conversationName"] ?? '',
    unReader: json["unReader"] ?? 0,
    isGroup: json["isGroup"] ?? 0,
    senderId: json["senderId"] ?? 0,
    pinMessageId: json["pinMessageId"] ?? '',
    messageId: json["messageId"] ?? '',
    message: json["message"] ?? '' ,
    messageType: json["messageType"] ?? '',
    createdAt: DateTime.parse(json["createdAt"]),
    messageDisplay: json["messageDisplay"] ?? 0,
    countMessage: json["countMessage"] ?? 0,
    typeGroup: json["typeGroup"] ?? '',
    adminId: json["adminId"] ?? 0,
    shareGroupFromLink: json["shareGroupFromLink"] ?? 0,
    memberList: json["memberList"] ?? 0,
    browseMember: json["browseMember"]?? 0,
    isFavorite: json["isFavorite"] ?? 0,
    notification: json["notification"] ?? 0,
    isHidden: json["isHidden"] ?? 0,
    deleteTime: json["deleteTime"] ?? 0,
    deleteType: json["deleteType"] ?? 0,
    listMess: json["listMess"] ?? 0,
    linkAvatar: json["linkAvatar"] ?? '',
    avatarConversation: json["avatarConversation"]?? '',
    listMember: json["listMember"] == null ? [] : List<ListMember>.from(json["listMember"].map((x) => ListMember.fromJson(x))),
    listMessage: json["listMessage"] ?? null,
    countMem: json["countMem"] ?? 0,
    totalGroupMemebers: json["totalGroupMemebers"] ?? 0,
  );
}

class ListMember {
  int memberId;
  String conversationName;
  int unReader;
  int messageDisplay;
  int isHidden;
  int isFavorite;
  int notification;
  DateTime timeLastSeener;
  String lastMessageSeen;
  int deleteTime;
  int deleteType;
  List<dynamic> favoriteMessage;
  dynamic liveChat;

  ListMember({
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
  });

  factory ListMember.fromJson(Map<String, dynamic> json) => ListMember(
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
    favoriteMessage: json["favoriteMessage"] == null ? [] : List<dynamic>.from(json["favoriteMessage"].map((x) => x)),
    liveChat: json["liveChat"] ?? '',
  );

}
