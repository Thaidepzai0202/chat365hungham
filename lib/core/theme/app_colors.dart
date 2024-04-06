import 'package:flutter/material.dart';

class Gradients {
// màu giao diện (Theme )
  static const LinearGradient greenGradientTheme = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xff3BA59B),
        Color(0xff6CD495),
      ]);
  static const LinearGradient orangeGradientTheme = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xffFC9C80),
        Color(0xffFCC88C),
      ]);
  static const LinearGradient purpleGradientTheme = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xff7D79D9),
        Color(0xfFAA82C1),
        Color(0xfFDD8CA2),
      ]);
  static const LinearGradient purple2GradientTheme = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xff662f72),
        Color(0xfFa73a61),
      ]);
  static const LinearGradient blueGradientTheme = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        // Color(0xff3A85D4),
        // Color(0xff3E8CD8),
        Color(0xff4295DC),
        // Color(0xff479FE0),
        // Color(0xff4BA6E3),
        Color(0xff00BFFF),
      ]);
  static const LinearGradient gradientAppBar = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xff3A85D4),
        Color(0xff3E8CD8),
        Color(0xff4295DC),
        Color(0xff479FE0),
        Color(0xff4BA6E3),
        Color(0xff4BA6E3),
        Color(0xff4BA6E3),
        Color(0xff4BA6E3),
        Color(0xff4BA6E3),
        Color(0xff4BA6E3),
      ]);

  static const LinearGradient gradientButtonPC = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xff0086DA),
        Color(0xff00A9E9),
        Color(0xff00A9E9),
      ]);
  static const LinearGradient gradientButton = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xff4193DB),
        Color(0xff4BA6E3),
      ]);
  static const LinearGradient gradientOrange = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xffF8924F),
        Color(0xffFAB66D),
      ]);
  static const LinearGradient gradientCounterPage = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xff3A85D3),
        Color(0xff4BA6E3),
      ]);
  static const LinearGradient gradientGreen = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xff42D677),
        Color(0xff31CB53),
      ]);
  static const LinearGradient noneLinear = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        Colors.transparent,
      ]);
  static const LinearGradient offLinearLight = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        AppColors.tundora,
        AppColors.grayHint,
        //AppColors.grayC4C4C4,
      ]);
  static const LinearGradient offLinearDark = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        
        Color.fromARGB(255, 246, 246, 246),
        Color.fromARGB(255, 189, 189, 189),
        //AppColors.grayC4C4C4,
      ]);
  static const LinearGradient primaryLinear = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        AppColors.primary,
        AppColors.primary,
      ]);
  static const LinearGradient sappbarLinear = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color.fromARGB(255, 152, 253, 255),
        Color.fromARGB(255, 191, 254, 255),
      ]);

  static const LinearGradient dangerGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color.fromARGB(255, 255, 83, 70),
        Color.fromARGB(255, 253, 35, 111),
      ]);
}

class AppColors {
//Màu sắc chủ đạo của app
  static const List<Color> colorGeneral1 = [
    Color.fromARGB(255, 14, 161, 253),
    Color.fromARGB(255, 137, 202, 255)
  ];
  static const List<Color> colorGeneral2 = [
    Color.fromARGB(255, 225, 14, 253),
    Color.fromARGB(255, 236, 93, 255)
  ];
  static const List<Color> colorGeneral3 = [
    Color.fromARGB(255, 14, 225, 253),
    Color.fromARGB(255, 14, 225, 253)
  ];
  static const List<Color> colorGeneral4 = [
    Color.fromARGB(255, 14, 253, 98),
    Color.fromARGB(255, 14, 253, 98)
  ];
  static const List<Color> colorGeneral5 = [
    Color.fromARGB(255, 253, 181, 14),
    Color.fromARGB(255, 253, 181, 14)
  ];
  static const List<Color> colorGeneral6 = [
    Color.fromARGB(255, 253, 14, 201),
    Color.fromARGB(217, 255, 100, 222)
  ];
  static const List<Color> colorGeneral7 = [
    Color.fromARGB(255, 255, 179, 92),
    Color.fromARGB(255, 255, 206, 150)
  ];
  static const List<Color> colorGeneral8 = [
    Color(0xFF3BA59B),
    Color(0xFF6CD495)
  ];
  static const List<Color> colorGeneral9 = [
    AppColors.blueGradients1,
    AppColors.blueGradients2,
    AppColors.blueGradients2,
  ];
  static const List<Color> colorGeneral10 = [
    Color(0xFF3BA59B),
    Color(0xFF6CD495),
  ];
  static const List<Color> colorGeneral11 = [
    Color(0xFF7D79D9),
    Color(0xFFAA82C1),
    Color(0xFFDD8CA2)
  ];
  static const List<Color> colorGeneral12 = [
    Color(0xFFB2CB62),
    Color(0xFF9AD6B2)
  ];
  static const List<Color> colorGeneral13 = [
    Color(0xFFF7B3BE),
    Color(0xFFFCC3CC)
  ];

//-------------App destop---------------

  static const Color blue = Colors.blue;
  static const colorsappbar = Color.fromARGB(255, 237, 243, 251);
  static const Color indigoD6D9F5 = Color(0xFFD6D9F5);
  static const Color grayF3F3F3 = Color(0xFFF3F3F3);
  static const Color grayE9E6E6 = Color(0xFFE9E6E6);
  static const Color blueDFEAFF = Color(0xffDFEAFF);
  static const Color orangeFFA13B = Color(0xffFFA13B);
  static const Color blue5FB1F0 = Color(0xff5FB1F0);
  static const Color blueEBF2FF = Color(0xffEBF2FF);
  static const Color skillColor = Color(0xffFBC3B1);
  static const Color redE74C3C = Color(0xffE74C3C);
  static const Color green20744A = Color(0xff20744A);
  static const Color amberF8924F = Color(0xffF8924F);
  static const Color orangeF36F56 = Color(0xffF36F56);
  static const Color amberF99C4D = Color(0xffF99C4D);
  static const Color blueE2F2FF = Color(0xffE2F2FF);
  static const Color greyEBE8E8 = Color(0xffEBE8E8);
  static const Color blue469CDE = Color(0xff469CDE);
  static const Color blue4090D8 = Color(0xff4090D8);
  static const Color blue3B87D4 = Color(0xff3B87D4);
  static const Color greyDD = Color(0xffDDDDDD);
  static const Color grey9F = Color(0xff9F9F9F);
  static const Color black47 = Color(0xff474747);
  static const Color blueBCE0FF = Color(0xffBCE0FF);
  static const Color greyCF = Color(0xffCFCFCF);
  static const Color textColor5B = Color(0xff5B5B5B);
  static const Color scarlet = Color(0xffFF5B4D);
  static const Color blue3B86D4 = Color(0xff3B86D4);
  static const Color blueD4EBFF = Color(0xffD4EBFF);
  static const Color blue3B87D5 = Color(0xff3B87D5);
  static const Color candidateBtn = Color(0xffFFFFFF);
  static const Color pink05 = Color(0xffFFF0EB);
  static const Color white = Colors.white;
  static const Color red302A = Color(0xFFDA302A);

  static const Color greyD9 = Color(0xffD9D9D9);
  static const Color greyD10 = Color(0xffbebebe);
  static const Color borderCandidateItem = Color(0xFFE1E1E1);
  static const Color indigo = Color(0xFF4C5BD4);
  static const Color textNote = Color(0xFF555D9C);
  static const Color slowBlue = Color(0xFFE0F1FA);
  static const Color green28 = Color(0xFF70BE28);

  static const Color green29 = Color(0xFF4CC724);

  static const Color green30 = Color(0xFF119422);

  static const Color blueF1 = Color(0xFF5DA5F1);
  static const Color orange13B = Color(0xFFFFA13B);

  static const Color blueD4 = Color(0xFF3B86D4);

  static const Color black = Colors.black;

  static const Color black51 = Color(0xE0000000);

  static const Color black50 = Color(0x80000000);
  static const Color black60 = Color(0xC7000000);
  static const Color blueBorder = Color(0xff3A85D4);

  static const Color grey666 = Color(0xFF666666);
  static const Color tundora = Color(0xFF474747);

  static const Color mineShaft = Color(0xFF333333);
  

  static const Color borderGray = Color(0xFFEBEBEBE);

  static const black99 = Color(0xFF999999);
  static const black100 = Color(0xFFE5E1E1);

  static const Color dustyGray = Color(0xFF999999);

  static const Color gray7777777 = Color(0xFF777777);

  static const Color transparentGrey = Color.fromARGB(15, 244, 244, 244);

  static const Color gray = Color(0xFF808080);
  static const Color grayEAEDF0 = Color(0xFFEAEDF0);

//kien them
  static const Color grayF8 = Color(0xFFF8F8F8);
  static const Color grayF9 = Color(0xFFD9D9D9);

  //
  static const Color grayDCDCDC = Color(0xFFDCDCDC);

  static const Color grayCCCCCC = Color(0xFFCCCCCC);
  static const Color grayCCCCCC1 = Color(0xFFD9D8D8);

  static const Color indigo2 = Color(0xFF737FDD);

  static const Color blueLine = Color(0xFF1D90F4);

  static const Color blueEdit = Color(0xFF3F8FD9);

  static const Color grayE6E9FD = Color(0xFFE6E9FD);

  static const Color grayUnder = Color(0xFFD2D2D2);

  static const Color red = Color(0xFFFF3333);

  static const Color boulder = Color(0xFF757575);

  static const Color ghostWhite = Color(0xFFF1F1F4);

  static const Color lima = Color(0xFF76B51B);

  static const Color green1 = Color(0xFF119422);

  static const Color green22A6B3 = Color(0xFF22A6B3);

  static const Color violetBE2EDD = Color(0xFFBE2EDD);

  static const Color orangeCEA744 = Color(0xFFCEA744);

  static const Color lawnGreen = Color(0xFF83DD00);

  static const Color greenF4FCE9 = Color(0xFFF4FCE9);

  static const Color orange = Color(0xFFFFA800);
  static const Color sunfill = Color(0xFFF9B970);

  static const Color whiteLilac = Color(0xFFF7F8FC);

  static final Color dialogBarrier = Colors.black.withOpacity(0.50);

  static const Color doveGray = Color(0xFF666666);
  static const Color slowGray = Color(0xFFF2F2F2);
  static const Color E0Gray = Color(0xFFE0E0E0);

  static const Color grayHint = Color(0xFF999999);
  static const Color lightGray = Color(0xFFE4E4E4);
  static const Color grayF3F4FF = Color(0xFFF3F4FF);

  static const Color grayC4C4C4 = Color(0xFFC4C4C4);

  static const Color grayACACAC = Color(0xFFACACAC);

  /// Colors.black.withOpacity(0.1);
  static const Color shadow10 = Color(0x1A000000);

  /// Colors.black.withOpacity(0.2);
  static const Color shadow20 = Color(0x33000000);

  /// Colors.black.withOpacity(0.25);
  static const Color shadow25 = Color(0x40000000);

  ///Không xóa màu đơn của gradient vì dùng cho màn cài đặt chung
  static const Color blueGradients1 = Color(0xff0086DA);
  static const Color blueGradients2 = Color(0xff00A9E9);
  static const Color blueD4E7F7 = Color(0xffD4E7F7);

  static const LinearGradient blueGradients = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [blueGradients1, blueGradients2]);

  static const Color peachGradients1 = Color(0xffFC9C80);
  static const Color peachGradients2 = Color(0xffFDB187);
  static const Color peachGradients3 = Color(0xffFDB187);

  static const LinearGradient peachGradients = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [peachGradients1, peachGradients2, peachGradients3]);

  //

  static const Color textSelection = Color(0x90001EFF);
  static const Color primary = Color(0xFF4C5BD4);
  static const Color blueEDF8FD = Color(0xFFEDF8FD);
  static const Color orangeF88C00 = Color(0xFFF88C00);

  static const Color borderColor = doveGray;

  static const Color text = doveGray;

  // static const Color inactive = doveGray;
  static const Color inactive = lightGray;

  static const Color active = primary;

  static const Color error = red;

  static const Color primaryColorLightTheme = white;

  static const Color primaryColorDarkTheme = mineShaft;

  static const Color backgroundChatContent = Color.fromARGB(255, 31, 31, 31);
  static const Color backgroundDarkListChat = Color.fromARGB(255, 46, 46, 46);

  static const Color online = lima;

  static const Color offline = orange;

  static const Color grayyyy = Color(0xffB6B6B6);

  static const Color colorIconLight = boulder;

  static const Color colorIconDark = Colors.white;

  static const Color dividerColorLightTheme = dustyGray;

  static const Color fillColor = whiteLilac;

  static const Color divider = doveGray;

  static const greyCC = Color(0xFFCCCCCC);
  static const greyCACA = Color(0xFFCACACA);

  static final Color shimmerBaseColor = Colors.grey.shade300;

  static final Color shimmerHighlightColor = Colors.grey.shade100;

  static final Color lightThemeTextColor = AppColors.tundora;

  static final Color darkThemeTextColor = AppColors.white;

  static final Color lightThemeDisableColor = AppColors.ghostWhite;
  static final Color darkThemeDisableColor = AppColors.tundora;

  static final Color lightThemeHintTextColor = AppColors.grayHint;
  static final Color darkThemeHintTextColor = AppColors.gray;
  static final Color blackThemeHintTextColor = AppColors.black;

  static final Color buttonCallScreenColor = AppColors.tundora;
  static final Color buttonDisableCallScreenColor =
      AppColors.tundora.withOpacity(0.4);
  static final Color iconDisableCallScreenColor =
      AppColors.white.withOpacity(0.4);
  static final Color iconCallScreenColor = AppColors.white;
  static final Color timeCallColor = AppColors.lawnGreen;
}
