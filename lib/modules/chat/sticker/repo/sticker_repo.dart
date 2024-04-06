import 'dart:convert';

import 'package:app_chat365_pc/common/models/com_item_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/get_token_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';

class StickerRepos {
  ApiClient client = ApiClient();

  Future<RequestResponse> getAllSticker() async {
    //ComItem? comItem = await GetTokenRepo(AuthRepo()).comID();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer '
    };

    return await client.fetch(ApiPath.getSticker,
        headers: headers, method: RequestMethod.post);
  }
}
