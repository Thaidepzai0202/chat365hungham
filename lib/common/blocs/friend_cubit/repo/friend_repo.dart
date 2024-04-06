import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:dio/dio.dart';

class FriendRepo {
  FriendRepo();

  final ApiClient _apiClient = ApiClient();

  // @contactId: ID của người mà mình cần check kết bạn với mình
  Future<RequestResponse> checkFriendStatus(int contactId) async {
    return await _apiClient.fetch(ApiPath.checkStatus, data: {
      'userId': AuthRepo().userId,
      'contactId': contactId,
    });
  }

  Future<RequestResponse> getListRequest(int userId) => _apiClient.fetch(
        ApiPath.listFriendRequest,
        data: {
          'ID': userId,
        },
        options: Options(
          receiveTimeout: Duration(seconds: 5000),
        ),
      );
  // lay danh sach ban moi
  Future<RequestResponse> getListNewFriends(int userId) => _apiClient
      .fetch(ApiPath.getListNewFriends(userId), method: RequestMethod.get);

  Future<RequestResponse> addFriend(int senderId, int chatId) =>
      ApiClient().fetch(
        ApiPath.addFriend,
        data: {
          'userId': senderId,
          'contactId': chatId,
        },
      );

  Future<RequestResponse> deleteRequestAddFriend(int senderId, int chatId) =>
      ApiClient().fetch(
        ApiPath.deleteRequestAddFriend,
        data: {
          'userId': senderId,
          'contactId': chatId,
        },
      );

  Future<RequestResponse> deleteContact(int userId, int contact) async {
    return ApiClient().fetch(ApiPath.deleteContact, data: {
      'userId': userId,
      'contactId': contact,
    });
  }
}
