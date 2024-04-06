import 'dart:async';

import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/date_time_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:hive/hive.dart';

part 'chat_member_model.g.dart';

@HiveType(typeId: HiveTypeId.chatMemberModelHiveTypeId)
class ChatMemberModel extends IUserInfo {
  ChatMemberModel({
    required this.unReader,
    this.readMessageTime,
    required super.id,
    required super.name,
    required super.avatar,
    this.unreadMessageId,
    super.userStatus = UserStatus.online,
    super.status,
    super.lastActive,
    super.companyId,
    this.liveChat,
    this.deleteTime,
    super.fromWeb,
    super.seenMessage,
  });

  @HiveField(IUserInfo.maxHiveFieldId + 1)
  int unReader;
  @HiveField(IUserInfo.maxHiveFieldId + 2)
  DateTime? readMessageTime;

  /// TL 9/1/2024: Tin nhắn cuối cùng được đọc?
  String? unreadMessageId;
  LiveChat? liveChat;
  int? deleteTime;

  /// TL 9/1/2024:
  /// fromMap() là code cũ, dùng để làm khỉ gì thì không biết
  /// fromJson() là code mới, dùng để lấy dữ liệu từ Hive
  factory ChatMemberModel.fromMap(Map<String, dynamic> json) {
    try {
      var lastActiveFromJson = NullableDateTimeExt.lastActiveFromJson(json);
      String? name = json["userName"];
      var id = json["id"];

      return ChatMemberModel(
        //check null id
        id: id ?? -1,
        //check null name
        name: name.valueIfNull('Người dùng 365'),
        //check null avatar
        avatar: (!(json["avatarUser"] as String?).isBlank
                ? json["avatarUser"]
                : json["linkAvatar"]) ??
            '',
        unReader: json["unReader"] ?? 0,
        userStatus: UserStatus.fromId(
          json["active"] ?? json["Active"] ?? UserStatus.online.id,
        ),
        status: json["status"],
        readMessageTime: json['timeLastSeenerApp'] == null
            ? null
            : DateTimeExt.timeZoneParse(json["timeLastSeenerApp"] ?? ''),
        lastActive: lastActiveFromJson,
        companyId: json['companyId'] ?? json['CompanyId'],
        unreadMessageId: json['lastMessageSeen'],
        liveChat: json['liveChat'] == null
            ? null
            : LiveChat.fromMap(json['liveChat']),
        deleteTime: json['deleteTime'],
        seenMessage: json['seenMessage'],
        fromWeb: json['fromWeb'],
      )..userType = UserType.fromId(json['type365'] ?? 0);
    } catch (e, s) {
      logger.logError(e, s);
      logger.logError(json, 'ChatMemberModel_JsonError');
      logger
          .logError('-------------------------------------------------------');
      return ChatMemberModel.unknown();
    }
  }

  factory ChatMemberModel.unknown() => ChatMemberModel(
        id: -1,
        name: 'Người dùng 365',
        avatar: '',
        unReader: 0,
      );

  /// TL 9/1/2024:
  ///
  /// fromMap() là code cũ, dùng để làm khỉ gì thì không biết
  ///
  /// fromJson() là code mới, dùng để lấy dữ liệu từ Hive
  ///
  /// @json là cái Map từ toJson() đã được decode cẩn thận, class nào ra class đấy
  factory ChatMemberModel.fromJson(Map<String, dynamic> json) {
    return ChatMemberModel(
      id: json["id"],
      name: json["name"]??"",
      avatar: json["avatar"],
      unReader: json["unReader"],
      userStatus: UserStatus.fromId(json["userStatus"]),
      status: json["status"],
      readMessageTime: json["readMessageTime"] == null
          ? null
          : DateTime.tryParse(json["readMessageTime"]) ?? DateTime(0),
      unreadMessageId: json["unreadMessageId"],
      liveChat:
          json["liveChat"] == null ? null : LiveChat.fromMap(json["liveChat"]),
      lastActive: json["lastActive"] == null
          ? null
          : DateTime.tryParse(json["lastActive"]) ?? DateTime(0),
      deleteTime: json["deleteTime"],
      seenMessage: json["seenMessage"],
      companyId: json["companyId"],
      fromWeb: json["fromWeb"],
    )..userType =
        json["userType"] == null ? null : UserType.fromId(json["userType"]);
    // TL 9/1/2024: Chắc mấy cái này không quan trọng lắm. Nếu cần thì uncomment ra
    // ..password = json["password"]
    // ..email = json["email"]
    // ..id365 = json["id365"]
    // ..idTimviec = json["idTimviec"];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "avatar": avatar,
      "unReader": unReader,
      "password": password,
      "userStatus": userStatus.id,
      "status": status,
      "isOnline": isOnline,
      "readMessageTime": readMessageTime?.toIso8601String(),
      "unreadMessageId": unreadMessageId,
      "liveChat": liveChat?.toMap(),
      "lastActive": lastActive?.toIso8601String(),
      "deleteTime": deleteTime,
      "seenMessage": seenMessage,
      "userType": userType?.id,
      "companyId": companyId,
      "id365": id365,
      "idTimviec": idTimviec,
      "fromWeb": fromWeb,
    };
  }

  @override
  FutureOr<Map<String, dynamic>> toLocalStorageJson() {
    return toJson();
  }

  @override
  String toString() => name;
}

// extension ListChatMemberModelExt on List<ChatMemberModel> {
//   ValueNotifier<List<ChatMemberModel>> get toValueListenable =>
//       ValueNotifier(this);

//   List<int> get memberIds => map((e) => e.id).toList();

//   int get firstMemberId => first.id;
// }
