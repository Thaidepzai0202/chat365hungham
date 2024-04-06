import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';

class UserSearchRepo{
  Future<RequestResponse> userSearch(
      int senderId,
      String type,
      String? message,
      int companyId
      ) async {
    return await ApiClient().fetch(
        ApiPath.userSearch,
        data: {
          'senderId': senderId,
          'type': type,
          'message': message,
          'companyId': companyId
        },
        method: RequestMethod.post
    );}
}