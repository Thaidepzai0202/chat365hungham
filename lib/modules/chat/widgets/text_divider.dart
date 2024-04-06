import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  const TextDivider({
    Key? key,
    required this.text,
    this.color,
  }) : super(key: key);

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color _color = color ?? context.theme.dividerDefaultColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: _color,
              thickness: 0.2,
            ),
          ),
          const SizedBox(width: AppConst.kDividerTextPadding),
          Text(
            text,
            style: AppTextStyles.regularW400(
              context,
              size: 12,
              color: _color,
            ),
          ),
          const SizedBox(width: AppConst.kDividerTextPadding),
          Expanded(
            child: Divider(
              color: _color,
              thickness: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
