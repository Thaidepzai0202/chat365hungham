import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'friend_status.g.dart';

@HiveType(typeId: HiveTypeId.friendStatusHiveTypeId)
enum FriendStatus {
  /// Một trong hai người đã từ chối
  @HiveField(0)
  decline,

  /// [user hiện tại] gửi kết bạn đến [user khác]
  @HiveField(1)
  send,

  /// [user khác] gửi kết bạn đến [user hiện tại]
  @HiveField(2)
  request,

  /// Đã là bạn bè
  @HiveField(3)
  accept,

  /// Chưa phải bạn bè?
  @HiveField(4)
  unknown,
}

extension FriendStatusExt on FriendStatus {
  /// TL 11/1/2024: Dùng để lưu local cho tiện
  static String valueOf(FriendStatus? status) {
    switch (status) {
      case FriendStatus.accept:
        return 'accept';
      case FriendStatus.decline:
        return 'deciline';
      case FriendStatus.request:
        return 'request';
      case FriendStatus.send:
        return 'send';
      default:
        return 'none';
    }
  }

  String get apiValue {
    return FriendStatusExt.valueOf(this);
  }

  static FriendStatus fromValue(String value) =>
      FriendStatus.values.singleWhere(
        (e) => e.apiValue == value,
        orElse: () => FriendStatus.unknown,
      );

  static final _apiValue = {
    'none': FriendStatus.unknown,
    'accept': FriendStatus.accept,
    'deciline': FriendStatus.decline,
    'send': FriendStatus.send,
    'request': FriendStatus.request,
    'friend': FriendStatus.accept,
  };

  static FriendStatus fromApiValue(String value) =>
      _apiValue[value] ?? FriendStatus.unknown;
}
