class ModelMemberOfGroup {
  final int id;
  final String userName;
  final String avatarUser;
  final int isOnline;
  final String lastActive;
  final String linkAvatar;
  final int companyId;
  final int idTimViec;
  final int type365;
  final String friendStatus;
  final String liveChat;
  ModelMemberOfGroup({
    required this.id,
    required this.userName,
    required this.avatarUser,
    required this.isOnline,
    required this.lastActive,
    required this.linkAvatar,
    required this.companyId,
    required this.idTimViec,
    required this.type365,
    required this.friendStatus,
    required this.liveChat,
  });
  factory ModelMemberOfGroup.fromJson(Map<String, dynamic> json) {
    return ModelMemberOfGroup(
      id: json['id'] ?? 0,
      userName: json['userName'] ?? '',
      avatarUser: json['avatarUser'] ?? '',
      isOnline: json['isOnline'] ?? 0,
      lastActive: json['lastActive'] ?? '',
      linkAvatar: json['linkAvatar'] ?? '',
      companyId: json['companyId'] ?? 0,
      idTimViec: json['idTimViec'] ?? 0,
      type365: json['type365'] ?? 0,
      friendStatus: json['friendStatus'] ?? '',
      liveChat: json['liveChat'] ?? '',
    );
  }
}
