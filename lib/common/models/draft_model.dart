import 'package:app_chat365_pc/common/models/api_livechat_message_model.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';

/// Model dùng để lưu trữ các tin nhắn nháp
class DraftModel {
  final SocketSentMessageModel? editingMessage;
  final ApiReplyMessageModel? replyingMessage;
  final String draftContent;

  DraftModel(
    this.draftContent, {
    this.editingMessage,
    this.replyingMessage,
  });
}
