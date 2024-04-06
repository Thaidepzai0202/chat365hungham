import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/data/services/sp_utils_service/sp_utils_services.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:app_chat365_pc/utils/helpers/validators.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class EmailField extends StatefulWidget {
  const EmailField({
    Key? key,
    this.controller,
    this.focusNode,
    this.validator,
  }) : super(key: key);
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  @override
  _EmailFieldState createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  late final TextEditingController _controller;
  final List<String> _emails = spService.loggedInEmail;
  String? Function(String?)? _validatorAccount;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _validatorAccount = Validator.requiredInputPhoneOrEmailValidator;
    // _controller.addListener(_handleControllerChanged);
    // widget.data.addListener(_onData);
  }

  @override
  void didUpdateWidget(covariant EmailField oldWidget) {
    _validatorAccount =
        widget.validator ?? Validator.requiredInputPhoneOrEmailValidator;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 70,
      child: TextFormField(
        validator: _validatorAccount,
        autovalidateMode: AutovalidateMode.onUserInteraction,
          style: context.theme.inputStyle,
          controller: _controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            if (_validatorAccount != null) {
              setState(() {
                _validatorAccount = Validator.requiredInputPhoneOrEmailValidator;
              });
            }
          },
          decoration: context.theme.inputDecoration.copyWith(

            hintText: AppLocalizations.of(context)!.inputPhoneOrEmail,
            hintStyle: context.theme.hintStyle,
            prefixIcon: Container(
              padding: EdgeInsets.only(left: 10),
              child: SvgPicture.asset(
                Images.ic_person,
                height: 20,
                width: 20,
                color: AppColors.grey666,
              ),
            ),
          ),
      ),
    );
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }
}
