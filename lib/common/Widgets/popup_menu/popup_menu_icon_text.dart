import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PopUpMenuItemIconText extends StatelessWidget {
  PopUpMenuItemIconText(
      {super.key, required this.text, required this.svgIcon, this.color});

  String text;
  String svgIcon;
  Color? color;

  @override
  Widget build(BuildContext context) {
    return PopupMenuItem<String>(
      value: text,
      height: 0,
      child: ListTile(
        leading: SvgPicture.asset(
          svgIcon,
          width: 25,
          height: 25,
          color: color ?? null,
        ), // Biểu tượng ở đây
        title: Text(
          text,
          style: TextStyle(color: color, fontSize: 13),
        ),
      ),
    );
  }
}
