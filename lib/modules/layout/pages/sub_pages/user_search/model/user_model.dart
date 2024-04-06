class UserModel {
  int id;
  String email;
  String userName;
  String status;
  int active;
  int isOnline;
  int looker;
  int statusEmotion;
  DateTime lastActive;
  String avatarUserSmall;
  String linkAvatar;
  String avatarUser;
  int companyId;
  int type365;
  String friendStatus;

  UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"] ?? 0,
    email: json["email"] ?? '',
    userName: json["userName"] ?? '',
    status: json["status"] ?? '',
    active: json["active"] ?? 0,
    isOnline: json["isOnline"] ?? 0,
    looker: json["looker"] ?? 0,
    statusEmotion: json["statusEmotion"] ?? 0,
    lastActive: DateTime.parse(json["lastActive"]),
    avatarUserSmall: json["avatarUserSmall"] ?? '',
    linkAvatar: json["linkAvatar"] ?? '',
    avatarUser: json["avatarUser"] ?? '',
    companyId: json["companyId"] ?? 0,
    type365: json["type365"] ?? 0,
    friendStatus: json["friendStatus"] ?? 0,
  );

}