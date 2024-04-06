import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
// import 'package:app_chat365_pc/core/theme/app_text_style.dart';
// import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/dashed_line.dart';
// import 'package:app_chat365_pc/modules/layout/views/setting/dropdown_country_box.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/notification_setting.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/setting.dart';
// import 'package:app_chat365_pc/modules/layout/views/setting/setting.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/switch_gradient.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class DigitalTransformation extends StatefulWidget {
  @override
  State<DigitalTransformation> createState() => _DigitalTransformationState();
}

class _DigitalTransformationState extends State<DigitalTransformation> {
  bool _rewardAndFineNotificationSetting = false;
  bool _workCalendarNotificationSetting = false;
  bool _staffRotationNotificationSetting= false;
  bool _rewardAndDisciplineNotificationSetting= false;
  bool _newStaffNotificationSetting= false;
  bool _documentNotificationSetting = false;
  bool _newProposeNotificationSetting = false;
  bool _changePersonalInforNotiSetting = false;
  bool _propertyNavigationNotiSetting = false;
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
          children: [
            Container(
              height: 55,
              decoration:  BoxDecoration(
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
                    AppLocalizations.of(context)?.digitalTransformationNotification365 ??'',
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
                  //tính lương----------------------------------------------
                  Container(
                    padding: EdgeInsets.only(top: 16,left: 26),
                    
                    child: GradientText(
                      gradient: context.theme.gradient,
                      AppLocalizations.of(context)?.salaryCalculationSetting ??'',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _buildSalaryNotificationToChat365(),
                  _dashedLines(),
                  _buildRewardAndFineNotificationSetting(),
                  _dashedLines(),
                  _buildWorkCalendarNotificationSetting(),
                  _dashedLines(),
                  _buildCommissionNotificationSetting(),
                  _dashedLines(),

                  //-----quản trị nhân sự ------------------
                  Container(
                    padding: EdgeInsets.only(top: 16,left: 26),
                    child: GradientText(
                      gradient: context.theme.gradient,
                      AppLocalizations.of(context)?.personelManagement ??'',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _buildStaffRotationNotificationSetting(),
                  _dashedLines(),
                  _buildRewardAndDisciplineNotificationSetting(),
                  _dashedLines(),
                  _buildnewStaffNotificationSetting(),
                  _dashedLines(),


                  //----văn thư lưu trữ
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 26),
                    child: GradientText(
                      gradient: context.theme.gradient,
                      AppLocalizations.of(context)?.archicalDocument ??'',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _buildDocumentNotificationSetting(),
                  _dashedLines(),
                  _buildNewProposeNotificationSetting(),
                  _dashedLines(),


                  //----quản lý chung ---------
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 26),
                    child: GradientText(
                      gradient: context.theme.gradient,
                      AppLocalizations.of(context)?.genaralManagement ??'',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _buildChangePersonalInforNotiSetting(),
                  _dashedLines(),




                  //----quản lý tài sản -------
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 26),
                    child: GradientText(
                      gradient: context.theme.gradient,
                      AppLocalizations.of(context)?.assetManagement ??'',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _buildPropertyNavigationNotiSetting(),
                  SizedBox(height: 20,)




                ],
              ),
            )
          ],
        ),
      ),
    );
  }



  Widget _buildSalaryNotificationToChat365() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              //---------
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.salaryNotificationToChat365 ??'',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
                ),
                SizedBox(height: 4),
                Container(
                  child: Text(
                    AppLocalizations.of(context)?.salaryNotificationToChat365Content ??'',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400,color:context.theme.textColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardAndFineNotificationSetting() {
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
                AppLocalizations.of(context)?.rewardAndFineNotificationSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _rewardAndFineNotificationSetting,
                  onChanged: (value) {
                    setState(() {
                      _rewardAndFineNotificationSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkCalendarNotificationSetting() {
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
                AppLocalizations.of(context)?.workCalendarNotificationSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _workCalendarNotificationSetting,
                  onChanged: (value) {
                    setState(() {
                      _workCalendarNotificationSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionNotificationSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              //---------
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.commissionNotificationSetting ??'',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
                ),
                SizedBox(height: 4),
                Container(
                  child: Text(
                    AppLocalizations.of(context)?.commissionNotificationSettingContent ??'',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400,color:context.theme.textColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffRotationNotificationSetting() {
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
                AppLocalizations.of(context)?.staffRotationNotificationSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _staffRotationNotificationSetting,
                  onChanged: (value) {
                    setState(() {
                      _staffRotationNotificationSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardAndDisciplineNotificationSetting() {
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
                AppLocalizations.of(context)?.rewardAndDisciplineSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _rewardAndDisciplineNotificationSetting,
                  onChanged: (value) {
                    setState(() {
                      _rewardAndDisciplineNotificationSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildnewStaffNotificationSetting() {
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
                AppLocalizations.of(context)?.newStaffSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _newStaffNotificationSetting,
                  onChanged: (value) {
                    setState(() {
                      _newStaffNotificationSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDocumentNotificationSetting() {
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
                AppLocalizations.of(context)?.documentNotificationSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _documentNotificationSetting,
                  onChanged: (value) {
                    setState(() {
                      _documentNotificationSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewProposeNotificationSetting() {
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
                AppLocalizations.of(context)?.newProposeNotificationSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _newProposeNotificationSetting,
                  onChanged: (value) {
                    setState(() {
                      _newProposeNotificationSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildChangePersonalInforNotiSetting() {
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
                AppLocalizations.of(context)?.changePersonalInforNotiSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _changePersonalInforNotiSetting,
                  onChanged: (value) {
                    setState(() {
                      _changePersonalInforNotiSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPropertyNavigationNotiSetting() {
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
                AppLocalizations.of(context)?.propertyNavigationNotiSetting ??'',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _propertyNavigationNotiSetting,
                  onChanged: (value) {
                    setState(() {
                      _propertyNavigationNotiSetting = value;
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
