import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/modules/auth/modules/forgot_password/forgot_password_screen.dart';
import 'package:app_chat365_pc/modules/auth/modules/forgot_password/update_password_screen.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/cubit/signup_cubit.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/screens/confirm_otp_webview_screen.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/sign_up_employee.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/sign_up_employee_id_company.dart';
import 'package:app_chat365_pc/modules/layout/views/app_layout.dart';
import 'package:app_chat365_pc/router/page_config.dart';
import 'package:app_chat365_pc/modules/auth/modules/login/login_singup.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/sign_up.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_mode.dart';
import 'package:app_chat365_pc/utils/data/enums/type_screen_to_otp.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/photo_view.dart';

enum AppPages {
  initial,
  testPage,
  logIn,
  inPutSignUp,
  inPutLogIn,
  ChoosePosition,
  Auth_ConfirmOTPWebView,
  Auth_ForgotPass,
  Auth_UpdatePass,
  appLayOut,
  inPutEmployee,
  imageSlide,
}

String _getPageArgumentErrorString(List<String> args) => args.join(', ');

void _checkMissingRequiredArgumentsAndAssureError(
    Map<String, dynamic>? arguments, List<String> argNames) {
  try {
    if (arguments == null) {
      throw ArgumentError.notNull(_getPageArgumentErrorString(argNames));
    }

    final List<String> missingArgNames =
        argNames.where((e) => arguments.containsKey(e) == false).toList();

    if (missingArgNames.isNotEmpty) {
      throw ArgumentError.notNull(_getPageArgumentErrorString(missingArgNames));
    }
  } catch (e) {
    print(e);
    rethrow;
  }
}

extension AppPagesExtension on AppPages {
  String get key => toString()
      .split('.')
      .last
      .replaceAll(r'_', '.')
      .replaceAllMapped(
        RegExp(r'(?<=[a-z])[A-Z]'),
        (Match m) => "_${m.group(0) ?? ''}",
      )
      .toLowerCase();

  String get path => "/${this.key.replaceAll(r'.', '/')}";

  String get name => path;

  static PageConfig getPageConfig(
      AppPages page, Map<String, dynamic>? arguments) {
    switch (page) {
      case AppPages.Auth_ConfirmOTPWebView:
        _checkMissingRequiredArgumentsAndAssureError(arguments, ['email']);
        String email = arguments!['email'];
        TypeScreenToOtp type =
            arguments['typeOTP'] ?? TypeScreenToOtp.FORGOTPASSWORD;
        IUserInfo? userInfo = arguments['userInfo'];
        UserType? userType = arguments['userType'];
        bool isMD5 = arguments['isMD5'] ?? true;
        return PageConfig()
          ..pageBuilder = () => ConfirmOtpWebViewScreen(
                email: email,
                typeOTP: type,
                userInfo: userInfo,
                isMD5: isMD5,
              );
      case AppPages.imageSlide:
        var initIndex = arguments![ImageMessageSliderScreen.initIndexArg];
        var images = arguments[ImageMessageSliderScreen.imagesArg];
        return PageConfig()
          ..pageBuilder = () => ImageMessageSliderScreen(
            images: images,
            initIndex: initIndex,
          );
      case AppPages.initial:
        var arg = arguments?['arg'];
        return PageConfig()..pageBuilder = () => const SizedBox();
      case AppPages.testPage:
        var arg = arguments?['arg'];
        return PageConfig()..pageBuilder = () => const SizedBox();
      case AppPages.logIn:
        var arg = arguments?['arg'];
        return PageConfig()..pageBuilder = () => LogInOrSignUp();
      case AppPages.Auth_UpdatePass:
        _checkMissingRequiredArgumentsAndAssureError(
            arguments, [UpdatePasswordScreen.userTypeArg]);

        final UserType userType = arguments![UpdatePasswordScreen.userTypeArg];
        final String? email = arguments[UpdatePasswordScreen.idEmail];
        return PageConfig()
          ..pageBuilder = () => UpdatePasswordScreen(
                userType: userType,
                email: email,
              );
      case AppPages.inPutSignUp:
        var yourchoose = arguments?['yourchoose'];
        return PageConfig()
          ..pageBuilder = () => InPutSignUp(yourchoose: yourchoose);
      case AppPages.inPutLogIn:
        //var userType = arguments![InPutLogIn.userTypeArg] as UserType;
        var userType = arguments![InPutLogIn.userTypeArg] as UserType;
        final AuthMode? authMode = arguments[InPutLogIn.authMode];
        return PageConfig()
          ..pageBuilder = () => InPutLogIn(
                userType: userType,
                mode: authMode,
              );
      case AppPages.ChoosePosition:
        var isLogIn = arguments?['isLogIn'];
        return PageConfig()
          ..pageBuilder = () => ChoosePosition(isLogIn: isLogIn);
      case AppPages.appLayOut:
        IUserInfo userInfo = arguments!['UserInfo'];
        int receiveID = arguments!['receiveID'];
        return PageConfig()
          ..pageBuilder = () => AppLayout(
                // userInfo: userInfo,
                receiveID: receiveID,
              );
      case AppPages.inPutEmployee:
        final AuthMode mode = arguments![InputSignUpEmployee.authModeArg];
        return PageConfig()
          ..pageBuilder = () => InputSignUpEmployee(
                mode: mode,
              );
      case AppPages.Auth_ForgotPass:
        var userType = arguments![ForgotPasswordScreen.userTypeArg] as UserType;
        return PageConfig()
          ..pageBuilder = () => BlocProvider.value(
              value: SignUpCubit(),
              child: ForgotPasswordScreen(userType: userType));
    }
  }
}
