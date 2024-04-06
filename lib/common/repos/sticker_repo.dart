import 'dart:convert';

import 'package:app_chat365_pc/common/models/api_sticker_model.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:dio/dio.dart';

import '../../utils/data/clients/api_client.dart';

class StickerRepo {
  final _apiClient = ApiClient();
  Future<List<StickerModel>> getSticker() async {
    try {
      var requestResponse = await Dio().request(ApiPath.getSticker);
      if (requestResponse.statusCode != 200) {
        logger.log(requestResponse.data);
      } else {
        List data = jsonDecode(requestResponse.data);

        var liststicker =
            data.map<StickerModel>((e) => StickerModel.fromJson(e)).toList();
        print(liststicker.toString());

        return liststicker;
      }
    } catch (e) {
      logger.logError(e.toString());
    }
    return [];
  }
}
