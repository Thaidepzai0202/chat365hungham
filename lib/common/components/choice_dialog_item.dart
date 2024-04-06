import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChoiceDialogItem<T> extends StatelessWidget {
  const ChoiceDialogItem({
    Key? key,
    required this.value,
    required this.onTap,
    this.iconPath,
    this.boldText = false,
    this.color,
  }) : super(key: key);

  final T value;
  final VoidCallback onTap;
  final bool boldText;
  final String? iconPath;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        try {
          Navigator.of(context).pop();
        } catch (e, s) {
          logger.logError(e, s);
        }
        onTap();
      },
      child: Column(
        crossAxisAlignment: iconPath!=null?CrossAxisAlignment.center:CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          if(iconPath!=null)SvgPicture.asset(iconPath!,color: color,),
          Ink(
            // color: boldText?AppColors.lightGray:null,
            height: iconPath!=null?30:40,
            padding: EdgeInsets.symmetric(horizontal: iconPath!=null?0:10),
            child: Align(
              alignment: iconPath!=null?Alignment.topCenter:Alignment.centerLeft,
              child: Text(
                value.toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.regularW400(
                  context,
                  size: 13,
                  lineHeight: 16,
                  color: context.theme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
