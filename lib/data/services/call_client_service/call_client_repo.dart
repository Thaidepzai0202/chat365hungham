import 'dart:convert';

import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';


class CallClientRepo {
  ApiClient client = ApiClient();

  Future<bool> getServiceStatus() async {
    RequestResponse res = await client.fetchPost(ApiPath.getSFUServiceStatus);
    if (!res.hasError) {
      Map<String, dynamic> json = jsonDecode(res.data);
      return json["sfuAvailable"];
    } else {
      return false;
    }
  }
}
