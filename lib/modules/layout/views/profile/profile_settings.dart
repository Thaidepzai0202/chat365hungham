

import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/digital_transformation.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/genenal_setting.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/message_setting.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/notification_setting.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ProfileSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
            color: context.theme.backgroundColor,
            borderRadius: BorderRadius.circular(10)),
        width: AppDimens.widthPC / 2.5,
        height: 580,
        child: Column(
          children: [
            Container(
              height: 55,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  gradient: context.theme.gradient),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.setting ??'',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.white,
                    ),
                      onPressed: () {
                        AppRouter.back(context);
                      },
                    ),
                  ],
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Chung
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () {
                      //-------------
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return GeneralSetting();
                          });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                Images.ic_setting,
                                width: 30,
                                height: 30,
                                color: context.theme.textColor,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(AppLocalizations.of(context)?.genaral ??'',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: context.theme.textColor)),
                            ],
                          ),
                          SvgPicture.asset(
                            Images.ic_drop_right,
                            width: 30,
                            height: 30,
                            color: context.theme.textColor,
                          ),
                        ],
                      ),
                    ),
                    // Đặt kiểu con trỏ chuột thành hình ngón tay
                    //cursor: SystemMouseCursors.click,
                  ),
                ),
                //Nhắn tin
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () {
                      //-------------
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MessageSetting();
                          });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                Images.ion_chatbox_ellipses_outline,
                                width: 30,
                                height: 30,
                                color: context.theme.textColor,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(AppLocalizations.of(context)?.message ??'',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: context.theme.textColor)),
                            ],
                          ),
                          SvgPicture.asset(
                            Images.ic_drop_right,
                            width: 30,
                            height: 30,
                            color: context.theme.textColor,
                          ),
                        ],
                      ),
                    ),
                    // Đặt kiểu con trỏ chuột thành hình ngón tay
                    //cursor: SystemMouseCursors.click,
                  ),
                ),
                //Thông báo
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () {
                      //-------------
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NotificationSetting();
                          });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                Images.ic_bell,
                                width: 30,
                                height: 30,
                                color: context.theme.textColor,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(AppLocalizations.of(context)?.notification ??'',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: context.theme.textColor)),
                            ],
                          ),
                          SvgPicture.asset(
                            Images.ic_drop_right,
                            width: 30,
                            height: 30,
                            color: context.theme.textColor,
                          ),
                        ],
                      ),
                    ),
                    // Đặt kiểu con trỏ chuột thành hình ngón tay
                    //cursor: SystemMouseCursors.click,
                  ),
                ),
                //Chuyển đổi số
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () {
                      //-------------
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DigitalTransformation();
                          });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                Images.ic_notify_plane,
                                width: 30,
                                height: 30,
                                color: context.theme.textColor,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                AppLocalizations.of(context)?.digitalTransformationNotification365 ?? '',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: context.theme.textColor)),
                            ],
                          ),
                          SvgPicture.asset(
                            Images.ic_drop_right,
                            width: 30,
                            height: 30,
                            color: context.theme.textColor,
                          ),
                        ],
                      ),
                    ),
                    // Đặt kiểu con trỏ chuột thành hình ngón tay
                    //cursor: SystemMouseCursors.click,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
