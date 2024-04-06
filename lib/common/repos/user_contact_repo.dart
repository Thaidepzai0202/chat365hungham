import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/get_token_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';

class UserContactRepo{
  Future<RequestResponse> getUsercompanyRandom()async{
    String token = await GetTokenRepo(AuthRepo()).getTokenEmp();
    return await ApiClient().fetch(
        ApiPath.allContactsInCompany2,
        data: {
          'ID': AuthRepo().userInfo!.id,
          'CompanyID': AuthRepo().userInfo?.companyId ?? 0,
          // 'token': AuthRepo.token
        }
    );
  }
}