import 'dart:convert';

import 'package:app_chat365_pc/common/models/api_contact.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/models/auto_delete_message_time_model.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/generator_service.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/utils/data/enums/emoji.dart';
import 'package:app_chat365_pc/utils/data/enums/message_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/date_time_extension.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
part 'result_socket_chat.g.dart';

String sockeSentMessageModelToHiveObjectJson(SocketSentMessageModel model) {
  var hiveObjectMap = model.toHiveObjectMap();
  return json.encode(hiveObjectMap);
}

SocketSentMessageModel sockeSentMessageModelFromHiveObjectJson(
  String encoded, {
  CurrentUserInfoModel? currentInfo,
}) =>
    SocketSentMessageModel.fromHiveObjectMap(
      json.decode(encoded),
      currentInfo: currentInfo,
    );

@HiveType(typeId: HiveTypeId.socketSentMessageModelHiveTypeId)
class SocketSentMessageModel extends Equatable {
  SocketSentMessageModel({
    required this.isCheck,
    required this.conversationId,
    required this.messageId,
    required this.senderId,
    this.emotion = const {},
    this.type,
    this.message,
    this.relyMessage,
    required this.createAt,
    this.files,
    this.infoLink,
    this.contact,
    MessageStatus? messageStatus,
    this.linkNotification,
    required this.autoDeleteMessageTimeModel,
    this.linkPdf,
    this.linkPng,
    this.infoSupport,
    this.liveChat,
    this.IsFavorite = 0,
    this.senderName,
    this.senderAvatar,
    this.listDeleteUser,
    this.uscId,
    this.isSecretGroup,
    this.infoSeen,
    this.deleteTime,
    // deletetype để phân biệt giữa tin nhắn tự xóa và tin nhắn bí mật
    // tạm thời app không cần dùng đến trường này vì khi cài đặt tin nhắn tự xóa
    // app sẽ gọi api SetupDeleteTimeV2 cho tin nhắn tiếp theo
    this.deleteType,
    this.strange,
    this.isClicked,
  }) : _messageStatus = messageStatus ?? MessageStatus.normal;

  @HiveField(0)
  final int conversationId;
  @HiveField(1)
  final String messageId;
  @HiveField(2)
  final int senderId;
  @HiveField(3)
  final MessageType? type;
  @HiveField(4)
  late String? message;
  @HiveField(5)
  Map<Emoji, Emotion> emotion;
  @HiveField(6)
  final ApiReplyMessageModel? relyMessage;
  @HiveField(7)
  final DateTime createAt;
  @HiveField(8)
  final List<ApiFileModel>? files;
  // TL 8/1/2024: infoLink làm khỉ gì, mình không biết luôn
  @HiveField(9)
  final InfoLink? infoLink;
  @HiveField(10)
  final IUserInfo? contact;

  // Tin nhắn đã xóa
  @HiveField(11)
  MessageStatus _messageStatus;
  @HiveField(12)
  final String? linkNotification;
  @HiveField(13)
  final AutoDeleteMessageTimeModel autoDeleteMessageTimeModel;
  @HiveField(14)
  final String? linkPdf;
  @HiveField(15)
  final String? linkPng;
  @HiveField(16)
  final InfoSupport? infoSupport;
  @HiveField(17)
  final LiveChat? liveChat;
  @HiveField(18)
  int IsFavorite;
  @HiveField(19)
  final String? senderName;
  @HiveField(20)
  final String? senderAvatar;
  @HiveField(21)
  List<int>? listDeleteUser;
  @HiveField(22)
  String? uscId;
  @HiveField(23)
  bool isCheck = false;
  @HiveField(24)
  int? isSecretGroup;
  @HiveField(25)
  List<InfoSeen>? infoSeen;
  @HiveField(26)
  int? deleteTime;
  @HiveField(27)
  int? deleteType;
  @HiveField(28)
  List<dynamic>? strange;
  @HiveField(29)
  int? isClicked;
  MessageStatus get messageStatus => _messageStatus;

  set messageStatus(MessageStatus nextStatus) {
    if (messageStatus != MessageStatus.deleted) _messageStatus = nextStatus;
  }

  bool get hasRelyMessage => relyMessage != null;

  factory SocketSentMessageModel.fromMap(
    Map<String, dynamic> map, {
    IUserInfo? userInfo,
    UserType? userType,
  }) {
    var _emotion = [];
    var _quote = null;
    try {
      if (map['emotionMessage'] is List)
        _emotion = map['emotionMessage'];
      else
        _emotion = [];
      if (map['quoteMessage'] is String)
        _quote = null;
      else
        _quote = map['quoteMessage'];
    } catch (e) {}
    var _userDeleted =
        map['listDeleteUser'] == null ? null : List.from(map['listDeleteUser']);
    _userDeleted?.removeWhere((element) => element == null);

    // TL 19/2/2024: Bật debugger, thấy map livechat trả về có duy nhất mỗi fromConversation = 0 -.-
    // Chịu đấy. Chắc thế là null, nhỉ?
    var newLivechat = null;
    if (map['liveChat'] != null) {
      newLivechat = LiveChat.fromMap(map['liveChat']);
      if ((newLivechat?.fromConversation ?? 0) == 0) {
        newLivechat = null;
      }
    }

    return SocketSentMessageModel(
      conversationId: map['conversationId'] ?? map['conversationID'],
      messageId: map['messageID'] ?? map['_id'],
      senderId: map['senderID'] ?? map['SenderID'] ?? map['senderId'] ?? -1,
      senderName: map['senderName'],
      senderAvatar: map['senderAvatar'],
      type: MessageTypeExt.valueOf(map['messageType']),
      message: map['message'] ?? '',
      emotion: Emotion.mapEmojiEmotionFromJson(_emotion),
      relyMessage: _quote == null
          ? null
          : ApiReplyMessageModel.fromMap(map['quoteMessage']),
      createAt: DateTimeExt.timeZoneParse(map['createAt']),
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
          : map['isEdited'] == 2 &&
                  (_userDeleted?.cast<int>() ?? []).contains(userInfo?.id)
              ? MessageStatus.deleted
              : map['isEdited'] == 3
                  ? MessageStatus.recall
                  : null,

      //messageStatus: map['isEdited'] == 1 ? MessageStatus.edited : null,
      linkNotification: map['linkNotification'],
      autoDeleteMessageTimeModel: AutoDeleteMessageTimeModel.fromJson(map),
      linkPdf: map['linkPdf'],
      linkPng: map['linkPng'],
      infoSupport: map['infoSupport'] == null
          ? null
          : InfoSupport.fromMap(map['infoSupport']),
      liveChat: newLivechat,
      isCheck: false,
      IsFavorite: map['IsFavorite'] ?? 0,
      listDeleteUser: _userDeleted?.cast<int>(),
      uscId: map['uscid'],
      isSecretGroup: map['isSecret'],
      infoSeen: map['inforSeen'] == null
          ? null
          : (map['inforSeen'] as List)
              ?.map((e) => InfoSeen.fromMap(e))
              .toList(),
      deleteTime: map['deleteTime'],
      deleteType: map['deleteType'],
      isClicked: map['isClicked'],
    );
  }
  factory SocketSentMessageModel.fromMapOfSocket(
    Map<String, dynamic> map, {
    CurrentUserInfoModel? currentInfo,
  }) {
    final messageType = MessageTypeExt.valueOf(map['MessageType']);
    final String? message = map['Message'] ?? '';
    return SocketSentMessageModel(
        conversationId: map['ConversationID'] is String
            ? int.parse(map['ConversationID'])
            : map['ConversationID'],
        messageId: map['MessageID'],
        senderId: map['SenderID'] is String
            ? int.parse(map['SenderID'])
            : map['SenderID'],
        senderName: map['SenderName'],
        senderAvatar: map['SenderAvatar'],
        type: messageType,
        message: messageType.displayMessageType(message),
        emotion: Emotion.mapEmojiEmotionFromJson(map["Emotion"] ?? []),
        relyMessage: map['QuoteMessage'] == null ||
                map['QuoteMessage']?['MessageID']?.isEmpty == true
            ? null
            : ApiReplyMessageModel.fromMapOfSocket(map['QuoteMessage']),
        createAt: map['CreateAt'] == null
            ? DateTime.now()
            : DateTimeExt.timeZoneParse(map['CreateAt']),
        files: map['ListFile'] == null || map['ListFile']?.isEmpty == true
            ? null
            : List.from(map['ListFile'])
                .map((e) => ApiFileModel.fromMap(e))
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
        linkPdf: map['linkPdf'],
        linkPng: map['linkPng'],
        infoSupport: map['InfoSupport'] == null
            ? null
            : InfoSupport.fromMapOfSocket(map['InfoSupport']),
        liveChat: map['LiveChat'] == null
            ? null
            : LiveChat.fromMapOfSocket(map['LiveChat']),
        isCheck: false,
        IsFavorite: map['IsFavorite'] ?? 0,
        listDeleteUser: map['listDeleteUser'] == null
            ? null
            : List.from(map['listDeleteUser']),
        uscId: map['Uscid'],
        isSecretGroup: map['isSecret'],
        infoSeen: map['inforSeen'] == null
            ? null
            : (map['inforSeen']).map((e) => InfoSeen.fromMap(e)).toList(),
        deleteTime: map['deleteTime'],
        deleteType: map['deleteType'],
        strange: List.from(map['strange'] ?? []),
        isClicked: map['isClicked']);
  }

  /// Thay đổi
  /// - [files]
  /// - [type]
  /// - [message]: edit tin nhắn
  SocketSentMessageModel copyWith({
    MessageType? type,
    String? message,
    MessageStatus? status,
    // String? messageId,
    // int? emotion,
    // ApiRelyMessageModel? relyMessage,
    // DateTime? createAt,
    // String? fileName,
    // int? fileSize,
    List<ApiFileModel>? files,
    InfoLink? infoLink,
  }) =>
      SocketSentMessageModel(
          files: files,
          conversationId: this.conversationId,
          senderId: this.senderId,
          messageId: this.messageId,
          type: type ?? this.type,
          message: message ?? this.message,
          contact: this.contact,
          infoLink: infoLink ?? this.infoLink,
          createAt: this.createAt.toLocal(),
          relyMessage: this.relyMessage,
          messageStatus: status ?? this.messageStatus,
          autoDeleteMessageTimeModel: this.autoDeleteMessageTimeModel,
          linkPng: this.linkPng,
          linkPdf: this.linkPdf,
          infoSupport: infoSupport ?? this.infoSupport,
          liveChat: liveChat ?? this.liveChat,
          isCheck: this.isCheck,
          IsFavorite: this.IsFavorite,
          senderName: this.senderName,
          isSecretGroup: this.isSecretGroup);

  Map<String, dynamic> toMap() => {
        'MessageID': messageId,
        'ConversationID': conversationId,
        'SenderID': senderId,
        'MessageType': type?.databaseName ?? MessageType.unknown,
        'Message': message,
        'Emotion': emotion,
        'Quote': relyMessage?.toMap(),
        'CreateAt': DateTimeExt.serverDateFormat.format(createAt),
        'InfoLink': infoLink?.toMap(),
        'Profile': contact == null ? null : contact!.toJsonString(),
        'ListFile': files?.map((e) => e.toMap()),
        'InfoSupport': infoSupport?.toMap(),
        'LiveChat': liveChat?.toMap(),
        'SenderName': senderName,
        'isSecret': isSecretGroup,
      }..addAll(autoDeleteMessageTimeModel.toMapOfSocket());

  /// TL: Cái này để lưu local
  Map<String, dynamic> toHiveObjectMap() {
    List<Map<String, dynamic>> emotionMapObject =
        emotion.values.map((e) => e.toMap()).toList();
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'type': type!.databaseName,
      'message': message,
      'emotion': emotionMapObject,
      'replyMessage': relyMessage?.toMap(),
      'createAt': createAt.toIso8601String(),
      //'infoLink': infoLink?.toMap(), TODO: infoLink có tác dụng gì vậy????
      'contact': contact != null
          ? ApiContact(
              name: contact!.name,
              avatar: contact!.avatar,
              id: contact!.id,
              companyId: contact!.companyId,
              lastActive: contact!.lastActive,
            ).toHiveObjectMap()
          : null,
      "autoDeleteMessageTimeModel": autoDeleteMessageTimeModel.toJson(),
      'files': files?.map((e) => e.toMap()).toList(),
      'messageStatus': messageStatus.index,
      'linkPdf': linkPdf,
      'linkPng': linkPng,
      'infoSupport': infoSupport?.toMap(),
      'liveChat': liveChat?.toMap(),
    };
  }

  /// TL: Cái này để lấy data local
  factory SocketSentMessageModel.fromHiveObjectMap(
    Map<String, dynamic> map, {
    CurrentUserInfoModel? currentInfo,
  }) {
    // logger.log(map['files'], name: "FilesLoggerMap");
    return SocketSentMessageModel(
      isCheck: false,
      type: MessageTypeExt.valueOf(map["type"]),
      conversationId: map["conversationId"],
      messageId: map["messageId"],
      senderId: map["senderId"],
      autoDeleteMessageTimeModel: AutoDeleteMessageTimeModel.fromJson(
          map["autoDeleteMessageTimeModel"]),
      emotion: Emotion.mapEmojiEmotionFromJson(map["emotion"] ?? []),
      message: map["message"],
      relyMessage: map["replyMessage"] == null
          ? null
          : ApiReplyMessageModel.fromMap(map["replyMessage"]),
      createAt: DateTime.tryParse(map["createAt"]) ?? DateTime(0),
      //infoLink: InfoLink.fromMap(map, link: link) map[""],
      contact: map["contact"] == null
          ? null
          : ApiContact.fromHiveObjectMap(map["contact"]),
      files: map['files'] == null || map['files']?.isEmpty == true
          ? null
          : List.from(map['files'])
              .map((e) => ApiFileModel.fromMap(e))
              .toList(),
      messageStatus: MessageStatus.values.elementAt(map["messageStatus"] ?? 0),
      linkPdf: map["linkPdf"],
      linkPng: map["linkPng"],
      infoSupport: map["infoSupport"] == null
          ? null
          : InfoSupport.fromMap(map["infoSupport"]),
      liveChat:
          map["liveChat"] == null ? null : LiveChat.fromMap(map["liveChat"]),
    );
  }

  Map<String, dynamic> toMapOfEditedMessage() => {
        'MessageID': messageId,
        'Message': message,
      };

  ApiMessageModel toApiMessageModel(int currentUserId) {
    return ApiMessageModel(
      messageId: messageId,
      conversationId: conversationId,
      senderId: currentUserId,
      files: files,
      contact: contact,
      type: type ?? MessageType.text,
      message: message?.valueIfNull(infoLink?.fullLink ?? ''),
    );
  }

  @override
  String toString() => (toMap()..remove('Emotion')).toString();

  @override
  List<Object?> get props => [conversationId, messageId, type];
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
  }) : fullLink = !link.isBlank && isNotification
            ? GeneratorService.generate365Link(
                link!,
                currentUserInfo: currentUserInfo,
                currentUserType: currentUserType,
              )
            : (linkHome ?? '');

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
    this.supportId,
    required this.haveConversation,
    required this.userId,
    this.status,
    this.time,
    this.userName,
  });
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String message;
  @HiveField(2)
  final String? supportId;
  @HiveField(3)
  final int haveConversation;
  @HiveField(4)
  final int userId;

  /// TL 19/2/2024:
  ///
  /// Chỉ có 2 trạng thái: 1 là đã bắt, 3 là bị nhỡ. Null hay 0 2 4 6 8 gì thì chịu
  @HiveField(5)
  late int? status;
  @HiveField(6)
  final String? time;
  @HiveField(8)
  final String? userName;

  factory InfoSupport.fromMap(Map<String, dynamic> map) => InfoSupport(
        title: map['title'] ?? '',
        message: map['message'] ?? '',
        supportId: map['suportId'],
        haveConversation: map['haveConversation'] ?? 0,
        userId: map['userId'] ?? -1,
        status: map['status'],
        time: map['time'],
      );

  factory InfoSupport.fromMapOfSocket(Map<String, dynamic> map) => InfoSupport(
        title: map['Title'] ?? '',
        message: map['Message'] ?? '',
        supportId: map['SupportId'],
        haveConversation: map['HaveConversation'] ?? 0,
        userId: map['UserId'] ?? -1,
        status: map['Status'],
        time: map['Time'],
        userName: map['userName'],
      );
  Map<String, dynamic> toMap() => {
        'title': title,
        'message': message,
        'supportID': supportId,
        'haveConversation': haveConversation,
        'userId': userId,
        'status': status,
        'time': time,
        'userName': userName,
      };
}

@HiveType(typeId: HiveTypeId.infoSeen)
class InfoSeen {
  InfoSeen({
    this.memberId,
    this.seenTime,
  });
  @HiveField(0)
  final int? memberId;
  @HiveField(1)
  final DateTime? seenTime;
  factory InfoSeen.fromMap(Map<String, dynamic> map) => InfoSeen(
        memberId: map['memberId'],
        seenTime: DateTime.parse(map['seenTime']).toLocal(),
      );
}

// TL 19/2/2024: Sửa parse model. Chỗ thì viết hoa đầu, chỗ thì không.
@HiveType(typeId: HiveTypeId.liveChatHiveTypeId)
class LiveChat {
  LiveChat({
    this.clientId,
    this.clientName,
    this.fromWeb,
    this.fromConversation,
    this.clientAvatarUrl,
  });
  @HiveField(0)
  final String? clientId;
  @HiveField(1)
  final String? clientName;
  @HiveField(2)
  final String? fromWeb;
  @HiveField(3)
  final int? fromConversation;
  @HiveField(4)
  final String? clientAvatarUrl;

  factory LiveChat.fromMap(Map<String, dynamic> map) {
    return LiveChat(
      clientId: (map['clientId'] ?? map['ClientId'] ?? "").toString(),
      clientName: map['clientName']?.toString(),
      clientAvatarUrl: map['clientAvatar'],
      fromWeb: map['fromWeb'] ?? map["FromWeb"],
      fromConversation: int.tryParse(
          (map['FromConversation'] ?? map['fromConversation']).toString()),
    );
  }

  factory LiveChat.fromMapOfSocket(Map<String, dynamic> map) => LiveChat(
        clientAvatarUrl: map['ClientAvatar'],
        clientId: (map['clientId'] ?? map['ClientId'])?.toString(),
        clientName: (map['clientName'] ?? map['ClientName'])?.toString(),
        fromWeb: map['fromWeb'] ?? map["FromWeb"],
        fromConversation: int.tryParse(
            (map['FromConversation'] ?? map['fromConversation']).toString()),
      );

  Map<String, dynamic> toMap() => {
        'clientId': clientId,
        'clientName': clientName,
        'clientAvatar': clientAvatarUrl,
        'fromWeb': fromWeb,
        'fromConversation': fromConversation,
      };
}

/// Gồm [Emoji] và ds userId
@HiveType(typeId: HiveTypeId.emotionHiveTypeId)
class Emotion extends Equatable {
  Emotion({
    required this.type,
    required List<int> listUserId,
    required this.isChecked,
  }) : listUserId = [...listUserId];

  @HiveField(0)
  final Emoji type;
  @HiveField(1)
  final List<int> listUserId;
  @HiveField(2)
  final bool isChecked;

  factory Emotion.fromMap(Map<String, dynamic> json) {
    // List<int>.from((json["listUserId"] as List).map((e) => int.tryParse(e))),
    List<int> listUserIds = ((json["listUserId"] as List)
            .map((e) => int.tryParse(e.toString()))
            .toList()
          ..removeWhere((e) => e == null))
        .cast();
    return Emotion(
      type: Emoji.fromId(json["type"]),
      listUserId: listUserIds,
      isChecked: json["isChecked"] ?? false,
    );
  }

  static Map<Emoji, Emotion> emptyEmojiEmotion() => mapEmojiEmotionFromJson([]);

  toHiveObjectMap() => toMap();

  Map<String, dynamic> toMap() => {
        "type": type.id,
        "listUserId": listUserId,
        "isChecked": isChecked,
      };

  static Map<Emoji, Emotion> mapEmojiEmotionFromJson(List json) {
    var map = Map<Emoji, Emotion>.fromIterable(
      Emoji.values,
      value: (emotion) => Emotion(
        type: emotion,
        listUserId: [],
        isChecked: false,
      ),
    );
    json.forEach((element) {
      var emotion = Emotion.fromMap(element);
      map[emotion.type] = emotion;
    });
    return map;
  }

  didReact(int userId) => listUserId.contains(userId);

  @override
  List<Object?> get props => [type, ...listUserId];
}

class SocketSentMessageGetPasteModel {
  String? message;
  final MessageType? type;
  final ApiFileModel? file;
  SocketSentMessageGetPasteModel({this.message, this.type, this.file});
}
