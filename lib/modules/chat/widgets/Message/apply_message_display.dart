import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/com_item_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/common/repos/get_token_repo.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/data/services/generator_service.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplyMessageDisplay extends StatelessWidget {
  ApplyMessageDisplay({
    Key? key,
    required this.isSentByCurrentUser,
    this.infoLink,
    required String? link,
    required this.content,
    required this.isApply,
    required this.messageModel,
    this.uscId,
  })  : _link = getLink(infoLink, link, isApply, uscId),
        super(key: key);

  final InfoLink? infoLink;
  final String _link;
  final String content;
  final bool isApply;
  final String? uscId;

  final SocketSentMessageModel messageModel;

  static String getLink(
      InfoLink? infoLink, String? link, bool isApply, String? uscId) {
    if (link != null) {
      return GeneratorService.generate365Link(link);
    }
    return infoLink?.fullLink ?? "";
  }

  _onTapLink() async {
    if (_link.contains('www.google.com/maps')) _link.replaceAll('www', '');
    print('link đâu apply: ${_link}');
    chatRepo.clickMessage(
      userId: AuthRepo().userId ?? -1,
      conversationId: messageModel.conversationId,
      messageId: messageModel.messageId);
    if (messageModel.type == MessageType.OfferReceive) {
      String token = await GetTokenRepo(AuthRepo()).getTokenVanThu();
      final Uri url = Uri.parse('$_link?token=$token');
      return launchUrl(url);
    } else {
      return launchUrl(Uri.parse(_link));
    }
  }

  final bool isSentByCurrentUser;

  @override
  Widget build(BuildContext context) {
    var themeData = context.theme;
    var backgroundColor =
        isSentByCurrentUser ? null : themeData.messageBoxColor;
    var textStyleTitle = themeData.messageTextStyle.copyWith(
      color: isSentByCurrentUser ? AppColors.white : null,
      fontSize: 18, fontWeight: FontWeight.w700
    );

    var numFirstEnter = content.indexOf('\n');
    String titleContent = content;
    String endContent = content;
    if (numFirstEnter != -1) {
      titleContent = content.substring(0,numFirstEnter);
      endContent = content.substring(numFirstEnter+1);
    }


    return ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (BuildContext context, dynamic value, Widget? child) {
        return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            decoration: BoxDecoration(
              color: backgroundColor,
              gradient: isSentByCurrentUser ? themeData.gradient : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2,),
                      Center(child: Text(titleContent,style: textStyleTitle,)),
                      SizedBox(height: 6,),
                      Text(endContent,style: TextStyle(color: isSentByCurrentUser ? AppColors.white : context.theme.textColor, fontSize: 12)),
                      SizedBox(height: 4,)
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                InkWell(
                  onTap: _onTapLink,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 1,
                          color: messageModel.isClicked == 0
                              ? !isSentByCurrentUser
                                  ? AppColors.blueGradients1
                                  : AppColors.white
                              : AppColors.greyCC),
                      // color: context.theme.primaryColor,
                      gradient: messageModel.isClicked == 0
                          ? themeData.gradient
                          : LinearGradient(colors: [
                              Color.fromARGB(255, 64, 64, 64),
                              Colors.grey
                            ]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 11),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          messageModel.isClicked == 0
                          ? AppLocalizations.of(context)?.seeNow ?? ''
                          : AppLocalizations.of(context)?.seen ??'',
                          style: AppTextStyles.regularW600(
                            context,
                            size: 14,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBoxExt.w5,
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white
                          ),
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) => context.theme.gradient.createShader(bounds),
                            child: SvgPicture.asset(Images.ic_play_message,fit:BoxFit.contain,color: AppColors.white,height: 15,width: 15,)
                            ),
                        ),
                        // ShaderMask(child: SvgPicture.asset(Images.ic_play_message,))
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4,)
              ],
            ));
      },
    );
  }
}
