class UserContactModel {
  final int id;
  final String email;
  final String userName;
  final String status;
  final int active;
  final int isOnline;
  final int looker;
  final int statusEmotion;
  final DateTime? lastActive;
  final String avatarUserSmall;
  final String linkAvatar;
  final String avatarUser;
  final int companyId;
  final int type365;
  final String friendStatus;

  UserContactModel({
    required this.id,
    required this.email,
    required this.userName,
    required this.status,
    required this.active,
    required this.isOnline,
    required this.looker,
    required this.statusEmotion,
    required this.lastActive,
    required this.avatarUserSmall,
    required this.linkAvatar,
    required this.avatarUser,
    required this.companyId,
    required this.type365,
    required this.friendStatus,
  });

  factory UserContactModel.fromJson(Map<String, dynamic> json) => UserContactModel(
    id: json["id"]??0,
    email: json["email"]??'',
    userName: json["userName"]??'',
    status:json["status"]??'',
    active: json["active"]??0,
    isOnline: json["isOnline"]??0,
    looker: json["looker"]??0,
    statusEmotion: json["statusEmotion"]??0,
    lastActive: json["lastActive"] == null ? null : DateTime.parse(json["lastActive"]),
    avatarUserSmall: json["avatarUserSmall"]??'',
    linkAvatar: json["linkAvatar"]??'',
    avatarUser: json["avatarUser"]??'',
    companyId: json["companyId"]??0,
    type365: json["type365"]??0,
    friendStatus: json["friendStatus"]??'',
  );

}