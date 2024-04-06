import 'dart:convert';
import 'package:app_chat365_pc/common/models/com_item_model.dart';
import 'package:app_chat365_pc/common/models/result_login_get_token_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/sp_utils_service/sp_utils_services.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:sp_util/sp_util.dart';

class GetTokenRepo {
  final ApiClient _apiClient;
  final AuthRepo authRepo;
  GetTokenRepo(this.authRepo) : _apiClient = ApiClient();

  String? get _tokenVT => spService.tokenVT;

  // IUserInfo get userInfo => authRepo.userInfo!;

  // Future<RequestResponse> _getToken(
  //     String? pass, int? idUser, int? idCom, String? account, int? type) async {
  //   if (idCom == 220309 || (idUser ?? 0) > 10000000) {
  //     var res = await _apiClient.fetch(
  //       ApiPath.get_token_new,
  //       data: {
  //         'account': account,
  //         'password': pass,
  //         'type': type,
  //         'pass_type': 1
  //       },
  //       method: RequestMethod.post,
  //     );
  //     dynamic result = json.decode(res.data);
  //     String data = jsonEncode({
  //       'data': {
  //         'result': true,
  //         'message': "Đăng nhập thành công",
  //         'access_token': result['data']['data']['access_token'],
  //         'refresh_token': result['data']['data']['refresh_token'],
  //       }
  //     });
  //     res = RequestResponse(data, res.result, res.code, error: res.error);
  //     return res;
  //   } else {
  //     var res = await _apiClient.fetch(
  //       ApiPath.get_token,
  //       data: {
  //         'pass': pass,
  //         'ep_id': idUser,
  //         'com_id': idCom,
  //       },
  //       method: RequestMethod.post,
  //     );
  //     return res;
  //   }}
  Future<RequestResponse> _getTokenNewAPI(
    String? pass,
    String? phoneTk,
  ) async {
    var res = await ApiClient().fetch(
      ApiPath.loginComQlc,
      data: {
        'phoneTK': phoneTk,
        'password': pass,
        'type': 1,
      },
      method: RequestMethod.post,
    );
    return res;
  }
  // get token company QLC
  Future<String> getTokenComQLC() async {
    final RequestResponse res = await _getTokenComQLC(
      SpUtil.getString(LocalStorageKey.passwordClass),
      SpUtil.getString(LocalStorageKey.phoneTk),
    );
    if (res.error == null) {
      await SpUtil.putString(LocalStorageKey.tokenQLC,
          jsonDecode(res.data)['data']['data']['access_token']);
      return _tokenQLC!;
    } else {
      if (res.error!.messages ==
          'Thông tin tài khoản hoặc mật khẩu không chính xác')
        BotToast.showText(text: StringConst.function_error);
      throw CustomException(res.error!);
    }
  }
  Future<RequestResponse> _getTokenComQLC(
      String? pass,
      String? account,
      ) async {
    var res = await ApiClient().fetch(
      ApiPath.get_token_new,
      data: {
        'account': account,
        'password': pass,
        'type': 1,
      },
      method: RequestMethod.post,
    );

    return res;
  }

  Future<RequestResponse> _getTokenEmp(
      String? pass,
      String? account,
      ) async {
    var res = await ApiClient().fetch(
      ApiPath.get_token_new,
      data: {
        'account': account,
        'password': pass,
        'type': 2,
      },
      method: RequestMethod.post,
    );

    return res;
  }
  Future<ComItem> comID() async {
    final RequestResponse res = await _getTokenNewAPI(
      SpUtil.getString(LocalStorageKey.passwordClass),
      SpUtil.getString(LocalStorageKey.phoneTk),
    );
    if (!res.hasError) {
      var data = json.decode(res.data);
     var comItem = ComItem.fromJson(data['data']['data']);
     return comItem;
    } else {
      if (res.error!.messages ==
          'Thông tin tài khoản hoặc mật khẩu không chính xác')
        BotToast.showText(text: StringConst.function_error);
;
      throw CustomException(res.error!);
    }
  }
  Future<String> getRefeshTokenNewAPI(
      ) async {
    final RequestResponse res = await _getTokenNewAPI(
      SpUtil.getString(LocalStorageKey.passwordClass),
      SpUtil.getString(LocalStorageKey.phoneTk),
    );
    if (res.error == null) {
      await SpUtil.putString(LocalStorageKey.tokenQLC,
          jsonDecode(res.data)['data']['data']['refresh_token']);
      return _tokenQLC!;
    } else {
      if (res.error!.messages ==
          'Thông tin tài khoản hoặc mật khẩu không chính xác')
        BotToast.showText(text: StringConst.function_error);
;
      throw CustomException(res.error!);
    }
  }
  Future<String> getTokenNewAPI(
      ) async {
    final RequestResponse res = await _getTokenNewAPI(
      SpUtil.getString(LocalStorageKey.passwordClass),
      SpUtil.getString(LocalStorageKey.phoneTk),
    );
    if (res.error == null) {
      await SpUtil.putString(LocalStorageKey.tokenQLC,
          jsonDecode(res.data)['data']['data']['access_token']);
      return _tokenQLC!;
    } else {
      if (res.error!.messages ==
          'Thông tin tài khoản hoặc mật khẩu không chính xác')
        BotToast.showText(text: StringConst.function_error);
;
      throw CustomException(res.error!);
    }
  }
  Future<RequestResponse> _getToken(
      String? pass, int? idUser, int? idCom, String? account, int? type) async {
    print('______________${idCom}________${idUser}');
    if (idCom == 220309 || (idUser ?? 0) > 10000000) {
      var res = await _apiClient.fetch(
        ApiPath.get_token_new,
        data: {
          'account': account,
          'password': pass,
          'type': type,
          'pass_type': 1
        },
        method: RequestMethod.post,
      );
      dynamic result = json.decode(res.data);
      String data = jsonEncode({
        'data': {
          'result': true,
          'message': "Đăng nhập thành công",
          'access_token': result['data']['data']['access_token'],
          'refresh_token': result['data']['data']['refresh_token'],
        }
      });
      res = RequestResponse(data, res.result, res.code, error: res.error);
      return res;
    } else {
      var res = await _apiClient.fetch(
        ApiPath.get_token,
        data: {
          'pass': pass,
          'ep_id': idUser,
          'com_id': idCom,
        },
        method: RequestMethod.post,
      );
      return res;
    }
  }



  IUserInfo get userInfo => authRepo.userInfo!;

  String? get _token => spService.token;

  // getConfig() async {
  //   if (token == null) {
  //     var error = await getToken();
  //     if (error != null)
  //     return emit(GetTokenStateLoadError(error));
  //   }
  //   _getConfig();
  // }
  Future<String> getTokenEmp() async {
    ///Check token null || ""
    // if (!token.isBlank) return token!;
    final RequestResponse res = await _getTokenEmp(
      SpUtil.getString(LocalStorageKey.passwordClass),
      userInfo.email,
    );
    if (res.error == null) {
      await SpUtil.putString(LocalStorageKey.tokenQLC,
          jsonDecode(res.data)['data']['data']['access_token']);
      return _tokenQLC!;
    } else {
      if (res.error!.messages ==
          'Thông tin tài khoản hoặc mật khẩu không chính xác')
        BotToast.showText(text: StringConst.function_error);
;
      throw CustomException(res.error!);
    }
  }
  Future<String> getToken() async {
    ///Check token null || ""
    // if (!token.isBlank) return token!;
    final RequestResponse res = await _getToken(
        userInfo.password!,
        userInfo.id365,
        userInfo.companyId,
        userInfo.email,
        userInfo.userType != null ? userInfo.userType!.id : 2);
    var model = resultGetTokensModelFromJson(res.data);
    if (res.error == null) {
      await SpUtil.putString(
          LocalStorageKey.token, model.data?.accessToken ?? '');
      await SpUtil.putString(
          LocalStorageKey.refresh_token, model.data?.refreshToken ?? '');
      print('AccessToken: ${model.data?.accessToken}');
      print('RefreshToken: ${model.data?.refreshToken}');
      return _token!;
    } else {
      if (res.error!.messages ==
          'Thông tin tài khoản hoặc mật khẩu không chính xác')
        BotToast.showText(text: StringConst.function_error);
;
      throw CustomException(res.error!);
    }
  }

  String? get _tokenQLC => spService.tokenQLC;

  String? get _tokenCc => spService.tokenCc;

  Future<RequestResponse> _getTokenCC(String? pass, String? email) async {
    var res = await ApiClient().fetch(
      ApiPath.loginEmployeeCC,
      data: {'email': email, 'pass': pass},
      method: RequestMethod.post,
    );

    return res;
  }

  Future<RequestResponse> _getTokenQLC(
      String? pass, String? email, int? type) async {
    var res = await ApiClient().fetch(
      ApiPath.loginQLCNew,
      data: {'account': email, 'password': pass, 'type': type},
      method: RequestMethod.post,
    );

    return res;
  }

  Future<RequestResponse> _getTokenTV365(String? pass, String? email) async {
    var res = await ApiClient().fetch(
      ApiPath.loginOldApi,
      data: {'email': email, 'pass': pass},
      method: RequestMethod.post,
    );

    return res;
  }

  Future<String> getTokenTV() async {
    final RequestResponse res = await _getTokenTV365(
      SpUtil.getString(LocalStorageKey.passwordClass),
      AuthRepo().userInfo!.email,
    );
    if (res.error == null) {
      await SpUtil.putString(
          LocalStorageKey.tokenCC, jsonDecode(res.data)['data']['token']);
      // await SpUtil.putString(LocalStorageKey.refresh_token,
      //     jsonDecode(res.data)['data']['refresh_token']);
      print('AccessTokenCC: ${_tokenCc}');
      return _tokenCc!;
    } else {
      if (res.error!.messages ==
          'Thông tin tài khoản hoặc mật khẩu không chính xác')
        ;
      throw CustomException(res.error!);
    }
  }

  // getToken Chấm công
  Future<String> getTokenCC() async {
    final RequestResponse res = await _getTokenCC(
      SpUtil.getString(LocalStorageKey.passwordClass),
      AuthRepo().userInfo!.email,
    );
    if (res.error == null) {
      await SpUtil.putString(LocalStorageKey.tokenCC,
          jsonDecode(res.data)['data']['access_token']);
      await SpUtil.putString(LocalStorageKey.refresh_token,
          jsonDecode(res.data)['data']['refresh_token']);
      print('AccessTokenCC: ${_tokenCc}');
      return _tokenCc!;
    } else {
      if (res.error!.messages ==
          'Thông tin tài khoản hoặc mật khẩu không chính xác')
        BotToast.showText(text: StringConst.function_error);
;
      throw CustomException(res.error!);
    }
  }

// getTokenQLC
  Future<String> getTokenQLC() async {
    final RequestResponse res = await _getTokenQLC(
      SpUtil.getString(LocalStorageKey.passwordClass),
      AuthRepo().userInfo!.email,
      AuthRepo().userType.id,
    );
    if (res.error == null) {
      await SpUtil.putString(LocalStorageKey.nameDepartment,
          jsonDecode(res.data)['data']['data']['user_info']['dep_name']);
      await SpUtil.putString(LocalStorageKey.tokenQLC,
          jsonDecode(res.data)['data']['data']['access_token']);
      await SpUtil.putString(LocalStorageKey.refresh_token,
          jsonDecode(res.data)['data']['data']['refresh_token']);
      print('AccessTokenQLC: ${_tokenCc}');
      return _tokenQLC!;
    } else {
      if (res.error!.messages ==
          'Thông tin tài khoản hoặc mật khẩu không chính xác')
        BotToast.showText(text: StringConst.function_error);
;
      throw CustomException(res.error!);
    }
  }

  /// dùng để test văn thư
  Future<RequestResponse> _getTokenVT(
      String? pass, String? email, int? type) async {
    var res = await ApiClient().fetchVanThu(
      ApiPath.loginQLCNew,
      data: {'account': email, 'password': pass, 'type': type},
      method: RequestMethod.post,
    );
    return res;
  }

  // getToken Văn thư
  Future<String> getTokenVanThu() async {
    final RequestResponse res = await _getTokenVT(
      SpUtil.getString(LocalStorageKey.passwordClass),
      AuthRepo().userInfo!.email,
      AuthRepo().userType.id,
    );
    if (res.error == null) {
      var data = jsonDecode(res.data);

      await SpUtil.putString(
          LocalStorageKey.tokenVT, data['data']['data']['access_token']);
      print('AccessTokenVT: ${SpUtil.getString(LocalStorageKey.tokenVT)}');
      return _tokenVT!;
    } else {
      if (res.error!.messages ==
          'Thông tin tài khoản hoặc mật khẩu không chính xác')
        AppDialogs.showFunctionLockDialog(navigatorKey.currentContext!,
            title: StringConst.function_error);
      throw CustomException(res.error!);
    }
  }
}
