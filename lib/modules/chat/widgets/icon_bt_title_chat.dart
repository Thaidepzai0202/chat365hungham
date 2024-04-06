import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconEndTitleChat extends StatelessWidget {
  IconEndTitleChat({super.key, required this.icon, required this.callback});

  String icon;
  VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: ValueListenableBuilder(
          valueListenable: changeTheme,
          builder: (context, value, child) {
            return InkWell(
              onTap: callback,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, gradient: context.theme.gradient),
                child: Transform.scale(
                  scale: 0.7, // Điều chỉnh tỷ lệ kích thước của hình ảnh
                  child: SvgPicture.asset(
                    icon,
                    color: AppColors.white,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
