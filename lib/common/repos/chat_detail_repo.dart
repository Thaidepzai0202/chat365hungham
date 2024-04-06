import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:dio/dio.dart';

class ChatDetailRepo {
  /// Id người dùng hiện tại
  final int userId;

  ChatDetailRepo(this.userId);

  @Deprecated("Dùng ChatRepo().getChatItemModel(conversationId) nhé")
  // Future<RequestResponse> loadConversationDetail(int conversationId) =>
  //     ApiClient().fetch(ApiPath.chatInfo, data: {
  //       "conversationId": conversationId,
  //       "senderId": userId,
  //     });

  Future<RequestResponse> changePassword(
          {required String email,
          required int type365,
          required String newPassword,
          required String oldPassword}) =>
      ApiClient().fetch(ApiPath.changePassword, data: {
        "Email": email,
        "type365": type365.toString(),
        "newPassword": newPassword,
        "oldPassword": oldPassword,
      });
  Future<RequestResponse> UpdateDoubleVerify({
    required int status,
    required int userId,
  }) {
    return ApiClient().fetch(
      ApiPath.UpdateDoubleVerify,
      data: {
        'userId': userId,
        'status': status,
      },
    );
  }

  Future<RequestResponse> GetStatusDoubleVerify({
    required int userId,
  }) {
    return ApiClient().fetch(
      ApiPath.GetStatusDoubleVerify,
      data: {
        'userId': userId,
      },
    );
  }

  /// DEPRECATED. Dùng ChatRepo().getMessage()
  // Future<RequestResponse> loadListMessage(
  //   int conversationId,
  //   int adminId, {
  //   // Tổng số tin đã load
  //   required int loadedMessages,

  //   /// Tổng số tin nhắn
  //   required int totalMessages,
  //   int? messageDisplay,
  //   String? messageId,
  // }) =>
  //     //if (totalMessages > loadedMessages) call api
  //     ApiClient().fetch(
  //       ApiPath.chatDetail,
  //       data: {
  //         "conversationId": conversationId,
  //         "adminId": adminId,
  //         "listMess": loadedMessages,
  //         "countMessage": totalMessages,
  //         "messageDisplay": messageDisplay,
  //         "messageId": messageId,
  //       },
  //       options: Options(
  //         receiveTimeout: Duration(milliseconds: 9000),
  //       ),
  //     );

  // lấy danh sách tin nhắn  trùng với tin nhắn tìm kiếm
  Future<RequestResponse> getListFindMessage(
    int conversationId,
    String text,
    String time,
  ) =>
      ApiClient().fetch(
        ApiPath.findMessage,
        data: {
          '_id': conversationId,
          'findword': text.trim(),
          'time': time,
        },
        method: RequestMethod.post,
      );

  // [favorite] 1: true, 0: false
  // TL 18/1/2024: DEPRECATED: Dùng ChatRepo().changeFavoriteStatus() nhé
  // Future<RequestResponse> changeFavoriteConversationStatus(
  //   int conversationId, {
  //   required int favorite,
  // }) =>
  //     ApiClient().fetch(
  //       ApiPath.toogleFavoriteChat,
  //       data: {
  //         'conversationId': conversationId,
  //         'senderId': userId,
  //         'isFavorite': favorite,
  //       },
  //       options: Options(
  //         receiveTimeout: Duration(milliseconds: 7000),
  //       ),
  //     );

  Future<RequestResponse> getMessage(String value) =>
      ApiClient().fetch(ApiPath.getMessage, data: {
        'MessageID': value,
      });

  Future<RequestResponse> getDetailInfo(int idChat, int type, String name) =>
      ApiClient().fetch(ApiPath.get_detail_info,
          data: {
            'id_chat': idChat,
            'type': type,
            'name': name,
          },
          method: RequestMethod.post);
  Future<RequestResponse> getRaonhanhUserInfo(int idChat, int type) =>
      ApiClient().fetch(ApiPath.get_info_raonhanh,
          data: {
            'id_chat': idChat,
            'type': type,
          },
          options: Options(
            receiveTimeout: Duration(milliseconds: 10000),
          ),
          retryTime: 1,
          method: RequestMethod.post);

  deleteNotiMsg(String msgId, int convId, {List<int>? member}) async {
    await ApiClient().fetch(ApiPath.deleteMessage, data: {
      'ConversationID': convId,
      'MessageID': msgId,
    });
    chatClient.emit(ChatSocketEvent.deleteMessage, [
      {
        'MessageID': msgId,
        'ConversationID': convId,
      },
      member,
    ]);
  }
}
