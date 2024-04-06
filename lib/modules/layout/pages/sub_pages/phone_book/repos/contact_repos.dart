import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';

class ContactListRepo {
// lấy danh sách bạn bè
  Future<RequestResponse> getMyContact() async {
    return await ApiClient().fetch(ApiPath.myContacts,
        data: {
          'ID': AuthRepo().userInfo!.id,
          'countContact': 0,
        },
        method: RequestMethod.post);
  }

  // danh sách bạn mới(mới kết bạn gần đây)
  Future<RequestResponse> getListNewFriend() async {
    return await ApiClient().fetch(
        ApiPath.getListNewFriends(AuthRepo().userInfo!.id),
        method: RequestMethod.get);
  }

  // xoá liên hệ
  Future<RequestResponse> deleteContact(int contactId) async {
    return await ApiClient().fetch(ApiPath.deleteContact,
        data: {
          'userId': AuthRepo().userInfo!.id,
          'contactId': contactId,
        },
        method: RequestMethod.post);
  }
}
