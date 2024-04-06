import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


// ignore: must_be_immutable
class TextDisplay extends StatelessWidget {
  TextDisplay({
    Key? key,
    required this.isSentByCurrentUser,
    required this.message,
    required this.emotionBarSize,
    this.sentTime,
    this.mesFinded,
  }) : super(key: key);

  final bool isSentByCurrentUser;
  final String? message;
  final DateTime? sentTime;
  final String? mesFinded;
  final ValueNotifier<double> emotionBarSize;
  // Future<Offset> getCursorPosition;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: ValueListenableBuilder(
          valueListenable: changeTheme,
          builder: (context, value, child) {
            return ValueListenableBuilder(
              valueListenable: emotionBarSize,
              builder: (_, __, ___) {
                var boxWidth = emotionBarSize.value <= 0? null: emotionBarSize.value + 40;
                return Container(
                  constraints: boxWidth != null ? BoxConstraints(
                    minWidth: boxWidth
                  ) : null,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: isSentByCurrentUser
                          ? null
                          : context.theme.backgroundListChat,
                      gradient: isSentByCurrentUser ? context.theme.gradient : null),
                  child: Column(
                    crossAxisAlignment: isSentByCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Linkify(
                        onOpen: (link, details) {
                          logger.log(link.runtimeType, name: "Cursor Event");
                          if (link is UrlElement) {
                            showMenu(
                              color: context.theme.backgroundOnForward,
                              context: context,
                              position: RelativeRect.fromLTRB(
                                details.globalPosition.dx,
                                details.globalPosition.dy,
                                details.globalPosition.dx + 1,
                                details.globalPosition.dy + 1),
                              items: [
                                PopupMenuItem(
                                  height: 33,
                                  child: Text(
                                    AppLocalizations.of(context)?.openLink ?? '',
                                    style: TextStyle(color: context.theme.text2Color,fontSize: 14),
                                  ),
                                  onTap: () async {
                                    final Uri url = Uri.parse(link.url);
                                    launchUrl(url).then((success) {
                                      if (!success) {
                                        AppDialogs.toast("Đã xảy ra lỗi khi mở link");
                                      }
                                    });
                                  },
                                ),
                                PopupMenuItem(
                                  height: 33,
                                  child: Text(
                                    AppLocalizations.of(context)?.copy ?? '',
                                    style: TextStyle(color: context.theme.text2Color,fontSize: 14),
                                  ),
                                  onTap: () async {
                                    Clipboard.setData(ClipboardData(text: link.url));
                                    AppDialogs.toast(AppLocalizations.of(context)!.savedToClipboard);
                                  },
                                ),
                              ]
                            );
                            
                          } else if (link is EmailElement) {
                            Clipboard.setData(ClipboardData(text: link.text));
                            AppDialogs.toast(AppLocalizations.of(context)!.savedToClipboard);
                          } else if (link is PhoneNumberElement) {
                            Clipboard.setData(ClipboardData(text: link.text));
                            AppDialogs.toast(AppLocalizations.of(context)!.savedToClipboard);
                          }
                        },
                        useMouseRegion: true,
                        linkifiers: const [
                          EmailLinkifier(),
                          UrlLinkifier(),
                          PhoneNumberLinkifier()
                        ],
                        options: const LinkifyOptions(
                          humanize: false
                        ),
                        text: message??"",
                        linkStyle: TextStyle(
                          color: isSentByCurrentUser ? AppColors.white : context.theme.textColor
                        ),
                        style: TextStyle(
                          color: isSentByCurrentUser ? AppColors.white : context.theme.textColor
                        ),
                      )],
                  ),
                );
              }
            );
          }),
    );
  }
}