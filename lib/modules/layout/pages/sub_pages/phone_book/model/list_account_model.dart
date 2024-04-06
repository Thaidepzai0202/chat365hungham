class ListAccount {
  final int id;
  final String userName;
  final String avatarUserSmall;
  final String avatarUser;
  final DateTime lastActive;
  final int isOnline;
  final int companyId;

  ListAccount({
    required this.id,
    required this.userName,
    required this.avatarUserSmall,
    required this.avatarUser,
    required this.lastActive,
    required this.isOnline,
    required this.companyId,
  });

  factory ListAccount.fromJson(Map<String, dynamic> json) => ListAccount(
    id: json["_id"]??0,
    userName: json["userName"]??'',
    avatarUserSmall: json["avatarUserSmall"]??'',
    avatarUser: json["avatarUser"]??'',
    lastActive: DateTime.parse(json["lastActive"]),
    isOnline: json["isOnline"]??0,
    companyId: json["companyId"]??0,
  );
}
