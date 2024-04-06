import 'dart:convert';

import 'package:app_chat365_pc/common/models/api_contact.dart';
import 'package:app_chat365_pc/common/models/api_livechat_message_model.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/models/auto_delete_message_time_model.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/generator_service.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/enums/emoji.dart';
import 'package:app_chat365_pc/utils/data/enums/message_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/date_time_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
part 'result_socket_livechat.g.dart';

String socketSentLivechatModelToHiveObjectJson(
    SocketSentLivechatMessageModel model) {
  var hiveObjectMap = model.toHiveObjectMap();
  return json.encode(hiveObjectMap);
}

SocketSentLivechatMessageModel sockeSentLivechatModelFromHiveObjectJson(
  String encoded, {
  CurrentUserInfoModel? currentInfo,
}) =>
    SocketSentLivechatMessageModel.fromHiveObjectMap(
      json.decode(encoded),
      currentInfo: currentInfo,
    );

@HiveType(typeId: HiveTypeId.socketSentLiveChatModelHiveTypeId)
class SocketSentLivechatMessageModel extends Equatable {
  SocketSentLivechatMessageModel({
    required this.conversationId,
    required this.messageId,
    required this.senderId,
    this.emotion = const {},
    this.type,
    this.message,
    this.replyMessage,
    required this.createAt,
    this.files,
    this.infoLink,
    this.contact,
    MessageStatus? messageStatus,
    this.linkNotification,
    this.infoSupport,
    this.liveChat,
    required this.autoDeleteMessageTimeModel,
  }) : this._messageStatus = messageStatus ?? MessageStatus.normal;

  @HiveField(0)
  final int conversationId;
  @HiveField(1)
  final String messageId;
  @HiveField(2)
  final int senderId;
  @HiveField(3)
  final MessageType? type;
  @HiveField(4)
  final String? message;
  @HiveField(5)
  Map<Emoji, Emotion> emotion;
  @HiveField(6)
  final ApiReplyMessageModel? replyMessage;
  @HiveField(7)
  final DateTime createAt;
  @HiveField(8)
  final List<ApiFileModel>? files;
  @HiveField(9)
  final InfoLink? infoLink;
  @HiveField(10)
  final IUserInfo? contact;
  @HiveField(11)
  MessageStatus _messageStatus;
  @HiveField(12)
  final String? linkNotification;
  @HiveField(13)
  final AutoDeleteMessageTimeModel autoDeleteMessageTimeModel;
  @HiveField(14)
  final InfoSupport? infoSupport;
  @HiveField(15)
  final LiveChat? liveChat;
  MessageStatus get messageStatus => _messageStatus;

  set messageStatus(MessageStatus nextStatus) {
    if (messageStatus != MessageStatus.deleted) _messageStatus = nextStatus;
  }

  bool get hasRelyMessage => replyMessage != null;

  factory SocketSentLivechatMessageModel.fromMap(
    Map<String, dynamic> map, {
    IUserInfo? userInfo,
    UserType? userType,
  }) =>
      SocketSentLivechatMessageModel(
        conversationId: map['conversationID'],
        messageId: map['messageID'],
        senderId: map['senderID'],
        type: MessageTypeExt.valueOf(map['messageType']),
        message: map['message'],
        emotion: Emotion.mapEmojiEmotionFromJson(map['emotionMessage'] ?? []),
        replyMessage: map['quoteMessage'] == null
            ? null
            : ApiReplyMessageModel.fromMap(map['quoteMessage']),
        createAt: DateTimeExt.timeZoneParse(map['createAt']).toLocal(),
        files: map['listFile'] == null
            ? null
            : List.from(map['listFile'])
                .map(
                  (e) => ApiFileModel(
                    fileName: e['fullName'],
                    resolvedFileName:
                        e['fullName'].replaceAll(RegExp('[ +!@#%^&*]'), ''),
                    fileType: MessageTypeExt.valueOf(e['typeFile']),
                    displayFileSize: e['fileSizeInByte'],
                    fileSize: e['sizeFile'],
                    imageSource: e['imageSource'],
                    width: e['width'],
                    height: e['height'],
                    uploaded: true,
                  ),
                )
                .toList(),
        infoLink: map['infoLink'] == null
            ? null
            : InfoLink.fromMap(
                map['infoLink'],
                link: map['message'],
                currentUserInfo: userInfo,
                currentUserType: userType,
              ),
        contact: map['userProfile'] != null
            ? ApiContact.fromMyContact(map['userProfile'])
            : null,
        //isedited = 1 => edited, isedited = 2 => deleted, isedited = 3 => recall
        //messageStatus: map['isEdited'] == 1 ? MessageStatus.edited : null,
        messageStatus: map['isEdited'] == 1
            ? MessageStatus.edited
            // if (map['isEdited'] == 2 && map['senderID'] == userInfo?.id)
            : map['isEdited'] == 2 && map['senderID'] == userInfo?.id
                ? MessageStatus.deleted
                : map['isEdited'] == 3
                    ? MessageStatus.recall
                    : null,

        //messageStatus: map['isEdited'] == 1 ? MessageStatus.edited : null,
        linkNotification:
            map['linkNotification'] == null ? null : map['linkNotification'],
        autoDeleteMessageTimeModel: AutoDeleteMessageTimeModel.fromJson(map),
        infoSupport: map['infoSupport'] == null
            ? null
            : InfoSupport.fromMap(map['infoSupport']),
        liveChat:
            map['liveChat'] == null ? null : LiveChat.fromMap(map['liveChat']),
      );

  factory SocketSentLivechatMessageModel.fromMapOfSocket(
    Map<String, dynamic> map, {
    CurrentUserInfoModel? currentInfo,
  }) {
    final messageType = MessageTypeExt.valueOf(map['MessageType']);

    final String? message = map['Message'];
    return SocketSentLivechatMessageModel(
      conversationId: map['ConversationID'] is String
          ? int.parse(map['ConversationID'])
          : map['ConversationID'],
      messageId: map['MessageID'],
      senderId: map['SenderID'] is String
          ? int.parse(map['SenderID'])
          : map['SenderID'],
      type: messageType,
      message: messageType.displayMessageType(message),
      emotion: Emotion.mapEmojiEmotionFromJson(map["Emotion"] ?? []),
      replyMessage: map['QuoteMessage'] == null ||
              map['QuoteMessage']?['MessageID']?.isEmpty == true
          ? null
          : ApiReplyMessageModel.fromMapOfSocket(map['QuoteMessage']),
      createAt: map['CreateAt'] == null
          ? DateTime.now()
          : DateTimeExt.timeZoneParse(map['CreateAt']),
      files: map['ListFile'] == null || map['ListFile']?.isEmpty == true
          ? null
          : List.from(map['ListFile'])
              .map(
                (e) => ApiFileModel(
                  fileName: e['FullName'],
                  resolvedFileName:
                      e['FullName'].replaceAll(RegExp('[ +!@#%^&*]'), ''),
                  fileType: MessageTypeExt.valueOf(e['TypeFile']),
                  displayFileSize: e['FileSizeInByte'],
                  fileSize: e['SizeFile'],
                  imageSource: e['ImageSource'],
                  width: e['Width'] is int
                      ? double.parse(e['Width'].toString())
                      : e['Width'],
                  height: e['Height'] is int
                      ? double.parse(e['Height'].toString())
                      : e['Height'],
                  uploaded: true,
                ),
              )
              .toList(),
      infoLink: map['InfoLink'] == null
          ? null
          : InfoLink.fromMapOfSocket(
              map['InfoLink'],
              link: map['Message'],
              currentUserInfo: currentInfo?.userInfo,
              currentUserType: currentInfo?.userType,
            ),
      contact: messageType.isNotContactCard || map["UserProfile"] == null
          ? null
          : ApiContact.fromSocketContact(map["UserProfile"]),
      messageStatus: map['MessageStatus'] != null
          ? MessageStatus.values.elementAt(map['MessageStatus'])
          : null,
      autoDeleteMessageTimeModel: AutoDeleteMessageTimeModel.fromJson(map),
      infoSupport: map['InfoSupport'] == null
          ? null
          : InfoSupport.fromMapOfSocket(map['InfoSupport']),
      liveChat: map['LiveChat'] == null
          ? null
          : LiveChat.fromMapOfSocket(map['LiveChat']),
    );
  }

  /// Thay đổi
  /// - [files]
  /// - [type]
  /// - [message]: edit tin nhắn
  SocketSentLivechatMessageModel copyWith({
    MessageType? type,
    String? message,
    MessageStatus? status,
    // String? messageId,
    // int? emotion,
    // ApiReplyMessageModel? replyMessage,
    // DateTime? createAt,
    // String? fileName,
    // int? fileSize,
    List<ApiFileModel>? files,
    InfoLink? infoLink,
  }) =>
      SocketSentLivechatMessageModel(
        files: files,
        conversationId: this.conversationId,
        senderId: this.senderId,
        messageId: this.messageId,
        type: type ?? this.type,
        message: message ?? this.message,
        contact: this.contact,
        infoLink: infoLink ?? this.infoLink,
        createAt: this.createAt.toLocal(),
        replyMessage: this.replyMessage,
        messageStatus: status ?? this.messageStatus,
        autoDeleteMessageTimeModel: this.autoDeleteMessageTimeModel,
        infoSupport: infoSupport ?? this.infoSupport,
        liveChat: liveChat ?? this.liveChat,
      );

  Map<String, dynamic> toMap() => {
        'MessageID': messageId,
        'ConversationID': conversationId,
        'SenderID': senderId,
        'MessageType': type!.databaseName,
        'Message': message,
        'Emotion': emotion,
        'Quote': replyMessage?.toMap(),
        'CreateAt': DateTimeExt.serverDateFormat.format(createAt),
        'InfoLink': infoLink?.toMap(),
        'Profile': contact == null ? null : contact!.toJsonString(),
        'ListFile': files?.map((e) => e.toMap()),
        'InfoSupport': infoSupport?.toMap(),
        'LiveChat': liveChat?.toMap(),
      }..addAll(autoDeleteMessageTimeModel.toMapOfSocket());

  Map<String, dynamic> toHiveObjectMap() {
    List<Map<String, dynamic>> emotionMapObject =
        emotion.values.map((e) => e.toMap()).toList();
    return {
      'MessageID': messageId,
      'ConversationID': conversationId,
      'SenderID': senderId,
      'MessageType': type!.databaseName,
      'Message': message,
      'Emotion': emotionMapObject,
      'Quote': replyMessage?.toMap(),
      'CreateAt': createAt.toTimezoneFormatString(),
      'InfoLink': infoLink?.toMap(),
      'UserProfile': contact != null
          ? ApiContact(
              name: contact!.name,
              avatar: contact!.avatar,
              id: contact!.id,
              companyId: contact!.companyId,
              lastActive: contact!.lastActive,
            ).toHiveObjectMap()
          : null,
      'ListFile': files?.map((e) => e.toMap()).toList(),
      'MessageStatus': messageStatus.index,
      'InfoSupport': infoSupport?.toMap(),
      'LiveChat': liveChat?.toMap(),
    };
  }

  factory SocketSentLivechatMessageModel.fromHiveObjectMap(
    Map<String, dynamic> map, {
    CurrentUserInfoModel? currentInfo,
  }) =>
      SocketSentLivechatMessageModel.fromMapOfSocket(map,
          currentInfo: currentInfo);

  Map<String, dynamic> toMapOfEditedMessage() => {
        'MessageID': messageId,
        'Message': message,
      };

  @override
  String toString() => (toMap()..remove('Emotion')).toString();

  @override
  List<Object?> get props => [conversationId, messageId];
}

@HiveType(typeId: HiveTypeId.infoLinkHiveTypeId)
class InfoLink {
  InfoLink({
    this.messageId,
    this.description,
    this.title,
    this.linkHome,
    this.image,
    this.haveImage = false,
    this.isNotification = false,
    this.link,
    IUserInfo? currentUserInfo,
    UserType? currentUserType,
  }) : fullLink = "";

  // InfoLink({
  //   this.messageId,
  //   this.description,
  //   this.title,
  //   this.linkHome,
  //   this.image,
  //   this.haveImage = false,
  //   this.isNotification = false,
  //   this.link,
  //   IUserInfo? currentUserInfo,
  //   UserType? currentUserType,
  // }) : fullLink = !link.isBlank && isNotification
  //           ? GeneratorService.generate365Link(
  //               link!,
  //               currentUserInfo: currentUserInfo,
  //               currentUserType: currentUserType,
  //             )
  //           : (linkHome ?? '');

  @HiveField(0)
  final String? messageId;
  @HiveField(1)
  final String? description;
  @HiveField(2)
  final String? title;
  @HiveField(3)
  final String? linkHome;
  @HiveField(4)
  final String? image;
  @HiveField(5)
  final bool haveImage;
  @HiveField(6)
  final String? link;
  @HiveField(7)
  final bool isNotification;

  late final String fullLink;

  factory InfoLink.fromMap(
    Map<String, dynamic> map, {
    required String? link,
    IUserInfo? currentUserInfo,
    UserType? currentUserType,
  }) =>
      InfoLink(
        messageId: map['messageID'],
        description: map['description'],
        title: map['title'],
        linkHome: map['linkHome'] ?? "",
        image: map['image'],
        haveImage: map['haveImage'] == "True",
        link: (link.isBlank ? null : link) ?? map['linkHome'],
        isNotification: map['isNotification'] == 1,
        currentUserInfo: currentUserInfo,
        currentUserType: currentUserType,
      );

  factory InfoLink.fromMapOfSocket(
    Map<String, dynamic> map, {
    required String? link,
    IUserInfo? currentUserInfo,
    UserType? currentUserType,
  }) =>
      InfoLink(
        messageId: map['MessageID'],
        description: map['Description'],
        title: map['Title'],
        linkHome: map['LinkHome'],
        image: map['Image'],
        haveImage: map['HaveImage'] == "True",
        link: (link.isBlank ? null : link) ?? map['LinkHome'],
        isNotification: map['IsNotification'] == 1,
        currentUserInfo: currentUserInfo,
        currentUserType: currentUserType,
      );

  Map<String, dynamic> toMap() => {
        'MessageID': messageId,
        'Description': description,
        'Title': title,
        'LinkHome': linkHome,
        'Image': image,
        'HaveImage': haveImage,
        'IsNotification': isNotification ? 1 : 0,
      };
}

@HiveType(typeId: HiveTypeId.infoSupportHiveTypeId)
class InfoSupport {
  InfoSupport({
    required this.title,
    required this.message,
    required this.suportId,
    required this.haveConversation,
    required this.userId,
    required this.status,
    this.time,
  });
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String message;
  @HiveField(2)
  final String suportId;
  @HiveField(3)
  final int haveConversation;
  @HiveField(4)
  final int userId;
  @HiveField(5)
  final int status;
  @HiveField(6)
  final String? time;

  factory InfoSupport.fromMap(Map<String, dynamic> map) => InfoSupport(
        title: map['title'],
        message: map['message'],
        suportId: map['suportId'],
        haveConversation: map['haveConversation'],
        userId: map['userId'],
        status: map['status'],
        time: map['time'],
      );

  factory InfoSupport.fromMapOfSocket(Map<String, dynamic> map) => InfoSupport(
        title: map['title'],
        message: map['message'],
        suportId: map['suportID'],
        haveConversation: map['haveConversation'],
        userId: map['userID'],
        status: map['status'],
        time: map['time'],
      );
  Map<String, dynamic> toMap() => {
        'title': title,
        'message': message,
        'suportID': suportId,
        'haveConversation': haveConversation,
        'userID': userId,
        'status': status,
        'time': time,
      };
}

@HiveType(typeId: HiveTypeId.liveChatHiveTypeId)
class LiveChat {
  LiveChat(
      {required this.clientId,
      required this.clientName,
      required this.fromWeb,
      required this.fromConversation});
  @HiveField(0)
  final String clientId;
  @HiveField(1)
  final String clientName;
  @HiveField(2)
  final String fromWeb;
  @HiveField(3)
  final int fromConversation;

  factory LiveChat.fromMap(Map<String, dynamic> map) => LiveChat(
        clientId: map['clientId'],
        clientName: map['clientName'],
        fromWeb: map['fromWeb'],
        fromConversation: map['FromConversation'],
      );

  factory LiveChat.fromMapOfSocket(Map<String, dynamic> map) => LiveChat(
        clientId: map['ClientID'],
        clientName: map['ClientName'],
        fromWeb: map['FromWeb'],
        fromConversation: map['FromConversation'],
      );

  Map<String, dynamic> toMap() => {
        'ClientID': clientId,
        'ClientName': clientName,
        'FromWeb': fromWeb,
        'FromConversation': fromConversation,
      };
}

/// Gồm [Emoji] và ds userId
// @HiveType(typeId: HiveTypeId.emotionHiveTypeId)
// class Emotion extends Equatable {
//   Emotion({
//     required this.type,
//     required List<int> listUserId,
//     required this.isChecked,
//   }) : listUserId = [...listUserId];
//
//   @HiveField(0)
//   final Emoji type;
//   @HiveField(1)
//   final List<int> listUserId;
//   @HiveField(2)
//   final bool isChecked;
//
//   factory Emotion.fromMap(Map<String, dynamic> json) {
//     // List<int>.from((json["listUserId"] as List).map((e) => int.tryParse(e))),
//     List<int> listUserIds = ((json["listUserId"] as List)
//             .map((e) => int.tryParse(e.toString()))
//             .toList()
//           ..removeWhere((e) => e == null))
//         .cast();
//     return Emotion(
//       type: Emoji.fromId(json["type"]),
//       listUserId: listUserIds,
//       isChecked: json["isChecked"] ?? false,
//     );
//   }
//
//   static Map<Emoji, Emotion> emptyEmojiEmotion() => mapEmojiEmotionFromJson([]);
//
//   toHiveObjectMap() => toMap();
//
//   Map<String, dynamic> toMap() => {
//         "type": type.id,
//         "listUserId": listUserId,
//         "isChecked": isChecked,
//       };
//
//   static Map<Emoji, Emotion> mapEmojiEmotionFromJson(List json) {
//     var map = Map<Emoji, Emotion>.fromIterable(
//       Emoji.values,
//       value: (emotion) => Emotion(
//         type: emotion,
//         listUserId: [],
//         isChecked: false,
//       ),
//     );
//     json.forEach((element) {
//       var emotion = Emotion.fromMap(element);
//       map[emotion.type] = emotion;
//     });
//     return map;
//   }
//
//   didReact(int userId) => listUserId.contains(userId);
//
//   @override
//   List<Object?> get props => [type, ...listUserId];
// }
