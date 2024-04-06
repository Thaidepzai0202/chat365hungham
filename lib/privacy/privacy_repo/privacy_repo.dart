import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:dio/dio.dart';
import 'package:sp_util/sp_util.dart';

class PrivacyRepo {
  final dio = Dio();
  // Các api về bật tắt đều quy định 1 là bật - 0 là tắt
  // Hiện sinh nhật
  Future<RequestResponse> changeShowDateOfBirth({
    required int idUser,
    required int showDateOfBirth,
  }) =>
      ApiClient().fetch(
        ApiPath.changeShowDateOfBirth,
        data: {
          'userId': idUser,
          'showDateOfBirth': showDateOfBirth,
        },
      );
  // Hiện trạng thái truy cập
  Future<RequestResponse> changestatusOnline(
    int? idUser,
    int active,
  ) =>
      ApiClient().fetch(
        ApiPath.changestatusOnline,
        data: {
          'userId': idUser,
          'status': active,
        },
      );
  //Cho phép nhắn tin
  Future<RequestResponse> changeChat(
    int? idUser,
    int chat,
  ) =>
      ApiClient().fetch(
        ApiPath.changeChat,
        data: {
          'userId': idUser,
          'chat': chat,
        },
      );
  // Cho phép gọi điện
  Future<RequestResponse> changeCall(
    int? idUser,
    int call,
  ) =>
      ApiClient().fetch(
        ApiPath.changeCall,
        data: {
          'userId': idUser,
          'call': call,
        },
      );
  // Cho phép xem và bình luận
  Future<RequestResponse> changeShowPost(
    int? idUser,
    String post,
  ) =>
      ApiClient().fetch(
        ApiPath.changeShowPost,
        data: {
          'userId': idUser,
          'post': post,
        },
      );
  // Bật tắt hiển thị trạng thái đã xem
  Future<RequestResponse> changeSeenMessage(
    int? idUser,
    int status,
  ) =>
      ApiClient().fetch(
        ApiPath.changeSeenMessage,
        data: {
          'userId': idUser,
          'status': status,
        },
      );
  // Chặn tin nhắn
  Future<RequestResponse> blockMessage(
    int? idUser,
    int userBlocked,
  ) =>
      ApiClient().fetch(
        ApiPath.blockMessage,
        data: {
          'userId': idUser,
          'userBlocked': userBlocked,
        },
      );
  // Bỏ chặn tin nhắn
  Future<RequestResponse> unblockMessage(
    int? idUser,
    int userBlocked,
  ) =>
      ApiClient().fetch(
        ApiPath.unblockMessage,
        data: {
          'userId': idUser,
          'userBlocked': userBlocked,
        },
      );
  // check 2 người có chặn nhau không
  Future<bool> checkBlockMessage(
    int? idUser,
    int userId2,
  ) async {
    Response response;
    response = await dio.post(
      ApiPath.checkBlockMessage,
      data: {
        'userId1': idUser,
        'userId2': userId2,
      },
    );
    print(response.data.toString());
    return response.data;
  }

  // Lấy danh sách người dùng bị chặn tin nhắn
  // Future<RequestResponse> getListBlockMessage(
  //   int? idUser,
  //   int userBlocked,
  // ) =>
  //     ApiClient().fetch(
  //       ApiPath.getListBlockMessage,
  //       data: {
  //         'userId': idUser,
  //         'type': userBlocked,
  //       },
  //     );
  // // Lấy danh sách người dùng bị chặn tin đăng
  // Future<RequestResponse> getListBlockPost(
  //   int? idUser,
  //   int type,
  // ) =>
  //     ApiClient().fetch(
  //       ApiPath.getListBlockPost,
  //       data: {
  //         'userId': idUser,
  //         'type': type,
  //       },
  //     );
  // Quản lý nguồn tìm kiếm và kết bạn
  Future<RequestResponse> searchSource(
    int? idUser,
    int? searchByPhone,
    int? qrCode,
    int? generalGroup,
    int? businessCard,
    int? suggest,
  ) =>
      ApiClient().fetch(
        ApiPath.searchSource,
        data: {
          'userId': idUser,
          'searchByPhone': searchByPhone,
          'qrCode': qrCode,
          'generalGroup': generalGroup,
          'businessCard': businessCard,
          'suggest': suggest,
        },
      );
  // Lấy thông tin quyền riêng tư
  Future<RequestResponse> GetPrivacy({
    int? idUser,
  }) =>
      ApiClient().fetch(
        ApiPath.getPrivacy,
        data: {
          'userId': idUser,
        },
      );
  Future<RequestResponse> GetAccountsByDevice({
    int? idUser,
  }) =>
      ApiClient().fetch(
        ApiPath.getAccountsByDevice,
        data: {
          'userId': idUser,
          //'idDevice': '4c51b1cbb13480ed',
          'idDevice': SpUtil.getString(LocalStorageKey.idDevice),
        },
      );
}
