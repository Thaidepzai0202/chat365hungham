import 'dart:async';
import 'dart:convert';

import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

// where is phone number
/// Hiển thị [name], [avatar], [id] người dùng hiện tại
@HiveType(typeId: HiveTypeId.iUserInfoHiveTypeId)
abstract class IUserInfo extends Equatable implements Comparable<IUserInfo> {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  UserStatus userStatus;

  /// TL 13/1/2024: Từ giờ sẽ sử dụng URL thôi nhé,
  /// không lưu dạng binary List<int> nữa.
  /// Việc lưu như nào, để DefaultCacheManager() lo
  @HiveField(3)
  String? avatar;

  @HiveField(4)
  int? companyId;
  @HiveField(5)
  String? email;
  @HiveField(6)
  int? id365;

  /// Dòng text hiển thị dưới tên người dùng
  @HiveField(7)
  String? status;

  /// Thời gian online gần nhất
  ///
  /// Nếu là [null]: người đó đang online
  @HiveField(8)
  DateTime? lastActive;
  @HiveField(9)
  String? password;

  /// [FriendStatus] của user với user hiện tại
  /// - Nếu là user => mặc định [FriendStatus.unknown]
  /// - Nếu là group hoặc không phải thông tin người dùng => [null]
  @HiveField(10)
  FriendStatus? friendStatus;

  @HiveField(11)
  UserType? userType;

  @HiveField(12)
  String? userQr;
  @HiveField(13)
  String? fromWeb;
  @HiveField(14)
  int? idTimviec;
  @HiveField(15)
  int? seenMessage;
  @HiveField(16)
  int? depId;

  /// Tên công ty
  @HiveField(17)
  String? nameCom;
  @HiveField(18)
  int? isOnline;

  /// Thêm 1 trường [HiveField] cần tăng thêm 1 đơn vị
  static const maxHiveFieldId = 18;

  IUserInfo(
      {required this.id,
      required this.name,
      this.id365,
      this.avatar,
      this.companyId,
      this.depId,
      this.userStatus = UserStatus.online,
      this.email,
      this.status,
      this.lastActive,
      this.password,
      this.friendStatus,
      this.userType,
      this.userQr,
      this.fromWeb,
      this.idTimviec,
      this.seenMessage,
      this.nameCom,
      this.isOnline});

  factory IUserInfo.fromJson(
    Map<String, dynamic> json, {
    UserType userType = UserType.staff,
  }) {
    // if (userType == UserType.staff || userType == UserType.customer)
    return UserInfo.fromJson(json);
    // else
    //   throw UnimplementedError();
  }

  factory IUserInfo.fromLocalStorageJson(
    Map<String, dynamic> json, {
    UserType userType = UserType.staff,
  }) {
    // if (userType == UserType.staff || userType == UserType.customer)
    return UserInfo.fromLocalStorageJson(json);
    // else
    //   throw UnimplementedError();
  }

  Map<String, dynamic> toJson();

  FutureOr<Map<String, dynamic>> toLocalStorageJson();

  String toJsonString() => json.encode(toJson());

  @override
  int compareTo(IUserInfo other) {
    return this.name.compareTo(other.name);
  }

  @override
  List<Object?> get props => [id];
}

class BasicInfo extends IUserInfo {
  BasicInfo({
    required int id,
    String? name,
    DateTime? lastActive,
    // required this.state,
  }) : super(id: id, name: name ?? 'Người dùng $id', lastActive: lastActive
            // userStatus: state,
            );

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  FutureOr<Map<String, dynamic>> toLocalStorageJson() {
    throw UnimplementedError();
  }

  @override
  String toString() => name;
}
