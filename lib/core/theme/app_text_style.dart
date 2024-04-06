

import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';

import 'app_dimens.dart';

class AppTextStyles {

  

  ///PC
  static  TextStyle subTextProfile(BuildContext context) => TextStyle(
    fontSize: 12,
    color: context.theme.colorSubTextProfile,
    fontWeight: FontWeight.w400,
  );
  static TextStyle nameProfile(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: context.theme.colorTextNameProfile,
  );
  static  TextStyle nameChatConversation(BuildContext context) => TextStyle(
      letterSpacing: 1.1,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: context.theme.colorTextNameProfile);

  ///
  static TextStyle chosenConversationList(BuildContext context) => TextStyle(
      fontSize: 15,
      color: context.theme.textColor,
      fontWeight: FontWeight.w600,
      height: 20/18);


  static const TextStyle forwardText = TextStyle(
      fontSize: 18,
      color: AppColors.white,
      fontWeight: FontWeight.w600,
      height: 26/24);
  static const TextStyle workShift = TextStyle(
      fontSize: 10,
      color: Colors.black,
      fontWeight: FontWeight.w400,
      height: 1.36);
  static const TextStyle textPercentageProposal = TextStyle(
      color: Color(0xFF5DA5F1), fontWeight: FontWeight.w500, fontSize: 14);
  static const TextStyle titleMyProposal = TextStyle(
      fontSize: 16,
      height: 21.76 / 21.76,
      fontWeight: FontWeight.w600,
      color: AppColors.tundora);
  static const TextStyle chosenStatusProposal = TextStyle(
      fontSize: 16,
      height: 21.76 / 21.76,
      fontWeight: FontWeight.w500,
      color: AppColors.blueD4);
  static const TextStyle timePropose = TextStyle(
      fontSize: 15,
      height: 20.4 / 20.4,
      fontWeight: FontWeight.w400,
      color: Color(0xFF666666));
  static const TextStyle namePropose = TextStyle(
      fontSize: 16,
      height: 21.76 / 21.76,
      fontWeight: FontWeight.w500,
      color: Color(0xFF3B86D4));
  static const TextStyle fullNamePropose = TextStyle(
      fontSize: 15,
      height: 21.76 / 21.76,
      fontWeight: FontWeight.w500,
      color: Color(0xFF3B86D4));
  static const TextStyle textAfterNamePropose = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.tundora,
  );
  static const TextStyle textId = TextStyle(
      color: AppColors.tundora,
      fontWeight: FontWeight.w400,
      fontSize: 10,
      height: 13.6 / 13.6);
  static const TextStyle textDocument = TextStyle(
      color: Color(0xFF3B86D4),
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 19.04 / 19.04);
  static const TextStyle itemInfoPropose = TextStyle(
    fontSize: 16,
    height: 21.76 / 21.76,
    fontWeight: FontWeight.w400,
    color: Color(0xFF666666),
  );
  static const TextStyle itemTextBlueInfoPropose = TextStyle(
    fontSize: 16,
    height: 21.76 / 21.76,
    fontWeight: FontWeight.w400,
    color: Color(0xFF3B86D4),
  );
  static const TextStyle textProposeForLeave = TextStyle(
    fontSize: 20,
    height: 27 / 27,
    fontWeight: FontWeight.w500,
    color: AppColors.tundora,
  );
  static const TextStyle textInfoPropose = TextStyle(
    fontSize: 17,
    height: 23.12 / 23.12,
    fontWeight: FontWeight.w500,
    color: AppColors.tundora,
  );
  static const TextStyle timeTypeProposal = TextStyle(
    fontSize: 18,
    height: 1.36,
    fontWeight: FontWeight.w600,
    color: Color(0xFF3B86D4),
  );
  static const TextStyle contentInDetailIdeaPoll = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.tundora,
  );
  static const TextStyle whiteText = TextStyle(
    fontSize: 15,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: Color(0xffFFFFFF),
  );
  static const TextStyle text15 = TextStyle(
    fontSize: 15,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: Color(0xff474747),
  );
  static const TextStyle askInDetailIdeaPoll = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xff474747),
  );
  static const TextStyle viewDetailPoll = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 19.2 / 16,
    color: Color(0xff474747),
  );
  static const TextStyle BtnCancelDelete = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 19.2 / 16,
    color: Color(0xff4C5BD4),
  );
  static const TextStyle candidate_categoryItemName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    color: Color(0xff333333),
  );
  static const TextStyle titleDialog = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static const TextStyle titleDecentralization = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static const TextStyle titleNotify = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static const TextStyle delete = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    color: AppColors.red,
  );
  static const TextStyle edit = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    color: Colors.indigo,
  );
  static const TextStyle titleModalFinding = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.blue,
  );
  static const TextStyle candidate_textSearchInput = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 17.58 / 15,
      color: Color(0xff757575));
  static const TextStyle candidate_dowloadCvBtn = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 21.82 / 16,
    color: Colors.blue,
  );
  static const TextStyle candidateName_seeBtn = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
  static const TextStyle candidateCancel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    color: Colors.white,
  );
  static const TextStyle titleCreateProposal = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 22 / 16,
    color: Colors.black,
  );
  static const TextStyle titleItemProposal = TextStyle(
    fontSize: 15,
    fontStyle: FontStyle.normal,
  );
  static const TextStyle selectTitle = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF474747),
  );
  static const TextStyle selectTitleWhite = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static const TextStyle selectTitleWhiteStatus = TextStyle(
    fontSize: 16,
    height: 21.76 / 21.76,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static const TextStyle selectTitleStatus = TextStyle(
    fontSize: 16,
    height: 21.76 / 21.76,
    fontWeight: FontWeight.w500,
    color: Color(0xFF474747),
  );
  static const TextStyle candidateBtn = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    color: AppColors.white,
  );
  static const TextStyle titleCandidateFinding = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.tundora,
  );
  static const TextStyle createProfileTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xff474747),
  );
  static const TextStyle candidateCategoryFinding = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 18.75 / 16,
    color: AppColors.text,
  );
  static const TextStyle candidateFinding = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    height: 15 / 16,
    color: AppColors.mineShaft,
  );

  static const TextStyle textCandidateDetailInfTitle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 20 / 18,
      color: AppColors.tundora);
  static const TextStyle textCandidateDetailInfContent = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 24 / 18,
      color: AppColors.tundora);

  static TextStyle detailInfConentHightLight = TextStyle(
    foreground: Paint()
      ..shader = LinearGradient(
        colors: [Color(0xff0086DA), Color(0xff00A9E9), Color(0xff00A9E9)],
      ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 20 / 18,
  );

  static const TextStyle textIsSeeContact = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w300,
      height: 1,
      color: Color(0xffFF4D00));
  static const TextStyle candidateDetailName = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 20 / 20,
      color: Color(0xff0086DA));
  static const TextStyle candidateDetailPosition = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 20.25 / 15,
      color: AppColors.tundora);
  static const TextStyle candidateDescription = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 15.23 / 13,
    color: AppColors.tundora,
  );
  static const TextStyle chatIcon = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 15.23 / 13,
    color: AppColors.white,
  );
  static const TextStyle introDescription = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    color: AppColors.text,
  );
  static const TextStyle candidate_description = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    color: Color(0xff505050),
  );
  static const TextStyle textGridImage = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static const TextStyle textWhite = TextStyle(
    color: AppColors.white,
  );
  static const TextStyle textWhiteTitleProposal = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  static const TextStyle textWhiteProposal = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  static const TextStyle titleCreatePropose = TextStyle(
    color: AppColors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 27.2,
  );
  static const TextStyle textNumber =
      TextStyle(color: AppColors.white, fontSize: 20);
  static const TextStyle textTabbar = TextStyle(
    fontSize: 11.7,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle textComment = TextStyle(
    color: AppColors.blueGradients1,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle hintGrey = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );
  static const TextStyle titleDetailRecruit = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );
  static const TextStyle hintDrop = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );
  static const TextStyle textDetailRecruit = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.blueGradients1,
      height: 20 / 18);
  static const TextStyle textQrRecruit = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.blueGradients1,
  );
  static const TextStyle textCompany = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.blueGradients1,
  );
  static const TextStyle titleCategoryManage = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );
  static const TextStyle titleRecruit = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      color: AppColors.blueGradients1);
  static const TextStyle titlePoll = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      color: AppColors.tundora);

  static const TextStyle authTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    color: AppColors.black
  );

  static const TextStyle albumTitle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      color: AppColors.black
  );

  static const TextStyle textSaveAppBar = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
  );
  static const TextStyle noteEmotion = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
  );
  static const TextStyle appbarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
  );
  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
  );

  static TextStyle button(BuildContext context) => regularW700(
        context,
        size: 16,
        fontStyle: FontStyle.normal,
      );

  static TextStyle iconButton(BuildContext context) => regularW400(
        context,
        size: 14,
        lineHeight: 20,
      );
  static const TextStyle iconWhiteBackgroundButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.tundora,
  );
  static const TextStyle hintTextInputPoll = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.dustyGray,
  );
  static const TextStyle candidateName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.orangeF88C00,
  );
  static const TextStyle createPollBtn = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Color(0xffFFFFFF),
  );

  static const TextStyle textIdeaPoll = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: Color(0xff666666),
  );

  static const TextStyle italicText = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.blueGradients1,
      fontStyle: FontStyle.italic);
  static const TextStyle iconPrimaryTextButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );
  static const TextStyle iconTextButtonNews = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static const TextStyle textRed = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.red,
      fontStyle: FontStyle.italic);
  static const TextStyle textGray = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.dustyGray,
  );
  static const TextStyle iconColorButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static const TextStyle textOrange = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFFF88C00),
  );
  static const TextStyle textBlue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.blue,
  );

  static const TextStyle textBlue3B86D4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.blue3B86D4,
  );

  static const TextStyle contactItem = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
  );

  static TextStyle contactGroupName(BuildContext context) => regularW700(
        context,
        size: 16,
        lineHeight: 20,
      );

  static const TextStyle optionsDialogItem = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle dropdownItem = iconWhiteBackgroundButton;
  static const TextStyle selectedDropdownItem = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const TextStyle hintText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: Colors.black,
  );
  static const TextStyle titleSuggest = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.tundora,
      height: 21.6 / 16);
  static const TextStyle titleSuggestCandidate = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.tundora,
      height: 21.6 / 16);
  static const TextStyle labelText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.black,
    fontStyle: FontStyle.normal,
  );
  static const TextStyle textNote = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
    fontStyle: FontStyle.italic,
  );
  static const TextStyle textPosition = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Colors.green,
    // fontStyle: FontStyle.normal,
  );

  static const TextStyle dialogDescription = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );
  static TextStyle text(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: context.theme.text2Color,
  );
  static const TextStyle listTile = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 21.6 / 16,
    color: AppColors.tundora,
  );
  static const TextStyle listTileUnderline = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.underline,
    color: Colors.blue,
    height: 21.6 / 16,
  );

  static TextStyle mbsTitle(BuildContext context) => regularW500(
        context,
        size: 16,
        lineHeight: 19.1,
        color: context.theme.primaryColor,
      );

  static TextStyle mbsItem(BuildContext context) => regularW500(
        context,
        size: 14,
        color: context.theme.textColor,
      );

  static TextStyle titleListTileSetting(BuildContext context) => regularW700(
        context,
        size: 16,
        lineHeight: 19.1,
      );

  static TextStyle recommend(BuildContext context) => regularW500(
        context,
        size: 16,
        lineHeight: 19.1,
      );

  static const TextStyle boldTextProfile = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      color: AppColors.black);

  static TextStyle textMessageDisplayStyle(
    BuildContext context, {
    Color? color,
  }) =>
      TextStyle(
        color: color,
        fontSize: 14.0,
        height: 18.75 / 16.0,
      );

  static TextStyle nameCustomerProfileChat(BuildContext context) => regularW700(
        context,
        size: 18,
        lineHeight: 20,
        color: context.theme.primaryColor,
      );

  // Text style with font Normal
  static TextStyle regularW500(BuildContext context,
      {@required double? size,
      FontStyle? fontStyle,
      Color? color,
      double lineHeight = AppDimens.lineHeightXSmall,
      TextDecoration? decoration}) {
    var height = 1.0;
    if (lineHeight > size!) {
      height = lineHeight / size;
    }
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontSize: size,
          fontWeight: FontWeight.w500,
          color: color,
          height: height,
          decoration: decoration,
        );
  }

  static TextStyle regularW700(
    BuildContext context, {
    @required double? size,
    FontStyle? fontStyle,
    Color? color,
    double lineHeight = AppDimens.lineHeightSmall,
  }) {
    var height = 1.0;
    if (lineHeight > size!) {
      height = lineHeight / size;
    }
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: color ?? context.theme.text2Color,
          height: height,
        );
  }

  static TextStyle regularW400(BuildContext context,
      {@required double? size,
      FontStyle? fontStyle,
      Color? color,
      double lineHeight = AppDimens.lineHeightXSmall,
      TextDecoration? decoration,
      Color? backgroundColor}) {
    var height = 1.0;
    if (lineHeight > size!) {
      height = lineHeight / size;
    }
    return Theme.of(context).textTheme.titleMedium!.copyWith(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        backgroundColor: backgroundColor);
  }

  static TextStyle regularW600(BuildContext context,
      {@required double? size,
      FontStyle? fontStyle,
      Color? color,
      double lineHeight = AppDimens.lineHeightXSmall}) {
    var height = 1.0;
    if (lineHeight > size!) {
      height = lineHeight / size;
    }
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontSize: size,
          fontWeight: FontWeight.w600,
          color: color,
          height: height,
          fontStyle: fontStyle,
        );
  }

  static TextStyle regular(BuildContext context,
      {@required double? size,
      FontWeight? fontWeight,
      Color? color,
      double lineHeight = AppDimens.lineHeightXSmall}) {
    var height = 1.0;
    if (lineHeight > size!) {
      height = lineHeight / size;
    }
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontSize: size,
          fontWeight: FontWeight.w300,
          color: color,
          height: height,
        );
  }
}
