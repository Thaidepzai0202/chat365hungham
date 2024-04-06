import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatScreenSettingDialog extends StatelessWidget {
  /// Tiêu đề xuất hiện trên Dialog
  final String title;

  /// Những mục xuất hiện trên dialog
  final List<Widget> children;
  final Size size;

  final double titleBarHeight;
  const ChatScreenSettingDialog({
    super.key,
    this.title = "",
    this.size = const Size(400, 450),
    this.children = const <Widget>[],
    this.titleBarHeight = 75.0,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            // Thanh xanh xanh trang trí (giống kiểu AppBar)
            Container(
              height: titleBarHeight,
              decoration:  BoxDecoration(
                gradient: context.theme.gradient,
                // Buộc radius ở đây phải bé hơn radius của Container bên trên
                // Không là sẽ lòi ra khoảng trắng khó hiểu
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
        children: [
          const SizedBox(
            width: 15,
          ),
          // Dialog exit button
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset(
              Images.ic_back_propose,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.modulate,
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
            ),
          ),

          const SizedBox(
            width: 15,
          ),
        ],
      ),

            ),
            Container(
              width: size.width,
              height: size.height-75,
              decoration: BoxDecoration(
                color: context.theme.backgroundColor,
                borderRadius: BorderRadius.circular(15)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // titleWidget,
                  // titleWidget,
                  ...children,
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
