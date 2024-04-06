import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/advanceNotification.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/dashed_line.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/dropdown_country_box.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/setting.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/switch_gradient.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:sp_util/sp_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class NotificationSetting extends StatefulWidget {
  @override
  State<NotificationSetting> createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  bool _notificationChatting = true;
  bool _interactSetting = true;
  bool _notificationTone = false;
  bool _tipsAdnTricks = false;
  bool _missedConversation = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(10.0),
      // ),
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
                    AppLocalizations.of(context)?.notificationSetting ??'',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              height: 580 - 55,
              width: 480,
              child: ListView(
                children: [
                  _buildNotificationChat(),
                  _dashedLines(),
                  _buildInteractSetting(),
                  _dashedLines(),
                  _buildNotificationToneSetting(),
                  _dashedLines(),
                  _buildtipsAndTricksSetting(),
                  _dashedLines(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      AppLocalizations.of(context)?.notificationByEmail ??'',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.theme.hitnTextColorInputBar,
                      ),
                    ),
                  ),
                  _buildMissesConversation(),
                  _dashedLines(),
                  _buildAdvancedNotification(),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedNotification() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
            onTap: () {
              //-------------------
              Navigator.of(context).pop();
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AdvanceNotificationSetting();
                  });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)?.advanceNotification ??'',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.theme.textColor),
                ),
                SvgPicture.asset(
                  Images.ic_arrow_right,
                  color: context.theme.textColor,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissesConversation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.missedConversationSetting ??'',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.theme.textColor),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 330,
                    child: Text(
                      AppLocalizations.of(context)?.missedConversationSettingContent ??'',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: context.theme.textColor),
                    ),
                  ),
                ],
              ),
              CustomSwitch(
                  value: _missedConversation,
                  onChanged: (value) {
                    setState(() {
                      _missedConversation = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildtipsAndTricksSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.tipsAndTricksSetting ?? '',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.theme.textColor),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 330,
                    child: Text(
                      AppLocalizations.of(context)?.tipsAndTricksSettingContent ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: context.theme.textColor),
                    ),
                  ),
                ],
              ),
              CustomSwitch(
                  value: _tipsAdnTricks,
                  onChanged: (value) {
                    setState(() {
                      _tipsAdnTricks = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToneSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.notificationToneSetting ??'',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.theme.textColor),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 330,
                    child: Text(
                      AppLocalizations.of(context)?.notificationToneSettingContent ??'',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: context.theme.textColor),
                    ),
                  ),
                ],
              ),
              CustomSwitch(
                  value: _notificationTone,
                  onChanged: (value) {
                    setState(() {
                      _notificationTone = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.interactSetting ??'',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.theme.textColor),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 330,
                    child: Text(
                      AppLocalizations.of(context)?.interactSettingContent ??'',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: context.theme.textColor),
                    ),
                  ),
                ],
              ),
              CustomSwitch(
                  value: _interactSetting,
                  onChanged: (value) {
                    setState(() {
                      _interactSetting = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationChat() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.notificationChatting ?? '',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.theme.textColor),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 330,
                    child: Text(
                      AppLocalizations.of(context)?.notificationChattingContent ??'',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: context.theme.textColor),
                    ),
                  ),
                ],
              ),
              CustomSwitch(
                  value: notificationChatting,
                  onChanged: (value) {
                      notificationChatting = value;
                      SpUtil.putBool('notificationSetting', value);
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
        SizedBox(height: 15),
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
