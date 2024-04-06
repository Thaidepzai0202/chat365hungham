import 'package:app_chat365_pc/common/blocs/theme_cubit/theme_cubit.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/auth/widgets/password_field.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/conversation_item.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/dashed_line.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/dropdown_country_box.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/setting.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/switch_gradient.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:sp_util/sp_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GeneralSetting extends StatefulWidget {
  @override
  State<GeneralSetting> createState() => _GeneralSettingState();
}

class _GeneralSettingState extends State<GeneralSetting> {
  String dropDownValue =
      changeLanguage.value == 'vi' ? 'Tiếng Việt' : 'English';

  bool _autoStart = false;
  late Gradient gradientcheck;
  late bool _theLight;
  List<String> dropCountryData = ['Tiếng Việt', 'English'];
  late AppLayoutCubit _appLayoutCubit;

  late ThemeCubit themeCubit;

  @override
  void initState() {
    gradientcheck = context.theme.gradient;
    _theLight = !context.theme.isDarkTheme;
    themeCubit = context.read<ThemeCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: context.theme.backgroundColor),
        width: 480,
        height: 580,
        child: Column(
          children: [
            Container(
              height: 55,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  gradient: context.theme.gradient),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 12,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SettingLocal();
                          });
                    },
                    child: SvgPicture.asset(
                      Images.ic_back,
                      width: 35,
                      height: 35,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Text(
                    AppLocalizations.of(context)!.generalSetting,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Container(
              height: 525,
              decoration: BoxDecoration(
                  color: context.theme.backgroundColor,
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  //Ngôn Ngữ---------------------
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.language,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: context.theme.textColor),
                      ),
                      const SizedBox(
                        width: 72,
                      ),
                      Container(
                        width: 150,
                        height: 50,
                        child: DropdownCountryBox(dropDownValue,
                            values: dropCountryData, callBack: (value) {
                          setState(() {
                            dropDownValue = value;
                            if (value == 'Tiếng Việt') {
                              changeLanguage.value = 'vi';
                              SpUtil.putString('changeLanguage', 'vi');
                              // Locale('vi');
                            } else {
                              changeLanguage.value = 'en';
                              SpUtil.putString('changeLanguage', 'en');
                              // Locale('es');
                            }
                          });
                        }),
                      )
                    ],
                  ),

                  //Tự khởi động-------------------
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    AppLocalizations.of(context)!.startup,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.theme.textColor),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.autoStartChat365,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: context.theme.textColor),
                          ),
                          Text(
                            AppLocalizations.of(context)!.autoStartWhenTurnItOn,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: context.theme.textColor),
                          ),
                        ],
                      ),
                      CustomSwitch(
                          value: autoStart,
                          onChanged: (value) async {
                            autoStart = value;
                            SpUtil.putBool('autoStart', value);
                            if (autoStart) {
                              await launchAtStartup.enable();
                            } else {
                              await launchAtStartup.disable();
                            }
                          },
                          activeColor: AppColors.black)
                    ],
                  ),

                  //-----------------------------
                  SizedBox(height: 15),
                  CustomPaint(
                    painter: DashedLinePainter(),
                    child: Container(
                      width: 480 - 24 * 2,
                      height: 2,
                    ),
                  ),
                  //-------------------------------

                  //Màu giao diện
                  SizedBox(height: 15),
                  Text(
                    AppLocalizations.of(context)!.appearance,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.theme.textColor),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildColorTheme(1, Gradients.blueGradientTheme),
                      _buildColorTheme(2, Gradients.greenGradientTheme),
                      _buildColorTheme(3, Gradients.orangeGradientTheme),
                      _buildColorTheme(4, Gradients.purpleGradientTheme),
                      _buildColorTheme(5, Gradients.purple2GradientTheme),
                      _buildColorTheme(6, Gradients.gradientOrange),
                      _buildColorTheme(7, Gradients.primaryLinear),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _buildDarkOrLight(),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            TextEditingController _controller =
                                TextEditingController();
                            return Dialog(
                              backgroundColor: context.theme.backgroundColor,
                              //title: Text(AppLocalizations.of(context)!.deleteAccount),
                              child: Container(
                                width: 300,
                                height: 250,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        width: 300,
                                        height: 50,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15)),
                                            gradient: context.theme.gradient),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .deleteAccount,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17,
                                              color: AppColors.white),
                                        )),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(AppLocalizations.of(context)!.deleteAccountPasswordConfirmation,
                                          style: TextStyle(
                                            color: context.theme.text3Color
                                          ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          PasswordField(
                                            hintText:
                                                AppLocalizations.of(context)!
                                                    .inputPassword,
                                            controller: _controller,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              buttonWhite(
                                                  AppLocalizations.of(context)!
                                                      .cancel,
                                                  80, () {
                                                AppRouter.back(context);
                                              }, context),
                                              buttonBlue(
                                                  AppLocalizations.of(context)!
                                                      .delete,
                                                  80, () async {
                                                String? savedPassword =
                                                    SpUtil.getString(
                                                        LocalStorageKey
                                                            .passwordClass);
                                                if (savedPassword ==
                                                    _controller.text) {
                                                  AuthRepo authRepo = AuthRepo();
                                                  logger.log(authRepo.userInfo?.id);
                                                  if (authRepo.userInfo?.id != null) {
                                                    authRepo.deleteAccount(authRepo.userInfo!.id);
                                                  }
                                                  SystemUtils.logout(context);
                                                  await AppRouter.toPage(
                                                      context, AppPages.logIn);
                                                  var initialSize =
                                                      const Size(450, 690);
                                                  appWindow.minSize =
                                                      initialSize;
                                                  appWindow.maxSize =
                                                      initialSize;
                                                  appWindow.size = initialSize;
                                                  appWindow.alignment =
                                                      Alignment.center;
                                                  AppDialogs.toast(StringConst
                                                      .deleteAccountSuccess);
                                                } else {
                                                  AppDialogs.toast(StringConst
                                                      .wrongPassword);
                                                }
                                              }, context),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              // contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 24),
                            );
                          });
                    },
                    child: Container(
                      width: 120,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: Gradients.dangerGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.deleteAccount,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkOrLight() {
    return SizedBox(
      height: 75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              setState(() {
                _theLight = true;
                changeTheme.value = changeTheme.value + 10;
                context.theme.themeMode = ThemeMode.light;
                SpUtil.putInt(
                    'changeTheme',
                    context.theme.isDarkTheme
                        ? changeTheme.value
                        : (changeTheme.value % 10));
                        print("-----changeTheme - - - - - ${changeTheme.value}");
              });
            },
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                ),
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _theLight == true
                          ? context.theme.gradient
                          : Gradients.noneLinear,
                      border: Border.all(
                        width: 1,
                        color: _theLight == true
                            ? Colors.transparent
                            : AppColors.gray,
                      )),
                  child: _theLight == true
                      ? Icon(
                          Icons.check,
                          size: 20,
                          color: AppColors.white,
                        )
                      : Container(),
                ),
                SizedBox(
                  width: 16,
                ),
                Text(
                  AppLocalizations.of(context)!.light,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.theme.textColor),
                )
              ],
            ),
          ),
          SizedBox(
            height: 12,
          ),
          InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              setState(() {
                _theLight = false;
                changeTheme.value = changeTheme.value + 10;
                context.theme.themeMode = ThemeMode.dark;
                SpUtil.putInt(
                    'changeTheme',
                    context.theme.isDarkTheme
                        ? changeTheme.value
                        : (changeTheme.value % 10));
              });
            },
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                ),
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _theLight == false
                          ? context.theme.gradient
                          : Gradients.noneLinear,
                      border: Border.all(
                        width: 1,
                        color: _theLight == false
                            ? Colors.transparent
                            : AppColors.gray,
                      )),
                  child: _theLight == false
                      ? Icon(
                          Icons.check,
                          size: 20,
                          color: AppColors.white,
                        )
                      : Container(),
                ),
                SizedBox(
                  width: 16,
                ),
                Text(
                  AppLocalizations.of(context)!.dark,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.theme.textColor),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildColorTheme(int numberTheme, Gradient gradient) {
    return InkWell(
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        setState(() {
          gradientcheck = gradient;

          switch (gradient) {
            case Gradients.blueGradientTheme:
              context.theme.appTheme = AppThemeColor.blueTheme;
              changeTheme.value = changeTheme.value = changeTheme.value ~/ 10 *10  + 0;
              SpUtil.putInt(
                  'changeTheme',
                  context.theme.isDarkTheme
                      ? changeTheme.value
                      : (changeTheme.value % 10));
              break;
            case Gradients.greenGradientTheme:
              context.theme.appTheme = AppThemeColor.greenTheme;
              changeTheme.value = changeTheme.value = changeTheme.value ~/ 10 *10  + 1;
              SpUtil.putInt(
                  'changeTheme',
                  context.theme.isDarkTheme
                      ? changeTheme.value
                      : (changeTheme.value % 10));
              break;
            case Gradients.orangeGradientTheme:
              context.theme.appTheme = AppThemeColor.orangeTheme;
              changeTheme.value = changeTheme.value = changeTheme.value ~/ 10 *10  + 2;
              SpUtil.putInt(
                  'changeTheme',
                  context.theme.isDarkTheme
                      ? changeTheme.value
                      : (changeTheme.value % 10));
              break;
            case Gradients.purpleGradientTheme:
              context.theme.appTheme = AppThemeColor.purpleTheme;
              changeTheme.value = changeTheme.value = changeTheme.value ~/ 10 *10  + 3;
              SpUtil.putInt(
                  'changeTheme',
                  context.theme.isDarkTheme
                      ? changeTheme.value
                      : (changeTheme.value % 10));
              break;
            case Gradients.purple2GradientTheme:
              context.theme.appTheme = AppThemeColor.purple2Theme;
              changeTheme.value = changeTheme.value = changeTheme.value ~/ 10 *10  + 4;
              SpUtil.putInt(
                  'changeTheme',
                  context.theme.isDarkTheme
                      ? changeTheme.value
                      : (changeTheme.value % 10));
              break;
            case Gradients.gradientOrange:
              context.theme.appTheme = AppThemeColor.orange2Theme;
              changeTheme.value = changeTheme.value = changeTheme.value ~/ 10 *10  + 5;
              SpUtil.putInt(
                  'changeTheme',
                  context.theme.isDarkTheme
                      ? changeTheme.value
                      : (changeTheme.value % 10));
              break;
            case Gradients.primaryLinear:
              context.theme.appTheme = AppThemeColor.primaryTheme;
              changeTheme.value = changeTheme.value = changeTheme.value ~/ 10 *10  + 6;
              SpUtil.putInt(
                  'changeTheme',
                  context.theme.isDarkTheme
                      ? changeTheme.value
                      : (changeTheme.value % 10));
              break;
            default:
          }
        });
      },
      child: Stack(
        children: [
          Container(
            height: gradientcheck == gradient ? 60 : 52,
            width: gradientcheck == gradient ? 60 : 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
            ),
          ),
          gradientcheck == gradient
              ? Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: gradient,
                        border: Border.all(
                          color: AppColors.white,
                        )),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
