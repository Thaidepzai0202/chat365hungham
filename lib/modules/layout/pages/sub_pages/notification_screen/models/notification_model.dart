class NotificationModel {
  final String title;
  final String message;
  final int isUndeader;
  final DateTime createAt;
  final String type;
  final dynamic messageId;
  final int conversationId;
  final String link;
  final String idNotification;
  final int userId;
  final Participant? participant;
  final String time;

  NotificationModel({
    required this.title,
    required this.message,
    required this.isUndeader,
    required this.createAt,
    required this.type,
    required this.messageId,
    required this.conversationId,
    required this.link,
    required this.idNotification,
    required this.userId,
    required this.participant,
    required this.time,
  });
  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    title: json["title"]??'',
    message: json["message"]??'',
    isUndeader: json["isUndeader"]??0,
    createAt: DateTime.parse(json["createAt"]),
    type: json["type"]??'',
    messageId: json["messageId"]??'',
    conversationId: json["conversationId"]??0,
    link: json["link"]??'',
    idNotification: json["idNotification"]??'',
    userId: json["userID"]??0,
      participant: (json["participant"] == null || json["participant"] == '') ? null : Participant.fromJson(json["participant"]),
    time: json["time"],
  );

}

class Participant {
  final int id;
  final String userName;
  final String avatarUser;
  final DateTime lastActive;

  Participant({
    required this.id,
    required this.userName,
    required this.avatarUser,
    required this.lastActive,
  });
  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    id: json["id"]??0,
    userName: json["userName"]??'',
    avatarUser: json["avatarUser"]??'',
    lastActive: DateTime.parse(json["lastActive"]),
  );
}

enum Type {
  CHANGE_SALARY,
  SEND_CANDIDATE,
  TAG
}

final typeValues = EnumValues({
  "ChangeSalary": Type.CHANGE_SALARY,
  "SendCandidate": Type.SEND_CANDIDATE,
  "tag": Type.TAG
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
