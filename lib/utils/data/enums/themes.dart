import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_form_field.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

//part 'themes.g.dart';

@HiveType(typeId: HiveTypeId.appThemeColorHiveTypeId)
enum AppThemeColor {
  @HiveField(0)
  blueTheme,
  @HiveField(1)
  greenTheme,
  @HiveField(2)
  orangeTheme,
  @HiveField(3)
  purpleTheme,
  @HiveField(4)
  purple2Theme,
  @HiveField(5)
  orange2Theme,
  @HiveField(6)
  primaryTheme,
}

extension AppThemeExt on AppThemeColor {
  Gradient get gradient {
    switch (this) {
      case AppThemeColor.blueTheme:
        return Gradients.blueGradientTheme;
      case AppThemeColor.greenTheme:
        return Gradients.greenGradientTheme;
      case AppThemeColor.orangeTheme:
        return Gradients.orangeGradientTheme;
      case AppThemeColor.purpleTheme:
        return Gradients.purpleGradientTheme;
      case AppThemeColor.purple2Theme:
        return Gradients.purple2GradientTheme;
      case AppThemeColor.orange2Theme:
        return Gradients.gradientOrange;
      case AppThemeColor.primaryTheme:
        return Gradients.primaryLinear;

      default:
        return Gradients.blueGradientTheme;
    }
  }

  Color get primaryColor => AppColors.blue;

// Gradient get gradient => this == AppThemeColor.defaultTheme
//     ? AppColors.blueGradients
//     : AppColors.peachGradients;

// Color get primaryColor => this == AppThemeColor.defaultTheme
//     ? AppColors.primary
//     : AppColors.peachGradients3;
}

@HiveType(typeId: HiveTypeId.myThemeHiveTypeId)
class MyTheme {
  BuildContext context;
  @HiveField(0)
  AppThemeColor appTheme;
  @HiveField(1)
  ThemeMode themeMode;
  @HiveField(2)
  double messageTextSize;

  MyTheme(
    this.context, {
    this.appTheme = AppThemeColor.blueTheme,
    this.themeMode = ThemeMode.light,
    double? messageTextSize,
  }) : this.messageTextSize =
            messageTextSize ?? AppConst.kDefaultMessageFontSize {
    themeData = Theme.of(context);
  }

  bool get isDarkTheme => this.themeMode == ThemeMode.dark ? true : false;

  // ThemeMode get themeModeApp => themeMode;

  late ThemeData themeData;

  TextStyle get userListTileTextTheme => AppTextStyles.regularW500(
        context,
        size: 18,
        lineHeight: 20,
        color: textColor,
      );

  // TextStyle get textInput => AppTextStyles.regularW500(
  //       context,
  //       size: 16,
  //       lineHeight: 19.2,
  //       color: textColor,
  //     );
  TextStyle get inputStyle => AppTextStyles.regularW400(
        context,
        size: 16,
        lineHeight: 18.75,
        color: AppColors.tundora,
      );

  Color get backgroundListChat {
    switch (this.appTheme) {
      case AppThemeColor.blueTheme:
        if (isDarkTheme)
          return AppColors.backgroundDarkListChat;
        else
          return Color.fromARGB(255, 246, 246, 246);
      case AppThemeColor.greenTheme:
        if (isDarkTheme)
          return AppColors.backgroundDarkListChat;
        else
          return Color.fromARGB(255, 246, 246, 246);
      case AppThemeColor.orangeTheme:
        if (isDarkTheme)
          return AppColors.backgroundDarkListChat;
        else
          return Color.fromARGB(255, 246, 246, 246);
      case AppThemeColor.purpleTheme:
        if (isDarkTheme)
          return AppColors.backgroundDarkListChat;
        else
          return Color.fromARGB(255, 246, 246, 246);
      case AppThemeColor.purple2Theme:
        if (isDarkTheme)
          return AppColors.backgroundDarkListChat;
        else
          return Color.fromARGB(255, 246, 246, 246);
      case AppThemeColor.orange2Theme:
        if (isDarkTheme)
          return AppColors.backgroundDarkListChat;
        else
          return Color.fromARGB(255, 246, 246, 246);
      case AppThemeColor.primaryTheme:
        if (isDarkTheme)
          return AppColors.backgroundDarkListChat;
        else
          return const Color.fromARGB(255, 246, 246, 246);

      default:
        if (isDarkTheme)
          return AppColors.backgroundDarkListChat;
        else
          return Color(0xff6CD495);
    }
  }

  Color get backgroundDarkListChat {
    switch (this.appTheme) {
      case AppThemeColor.blueTheme:
        return Color.fromARGB(255, 35, 35, 35).withOpacity(0.9);
      case AppThemeColor.greenTheme:
        return const Color.fromARGB(255, 25, 49, 35).withOpacity(0.9);
      case AppThemeColor.orangeTheme:
        return const Color.fromARGB(255, 69, 50, 29).withOpacity(0.9);
      case AppThemeColor.purpleTheme:
        return const Color.fromARGB(255, 67, 30, 40).withOpacity(0.9);
      case AppThemeColor.purple2Theme:
        return const Color.fromARGB(255, 36, 9, 19).withOpacity(0.9);
      case AppThemeColor.orange2Theme:
        return const Color.fromARGB(255, 79, 55, 28).withOpacity(0.9);
      case AppThemeColor.primaryTheme:
        return const Color.fromARGB(255, 13, 17, 49).withOpacity(0.9);

      default:
        return const Color.fromARGB(255, 0, 61, 81).withOpacity(0.9);
    }
  }

  Color get backgroundOnForward {
    switch (this.appTheme) {
      case AppThemeColor.blueTheme:
        return isDarkTheme
            ? AppColors.tundora
            : Color.fromARGB(255, 243, 246, 255);
      case AppThemeColor.greenTheme:
        return isDarkTheme
            ? AppColors.tundora
            : const Color.fromARGB(255, 243, 255, 244);
      case AppThemeColor.orangeTheme:
        return isDarkTheme
            ? AppColors.tundora
            : const Color.fromARGB(255, 255, 250, 243);
      case AppThemeColor.purpleTheme:
        return isDarkTheme
            ? AppColors.tundora
            : Color.fromARGB(255, 255, 243, 251);
      case AppThemeColor.purple2Theme:
        return isDarkTheme
            ? AppColors.tundora
            : const Color.fromARGB(255, 253, 243, 255);
      case AppThemeColor.orange2Theme:
        return isDarkTheme
            ? AppColors.tundora
            : const Color.fromARGB(255, 255, 248, 243);
      case AppThemeColor.primaryTheme:
        return isDarkTheme ? AppColors.tundora : AppColors.grayF3F4FF;

      default:
        return isDarkTheme
            ? AppColors.tundora
            : const Color.fromARGB(255, 243, 246, 255);
    }
  }

  Color get backgroundSelectChat {
    switch (this.appTheme) {
      case AppThemeColor.blueTheme:
        if (isDarkTheme)
          return AppColors.tundora;
        else
          return const Color(0xff00BFFF).withOpacity(0.4);
      case AppThemeColor.greenTheme:
        if (isDarkTheme) return AppColors.tundora;
        return const Color(0xff6CD495).withOpacity(0.4);
      case AppThemeColor.orangeTheme:
        if (isDarkTheme) return AppColors.tundora;
        return const Color(0xffFCC88C).withOpacity(0.4);
      case AppThemeColor.purpleTheme:
        if (isDarkTheme) return AppColors.tundora;
        return const Color(0xfFDD8CA2).withOpacity(0.4);
      case AppThemeColor.purple2Theme:
        if (isDarkTheme) return AppColors.tundora;
        return const Color(0xfFa73a61).withOpacity(0.4);
      case AppThemeColor.orange2Theme:
        if (isDarkTheme) return AppColors.tundora;
        return const Color(0xffFAB66D).withOpacity(0.4);
      case AppThemeColor.primaryTheme:
        if (isDarkTheme) return AppColors.tundora;
        return AppColors.primary.withOpacity(0.4);

      default:
        if (isDarkTheme) return AppColors.tundora;
        return Color(0xff6CD495).withOpacity(0.4);
    }
  }

  Color get colorPirimaryNoDarkLight {
    switch (this.appTheme) {
      case AppThemeColor.blueTheme:
        return const Color(0xff00BFFF);
      case AppThemeColor.greenTheme:
        return const Color(0xff6CD495);
      case AppThemeColor.orangeTheme:
        return const Color(0xffFCC88C);
      case AppThemeColor.purpleTheme:
        return const Color(0xfFDD8CA2);
      case AppThemeColor.purple2Theme:
        return const Color(0xfFa73a61);
      case AppThemeColor.orange2Theme:
        return const Color(0xffFAB66D);
      case AppThemeColor.primaryTheme:
        return AppColors.primary;

      default:
        return Color(0xff6CD495);
    }
  }

  Color get textColor => isDarkTheme
      ? AppColors.darkThemeTextColor
      : AppColors.lightThemeTextColor;

  Color get hitnTextColor => isDarkTheme
      ? AppColors.darkThemeHintTextColor
      : AppColors.lightThemeHintTextColor;

  Color get colorLine => this.themeMode == ThemeMode.light
      ? AppColors.greyD9
      : Color.fromARGB(255, 88, 88, 88);

  Color get iconColor => textColor;

  Color get backgroundColor => isDarkTheme
      ? AppColors.primaryColorDarkTheme
      : AppColors.primaryColorLightTheme;

  Color get textSelectInSearch => this.themeMode == ThemeMode.light
      ? AppColors.text
      : const Color.fromARGB(255, 168, 168, 168);

  Color get backgroundChatContent => isDarkTheme
      ? AppColors.backgroundChatContent
      : AppColors.primaryColorLightTheme;

  Color get text2Color => this.themeMode == ThemeMode.light
      ? AppColors.tundora
      : AppColors.whiteLilac;

  Color get text1Color => this.themeMode == ThemeMode.light
      ? AppColors.black
      : AppColors.white;

  Color get textColorInverted => this.themeMode == ThemeMode.light
      ? AppColors.whiteLilac
      : AppColors.tundora;

  Color get text3Color => this.themeMode == ThemeMode.light
      ? const Color.fromARGB(255, 103, 103, 103)
      : Color.fromARGB(255, 185, 185, 185);
    
  Color get dividerColor => this.themeMode == ThemeMode.light
      ? AppColors.greyD9
      : AppColors.whiteLilac;

  String get timviec365Logo => this.themeMode == ThemeMode.light
      ? Images.img_logo_timviec_blue
      : Images.img_logo_timviec_white;

  Color get backgroundFormFieldColor =>
      isDarkTheme ? AppColors.tundora : AppColors.primaryColorLightTheme;

  Color get disableColor => isDarkTheme
      ? AppColors.darkThemeDisableColor
      : AppColors.lightThemeDisableColor;

  TextStyle get messageTextStyle => AppTextStyles.regularW400(
        context,
        size: messageTextSize,
        color: textColor,
        lineHeight: messageTextSize * 1.2,
      );

  TextStyle get notificationMessageTextStyle => AppTextStyles.regularW400(
        context,
        size: 16,
        color: textColor,
        lineHeight: 20,
      );

  TextStyle get replyOriginTextStyle => AppTextStyles.regularW400(
        context,
        size: 16,
        lineHeight: 18.75,
        color: isDarkTheme ? AppColors.white : AppColors.text,
      );

  TextStyle get replyOriginTextStyle2 => AppTextStyles.regularW400(
        context,
        size: 16,
        lineHeight: 18.75,
        color: this.themeMode == ThemeMode.light
            ? AppColors.white
            : AppColors.text,
      );

  TextStyle get typingTextStyle => AppTextStyles.regularW400(
        context,
        size: 16,
        lineHeight: 18,
        color: AppColors.dustyGray,
      );

  TextStyle get wrongUserTypeAuthDialogTextStyle => AppTextStyles.regularW400(
        context,
        size: 16,
        lineHeight: 22,
      );

  //input bar

  Color get colorTextNameProfile =>
      isDarkTheme ? AppColors.white : AppColors.black47;
  Color get colorSubTextProfile =>
      isDarkTheme ? AppColors.white : AppColors.black60;

  Color get colorIconInputBar => isDarkTheme ? AppColors.white : AppColors.gray;

  Color get backgroundIconInputBar {
    switch (this.appTheme) {
      case AppThemeColor.blueTheme:
        if (isDarkTheme)
          return AppColors.transparentGrey;
        else
          return const Color(0xff4295DC).withOpacity(0.10);
      case AppThemeColor.greenTheme:
        if (isDarkTheme) return AppColors.transparentGrey;
        return const Color(0xff3BA59B).withOpacity(0.10);
      case AppThemeColor.orangeTheme:
        if (isDarkTheme) return AppColors.transparentGrey;
        return const Color(0xffFC9C80).withOpacity(0.10);
      case AppThemeColor.purpleTheme:
        if (isDarkTheme) return AppColors.transparentGrey;
        return const Color(0xff7D79D9).withOpacity(0.10);
      case AppThemeColor.purple2Theme:
        if (isDarkTheme) return AppColors.transparentGrey;
        return const Color(0xff662f72).withOpacity(0.10);
      case AppThemeColor.orange2Theme:
        if (isDarkTheme) return AppColors.transparentGrey;
        return const Color(0xffF8924F).withOpacity(0.10);
      case AppThemeColor.primaryTheme:
        if (isDarkTheme) return AppColors.transparentGrey;
        return AppColors.primary.withOpacity(0.10);

      default:
        if (isDarkTheme) return AppColors.gray7777777;
        return Color(0xff6CD495).withOpacity(0.10);
    }
  }

  Color get backgroundInputBar =>
      isDarkTheme ? AppColors.tundora : this.backgroundIconInputBar;

  Color get hitnTextColorInputBar =>
      isDarkTheme ? AppColors.greyD9 : AppColors.gray;

  Color get dividerDefaultColor =>
      isDarkTheme ? AppColors.white : AppColors.grayHint;

  Color get dividerHistoryColor =>
      isDarkTheme ? AppColors.white : AppColors.doveGray;

  Color get messageBoxColor =>
      isDarkTheme ? AppColors.tundora : AppColors.whiteLilac;

  Color get friendBoxColor =>
      isDarkTheme ? Color.fromARGB(255, 42, 42, 42) : AppColors.whiteLilac;

  Color get abcfriendBoxColor =>
      isDarkTheme ? AppColors.tundora : const Color(0xFFF3F4F5);

  Color get backgroundButtonLikeMes =>
      isDarkTheme ? AppColors.tundora : AppColors.white;

  Color get colorButtonLikeMes =>
      isDarkTheme ? AppColors.white : AppColors.dustyGray;

  Color get messageFileBoxColor =>
      isDarkTheme ? AppColors.tundora : Color.fromARGB(255, 239, 239, 239);

  Color get addFriendButtonColor => this.themeMode == ThemeMode.light
      ? AppColors.gray
      : const Color.fromARGB(255, 220, 220, 220);

  Color get addFriendButtonBackgroundColor => this.themeMode == ThemeMode.light
      ? AppColors.whiteLilac
      : AppColors.tundora;

  Gradient get gradient => appTheme.gradient;

  Gradient get swichoffgraident =>
      isDarkTheme ? Gradients.offLinearDark : Gradients.offLinearLight;

  ///Màu gradient của cuộc gọi không đổi theo theme
  Gradient get gradientPhoneCall => AppColors.blueGradients;

  IconThemeData get iconTheme => Theme.of(context).iconTheme.copyWith(
        color: textColor,
      );

  TextStyle get userStatusTextStyle => AppTextStyles.regularW400(
        context,
        size: 12,
        lineHeight: 15,
        color: isDarkTheme ? AppColors.white : AppColors.doveGray,
      );

  Color get unSelectedIconColor => textColor;

  Color get item3DotColor =>
      this.themeMode == ThemeMode.light ? AppColors.gray : AppColors.whiteLilac;

  Color get backgroundSTICKER =>
      isDarkTheme ? AppColors.doveGray : AppColors.white;

  Color get chatInputBarColor =>
      isDarkTheme ? AppColors.tundora : Color.fromARGB(255, 252, 252, 252);

  TextStyle get hintStyle => AppTextStyles.regularW400(
        context,
        size: 16,
        lineHeight: 18.75,
        color: hitnTextColor,
      );

  TextStyle get searchBigTextStyle => AppTextStyles.regularW700(
        context,
        size: 24,
        lineHeight: 26.4,
        color: AppColors.white,
      );

  TextStyle get locationListTileStyle => AppTextStyles.regularW500(
        context,
        size: 16,
        lineHeight: 21.6,
        color: textColor,
      );

  Color get primaryColor => appTheme.primaryColor;

  ButtonStyle get buttonStyle => ButtonStyle(
        elevation: MaterialStateProperty.all(0),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        fixedSize: MaterialStateProperty.all(Size.fromHeight(40)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: MaterialStateProperty.all(primaryColor.withOpacity(0.15)),
      );

  ButtonStyle get outlinedButtonStyle => buttonStyle.copyWith(
        side: MaterialStateProperty.all(BorderSide(color: primaryColor)),
      );

  ButtonStyle get elevatedButtonStyle => buttonStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(primaryColor),
      );

  Color get dropdownColor => isDarkTheme ? AppColors.black : AppColors.white;

  TextStyle get pinDropdownItemTextStyle => AppTextStyles.regularW400(
        context,
        size: 16,
      );

  TextStyle get sentTimeMessageTextStyle => AppTextStyles.regularW400(
        context,
        size: 13,
        color: textColor.withOpacity(0.7),
        lineHeight: 22,
      );

  TextStyle get chatConversationDropdownTextStyle => AppTextStyles.regularW400(
        context,
        size: 14,
        lineHeight: 16,
        color: isDarkTheme ? AppColors.white : AppColors.boulder,
      );

  TextStyle get diffOnlineTimeTextStyle => const TextStyle(
        fontSize: 8,
        height: 9.68 / 8,
        color: AppColors.lima,
        fontWeight: FontWeight.w500,
      );

  ThemeData get theme => ThemeData(
        // backgroundColor: Color(0xffFCC88C).withOpacity(0.07),
        primaryColor: primaryColor,
        chipTheme: Theme.of(context).chipTheme.copyWith(
              backgroundColor: backgroundColor,
              elevation: 0.0,
              disabledColor: backgroundColor,
            ),
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
              buttonColor: primaryColor,
              highlightColor: primaryColor.withOpacity(0.85),
              splashColor: primaryColor.withOpacity(0.85),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              height: 40,
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    outline: primaryColor,
                    onPrimary: primaryColor,
                    primary: primaryColor,
                  ),
            ),
        tabBarTheme: Theme.of(context).tabBarTheme.copyWith(
              labelColor: primaryColor,
            ),
        // colorScheme: Theme.of(context).colorScheme.copyWith(
        //       primary: primaryColor,
        //       secondary: primaryColor,
        //     ),
        primaryColorLight: primaryColor,
        primaryColorDark: primaryColor,
        canvasColor: primaryColor,
        dialogBackgroundColor: backgroundColor,
        checkboxTheme: Theme.of(context).checkboxTheme.copyWith(
              checkColor: MaterialStateProperty.all<Color>(backgroundColor),
              fillColor: MaterialStateProperty.all<Color>(primaryColor),
            ),
        textSelectionTheme: Theme.of(context).textSelectionTheme.copyWith(
              cursorColor: primaryColor,
              selectionColor: AppColors.textSelection,
            ),
        textTheme: Theme.of(context)
            .textTheme
            .copyWith(
              titleMedium: hintStyle,
            )
            .apply(
              displayColor: textColor,
              bodyColor: textColor,
            ),
        scaffoldBackgroundColor: backgroundColor,
        elevatedButtonTheme:
            ElevatedButtonThemeData(style: elevatedButtonStyle),
        outlinedButtonTheme:
            OutlinedButtonThemeData(style: outlinedButtonStyle),
        bottomNavigationBarTheme:
            Theme.of(context).bottomNavigationBarTheme.copyWith(
                  backgroundColor: backgroundColor,
                  selectedLabelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      foreground: Paint()
                        ..shader = AppColors.blueGradients
                            .createShader(Rect.fromLTWH(0, 0, 100, 13))
                      // color: AppColors.blueGradients1,
                      ),
                  // selectedItemColor: AppColors.blueGradients1,
                  // unselectedItemColor: textColor,
                  unselectedLabelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: iconTheme.color,
                  ),
                  unselectedIconTheme: iconTheme,
                  selectedIconTheme: IconThemeData(
                    color: primaryColor,
                    size: 26,
                  ),
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  elevation: 10,
                ),
        shadowColor: isDarkTheme
            ? AppColors.black.withOpacity(0.15)
            : AppColors.white.withOpacity(0.15),
        iconTheme: iconTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
          centerTitle: false,
          titleTextStyle: AppTextStyles.regularW700(
            context,
            size: 18,
            lineHeight: 21.6,
            color: textColor,
          ),
          actionsIconTheme: iconTheme,
          iconTheme: iconTheme,
        ),
        primaryIconTheme: iconTheme,
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 13, bottom: 13, left: 20),
              hintStyle: hintStyle,
              filled: true,
              fillColor: Colors.transparent,
            ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
        ),
        cardTheme: Theme.of(context).cardTheme.copyWith(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        dialogTheme: Theme.of(context).dialogTheme.copyWith(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        timePickerTheme: Theme.of(context).timePickerTheme.copyWith(
              backgroundColor: backgroundColor,
              dialBackgroundColor: primaryColor,
            ),
        popupMenuTheme: Theme.of(context).popupMenuTheme.copyWith(
              color: isDarkTheme ? AppColors.black : AppColors.white,
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        listTileTheme: Theme.of(context).listTileTheme.copyWith(
              iconColor: iconColor,
              minVerticalPadding: 0,
              textColor: textColor,
              dense: true,
              horizontalTitleGap: 0,
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            ),
        colorScheme: Theme.of(context)
            .colorScheme
            .copyWith(
              primary: primaryColor,
              secondary: primaryColor,
            )
            .copyWith(background: backgroundColor),
      );

  InputDecoration get inputDecoration => AppFormField.inputDecorationLight;
}
