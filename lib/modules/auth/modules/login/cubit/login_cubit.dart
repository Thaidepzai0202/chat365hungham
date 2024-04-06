import 'dart:convert';
import 'dart:io';

import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/api_contact.dart';
import 'package:app_chat365_pc/common/models/get_info_qr_model.dart';
import 'package:app_chat365_pc/common/models/login_model.dart';
import 'package:app_chat365_pc/common/models/login_verification_model.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/data/services/sp_utils_service/sp_utils_services.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/clients/mqtt_client.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_status.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:bloc/bloc.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/main.dart' as m;
import 'package:app_chat365_pc/service/injection.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/data/models/error_response.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:sp_util/sp_util.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  // LoginCubit() : super(LoginStateInit());

  final AuthRepo _authRepo = AuthRepo();

  static LoginCubit? _instance;

  factory LoginCubit() => _instance ??= LoginCubit._();

  LoginCubit._() : super(LoginStateInit());

  login(
    UserType userType,
    LoginModel loginModel, {
    bool rememberAccount = false,
    bool isMD5Pass = false,
    bool verifyRequire = true,
  }) async {
    var res;
    emit(LoginStateLoad());
    try {
      res = await _authRepo.login(
        userType,
        loginModel,
        isMD5Pass: isMD5Pass,
      );
      if (!res.hasError) {
        var data = resultLoginFromJson(res.data).data!;
        var userInfo = data.userInfo;

        AuthRepo().userInfo = userInfo;

        SpUtil.putString(LocalStorageKey.userInfo,
                json.encode(AuthRepo().userInfo!.toLocalStorageJson())) ??
            Future.value(false);
        chatClient.emit('Login', [AuthRepo().userInfo?.id ?? 0, 'chat365']);
        // logger.log(AuthRepo().userInfo!.id,name: 'lllllllll');
        // _authRepo.updateStatusDownLoadChat365(userInfo.id);
        // TL 13/1/2024: Sửa IUserInfo về hết thành URL
        //userInfo.avatar = await ApiClient().downloadImage(userInfo.avatar);
        SpUtil.putString(LocalStorageKey.phoneTk, loginModel.email);
        SpUtil.putInt(LocalStorageKey.userId2, userInfo.id);
        SpUtil.putString(
            LocalStorageKey.authToken, jsonDecode(res.data)['data']['token']);
        var body = jsonDecode(res.data);
        var token = body['data']['token'];
        var ref_token = body['data']['refreshtoken'];
        SpUtil.putString(LocalStorageKey.refresh_token, ref_token);
        SpUtil.putString(LocalStorageKey.token, token);
        List<ApiContact> listFriend = await getlistContact(userInfo.id);
        int status = await GetStatusDoubleVerify(userInfo.id);
        chatClient.emit(ChatSocketEvent.login,
              [userInfo.id, StringConst.fromChat365]);
        if (data.warning == 1 &&
            listFriend.isNotEmpty &&
            status == 1) if (verifyRequire)
          return emit(LoginWaring(
            userInfo,
            countConversation: data.countConversation,
            userType: userType,
            verifyRequire: verifyRequire,
          ));
        else
          await ApiClient().fetch(ApiPath.change_accept_device,
              data: {'userId': userInfo.id});

        /// Đăng nhập thành công
        emit(
          LoginStateSuccess(
            userInfo,
            message: 'Đăng nhập thành công',
            countConversation: data.countConversation,
            userType: userType,
          ),
        );
        // TL 4/1/2024: emit event đăng xuất để xóa cache
        AuthRepo().addStatus(AuthStatus.authenticated);
      } else {
        ErrorResponse error =
            ErrorResponse.fromJson(json.decode(res.data)['error']);
        // Khi tai khoan nhan vien chua duoc duyet
        switch (error.code) {
          case 301:
            logger.log('Có trigger chưa duyệt', color: StrColor.cyan);
            emit(LoginStateUnBrowser('Tài khoản chưa được duyệt bởi công ty'));
            break;
          case 308:
            emit(LoginStateError(
                'Tài khoản hoặc mật khẩu không chính xác', error));
            break;
          case 450:
            emit(LoginStateAlternateType(0));
            break;
          case 451:
            emit(LoginStateAlternateType(1));
            break;
          case 452:
            emit(LoginStateAlternateType(2));
            break;
          default:
            emit(LoginStateError(res.error!.messages!,
                ErrorResponse.fromJson(json.decode(res.data)['error'])));
            break;
        }
      }
      // }
      // print('Gia tri nhan duoc la : ${res.error}');
    } catch (e, s) {
      logger.logError(e, s);
      emit(LoginStateError(StringConst.errorHappenedTryAgain, null));
    }
  }

  String? passQR;
  String? emailQR;
  String? error;
  int? type365;

  Future getInfoQR(String? idUser, {int? typeUser}) async {
    emit(LoginLoadingQR());
    var res = await _authRepo.getInfoQR(idUser);
    try {
      if (res.error == null) {
        emit(LoginSuccessQR());
        var data = loginInfoQrModelFromJson(res.data);
        emailQR = data.data?.userInfo.email;
        passQR = data.data?.userInfo.password;
        type365 = typeUser ?? data.data?.userInfo.type365;
        await login(UserType.fromId(type365!), LoginModel(emailQR!, passQR!),
            isMD5Pass: true);
      } else {
        error = res.error?.messages;
        emit(LoginErrorQR(res.error?.messages ?? ""));
        // print('Error: ${res.error}');
      }
    } catch (e, s) {
      logger.logError(e, s);
      // emit(LoginErrorQR(e.toString()));
    }
  }

  // List<FriendList> listAccount;
  // List<String> listAccountId ;
  // List<String> listAccountName;

  Future listContact(
    int? idUser,
  ) async {
    var res = await _authRepo.getListContact(idUser);
    try {
      if (res.error == null) {
        final model = await loginVerificationModelFromJson(res.data);
        // listAccount = model.data!.listAccount;
        emit(ListContactSuccessState(model: model.data!));
      } else {
        print('lỗi rồi nhé!');
      }
    } catch (e, s) {
      logger.logError(e, s);
    }
  }

  Future<List<ApiContact>> getlistContact(
    int? idUser,
  ) async {
    var res = await _authRepo.getListContact(idUser);
    try {
      return res.onCallBack((_) {
        return List<ApiContact>.from(
            jsonDecode(res.data)['data']['friendlist'].map((e) => ApiContact(
                  id: e['_id'],
                  name: e['userName'],
                  companyId: null,
                  avatar: e['avatarUser'],
                  lastActive: DateTime.tryParse(e['lastActive'] ?? ''),
                )));
      });
    } on CustomException catch (_) {
      return [];
    }
  }

  Future<int> GetStatusDoubleVerify(int userId) async {
    var res = await _authRepo.GetStatusDoubleVerify(userId: userId);
    return res.onCallBack(
      (_) => int.parse(json
          .decode(res.data)['data']['data'] /*['configChat']*/ ['doubleVerify']
          .toString()),
    );
  }

  Future acceptLogin() async {
    var res = await _authRepo.acceptLogin();
    emit(LoginStateInit());
    try {
      if (res.error == null) {
        BotToast.showText(text: 'Bạn đã xác nhận tài khoản thành công');
        emit(LoginSuccessfulTestState());
      } else {}
    } catch (e, s) {
      s;
    }
  }

  // Future confirmLogin(
  //   String listContact,
  //   // UserType userType,
  //   // IUserInfo iUserInfo,
  // ) async {
  //   var res = await _authRepo.confirmLogin(listContact);
  //   emit(LoginStateInit());
  //   try {
  //     if (res.error == null) {
  //       AppDialogs.toast('Bạn đã xác nhận tài khoản thành công');
  //       emit(LoginSuccessfulTestState());
  //     } else {
  //       if (res.error!.messages == "Danh sách bạn bè không chính xác") {
  //         checkFail++;
  //         emit(CheckFailure());
  //       }
  //       AppDialogs.toast((json.decode(res.data)['error']['message']));
  //       // emit(LoginWrongFriendsListState());
  //     }
  //   } catch (e, s) {
  //     s;
  //   }
  // }

  Future confirmOtpCheckLogin() async {
    var res = await _authRepo.confirmLoginOTP();
    try {
      if (res.error == null) {
        BotToast.showText(text: 'Bạn đã xác nhận tài khoản thành công');
        emit(LoginSuccessfulTestState());
      } else {
        BotToast.showText(text: (json.decode(res.data)['error']['message']));
        // emit(LoginWrongFriendsListState());
      }
    } catch (e, s) {
      s;
    }
  }

  Future<LatLng> getCurrentPosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  LatLng defaultLatlng = const LatLng(21.0278, 105.8342);
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return defaultLatlng;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
       return defaultLatlng;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return defaultLatlng;
  } 
  Position currentPosition = await Geolocator.getCurrentPosition();
  return LatLng(currentPosition.latitude, currentPosition.longitude);
}

  Future<String> generateLoginQRData() async {
    LatLng currentPosition = await getCurrentPosition();
    Map<String, dynamic> qrData = {
      "QRType": "QRLoginPc",
      "idQR": base64.encode(utf8.encode(sessid)),
      "IdComputer": sessid,
      "NameComputer": Platform.localHostname,
      "latitude": currentPosition.latitude,
      "longitude": currentPosition.longitude,
      "Time": DateFormat("dd/MM/yyyy hh:mm").format(DateTime.now()),
      "UserType": 0,
      "fromWeb": "timviec365.vn"
    };
    logger.log(qrData, name: "SocketEventsQR");
    return jsonEncode(qrData);
  }

  void listenForQRLoginSocket() {
    chatClient.emit(ChatSocketEvent.loginWithDeviceId, [sessid, 'timviec365']);
  }

  @override
  void onChange(Change<LoginState> change) {
    // TODO: implement onChange
    if (change.nextState is LoginStateSuccess) {
      var state = (change.nextState as LoginStateSuccess);
      var userInfo = state.userInfo;
      var userType = state.userType;
    }

    //
    super.onChange(change);
  }
}
