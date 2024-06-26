import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'message_status.g.dart';

/// Trạng thái của [SocketSentMessageModel] hiện tại, bao gồm:
/// Bình thường, đã xóa, đã sửa, đang gửi, đang xóa, gửi bị lỗi, đã thu hồi
@HiveType(typeId: HiveTypeId.messageStatusHiveTypeId)
enum MessageStatus {
  @HiveField(0)
  normal,
  @HiveField(1)
  deleted,
  @HiveField(2)
  edited,
  @HiveField(3)
  sending,
  @HiveField(4)
  deleting,
  @HiveField(5)
  sendError,
  @HiveField(6)
  recall,
}

extension MessageStatusExt on MessageStatus {
  String get name {
    switch (this) {
      case MessageStatus.sending:
        return StringConst.sending;
      case MessageStatus.deleting:
        return StringConst.deleting;
      default:
        return '';
    }
  }

  static final _enableInteractive = {
    MessageStatus.normal: true,
    MessageStatus.deleted: false,
    MessageStatus.edited: true,
    MessageStatus.sending: false,
    MessageStatus.deleting: false,
    MessageStatus.sendError: true,
    MessageStatus.recall: false,
  };

  bool get enableInteractive => _enableInteractive[this]!;
}
