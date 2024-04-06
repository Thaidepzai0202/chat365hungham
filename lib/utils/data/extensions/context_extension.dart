import 'package:app_chat365_pc/common/blocs/theme_cubit/theme_cubit.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension ContextExt on BuildContext {

  IUserInfo userInfo() =>
      read<AuthRepo>().userInfo!; // TODO: Null check used on a null value
  UserType userType() => read<AuthRepo>().userType;
  // UserType userType() => read<AuthRepo>().userE;
  Map<String, dynamic> get args =>
      ModalRoute.of(this)?.settings.arguments as Map<String, dynamic>;

  bool get isDarkMode =>
      MediaQuery.of(this).platformBrightness == Brightness.dark;

  MyTheme get theme => read<ThemeCubit>().state.theme;

  Size get mediaQuerySize => MediaQuery.of(this).size;

  EdgeInsets get mediaQueryPadding => MediaQuery.of(this).padding;
}
