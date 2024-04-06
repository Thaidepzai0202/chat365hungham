import 'dart:convert';

import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:sp_util/sp_util.dart';

class SPService {
  Future<void> getInstance() async {
    if (!SpUtil.isInitialized()) await SpUtil.getInstance();
  }

  static final SPService _singleton = SPService._internal();

  factory SPService() => _singleton;

  SPService._internal();

  /// Get data

  int? get comId => SpUtil.getInt(LocalStorageKey.comId);

  String? get token => SpUtil.getString(LocalStorageKey.token);

  String? get tokenQLC => SpUtil.getString(LocalStorageKey.tokenQLC);

  String? get tokenCc => SpUtil.getString(LocalStorageKey.tokenCC);

  String? get tokenVT => SpUtil.getString(LocalStorageKey.tokenVT);

  String? get authToken => SpUtil.getString(LocalStorageKey.authToken,defValue: null);

  // String? get firebaseToken => SpUtil.getString(LocalStorageKey.firebase_token);

  String? get userType => SpUtil.getString(LocalStorageKey.userType);

  String? get userInfo => SpUtil.getString(LocalStorageKey.userInfo);

  int? get totalConversation =>
      SpUtil.getInt(LocalStorageKey.totalConversation);

  int? get serverDiffTickWithClient =>
      SpUtil.getInt(LocalStorageKey.serverDiffTickWithClient);

  List<String> get loggedInEmail =>
      SpUtil.getStringList(LocalStorageKey.loggedInEmail, defValue: []) ?? [];

  bool get isDeniedContactPermission => SpUtil.getBool(
        LocalStorageKey.isDeniedContactPermission,
        defValue: false,
      )!;

  /// Save data

  Future<bool> saveUserInfo(IUserInfo info) async {
    var encode = json.encode(await info.toLocalStorageJson());
    return SpUtil.putString(
          LocalStorageKey.userInfo,
          encode,
        ) ??
        Future.value(false);
  }

  Future<bool> saveUserType(UserType userType) =>
      SpUtil.putString(
        LocalStorageKey.userType,
        json.encode(userType.toJson()),
      ) ??
      Future.value(false);

  Future<bool> saveTotalConversation(int total) async {
    if (total == 0) {
      logger.logError('========= Saving 0 to TotalConversation =========');
    }
    return SpUtil.putInt(LocalStorageKey.totalConversation, total) ??
        Future.value(false);
  }

  Future<bool> saveServerDiffTickWithClient(int differenceTick) async {
    return SpUtil.putInt(
            LocalStorageKey.serverDiffTickWithClient, differenceTick) ??
        Future.value(false);
  }

  Future<bool> saveLoggedInEmail(String email) async {
    return await SpUtil.putStringList(
          LocalStorageKey.loggedInEmail,
          {...loggedInEmail, email}.toList(),
        ) ??
        false;
  }

  /// Lưu thông tin [IUserInfo] và [UserType] vào local dùng method .toJson()
  Future saveLoggedInInfo({
    required IUserInfo info,
    required UserType userType,
  }) {
    try {
      return Future.wait([
        saveUserInfo(info),
        saveUserType(userType),
      ]);
    } catch (e, s) {
      logger.logError(e, s);
      return Future.value(false);
    }
  }

  clearToLogout() => LocalStorageKey.logoutClearKey.forEach(
        (e) => SpUtil.remove(e),
      );
}

SPService spService = SPService();
