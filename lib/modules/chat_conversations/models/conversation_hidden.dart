class ConversationHidden {
  final int conversationId;
  final int isGroup;
  final String typeGroup;
  final String avatarConversation;
  final int adminId;
  final int shareGroupFromLinkOption;
  final int browseMemberOption;
  final String pinMessage;
  final DateTime timeLastMessage;
  final int senderLastMessage;
  final String message;
  final String messageType;
  final DateTime createAt;
  final int messageDisplay;
  final int isFavorite;
  final int notification;
  final int deleteTime;
  final int deleteType;
  final String conversationName;

  ConversationHidden({
    required this.conversationId,
    required this.isGroup,
    required this.typeGroup,
    required this.avatarConversation,
    required this.adminId,
    required this.shareGroupFromLinkOption,
    required this.browseMemberOption,
    required this.pinMessage,
    required this.timeLastMessage,
    required this.senderLastMessage,
    required this.message,
    required this.messageType,
    required this.createAt,
    required this.messageDisplay,
    required this.isFavorite,
    required this.notification,
    required this.deleteTime,
    required this.deleteType,
    required this.conversationName,
  });

  factory ConversationHidden.fromJson(Map<String, dynamic> json) => ConversationHidden(
    conversationId: json["conversationId"]??0,
    isGroup: json["isGroup"]??0,
    typeGroup: json["typeGroup"]??'',
    avatarConversation: json["avatarConversation"]??'',
    adminId: json["adminId"]??0,
    shareGroupFromLinkOption: json["shareGroupFromLinkOption"]??0,
    browseMemberOption: json["browseMemberOption"]??0,
    pinMessage: json["pinMessage"]??'',
    timeLastMessage: DateTime.parse(json["timeLastMessage"]),
    senderLastMessage: json["senderLastMessage"]??0,
    message: json["message"]??'',
    messageType: json["messageType"]??'',
    createAt:json["createAt"] == null ?DateTime(0): DateTime.parse(json["createAt"]),
    messageDisplay: json["messageDisplay"]??0,
    isFavorite: json["isFavorite"]??0,
    notification: json["notification"]??0,
    deleteTime: json["deleteTime"]??0,
    deleteType: json["deleteType"]??0,
    conversationName: json["conversationName"]??0 ,
  );

}
