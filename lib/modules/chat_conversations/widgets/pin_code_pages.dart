import 'dart:async';

import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinCodePages extends StatefulWidget {
  const PinCodePages(
      {super.key,required this.validator, required this.onComplete});

  final void Function(String) onComplete;
  final String? Function(String?) validator;


  @override
  State<PinCodePages> createState() => _PinCodePagesState();
}

class _PinCodePagesState extends State<PinCodePages> {
  final formKey = GlobalKey<FormState>();
  TextEditingController pinCodeChat = TextEditingController();

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(

      key: formKey,
      child: Container(
        // color: Colors.blue,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 20,
        ),
        height: 100,
        width: 300,
        child: PinCodeTextField(
          textStyle: TextStyle(color: context.theme.text2Color),
          appContext: context,
          pastedTextStyle:  TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.bold,
          ),
          length: 6,
          obscureText: false,
          blinkWhenObscuring: true,
          animationType: AnimationType.fade,
          validator: widget.validator,
          pinTheme: PinTheme(
              activeColor: context.theme.colorPirimaryNoDarkLight,
              selectedColor: AppColors.white,
              inactiveColor: Colors.white,
              activeFillColor: context.theme.backgroundSelectChat,
              selectedFillColor: context.theme.backgroundSelectChat,
              inactiveFillColor: context.theme.backgroundSelectChat),
          cursorColor: context.theme.colorPirimaryNoDarkLight,
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          errorAnimationController: errorController,
          controller: pinCodeChat,
          keyboardType: TextInputType.number,
          boxShadows: const [
            BoxShadow(
              offset: Offset(0, 1),
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
          onCompleted: widget.onComplete,
          onChanged: (value) {
            debugPrint(value);
            setState(() {
              currentText = value;
            });
          },
          beforeTextPaste: (text) {
            debugPrint("Allowing to paste $text");
            return true;
          },
        ),
      ),
    );
  }
}
