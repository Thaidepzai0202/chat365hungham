import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';

class NotificationRepos {
  // lấy danh sách thông báo
  Future<RequestResponse> takeListNoti() async {
    return await ApiClient().fetch(
      ApiPath.getListNoti(AuthRepo().userInfo!.id),
        method: RequestMethod.get
    );
  }

  // read all noti

  Future <RequestResponse> readAllNoti() async {
  return await ApiClient().fetch(
      ApiPath.readAllNoti(AuthRepo().userInfo!.id),
      method: RequestMethod.get
  );
  }

  // Delete all noti
Future <RequestResponse> deleteAllNoti () async{
    return await ApiClient().fetch(
        ApiPath.deleteAllNotification(AuthRepo().userInfo!.id),
        method: RequestMethod.get
    );
}

// Đọc thông báo
  Future <RequestResponse> readNoti (
      String notiId,
      ) async{
    return await ApiClient().fetch(
        ApiPath.readNoti(notiId),
        method: RequestMethod.get
    );
  }
}