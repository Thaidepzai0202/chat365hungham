import 'dart:convert';

import 'package:app_chat365_pc/common/models/auto_delete_message_time_model.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/date_time_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/adapters.dart';

part 'result_chat_conversation.g.dart';

String sockeChatItemModeldToHiveObjectJson(ChatItemModel model) {
  var hiveObjectMap = model.toHiveObjectMap();
  return json.encode(hiveObjectMap);
}

ChatItemModel ChatItemModelFromHiveObjectJson(
        String encoded, int currentUserId) =>
    ChatItemModel.fromHiveObjectMap(json.decode(encoded)); //, currentUserId);

@HiveType(typeId: HiveTypeId.chatItemModelHiveTypeId)
// @Deprecated(
//     "Ưu tiên dùng ConversationModel nhé. ConversationModel lấy từ API ver3, và có thể port ngược lại ChatItemModel được.")
class ChatItemModel {
  ChatItemModel({
    required this.conversationId,
    required this.numberOfUnreadMessage,
    required this.isGroup,
    required this.senderId,
    required String? message,
    required this.messageType,
    required this.totalNumberOfMessages,
    required this.messageDisplay,
    required this.typeGroup,
    required this.adminId,
    this.adminName,
    this.browerMemberList,
    required this.memberList,
    required this.isFavorite,
    required this.isHidden,
    required this.createAt,
    required this.conversationBasicInfo,
    String? status,
    this.autoDeleteMessageTimeModel = AutoDeleteMessageTimeModel.defaultModel,
    this.lastMessages,
    this.deleteTime,
    required this.isNotification,
    required this.deputyAdminId,
    this.memberApproval,
  }) : message = messageType?.displayMessageType(message) ?? '';

  @HiveField(0)
  final int conversationId;
  @HiveField(1)
  int numberOfUnreadMessage;
  @HiveField(2)
  final bool isGroup;
  @HiveField(3)
  int senderId;
  @HiveField(4)
  String message;
  @HiveField(5)
  MessageType? messageType;
  @HiveField(6)
  int totalNumberOfMessages;
  @HiveField(7)
  int messageDisplay;
  @HiveField(8)
  final String typeGroup;
  @HiveField(9)
  int adminId;
  @HiveField(10)
  String? adminName;
  @HiveField(11)
  List<ChatMemberModel>? browerMemberList;

  /// Những người ở trong cuộc trò chuyện này. Nếu là 1v1 thì 2 người
  /// Nếu là group thì hơn
  @HiveField(12)
  List<ChatMemberModel> memberList;
  @HiveField(13)
  bool isFavorite;
  @HiveField(14)
  bool isHidden;
  @HiveField(15)
  final DateTime createAt;
  @HiveField(16)
  ConversationBasicInfo conversationBasicInfo;

  // TL 16/1/2024 TODO: Là gì vậy?
  @HiveField(17)
  String? status;
  @HiveField(18)
  AutoDeleteMessageTimeModel autoDeleteMessageTimeModel;
  @HiveField(19)
  int? deleteTime;
  @HiveField(20)
  bool isNotification;
  @HiveField(21)
  List<int> deputyAdminId;
  @HiveField(22)
  int? memberApproval;
  @HiveField(23)
  List<SocketSentMessageModel>? lastMessages;

  Map<int, int> unreadMessageUserAndMessageIndex = {};

  /// Danh sách [senderId] và [message] tương ứng chưa đọc
  Map<int, String> unreadMessageUserAndMessageId = {};

  /// Người đầu tiên trong [memberList] có [userId] khác vs [userId] người dùng hiện tại
  ///
  /// [userId]: id người dùng hiện tại
  ChatMemberModel firstOtherMember(int userId) => memberList.firstWhere(
        (e) => e.id != userId,
        orElse: () => memberList.first,
      );

  bool checkFirstOtherMember(int userId) =>
      memberList.where((element) => element.id != userId).isNotEmpty;

  /// [userId] hiện tại của cuộc trò chuyện
  ///
  /// Nếu [isGroup] => [userId] hiện tại là conversationId
  ///
  /// Nếu không => [userId] hiện tại là id của người còn lại trong chat != conversationId
  int effectiveId(int userId) =>
      isGroup ? conversationId : firstOtherMember(userId).id;

  /// Tên hiển thị của cuộc trò chuyện
  ///
  /// Nếu [conversationName] isNotEmpty => [conversationName]
  ///
  /// Nếu [isGroup] => Tên DS thành viên
  ///
  /// Nếu không => chat 2 người => Tên người còn lại [firstOtherMember]
  String effectiveConversationName(int userId) =>
      conversationBasicInfo.name.isNotEmpty
          ? conversationBasicInfo.name
          : isGroup
              ? (browerMemberList ?? memberList).names
              : checkFirstOtherMember(userId)
                  ? firstOtherMember(userId).name
                  : 'unknow';

  /// Nếu [avatar] không null và không rỗng => [avataUrl]
  ///
  /// Nếu không:
  /// - [isGroup]: => rỗng vì [avatar] null hoặc rỗng nên group không có avatar
  /// - [avatar] người còn lại
  String effectiveConversationAvatar(int userId) => isGroup
      ? (conversationBasicInfo.avatar ?? '')
      : firstOtherMember(userId).avatar ?? "";

  // bool get hasUnReadMessgae => numberOfUnreadMessage.state.counter != 0;

  /// [UserStatus] hiện tại của cuộc trò chuyện
  UserStatus currentCoversationUserStatus(int userId) {
    if (!isGroup) return firstOtherMember(userId).userStatus;
    return UserStatus.none;
  }

  factory ChatItemModel.fromMap(
    Map<String, dynamic> json, {
    required MessageType? messageType,
    required String message,
    String? adminName,
    required List<ChatMemberModel> memberList,
    IUserInfo? currentUserInfo,
    UserType? currentUserType,
  }) {
    late final List<ChatMemberModel>? browerMemberList;
    // api thấy có browseMemberList
    if (json["listBrowerMember"] == null)
      browerMemberList = null;
    else {
      final list = List.of(json["listBrowerMember"]);

      browerMemberList = list.isEmpty
          ? null
          : list
              .map<ChatMemberModel>(
                  (e) => ChatMemberModel.fromMap(e['userMember']))
              .toList();
    }

    var isGroup = json["isGroup"] == 1;
    var createAt = json["createAt"] == null
        ? DateTime.now()
        : DateTimeExt.timeZoneParse(json["createAt"]);
    var countUnreadMessage = json["unReader"];

    final int senderId = json["senderId"] ?? -1;
    var lastMessageId = json['messageId'] ?? "-1";
    return ChatItemModel(
      conversationId: json["conversationId"],
      // conversationName: ,
      // avatarConversation: ,
      numberOfUnreadMessage: countUnreadMessage,
      isGroup: isGroup,
      senderId: senderId,
      message: message,
      messageType: messageType,
      totalNumberOfMessages: json["countMessage"],
      messageDisplay: json["messageDisplay"] ?? 0,
      typeGroup: json["typeGroup"],
      deleteTime: json['deleteTime'] ?? -1,
      adminId: json["adminId"],
      adminName: adminName,
      browerMemberList: browerMemberList,
      memberList: memberList,
      deputyAdminId: (json["deputyAdminId"] ?? []).cast<int>() ?? [],
      memberApproval: json["memberApproval"] ?? 2,
      isFavorite: json["isFavorite"] == 1,
      isHidden: json["isHidden"] == 1,
      isNotification: json["notification"] == 1,
      createAt: createAt,
      conversationBasicInfo: ConversationBasicInfo(
        isGroup: isGroup,
        userId: json["conversationId"],
        avatar: (json["avatarConversation"] as String?).isBlank
            ? json["linkAvatar"]
            : json["avatarConversation"],
        conversationId: json["conversationId"],
        lastConversationMessage: message,
        lastConversationMessageTime: createAt,
        countUnreadMessage: countUnreadMessage,
        // isGroup: json["isGroup"] == 1,
        // avatar: await ApiClient().downloadImage(json["avatarConversation"]),
        userStatus: UserStatus.fromId(
          int.tryParse(json["active"].toString()) ?? UserStatus.online.id,
        ),
        friendStatus: FriendStatusExt.fromApiValue(json["friendStatus"] ?? ''),
        // avatarUrl: ImageUrlResolver.avatar(
        //   json["conversationId"],
        //   json["avatarConversation"],
        // ),
        pinMessageId: json['pinMessageId'],
        name: json["conversationName"] ?? '',
        lastMessasgeId: lastMessageId,
        groupLastSenderId: senderId == 0 && lastMessageId != null
            ? int.tryParse(lastMessageId!.split('_').last)
            : senderId,
      ),

      lastMessages: json['listMessage'] != null
          ? List<SocketSentMessageModel>.from(
              (json['listMessage'] as List)
                  .map((e) => SocketSentMessageModel.fromMap(
                        e,
                        userInfo: currentUserInfo,
                        userType: currentUserType,
                      )),
            )
          : null,

      autoDeleteMessageTimeModel: AutoDeleteMessageTimeModel.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => toHiveObjectMap();

  Map<String, dynamic> toHiveObjectMap() {
    return {
      'conversationId': conversationId,
      'numberOfUnreadMessage': numberOfUnreadMessage,
      'isGroup': isGroup,
      'senderId': senderId,
      'message': message,
      'messageType': MessageTypeExt(messageType!)
          .name, // Sử dụng MessageTypeExt.valueOf() để convert ngược lại
      'totalNumberOfMessages': totalNumberOfMessages,
      'messageDisplay': messageDisplay,
      'typeGroup': typeGroup,
      'adminId': adminId,
      'adminName': adminName,
      'browerMemberList': browerMemberList == null
          ? null
          : jsonEncode(
              browerMemberList!.map((e) => jsonEncode(e.toJson())).toList()),
      'memberList':
          jsonEncode(memberList.map((e) => jsonEncode(e.toJson())).toList()),
      'isFavorite': isFavorite,
      'isHidden': isHidden,
      // TL 9/1/2024: Code mới, lưu thời gian theo milli. Code cũ lưu thời gian kiểu gì ý, chả hiểu
      'createAt': createAt.toIso8601String(),
      'conversationBasicInfo': conversationBasicInfo.toJson(),
      'status': status,
      'autoDeleteMessageTimeModel': autoDeleteMessageTimeModel,
      'lastMessages': lastMessages,
      'deleteTime': deleteTime,
      'isNotification': isNotification,
      "deputyAdminId": deputyAdminId,
    };
  }

  /// TL 9/1/2024: Trả về ChatItemModel tương ứng với string json lấy từ toHiveObjectMap()
  factory ChatItemModel.fromJsonString(String json) {
    // Xử lí các trường dynamic cho về đúng class của nó
    var processedJson = jsonDecode(json) as Map<String, dynamic>;
    processedJson["messageType"] =
        MessageTypeExt.valueOf(processedJson["messageType"]);
    processedJson["createAt"] =
        DateTime.tryParse(processedJson["createAt"]) ?? DateTime(0);
    // TL 9/1/2024 TODO: Cần check cả ["conversationBasicInfo"] nữa.
    processedJson["deputyAdminId"] =
        List<int>.from(processedJson["deputyAdminId"]);

    for (final listMem in ["memberList", "browerMemberList"]) {
      processedJson[listMem] = processedJson[listMem] == null
          ? null
          : (jsonDecode(processedJson[listMem]) as List<dynamic>).map((e) {
              //logger.log("Map CMM: ${e}", name: "$runtimeType");
              return ChatMemberModel.fromJson(
                  jsonDecode(e) as Map<String, dynamic>);
            }).toList();
    }

    return ChatItemModel.fromHiveObjectMap(processedJson);
  }

  // factory ChatItemModel.fromJson(Map<String, dynamic> json) =>
  //     ChatItemModel.fromHiveObjectMap(json);

  /// TL 9/1/2024: Code mới.
  /// @map mặc định là đã được jsonDecode tử tế rồi. Xem fromJsonString() nhé
  factory ChatItemModel.fromHiveObjectMap(Map<String, dynamic> map) {
    return ChatItemModel(
        conversationId: map["conversationId"],
        numberOfUnreadMessage: map["numberOfUnreadMessage"],
        isGroup: map["isGroup"],
        senderId: map["senderId"],
        message: map["message"],
        messageType: map["messageType"],
        totalNumberOfMessages: map["totalNumberOfMessages"],
        messageDisplay: map["messageDisplay"],
        typeGroup: map["typeGroup"],
        adminId: map["adminId"],
        memberList: map["memberList"],
        browerMemberList: map["browerMemberList"],
        isFavorite: map["isFavorite"],
        isHidden: map["isHidden"],
        createAt: map["createAt"],
        conversationBasicInfo:
            ConversationBasicInfo.fromJson(map["conversationBasicInfo"]),
        isNotification: map["isNotification"],
        deputyAdminId: map["deputyAdminId"]);
  }

  // TL 9/1/2024: Phá đi xây mới
  // TL 8/1/2024: Bỏ tham số currentUserId, lấy luôn từ AuthRepo
  // factory ChatItemModel.fromHiveObjectMap(
  //         Map<String, dynamic> map) => //, int currentUserId) =>
  //     ChatItemModel.fromConversationInfoJsonOfUser(
  //       AuthRepo().userId!, //currentUserId,
  //       conversationInfoJson: map,
  //     );

  // String toJson(){
  //   return jsonEncode({
  //     'conversationId': conversationId,
  //     'numberOfUnreadMessage': numberOfUnreadMessage,
  //     'isGroup': isGroup,
  //     'SenderID': senderId,
  //     'Message': message,
  //     'messageType': messageType?.toString(),
  //     'totalNumberOfMessages': totalNumberOfMessages,
  //     'messageDisplay': messageDisplay,
  //     'typeGroup': typeGroup,
  //     'adminId': adminId,
  //     'adminName': adminName,
  //     //'browerMemberList': browerMemberList.map((e) => e.),
  //     'memberList': memberList,
  //     'isFavorite': isFavorite,
  //     'isHidden': isHidden,
  //     'createAt': createAt,
  //     'conversationBasicInfo': conversationBasicInfo,
  //     'status': status,
  //     'autoDeleteMessageTimeModel': autoDeleteMessageTimeModel,
  //     'lastMessages': lastMessages,
  //     'deleteTime': deleteTime,
  //     'isNotification': isNotification,
  //   });
  // }

  // Tenshicomment
  factory ChatItemModel.fromConversationInfoJsonOfUser(
    int currentUserId, {
    required Map<String, dynamic> conversationInfoJson,
    IUserInfo? currentUserInfo,
    UserType? currentUserType,
  }) {
    final List<ChatMemberModel> memberList = List<ChatMemberModel>.from(
      conversationInfoJson["listMember"]
              ?.map((x) => ChatMemberModel.fromMap(x)) ??
          [],
    );

    MessageType? messageType;
    try {
      messageType = MessageTypeExt.valueOf(conversationInfoJson["messageType"]);
    } catch (e) {}

    var conversationLastMessage = conversationInfoJson["message"] ?? '';

    String message =
        messageType?.displayMessageType(conversationLastMessage) ?? '';
    // : await _userNameRepo.replaceIdByUserName(e["message"]);

    final model = ChatItemModel.fromMap(
      conversationInfoJson,
      messageType: messageType,
      message: message,
      memberList: memberList,
      currentUserInfo: currentUserInfo,
      currentUserType: currentUserType,
    );
    if (!model.checkFirstOtherMember(currentUserId))
      model.memberList = [model.firstOtherMember(currentUserId)];
    var firstOtherMember = model.firstOtherMember(currentUserId);

    model.conversationBasicInfo
      ..id = model.effectiveId(currentUserId)
      ..name = model.effectiveConversationName(currentUserId)
      ..avatar = model.effectiveConversationAvatar(currentUserId)
      ..userStatus = model.currentCoversationUserStatus(currentUserId)
      ..lastActive = model.isGroup ? null : firstOtherMember.lastActive;

    if (!model.isGroup) {
      model.conversationBasicInfo
        ..companyId = firstOtherMember.companyId
        ..userType = firstOtherMember.userType;
      model.status = firstOtherMember.status;
    } else {
      model.conversationBasicInfo.totalGroupMemebers =
          conversationInfoJson["totalGroupMemebers"] ?? memberList.length;
    }

    return model;
  }

  // ChatItemModel copyWithEdited(String message) => ChatItemModel(
  //       conversationId: conversationId,
  //       numberOfUnreadMessage: numberOfUnreadMessage.state.counter,
  //       isGroup: isGroup,
  //       senderId: senderId,
  //       message: message,
  //       messageType: messageType,
  //       totalNumberOfMessages: totalNumberOfMessages,
  //       messageDisplay: messageDisplay,
  //       typeGroup: typeGroup,
  //       adminId: adminId,
  //       adminName: adminName,
  //       browerMemberList: browerMemberList?,
  //       memberList: memberList,
  //       isFavorite: isFavorite,
  //       isHidden: false,
  //       createAt: createAt,
  //       conversationBasicInfo: conversationBasicInfo,
  //     );

  @override
  String toString() => conversationId.toString();

  @override
  List<Object?> get props => [conversationId, senderId];
}

extension on List<ChatMemberModel> {
  String get names => map((e) => e.name).join(', ');
}
