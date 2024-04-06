// To parse this JSON data, do
//
//     final resultLogin = resultLoginFromJson(jsonString);

import 'dart:convert';

import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/data/services/sp_utils_service/sp_utils_services.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/date_time_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/data/models/error_response.dart';
import 'package:hive_flutter/hive_flutter.dart';

ResultLogin resultLoginFromJson(String str) =>
    ResultLogin.fromJson(json.decode(str));

String resultLoginToJson(ResultLogin data) => json.encode(data.toJson());

class ResultLogin {
  ResultLogin({
    required this.data,
    required this.error,
  });

  final Data? data;
  final ErrorResponse? error;

  factory ResultLogin.fromJson(Map<String, dynamic> json) => ResultLogin(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        error: json["error"] == null
            ? null
            : ErrorResponse.fromJson(json["error"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? null : data!.toJson(),
        "error": error == null ? null : error!.toJson(),
      };
}

class Data {
  Data({
    required this.result,
    required this.message,
    required this.userInfo,
    required this.serverSentTime,
    required this.countConversation,
    required this.warning,
  }) {
    if (serverSentTime != 0) {
      serverTicks = serverSentTime;
      serverDifferenceTickWithClient = DateTimeExt.currentTicks - serverTicks;
    } else {
      serverDifferenceTickWithClient = spService.serverDiffTickWithClient ?? 0;
    }
    spService.saveServerDiffTickWithClient(serverDifferenceTickWithClient);
  }

  final bool result;
  final String message;
  final UserInfo userInfo;
  final int serverSentTime;
  final int countConversation;
  final int warning;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        result: json["result"] ?? false,
        message: json["message"] ?? '',
        userInfo: UserInfo.fromJson(json["user_info"] ?? {}),
        serverSentTime: json["currentTime"],
        countConversation: json["countConversation"],
        warning: json["warning"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "message": message,
        "user_info": userInfo.toJson(),
        "warning": warning,
      };
}

// TL 6/1/2024: Cắt bớt code dư do app mobile dùng Dart 2, còn app PC dùng Dart 3
// TODO: Cắt bớt userName, avatar, active
class UserInfo extends IUserInfo {
  UserInfo._({
    required super.id,
    required super.name,
    required super.avatar,
    required super.userStatus,
    super.fromWeb,
    super.email,
    super.password,
    super.status,
    super.isOnline,
    super.lastActive,
    super.companyId,
    super.id365,
    super.idTimviec,
    super.userQr,
    super.userType,
    super.seenMessage,
    super.nameCom,
    this.looker,
    this.statusEmotion,
    this.phoneTk,
    this.phone,
  });

  // TL 9/1/2024: Thêm constructor UserInfo để generate Hive
  // @avatarUser là URL avatar
  factory UserInfo({
    required int id,
    required String userName,
    required UserStatus active,
    String? avatarUser,
    String? fromWeb = '',
    String? email,
    String? password,
    String? status,
    int? isOnline,
    DateTime? lastActive,
    int? companyId,
    int? id365,
    int? idTimviec,
    String? userQr,
    UserType? userType,
    int? seenMessage = 1,
    String? companyName,
    int? looker,
    int? statusEmotion,
    String? phoneTk,
    String? phone,
  }) {
    var userInfo = UserInfo._(
      id: id,
      name: userName,
      // TL 13/1/2024: Sửa IUserInfo về hết thành URL
      avatar: avatarUser, //"",
      userStatus: active,
      fromWeb: fromWeb,
      email: email,
      password: password,
      status: status,
      isOnline: isOnline,
      lastActive: lastActive,
      companyId: companyId,
      id365: id365,
      idTimviec: idTimviec,
      userQr: userQr,
      userType: userType,
      seenMessage: seenMessage,
      nameCom: companyName,
      looker: looker,
      statusEmotion: statusEmotion,
      phone: phone,
      phoneTk: phoneTk,
    );

    // avatarUser.isBlank
    //     ? ApiClient().downloadImage(avatarUser).then(
    //         (value) => value.isNotEmpty ? userInfo.avatar = value : avatarUser)
    //     : userInfo.avatar = avatarUser;

    return userInfo;
  }

  @HiveField(IUserInfo.maxHiveFieldId + 1)
  final String? phoneTk;
  @HiveField(IUserInfo.maxHiveFieldId + 2)
  final String? phone;
  @HiveField(IUserInfo.maxHiveFieldId + 3)
  final int? looker;
  @HiveField(IUserInfo.maxHiveFieldId + 4)
  final int? statusEmotion;

  @override
  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: json["id"] ?? json["_id"] ?? 0,
        email: json["email"] ?? "",
        password: json["password"] ?? "",
        phone: json["phone"] ?? "",
        userName: json["userName"] ?? "",
        avatarUser: (!(json["avatarUser"] as String?).isBlank
                ? json["avatarUser"]
                : json["linkAvatar"]) is String
            ? ((!(json["avatarUser"] as String?).isBlank
                    ? json["avatarUser"]
                    : json["linkAvatar"]) ??
                "")
            : "",
        status: json["status"] ?? '',
        active: UserStatus.fromId(json["active"] ?? 0),
        isOnline: json["isOnline"] ?? 0,
        looker: json["looker"] ?? 0,
        statusEmotion: json["statusEmotion"] ?? 0,
        lastActive: NullableDateTimeExt.lastActiveFromJson(json),
        companyId: json["companyId"] ?? 0,
        companyName: json["companyName"] ?? "",
        id365: json["iD365"] ?? json["id365"],
        idTimviec: json["iDTimviec"] ?? json["idTimviec"] ?? json['idTimViec'],
        fromWeb: json["fromWeb"] ?? "",
        userQr: json["userQr"] ?? "",
        seenMessage: json["seenMessage"] ?? 1,
        userType: UserType.fromId(json['type365'] ?? 0),
      );

  @override
  factory UserInfo.fromLocalStorageJson(Map<String, dynamic> json) =>
      UserInfo.fromJson(json);

  UserInfo copyWith({
    int? id,
    String? userName,
    UserStatus? active,
    String? avatarUser,
    int? companyId,
    String? email,
    int? id365,
    String? status,
    DateTime? lastActive,
    String? password,
    UserType? userType,
    String? userQr,
    String? fromWeb,
    int? idTimviec,
    int? seenMessage,
    String? companyName,
    int? isOnline,
  }) {
    return UserInfo(
      id: id ?? this.id,
      userName: userName ?? name,
      active: active ?? userStatus,
      avatarUser: avatarUser ?? avatar,
      companyId: companyId ?? this.companyId,
      email: email ?? this.email,
      id365: id365 ?? this.id365,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      userQr: userQr ?? this.userQr,
      fromWeb: fromWeb ?? this.fromWeb,
      idTimviec: idTimviec ?? this.idTimviec,
      seenMessage: seenMessage ?? this.seenMessage,
      companyName: companyName ?? nameCom,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "userName": name,
        "avatar": avatar,
        "userStatus": userStatus,
        "fromWeb": fromWeb,
        "email": email,
        "password": password,
        "status": status,
        "isOnline": isOnline,
        "lastActive": DateTimeExt.lastActiveServerDateFormat
            .format(lastActive ?? DateTime.now()),
        "companyId": companyId,
        "iD365": id365,
        "iDTimviec": idTimviec,
        "userQr": userQr,
        "userType": userType,
        "seenMessage": seenMessage,
        "nameCom": nameCom,
        "looker": looker,
        "statusEmotion": statusEmotion,
        //this.phoneTk,
        "phone": phone,
      };

  @override
  Map<String, dynamic> toLocalStorageJson() {
    return toJson();
  }
}

class UserInfoAdapter extends TypeAdapter<UserInfo> {
  @override
  UserInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return UserInfo(
      id: fields[0],
      userName: fields[1],
      active: fields[2],
      avatarUser: fields[3],
      companyId: fields[4],
      email: fields[5] == "" ? null : fields[5],
      id365: fields[6] == -1 ? null : fields[6],
      status: fields[7] == "" ? null : fields[7],
      lastActive: fields[8] == -1
          ? null
          : DateTime.fromMicrosecondsSinceEpoch(fields[8]),
      password: fields[9] == "" ? null : fields[9],
      userType: fields[11],
      userQr: fields[12] == "" ? null : fields[12],
      fromWeb: fields[13],
      idTimviec: fields[14] == -1 ? null : fields[14],
      seenMessage: fields[15],
      companyName: fields[17] == "" ? null : fields[17],
      isOnline: fields[18] == -1 ? null : fields[18],
    );

    /// 2 fields không được đụng đến
    //{
    //friendStatus: fields[10],
    //depId: fields[16] == -1? null : fields[16],
    //}
  }

  @override
  int get typeId => HiveTypeId.userInfoHiveTypeId;

  @override
  void write(BinaryWriter writer, UserInfo obj) {
    writer.writeByte(19);
    writer.writeByte(0);
    writer.writeInt(obj.id);

    writer.writeByte(1);
    writer.writeString(obj.name);
    writer.writeByte(2);
    UserStatusAdapter().write(writer, obj.userStatus);

    writer.writeByte(3);
    writer.write(obj.avatar);
    writer.writeByte(4);
    writer.writeInt(obj.companyId ?? -1);

    writer.writeByte(5);
    writer.writeString(obj.email ?? "");
    writer.writeByte(6);
    writer.writeInt(obj.id365 ?? -1);

    writer.writeByte(7);
    writer.writeString(obj.status ?? "");

    writer.writeByte(8);
    writer.writeInt(obj.lastActive?.millisecondsSinceEpoch ?? -1);

    writer.writeByte(9);
    writer.writeString(obj.password ?? "");

    writer.writeByte(10);
    FriendStatusAdapter()
        .write(writer, obj.friendStatus ?? FriendStatus.unknown);

    writer.writeByte(11);
    UserTypeAdapter().write(writer, obj.userType ?? UserType.unAuth);
    writer.writeByte(12);
    writer.writeString(obj.userQr ?? "");
    writer.writeByte(13);
    writer.writeString(obj.fromWeb ?? "");
    writer.writeByte(14);
    writer.writeInt(obj.idTimviec ?? -1);
    writer.writeByte(15);
    writer.writeInt(obj.seenMessage ?? -1);
    writer.writeByte(16);
    writer.writeInt(obj.depId ?? -1);

    writer.writeByte(17);
    writer.writeString(obj.nameCom ?? "");
    writer.writeByte(18);
    writer.writeInt(obj.isOnline ?? -1);
  }
}
