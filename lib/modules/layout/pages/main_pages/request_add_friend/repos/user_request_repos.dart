import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';

class UserRequestRepo {

  // list request
  Future<RequestResponse> getListRequest()async{
    return await ApiClient().fetch(
      ApiPath.friendRequest,
      data: {
        'userId': AuthRepo().userInfo!.id,
        'skip': 0,
      }
    );
  }
  Future<RequestResponse> getListSendRequest()async{
    return await ApiClient().fetch(
        ApiPath.sentRequest,
        data: {
          'userId': AuthRepo().userInfo!.id,
          'skip': 0,
        }
    );
  }
  Future<RequestResponse> getListUserInCom(
      int idUser,
      int idCom,
      )async{
    return await ApiClient().fetch(
        ApiPath.allContactsInCompany2,
        data: {
          'ID': idUser,
          'CompanyID': idCom,
          // 'token': AuthRepo.authToken
        }
    );
  }

  // từ chối lời mời kết bạn
Future<RequestResponse> requestAddFriend(
    int userId,
    int contactId,
    int friendStatus,
    )async => await ApiClient().fetch(
    friendStatus == 2 ? ApiPath.decilineRequestAddFriend : ApiPath.acceptRequestAddFriend,
      data: {
        'userId': userId,
        'contactId': contactId
      }
    );

  //thu hoi yeu cau ket ban
  Future<RequestResponse> deleteRequestAddFriend(
      int userId,
      int contactId,
      )async => await ApiClient().fetch(
      ApiPath.deleteRequestAddFriend,
      data: {
        'userId': userId,
        'contactId': contactId
      }
  );

  // gửi lời mời kết bạn
  Future<RequestResponse> sendRequestAddFriend(
      int userId,
      int contactId,
      )async => await ApiClient().fetch(
      ApiPath.sendRequestAddFriend,
      data: {
        'userId': userId,
        'contactId': contactId
      }
  );
}