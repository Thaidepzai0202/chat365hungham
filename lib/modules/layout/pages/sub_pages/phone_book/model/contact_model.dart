class ContactModel {
  final String userName;
  final String avatarUser;
  final int isOnline;
  final String? fromWeb;
  final int createdAt;
  final int id365;
  final int type365;
  final String status;
  final int active;
  final int looker;
  final int statusEmotion;
  final DateTime lastActive;
  final int companyId;
  final int statusOnline;
  final int id;
  final String avatarUserSmall;
  final String linkAvatar;
  final String friendStatus;
  final String email;

  ContactModel({
    required this.userName,
    required this.avatarUser,
    required this.isOnline,
    required this.fromWeb,
    required this.createdAt,
    required this.id365,
    required this.type365,
    required this.status,
    required this.active,
    required this.looker,
    required this.statusEmotion,
    required this.lastActive,
    required this.companyId,
    required this.statusOnline,
    required this.id,
    required this.avatarUserSmall,
    required this.linkAvatar,
    required this.friendStatus,
    required this.email,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    userName: json["userName"]??'',
    avatarUser: json["avatarUser"]??'',
    isOnline: json["isOnline"]??0,
    fromWeb: json["fromWeb"]??'',
    createdAt: json["createdAt"]??0,
    id365: json["id365"]??0,
    type365: json["type365"]??0,
    status: (json["status"] == '' || json["status"] == null) ? '' : json["status"],
    active: json["active"]??0,
    looker: json["looker"]??0,
    statusEmotion: json["statusEmotion"]??0,
    lastActive: DateTime.parse(json["lastActive"]),
    companyId: json["companyId"]??0,
    statusOnline: json["statusOnline"]??0,
    id: json["id"]??0,
    avatarUserSmall: json["avatarUserSmall"]??'',
    linkAvatar: json["linkAvatar"]??'',
    friendStatus: json["friendStatus"]??'',
    email: json["email"]??'',
  );
}

