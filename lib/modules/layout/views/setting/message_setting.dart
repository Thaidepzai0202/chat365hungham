import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/dashed_line.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/dropdown_country_box.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/setting.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/switch_gradient.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
//import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MessageSetting extends StatefulWidget {
  @override
  State<MessageSetting> createState() => _MessageSettingState();
}

class _MessageSettingState extends State<MessageSetting> {
  bool _autoStart = false;
  bool _sendByEnter = true;
  bool _receiveMessagesFromStranger = false;
  bool _autoDownLoadImage = false;
  bool _autoDownLoadFile = false;
  bool _previewWebsLinks = true;
  String _fontSize = 'Bình thường';
  List<String>  _listFontSize = [
    'Nhỏ',
    'Bình thường',
    'Lớn',
    'Rất lớn'
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
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
                    AppLocalizations.of(context)!.messageSetting,
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Container(
              height: 580 - 55,
              width: 480,
              child: ListView(
                children: [
                  _buildReadedMessage(),
                  _dashedLines(),
                  _buildSendByEnter(),
                  _dashedLines(),
                  _buildMessagesFromStranger(),
                  _dashedLines(),
                  _buildFontSize(),
                  _dashedLines(),
                  _buildAutoDownLoadImage(),
                  _dashedLines(),
                  _buildAutoDownLoadFile(),
                  _dashedLines(),
                  _buildPreviewWebLinks(),
                  _dashedLines(),
                  _buildHideConversations(),
                  SizedBox(height: 20,)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFontSize() {
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
              Text(
                AppLocalizations.of(context)!.fontSizeSetting,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),

              Container(
                width: 150,height: 40,
                child: DropdownCountryBox(_fontSize,
                 callBack: (value){
                  setState(() {
                    _fontSize = value;
                  });
                 }, 
                 values: _listFontSize),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHideConversations() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //Tự khởi động-------------------
          const SizedBox(
            height: 20,
          ),

          Text(
            AppLocalizations.of(context)!.hideConversationSetting,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
          ),
          SizedBox(height: 4),
          Container(
            width: 330,
            child: Text(
              AppLocalizations.of(context)!.hideConversationSettingContent,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400,color:context.theme.textColor),
            ),
          ),
          SizedBox(height: 12),
          InkWell(
            onTap: () {},
            child: Container(
              width: 120,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: Gradients.sappbarLinear,
                borderRadius: BorderRadius.circular(6),
              ),
              child: GradientText(
                AppLocalizations.of(context)!.setUpPIN,
                gradient: context.theme.gradient,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPreviewWebLinks() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //Tự khởi động-------------------
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
                    AppLocalizations.of(context)!.previewWebLinks,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 330,
                    child: Text(
                      AppLocalizations.of(context)!.previewWebLinksContent,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400,color:context.theme.textColor),
                    ),
                  ),
                ],
              ),
              CustomSwitch(
                  value: _previewWebsLinks,
                  onChanged: (value) {
                    setState(() {
                      _previewWebsLinks = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoDownLoadFile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //Tự khởi động-------------------
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
                    AppLocalizations.of(context)!.autoDownLoadFile,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 330,
                    child: Text(
                      AppLocalizations.of(context)!.autoDownLoadFileContent,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400,color:context.theme.textColor),
                    ),
                  ),
                ],
              ),
              CustomSwitch(
                  value: _autoDownLoadFile,
                  onChanged: (value) {
                    setState(() {
                      _autoDownLoadFile = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoDownLoadImage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //Tự khởi động-------------------
          const SizedBox(
            height: 20,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.autoDownLoadImage,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _autoDownLoadImage,
                  onChanged: (value) {
                    setState(() {
                      _autoDownLoadImage = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesFromStranger() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //Tự khởi động-------------------
          const SizedBox(
            height: 20,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.messagesFromStranger,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
              ),
              CustomSwitch(
                  value: _receiveMessagesFromStranger,
                  onChanged: (value) {
                    setState(() {
                      _receiveMessagesFromStranger = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadedMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //Tự khởi động-------------------
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
                    AppLocalizations.of(context)!.messageRead,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 330,
                    child: Text(
                      AppLocalizations.of(context)!.messageReadContent,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400,color:context.theme.textColor),
                    ),
                  ),
                ],
              ),
              CustomSwitch(
                  value: _autoStart,
                  onChanged: (value) {
                    setState(() {
                      _autoStart = value;
                    });
                  },
                  activeColor: AppColors.black)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendByEnter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //Tự khởi động-------------------
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
                    AppLocalizations.of(context)!.sendMessageWithEnterKey,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color:context.theme.textColor),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 330,
                    child: Text(
                      AppLocalizations.of(context)!.sendMessageWithEnterKeyContent,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400,color:context.theme.textColor),
                    ),
                  ),
                ],
              ),
              CustomSwitch(
                  value: _sendByEnter,
                  onChanged: (value) {
                    setState(() {
                      _sendByEnter = value;
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
