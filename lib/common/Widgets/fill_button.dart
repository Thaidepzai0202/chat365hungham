import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/ui/app_border_and_radius.dart';
import 'package:app_chat365_pc/utils/ui/app_padding.dart';
import 'package:flutter/material.dart';

class FillButton extends StatelessWidget {
  final Function()? onPressed;
  final String title;
  final TextStyle? style;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final OutlinedBorder? shape;
  final double? width;
  final Color? backgroundColor;
  final Gradient? gradient;

  const FillButton(
      {Key? key,
      this.onPressed,
      required this.title,
      this.style,
      this.elevation,
      this.padding,
      this.shape,
      this.width,
      this.backgroundColor,
      this.gradient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: elevation ?? 0,
        backgroundColor: backgroundColor ?? context.theme.primaryColor,
        padding: padding ?? AppPadding.paddingHor15Vert10,
        shape: shape ?? AppBorderAndRadius.roundedRectangleBorder,
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: style ??
            AppTextStyles.button(context)
                .copyWith(color: context.theme.backgroundColor),
      ),
    );

    final button2 = InkWell(
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        padding: padding ?? AppPadding.paddingHor30Vert10,
        decoration: BoxDecoration(
            gradient: gradient ?? context.theme.gradient,
            borderRadius: BorderRadius.circular(30)),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: style ??
              AppTextStyles.button(context)
                  .copyWith(color: context.theme.text2Color),
        ),
      ),
    );

    return width == null
        ? button2
        : SizedBox(
            width: width,
            child: button2,
          );
  }
}
