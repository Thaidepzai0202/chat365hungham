import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_chat365_pc/common/models/login_model.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/map_service/map_service.dart';
import 'package:app_chat365_pc/data/services/sp_utils_service/sp_utils_services.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:dio/dio.dart';
import 'package:sp_util/sp_util.dart';

class AuthRepo {
  static AuthRepo? _instance;

  factory AuthRepo() => _instance ??= AuthRepo._();

  AuthRepo._();

  /// [UserType] hiện tại
  static UserType _userType = UserType.unAuth;

  UserType get userType => _userType;

  set userType(UserType value) => _userType = value;

  /// Thông tin người dùng hiện tại
  IUserInfo? _userInfo;

  IUserInfo? get userInfo => _userInfo;

  set userInfo(IUserInfo? info) => _userInfo = info;

  String get userName => _userInfo?.name ?? '';

  int? get userId => _userInfo?.id;

  // TL 13/1/2024: Sửa IUserInfo về hết thành URL
  String? get userAvatar => _userInfo?.avatar;

  //

  static String? get idUser => SpUtil.getString('id_user', defValue: null);

  static int? get depId => SpUtil.getInt(LocalStorageKey.depId, defValue: null);

  static String? get nameDepartment =>
      SpUtil.getString(LocalStorageKey.nameDepartment);

  static String? get nameUser => SpUtil.getString('name_user', defValue: null);

  //lưu lại idRoom
  static String? get idRoom => SpUtil.getString('id_room', defValue: null);

  static String? get deviceID =>
      SpUtil.getString(AppConst.DEVICE_ID, defValue: null);

  static String? get authToken =>
      SpUtil.getString(LocalStorageKey.authToken, defValue: null);
  static String? get token =>
      SpUtil.getString(LocalStorageKey.token, defValue: null);
  static String? get refreshtoken =>
      SpUtil.getString(LocalStorageKey.refresh_token, defValue: null);
  // static String? get tokenTimviec => dataInfo.value?.token?.value;

  // static Map<String, dynamic> get headersTimviec => {
  //       'Content-type': 'application/json',
  //       'Accept': 'application/json',
  //       'Authorization': 'Bearer $tokenTimviec'
  //     };

  static String? get tokenQLC =>
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7Il9pZCI6MTM0Mzc3MiwiaWRUaW1WaWVjMzY1IjowLCJpZFFMQyI6OTMyMzgyLCJpZFJhb05oYW5oMzY1IjoyMDQ2MTgsImVtYWlsIjoiIiwicGhvbmVUSyI6IjA5NjM0MzkyNjMiLCJjcmVhdGVkQXQiOjE2ODg2Mjc5NDEsInR5cGUiOjAsImNvbV9pZCI6MCwidXNlck5hbWUiOiJraHVvbmcifSwiaWF0IjoxNjkzNDQzODY1LCJleHAiOjE2OTM1MzAyNjV9.0wGNa4g__oQu9OIRksuHZn67y45ieWsosuN2D7zEAyo';

  final _controller = StreamController<AuthStatus>.broadcast();

  // TL 4/1/2024
  /// Khiến stream emit status cho các bên cần biết sự kiện đăng nhập thành công
  @Deprecated(
      """Lẽ ra các hành động đăng kí đăng nhập phải xử lí luôn ở AuthRepo, rồi emit status.
  Nhưng code hiện tại để logic hết ở LoginCubit nên đành làm TẠM thế này. 
  Tương lai cần rút logic từ LoginCubit về đây""")
  void addStatus(AuthStatus status) {
    _controller.add(status);
  }

  Stream<AuthStatus> get status async* {
    bool hasInfoInLocalStorage = checkInfoInLocalStorage();
    if (hasInfoInLocalStorage) {
      try {
        _userType = UserType.fromJson(json.decode(spService.userType!));
        _userInfo = IUserInfo.fromLocalStorageJson(
          json.decode(spService.userInfo!),
          userType: _userType,
        );

        await tryFetchNewUserInfo();
      } catch (e, s) {
        logger.logError(e, s);
        // spService.clearToLogout();
        if (e is CustomException && !e.error.isNetworkException)
          yield AuthStatus.unauthenticated;
      }
      yield AuthStatus.authenticated;
    } else {
      yield AuthStatus.unauthenticated;
    }
    yield* _controller.stream;
  }

  static bool checkInfoInLocalStorage() =>
      !spService.userInfo.isBlank && !spService.userType.isBlank;

  void saveNewestUserInfo(
    IUserInfo newUserInfo,
    int newCountConversation,
  ) async {
    _userInfo = newUserInfo;
    await spService.saveUserInfo(_userInfo!);
    if (newCountConversation != 0)
      await spService.saveTotalConversation(newCountConversation);
  }

  /// Fetch thông tin mới nhất của người dùng
  tryFetchNewUserInfo() async {
    try {
      var fetchNewestUserInfoResult = await getUserInfo(
        _userInfo!.id,
        retryTime: 1,
      );
      if (!fetchNewestUserInfoResult.hasError) {
        var resultLoginData =
            resultLoginFromJson(fetchNewestUserInfoResult.data).data!;
        var userInfo = resultLoginData.userInfo;
        saveNewestUserInfo(
          userInfo,
          resultLoginData.countConversation,
        );
      } else {
        // Fluttertoast.showToast(msg: 'Lỗi khi tải dữ liệu [-98]');
        throw fetchNewestUserInfoResult.error?.messages ?? '';
      }
    } catch (e) {
      print('id nef: ${_userInfo?.id}');
      print('[ERROR] ${e.toString()}');
      // Fluttertoast.showToast(msg: 'Lỗi khi tải dữ liệu [-99]');
    }
  }

  Future<RequestResponse> login(UserType userType, LoginModel loginModel,
      {bool isMD5Pass = false}) {
    var data = loginModel.toMap(
      userType.id.toString(),
      isMD5Pass: isMD5Pass,
    );
    // TL 4/1/2024: Bỏ test code
    // if (loginModel.email == "doanbh@gmail.com")
    //   data = {
    //     "Email": "doanbh@gmail.com",
    //     "Password": 123456,
    //     "Type365": 2,
    //   };
    // if (loginModel.email == fakeEmail) {
    //   dontNeedMarkRead = 1;
    // } else {
    //   dontNeedMarkRead = 0;
    // }
    return ApiClient().fetch(
      ApiPath.login,
      // 'http://43.239.223.142:9000/api/conv/auth/login',
      // isFormData: false,
      data: data,
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
  }

  //check tk đã tải app chat hay chưa
  Future<RequestResponse> updateStatusDownLoadChat365(int idChat) {
    return ApiClient().fetch(ApiPath.updateStatusDownLoadChat365, data: {
      'chat365_id': idChat,
      'status_dowload_appchat': 1,
      'status_dowload_wfchat': 0
    });
  }

  refreshTokenApp() async {
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${AuthRepo.refreshtoken}'
    };
    try {
      var res =
          await ApiClient().fetch(ApiPath.refresh_token, headers: headers);
      if (res.hasError) {
        logger.log(res.error!.messages, name: 'lỗi refreshToken');
      } else {
        var body = jsonDecode(res.data);
        var token = body['data']['token'];
        var refreshNewToken = body['data']['refreshToken'];
        SpUtil.putString(LocalStorageKey.authToken, token);
        SpUtil.putString(LocalStorageKey.token, token);
        SpUtil.putString(LocalStorageKey.refresh_token, refreshNewToken);
        print('refreshToken day---$token ----------- $refreshNewToken ----');
      }
    } catch (e, s) {
      logger.log('$e--------$s', name: 'lỗi refreshToken');
    }
  }

  ///QR Login
  Future<RequestResponse> getInfoQR(String? idUser) {
    return ApiClient().fetch(
      ApiPath.getUserInfo,
      data: {
        'ID': idUser,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 5000),
      ),
    );
  }

  Future<RequestResponse> getListContact(int? idUser) {
    return ApiClient().fetch(
      ApiPath.get_list_contact + '${idUser}',
      options: Options(
        receiveTimeout: Duration(milliseconds: 5000),
      ),
      method: RequestMethod.get,
    );
  }

  Future<RequestResponse> acceptLogin() {
    return ApiClient().fetch(ApiPath.acceptLogin, data: {
      'UserId': SpUtil.getInt(LocalStorageKey.userId2),
      'IdDevice': SpUtil.getString(LocalStorageKey.idDevice),
      'NameDevice':
          '${SpUtil.getString(LocalStorageKey.nameDevice)} - ${Platform.isAndroid ? 'Android' : 'Ios'}',
    });
  }

  Future<RequestResponse> GetStatusDoubleVerify({
    required int userId,
  }) {
    return ApiClient().fetch(
      ApiPath.GetStatusDoubleVerify,
      data: {
        'userId': userId,
      },
    );
  }

  // Future<RequestResponse> confirmLogin(String listContact) {
  //   return ApiClient().fetch(
  //     ApiPath.confirm_login,
  //     data: {
  //       'myId': SpUtil.getInt(LocalStorageKey.userId2),
  //       'IdDevice': SpUtil.getString(LocalStorageKey.idDevice),
  //       'NameDevice':
  //           '${SpUtil.getString(LocalStorageKey.nameDevice)} - ${Platform.isAndroid ? 'Android' : 'Ios'}',
  //       'listUserId': listContact,
  //     },
  //     options: Options(
  //       receiveTimeout: 5000,
  //     ),
  //     method: RequestMethod.post,
  //   );
  // }

  Future<RequestResponse> confirmLoginOTP() {
    return ApiClient().fetch(
      ApiPath.confirm_login_otp,
      data: {
        'myId': SpUtil.getInt(LocalStorageKey.userId2),
        'IdDevice': SpUtil.getString(LocalStorageKey.idDevice),
        // 'IdDevice': '${SpUtil.getString(LocalStorageKey.idDevice)}a',
        'NameDevice':
            '${SpUtil.getString(LocalStorageKey.nameDevice)} - ${Platform.isAndroid ? 'Android' : 'Ios'}',
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 5000),
      ),
      method: RequestMethod.post,
    );
  }

  // /// Chi dung de dang nhap tai khoan Cong ty va Nhan vien
  // Future<RequestResponse> loginAccountCompany(
  //     UserType userType, LoginModel loginModel) {
  //   return ApiClient().fetch(
  //     userType == UserType.company
  //         ? ApiPath.loginCompany
  //         : ApiPath.loginEmployee,
  //     data: loginModel.toMapAccountCompnay(),
  //     options: Options(
  //       receiveTimeout: 3000,
  //     ),
  //   );
  // }

  @Deprecated("Dùng UserInfoRepo().getUserInfo() nhé.")
  Future<RequestResponse> getUserInfo(
    int id, {
    int retryTime = AppConst.refecthApiThreshold,
  }) =>
      ApiClient().fetch(
        ApiPath.getUserInfo,
        data: {'ID': id},
        retryTime: retryTime,
      );

  Future<RequestResponse> compareId(String idCompany) {
    return ApiClient().fetch(
      ApiPath.detailCompany,
      method: RequestMethod.get,
      searchParams: {'id_com': idCompany},
      options: Options(
        receiveTimeout: Duration(milliseconds: 9000),
      ),
    );
  }

  Future<RequestResponse> getOTPForgotPassword(String email, int idUserType) {
    return ApiClient().fetch(
      ApiPath.sendOtp_nodeJS,
      data: {
        'mail': email,
        // 'type_user': idUserType == 2 ? '1' : idUserType == 1 ? '2' : '3',
        // 'type_otp': 1
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
  }

  // /// Chi dung cho dang ky tai khoan khach
  // Future<RequestResponse> getOTPSignUp(String email) {
  //   return ApiClient().fetch(
  //     ApiPath.register,
  //     data: {'Email': email},
  //     options: Options(
  //       receiveTimeout: 10000,
  //     ),
  //   );
  // }

  /// Dung cho gui otp cong ty
  Future<RequestResponse> sendOtpCompany({required String email}) {
    return ApiClient().fetch(
      ApiPath.sendOtp_nodeJS,
      // method: RequestMethod.get,
      data: {
        'mail': email,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 8000),
      ),
    );
  }

  /// Dung gui otp xac thuc dang ky tai khoan cong ty
  // Future<RequestResponse> sendconfirmOtpCompany({required String email}) {
  //   return ApiClient().fetch(
  //     ApiPath.sendOtp,
  //     // method: RequestMethod.get,
  //     data: {
  //       'email': email,
  //       'type_user': userType == UserType.company
  //           ? '2'
  //           : userType == UserType.staff
  //               ? '1'
  //               : '3',
  //       'type_otp': 0,
  //     },
  //     options: Options(
  //       receiveTimeout: 9000,
  //     ),
  //   );
  // }
  /// Dung de xac thuc otp tai khoan cong ty
  Future<RequestResponse> compareOTP({
    required String email,
  }) {
    return ApiClient().fetch(
      ApiPath.verifyOtp,
      // method: RequestMethod.get,
      data: {
        'email': email,
        'type_user': userType.reverseID,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
  }

  Future<RequestResponse> signUp(
      {required String account,
      required String userName,
      required String password}) {
    return ApiClient().fetch(
      ApiPath.signUpEmployeePrivateNew,
      data: {
        'phoneTK': account,
        'password': password.trim(),
        'userName': userName.trim(),
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
  }

  Future<RequestResponse> signUpEmployee(
      {required String email,
      required String userName,
      required String password,
      required String phoneNumber,
      required String address,
      required String gender,
      required String dateOfBirth,
      required String idAcademicLevel,
      required String idMaritalStatus,
      required String idWorkExperience,
      required String? idNest,
      required String? idGroup,
      required String idCompany,
      required String idDepartment,
      required String idPosition}) {
    return ApiClient().fetch(
      ApiPath.signUpEmployeeNew,
      data: {
        'phoneTK': email,
        'password': password,
        'userName': userName.trim(),
        'phone': phoneNumber,
        // 'role': 4,
        'com_id': idCompany,
        'dep_id': idDepartment,
        'position_id': idPosition,
        'address': address.trim(),
        'gender': gender,
        'birthday': (DateTime.tryParse(dateOfBirth) ?? DateTime.now())
            .toIso8601String(),
        'education': idAcademicLevel,
        'startWorkingTime': '',
        'married': idMaritalStatus,
        'experience': idWorkExperience,
        'team_id': idNest,
        'group_id': idGroup,
        //!Phan de tu kich hoat tai khoan api chamcong
        'from': 'chat365',
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
  }

  Future<RequestResponse> signUpCompany({
    required String email,
    required String userName,
    required String password,
    required String phoneNumber,
    required String address,
  }) {
    return ApiClient().fetch(
      ApiPath.signUpCompanyNew,
      data: {
        'phoneTK': email,
        'password': password,
        'userName': userName.trim(),
        'phone': phoneNumber,
        'address': address.trim(),
        //!Phan de tu kich hoat tai khoan api chamcong
        // 'from': 'chat365',
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
  }

  Future<RequestResponse> addEmployee({
    required String idCompany,
    required String email,
    required String userName,
    required String password,
    required String phoneNumber,
    required String address,
    required String idPosition,
    required String idPermision,
  }) {
    return ApiClient().fetch(
      ApiPath.addFirstEmployee,
      data: {
        'email': email,
        'password': password,
        'ep_name': userName.trim(),
        'ep_phone': phoneNumber,
        'role': idPermision,
        'com_id': idCompany,
        'ep_address': address.trim(),
        'position_id': idPosition,
        'from': 'chat365',
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
  }

  Future<RequestResponse> checkIdCompany({required String id_com}) {
    return ApiClient().fetch(
      ApiPath.newCompanyExists,
      method: RequestMethod.post,
      data: {
        'com_id': id_com,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
  }

  Future<RequestResponse> getNests(
      {required String idCom, required String idDepartment}) {
    return ApiClient().fetch(
      ApiPath.getListNest,
      method: RequestMethod.get,
      searchParams: {
        'id_nest': idDepartment,
        'cp': idCom,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
  }

  Future<RequestResponse> getGroups(
      {required String idCom, required String idNest}) {
    return ApiClient().fetch(
      ApiPath.getListGroup,
      method: RequestMethod.get,
      searchParams: {
        'id_nhom': idNest,
        'cp': idCom,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
  }

  Future<RequestResponse> checkNameCompany({required String nameCompany}) {
    return ApiClient().fetch(
      ApiPath.checkNameCompanyNew,
      data: {'username': nameCompany.trim()},
      options: Options(
        receiveTimeout: Duration(milliseconds: 8000),
      ),
    );
  }

  ///Ham kiem tra account bi trung hay khong
  ///Khong nhat thiet truyen id nguoi dung vi com id moi la bien phan biet
  Future<RequestResponse> checkAccount(
      {required String contactSignUp,
      required UserType userType,
      required String? idCompany}) {
    return ApiClient().fetch(
      ApiPath.checkAccountNew,
      data: {
        'input': contactSignUp,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
  }

  Future<RequestResponse> updatePassword(
      {required String contactSignUp,
      required String password,
      required int idType}) {
    return ApiClient().fetch(
      ApiPath.updatePassword,
      data: {
        'Email': contactSignUp,
        'Password': password,
        'Type365': idType,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 9000),
      ),
    );
  }

  Future<RequestResponse> takePerChangePassword({
    required String number,
  }) {
    return ApiClient().fetch(
      ApiPath.takePerChangePass,
      data: {
        'number': number,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 9000),
      ),
    );
  }

  Future<RequestResponse> changePassword(
      {required String contactSignUp,
      required String newPassword,
      required String oldPassword,
      //required int idType,
      required int idUser}) {
    return ApiClient().fetch(
      ApiPath.changePassword,
      data: {
        'Email': contactSignUp,
        'newPassword': newPassword,
        'oldPassword': oldPassword,
        //'Type365': idType,
        'ID': idUser,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 9000),
      ),
    );
  }

  Future<RequestResponse> getDepartment({required String id_com}) {
    return ApiClient().fetch(
      ApiPath.detailCompany,
      data: {
        'id_com': id_com,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
  }

  Future<RequestResponse> deleteAccount(int chatId) async {
    return ApiClient().fetch(
      ApiPath.deleteAccount,
      data: {'id': chatId},
      options: Options(
        receiveTimeout: const Duration(milliseconds: 10000),
      ),
    );
  }

  int _tempId = 0;

  int get tempId => _tempId;

  Future<bool> getIdChat365(String email) async {
    var res = await ApiClient().fetch(ApiPath.getIdChatByEmailPhone, data: {
      'EmailPhone': email,
      'type365': userType.id,
    });
    if (!res.hasError) {
      try {
        print(json.decode(res.data)['data']['user']['_id'].toString());
        _tempId = int.tryParse(
                json.decode(res.data)['data']['user']['_id'].toString()) ??
            0;
        if (AuthRepo().userId != null &&
            AuthRepo().userId != 0 &&
            !AuthRepo.authToken.isBlank) {
          chatClient.emit(ChatSocketEvent.login,
              [tempId, StringConst.fromChat365]);
        }
      } catch (e) {
        return false;
      }
      return true;
    }
    return false;
  }

  Future<List<IUserInfo>> takeDataUserByMailPhone(String email) async {
    var res = await ApiClient()
        .fetch(ApiPath.takeDataUserByMailPhone, data: {'Infor': email});
    if (res.hasError) return [];
    return (json.decode(res.data)['data']['listUser'] as List)
        .map((e) => IUserInfo.fromJson(e))
        .toList();
  }

  // Future<RequestResponse> updateLocation(int userId) async {
  //   var res = await ApiClient().fetch(ApiPath.updateLocation, data: {
  //     'userId': userId,
  //     'latitude': MapService().position.latitude,
  //     'longtitude': MapService().position.longitude
  //   });
  //   return res;
  // }

  emitLogin(int id) {
    chatClient.emit(ChatSocketEvent.login, [id, StringConst.fromChat365]);
  }

  logout() async {
    await SPService().clearToLogout();
    // chatClient.emit(
    //   ChatSocketEvent.logout,
    //   userId,
    // );
    // userInfo = null;
    // quickMessage.clear();
    // pinCode = '';
    // ListHidden.clear();
    // countText = 0;
    // dataInfo.value = null;
  }

  void dispose() {
    _controller.close();
  }
}
