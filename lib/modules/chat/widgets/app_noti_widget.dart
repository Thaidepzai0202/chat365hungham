import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class AppNotiWidget extends StatelessWidget {
  const AppNotiWidget({
    Key? key,
    required this.noti,
    this.onTap,
    required this.buttonLabel,
    this.showErrorButton = true,
  }) : super(key: key);

  final String noti;
  final VoidCallback? onTap;
  final String buttonLabel;
  final bool showErrorButton;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) {
        return Container(
          height: AppDimens.height,
          width: AppDimens.width,
          color: context.theme.backgroundChatContent,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  noti,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.text(context),
                ),
                const SizedBox(height: 10),
                if (showErrorButton)
                  InkWell(
                    onTap: onTap,
                    child: Container(
                      alignment: Alignment.center,
                      width: 130,
                      height: 40,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          gradient: context.theme.gradient),
                      child: Text(
                        buttonLabel,
                        style: AppTextStyles.text(context).copyWith(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
