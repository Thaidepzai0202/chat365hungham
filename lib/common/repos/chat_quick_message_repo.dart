import 'dart:io';

import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/chat_quick_message.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ChatQuickMessageRepo {
  /// Id người dùng hiện tại
  final int userId;

  ChatQuickMessageRepo(this.userId);

  Future<RequestResponse> createFastMessage(
      QuickMessageModel quickMessage) async {
    return ApiClient().fetch(ApiPath.createFastMessage,
        data: {
          'userId': quickMessage.userId,
          'title': quickMessage.title,
          'message': quickMessage.message,
          'image': quickMessage.image != null
              ? await MultipartFile.fromFile(quickMessage.image!.path)
              : null
        },
        method: RequestMethod.post,
        baseOptions: BaseOptions(connectTimeout: Duration(milliseconds: 25000)),
        retryTime: 5);
  }

  Future<RequestResponse> editFastMessage(
      {required String Id,
      required String title,
      required String message,
      required File? image,
      required int? isImage}) async {
    if (image != null && image.path.contains('https://')) {
      var save = (await getTemporaryDirectory()).absolute.path;
      var file = await Dio().download(
        image.path,
        save + '/${image.path.split('/').last}',
        // onReceiveProgress: (progress, total) =>
        //     logger.log((progress * 100 / total).toString()),
      );
      if (file.statusCode == 200)
        image =
            File.fromUri(Uri.parse(save + '/${image.path.split('/').last}'));
    }
    return ApiClient().fetch(ApiPath.editFastMessage,
        data: {
          'id': Id,
          'title': title,
          'message': message,
          'image':
              image != null ? await MultipartFile.fromFile(image.path) : null,
          'isImage': isImage ?? 0
        },
        method: RequestMethod.post,
        baseOptions: BaseOptions(connectTimeout: Duration(milliseconds: 25000)),
        retryTime: 5);
  }

  Future<RequestResponse> getFastMessage(int uID) => ApiClient().fetch(
      ApiPath.getFastMessage,
      data: {'userId': uID},
      method: RequestMethod.post,
      baseOptions: BaseOptions(connectTimeout: Duration(milliseconds: 25000)),
      retryTime: 5);

  Future<RequestResponse> deleteFastMessage(String id) => ApiClient().fetch(
      ApiPath.deleteFastMessage + '/$id',
      method: RequestMethod.delete,
      baseOptions: BaseOptions(connectTimeout: Duration(milliseconds: 25000)),
      retryTime: 5);
}
