class UserRequest {
  final String name;
  final String avatar;
  final num uid;
  final num id365;
  final num type365;
  UserRequest({
    required this.name,
    required this.avatar,
    required this.uid,
    required this.id365,
    required this.type365,
  });
  factory UserRequest.fromJson(Map<String, dynamic> json) => UserRequest(
    name: json["name"]??'',
    avatar: json["avatar"]??'',
    uid: json["uid"]??0,
    id365: json["id365"]??0,
    type365: json["type365"]??0,
  );
}
