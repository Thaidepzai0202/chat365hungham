// import 'package:chat_365/core/theme/app_colors.dart';
// import 'package:chat_365/modules/chat/model/result_socket_chat.dart';
// import 'package:chat_365/utils/data/enums/emoji.dart';
// import 'package:chat_365/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/enums/emoji.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class EmojiBar extends StatelessWidget {
  const EmojiBar({
    Key? key,
    this.onSelected,
    required this.emotion,
    this.isHoverEmoji,
  }) : super(key: key);
  final ValueChanged<Emoji>? onSelected;
  final Map<Emoji, Emotion> emotion;
  final bool? isHoverEmoji;

  @override
  Widget build(BuildContext context) {
    final int userId = context.userInfo().id;
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: Emoji.values
          .map(
            (e) => Container(
              width: AppConst.kBottomNavigationBarItemIconSize,
              height: AppConst.kBottomNavigationBarItemIconSize,
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  onSelected?.call(e);
                  // Navigator.of(context).pop();
                },
                child: Stack(
                  children: [
                    Image.asset(
                      e.assetPath,
                      fit: BoxFit.contain,
                    ),
                    if (emotion[e]?.didReact(userId) ?? false)
                      const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 2,
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
