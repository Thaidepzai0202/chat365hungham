import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/widgets/form/outline_text_form_field.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PasswordField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool showIconLock;
  final AutovalidateMode? autovalidateMode;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  const PasswordField({
    Key? key,
    required this.hintText,
    this.controller,
    this.validator,
    this.showIconLock = true,
    this.autovalidateMode,
    this.onChanged,
    this.focusNode,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 62,
      child: OutlineTextFormField(
        controller: widget.controller,
        style: context.theme.inputStyle,
        obscureText: isVisible,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        validator: widget.validator,
        autovalidateMode: widget.autovalidateMode,
        decoration: context.theme.inputDecoration.copyWith(
          fillColor: AppColors.white,
          // helperText: '',
          
          hintText: widget.hintText,
          prefixIcon: Container(
            padding: EdgeInsets.only(left: 10),
              child: SvgPicture.asset(
                Images.ic_pass,height: 20,width: 20,
                color: AppColors.grey666,
              ),
          ),
          suffixIcon: IconButton(
            onPressed: () => setState(() => isVisible = !isVisible),
            padding: EdgeInsets.only(right: 16),
            constraints: BoxConstraints(maxHeight: 20),
            splashRadius: 8,
            iconSize: 20,
            icon: SvgPicture.asset(
              isVisible ? Images.eye_off_2 : Images.ic_eye,
              width: 20,
              height: 20,
              color: isVisible ? AppColors.gray : AppColors.primary,
            ),
          ),
          hintStyle: TextStyle(color: AppColors.gray),
        ),
      ),
    );
  }
}
