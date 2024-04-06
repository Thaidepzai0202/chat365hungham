import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_form_field.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/utils/ui/app_border_and_radius.dart';
import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.primaryColorDarkTheme,
    // checkboxTheme: CheckboxThemeData(
    //   side: AppBorderAndRadius.uniformBorderSide,
    //   shape: AppBorderAndRadius.checkBoxShape,
    // ),
    iconTheme: IconThemeData(
      color: AppColors.colorIconDark,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        color: Colors.white,
      ),
    ),
    primaryColor: AppColors.primary,
    brightness: Brightness.dark,
    dividerColor: AppColors.dividerColorLightTheme,
    hintColor: Colors.white.withOpacity(0.7),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColorDarkTheme,
      elevation: 2,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    inputDecorationTheme: AppFormField.inputDecorationDarkTheme,
    scrollbarTheme: ScrollbarThemeData(
        // thumbVisibility: true,
        ),
    checkboxTheme: CheckboxThemeData(
      side: AppBorderAndRadius.uniformBorderSide,
      shape: AppBorderAndRadius.checkBoxShape,
    ).copyWith(
      fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
    ),
    colorScheme: ColorScheme(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      background: Colors.red,
      onBackground: Colors.white,
      secondary: Colors.red,
      onSecondary: Colors.white,
      error: Colors.black,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.white,
      brightness: Brightness.dark,
    ).copyWith(background: Colors.white),
  );

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    iconTheme: IconThemeData(
      color: AppColors.colorIconLight,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        color: AppColors.text,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
        color: AppColors.text,
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w400,
        color: AppColors.text,
        fontSize: 14,
      ),
      titleMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        color: AppColors.text,
      ),
    ),
    // checkboxTheme: CheckboxThemeData(
    //   side: AppBorderAndRadius.uniformBorderSide,
    //   shape: AppBorderAndRadius.checkBoxShape,
    // ),
    colorScheme: ColorScheme(
      primary: AppColors.primary,
      onPrimary: AppColors.text,
      background: Colors.white,
      onBackground: Colors.black,
      secondary: Colors.red,
      onSecondary: Colors.white,
      error: Colors.black,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      brightness: Brightness.light,
    ),
    primaryColor: AppColors.text,
    brightness: Brightness.light,
    dividerColor: AppColors.dividerColorLightTheme,
    canvasColor: AppColors.primary,
    dividerTheme: DividerThemeData(
      color: AppColors.dividerColorLightTheme,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: AppTextStyles.appbarTitle,
      iconTheme: IconThemeData(
        color: AppColors.primary,
      ),
    ),
    inputDecorationTheme: AppFormField.inputDecorationLightTheme,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
      selectedIconTheme: IconThemeData(
        color: AppColors.primary,
        size: 26,
      ),
      selectedLabelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
        // isAlwaysShown: true,
        ),
    checkboxTheme: CheckboxThemeData(
      side: AppBorderAndRadius.uniformBorderSide,
      shape: AppBorderAndRadius.checkBoxShape,
    ).copyWith(
      fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
    ),
  );
// static ThemeData lightTheme = ThemeData.light();
//
// static ThemeData darkTheme = ThemeData(
//   backgroundColor: Colors.white,
//   primaryColor: AppColors.primary,
//   unselectedWidgetColor: AppColors.primary,
//   appBarTheme: AppBarTheme(
//     backgroundColor: Colors.white,
//     elevation: 2,
//     titleTextStyle: AppTextStyles.appbarTitle,
//   ),
// );
}
