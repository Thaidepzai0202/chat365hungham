import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/dashed_line.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/dropdown_country_box.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/notification_setting.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/setting.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/switch_gradient.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class AdvanceNotificationSetting extends StatefulWidget {
  @override
  State<AdvanceNotificationSetting> createState() =>
      _AdvanceNotificationSettingState();
}

class _AdvanceNotificationSettingState
    extends State<AdvanceNotificationSetting> {
  bool _commentOnTimviec365 = false;
  bool _commentOnRaonhanh365 = false;
  bool _mentionNameSetting = true;
  bool _salaryChangeSetting = false;
  bool _assetManagementSetting = false;
  bool _approveProposalSetting = false;
  bool _rejectProposalSetting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(10.0),
      // ),
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.backgroundColor,
          borderRadius: BorderRadius.circular(10)
        ),
        width: 480,
        height: 580,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            return NotificationSetting();
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
                    AppLocalizations.of(context)?.advanceNotification ??'',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Container(
              height: 500,
              width: 480,
              child: ListView(
                children: [
                  _buildCommentOnTimViec365(),
                  _dashedLines(),
                  __buildCommentOnRaoNhanh365(),
                  _dashedLines(),
                  _buildMentionNameSetting(),
                  _dashedLines(),
                  _buildSalaryChangeSetting(),
                  _dashedLines(),
                  _buildAssetManagementSetting(),
                  _dashedLines(),
                  _buildApproveProposalSetting(),
                  _dashedLines(),
                  _buildRejectProposalSetting(),
                  _dashedLines(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMentionNameSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.mentionNameSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _mentionNameSetting,
                  onChanged: (value) {
                    setState(() {
                      _mentionNameSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryChangeSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.salaryChangeSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _salaryChangeSetting,
                  onChanged: (value) {
                    setState(() {
                      _salaryChangeSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetManagementSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.assetManagementSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _assetManagementSetting,
                  onChanged: (value) {
                    setState(() {
                      _assetManagementSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApproveProposalSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.approveProposalSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _approveProposalSetting,
                  onChanged: (value) {
                    setState(() {
                      _approveProposalSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRejectProposalSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.rejectProposalSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _rejectProposalSetting,
                  onChanged: (value) {
                    setState(() {
                      _rejectProposalSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget __buildCommentOnRaoNhanh365() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.commentOnRaoNhanh365 ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _commentOnRaonhanh365,
                  onChanged: (value) {
                    setState(() {
                      _commentOnRaonhanh365 = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentOnTimViec365() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.commentOnTimViec365 ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _commentOnTimviec365,
                  onChanged: (value) {
                    setState(() {
                      _commentOnTimviec365 = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _dashedLines() {
    return Column(
      children: [
        //-----------------------------
        SizedBox(height: 16),
        CustomPaint(
          painter: DashedLinePainter(),
          child: Container(
            width: 480 - 24 * 2,
            height: 1,
          ),
        ),
        //-------------------------------
      ],
    );
  }
}
