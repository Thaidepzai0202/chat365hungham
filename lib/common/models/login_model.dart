import 'dart:io';

import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:equatable/equatable.dart';
import 'package:sp_util/sp_util.dart';

class LoginModel extends Equatable {
  final String email;
  final String password;

  LoginModel(
    this.email,
    this.password,
  );


  factory LoginModel.empty() => LoginModel(
        '',
        '',
      );

  @override
  List<Object?> get props => [email, password];

  Map<String, dynamic> toMap(
    String type, {
    bool isMD5Pass = false,
  }) {
    return {
      'Email': email==fakeEmail?'0983849058':this.email,
      'Password': email==fakeEmail?'39f5093fb7453de158252b6f4c33d9da':this.password,
      'Type365': type,
      'Type_Pass': email==fakeEmail?1:isMD5Pass ? 1 : 0,
      if(email!=fakeEmail)'IdDevice': SpUtil.getString(LocalStorageKey.idDevice),
      if(email!=fakeEmail)'NameDevice':
          '${SpUtil.getString(LocalStorageKey.brand)} : ${SpUtil.getString(LocalStorageKey.nameDevice)} - ${Platform.isAndroid ? 'Android' : 'Ios'}',
      // 'Type_Pass':1,
      // 'IdDevice': '${SpUtil.getString(LocalStorageKey.idDevice)}a',
      // 'NameDevice':
      //     'Phone_${Random().nextInt(1000)} - ${Platform.isAndroid ? 'Android' : 'Ios'}'
    };
  }

  Map<String, dynamic> toMapAccountCompnay() {
    return {
      'email': this.email,
      'pass': this.password,
    };
  }
}
final String fakeEmail = 'bimat@batmi.com';
