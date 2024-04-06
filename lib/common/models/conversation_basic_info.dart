import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:hive/hive.dart';

part 'conversation_basic_info.g.dart';

@HiveType(typeId: HiveTypeId.conversationBasicInfoHiveTypeId)
@Deprecated("""Model này vi phạm Liskov trong 5 nguyên tắc SOLID của OOP.
Hãy dùng ConversationModel, là thay thế của ChatItemModel + ConversationBasicInfo """)
class ConversationBasicInfo extends IUserInfo {
  ConversationBasicInfo({
    required this.conversationId,
    required this.isGroup,
    required this.userId,
    this.pinMessageId,
    this.groupLastSenderId,
    this.lastConversationMessageTime,
    this.lastConversationMessage,
    this.countUnreadMessage,
    this.totalGroupMemebers,
    this.lastMessasgeId,
    required super.name,
    super.id365,
    super.avatar,
    super.userStatus = UserStatus.online,
    super.lastActive,
    super.companyId,
    super.email,
    FriendStatus? friendStatus,
    super.fromWeb,
    super.status,
  }) : super(
          id: isGroup ? conversationId : userId,
          friendStatus: isGroup ? null : friendStatus,
        );

  @HiveField(IUserInfo.maxHiveFieldId + 1)
  final bool isGroup;
  @HiveField(IUserInfo.maxHiveFieldId + 2)
  String? lastConversationMessage;
  @HiveField(IUserInfo.maxHiveFieldId + 3)
  DateTime? lastConversationMessageTime;
  @HiveField(IUserInfo.maxHiveFieldId + 4)
  int? countUnreadMessage;
  @HiveField(IUserInfo.maxHiveFieldId + 5)
  String? pinMessageId;

  /// [id] của người cuối cùng nhắn tin trong group
  @HiveField(IUserInfo.maxHiveFieldId + 6)
  int? groupLastSenderId;

  /// Message de lay id nguoi ghim va noi dung tin de ghim
  @HiveField(IUserInfo.maxHiveFieldId + 7)
  String? message;

  /// Đây là super.id nếu là nhóm
  @HiveField(IUserInfo.maxHiveFieldId + 8)
  final int conversationId;

  /// Đây là super.id nếu là người
  @HiveField(IUserInfo.maxHiveFieldId + 9)
  final int userId;

  @HiveField(IUserInfo.maxHiveFieldId + 10)
  int? totalGroupMemebers;

  /// TL 11/1/2024: Nhìn ông nào viết sai chính tả, ngứa mắt waaaaaaaaaaaaaaa
  @HiveField(IUserInfo.maxHiveFieldId + 11)
  String? lastMessasgeId;

  // FriendStatus? _friendStatus;

  // @override
  // FriendStatus? get friendStatus => super.friendStatus;

  // @override
  // set friendStatus(FriendStatus? status) => super.friendStatus = status;

  bool? isChecked = false;

  static const maxHiveFieldId = IUserInfo.maxHiveFieldId + 11;

  // ConversationBasicInfo copyWith({
  //   String? name,
  //   String? avatarUrl,
  //   UserStatus? userStatus,
  // }) =>
  //     ConversationBasicInfo(
  //       id: id,
  //       conversationId: this.conversationId,
  //       name: name ?? this.name,
  //       avatarUrl: avatarUrl,
  //       userStatus: userStatus ?? this.userStatus,
  //     );

  @override

  /// Thật may mắn cái này toàn string với int, nên JSON encode/decode đơn giản
  Map<String, dynamic> toJson() {
    return {
      "conversationId": conversationId,
      "isGroup": isGroup,
      "userId": userId,
      "pinMessageId": pinMessageId,
      "groupLastSenderId": groupLastSenderId,
      "lastConversationMessageTime":
          (lastConversationMessageTime?.toIso8601String() ?? ""),
      "lastConversationMessage": lastConversationMessage,
      "countUnreadMessage": countUnreadMessage,
      "totalGroupMemebers": totalGroupMemebers,
      "lastMessasgeId": lastMessasgeId,
      "name": name,
      "id365": id365,
      "avatar": avatar,
      "userStatus": userStatus.toJson(),
      "lastActive": (lastActive?.toIso8601String() ?? ""),
      "companyId": companyId,
      "email": email,
      "friendStatus": FriendStatusExt.valueOf(friendStatus),
      "fromWeb": fromWeb,
      "status": status,
      //"id": id,
    };
  }

  /// @json: Một chiếc json từ toJson()
  factory ConversationBasicInfo.fromJson(Map<String, dynamic> json) {
    if (json["avatar"] == null || json["avatar"] == "") {
      logger.log("CTC ${json["name"]} thiếu ava",
          name: "ConversationBasicInfo.fromJson");
    }
    return ConversationBasicInfo(
      conversationId: json["conversationId"],
      isGroup: json["isGroup"],
      userId: json["userId"],
      pinMessageId: json["pinMessageId"],
      groupLastSenderId: json["groupLastSenderId"],
      lastConversationMessageTime:
          DateTime.tryParse(json["lastConversationMessageTime"]) ?? DateTime(0),
      lastConversationMessage: json["lastConversationMessage"],
      countUnreadMessage: json["countUnreadMessage"],
      totalGroupMemebers: json["totalGroupMemebers"],
      lastMessasgeId: json["lastMessasgeId"],
      name: json["name"],
      id365: json["id365"],
      avatar: json["avatar"],
      userStatus: UserStatus.fromJson(json["userStatus"]),
      lastActive: DateTime.tryParse(json["lastActive"]) ?? DateTime(0),
      companyId: json["companyId"],
      email: json["email"],
      friendStatus: FriendStatusExt.fromValue(json["friendStatus"]),
      fromWeb: json["fromWeb"],
      status: json["status"],
    );
  }

  /// TL 11/1/2024: Không rõ có nên Deprecate cái này không
  /// Ai hiểu thì cứ dùng nhé
  Future<Map<String, dynamic>> toLocalStorageJson() async {
    return {
      "id": id,
      "name": name,
      "avatar":
          avatar, //.isBlank ? [] : await ApiClient().downloadImage(avatar!),
    };
  }

  /// TL 11/1/2024: Không rõ có nên Deprecate cái này không
  /// Ai hiểu thì cứ dùng nhé
  @override
  String toJsonString() {
    return """{
        "Id": $id,
        "ID365": $id365,
        "Email": "$email",
        "UserName": "$name",
        "AvatarUser": "$avatar",
        "Status": "$status",
      }""";
  }

  /// TL 9/1/2024:
  /// Thêm mới hàm này để convert json cho dễ
  /// @json: Một cái JSON từ toJsonString()
  // factory ConversationBasicInfo fromJsonString(String json){
  //   return {

  //   }
  // }

  @override
  String toString() => name;
}
