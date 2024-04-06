import 'dart:async';

import 'package:app_chat365_pc/common/Widgets/confirm_dialog.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SendMessageSearchForward extends StatefulWidget {
  SendMessageSearchForward({
    Key? key,
    required this.controller,
    this.onSubmit,
    this.stateNotifier,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSubmit;
  final ValueNotifier<DialogState>? stateNotifier;

  @override
  State<SendMessageSearchForward> createState() =>
      _SendMessageSearchForwardState();
}

class _SendMessageSearchForwardState extends State<SendMessageSearchForward> {
  final StreamController<DialogState> _controller =
      StreamController.broadcast();
  String _lastValue = '';

  Widget _buildSuffixIcon(BuildContext context) {
    return SizedBox.square(
      dimension: 18,
      child: StreamBuilder<DialogState>(
        stream: _controller.stream,
        builder: (_, sns) {
          if (sns.data == DialogState.processing)
            return CircularProgressIndicator(
              color: AppColors.white,
              strokeWidth: 2.5,
            );
          else if (widget.controller.text.isNotEmpty) {
            return _cancelButton();
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _cancelButton() {
    return IconButton(
      icon: Icon(Icons.cancel),
      color: AppColors.gray,
      padding: EdgeInsets.zero,
      onPressed: () => widget.controller.clear(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onSubmitted: widget.onSubmit,
      onChanged: (value) {
        if (value.isNotEmpty && value != _lastValue) {
          _controller.sink.add(DialogState.success);
          _lastValue = value;
        }
      },
      style: TextStyle(color:context.theme.textColor),
      decoration: InputDecoration(
        filled: true,
        // fillColor: AppColors.grayF3F4FF,
        fillColor: context.theme.backgroundOnForward,
        hintText: StringConst.search,
        hintStyle: TextStyle(color: context.theme.hitnTextColorInputBar),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _buildSuffixIcon(context),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: SvgPicture.asset(
            Images.ic_uil_search,
            color: context.theme.iconColor,
            width: 10,
            height: 10,
          ),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
        ),
      ),
    );
  }
}
