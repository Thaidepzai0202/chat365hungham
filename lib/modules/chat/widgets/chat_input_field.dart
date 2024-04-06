// ignore_for_file: deprecated_member_use

import 'package:app_chat365_pc/common/widgets/weighted_icon.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../utils/data/enums/message_type.dart';

class ChatInputField extends StatelessWidget {
  ChatInputField({
    super.key,
    this.onChanged,
    required this.onTapEmoji,
    this.controller,
    this.focusNode,
    this.autoFocus,
    this.onTapPaste,
    this.callback,
  });

  final ValueChanged<bool> onTapEmoji;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onTapPaste;
  VoidCallback? callback;
  final bool? autoFocus;
  bool isShow = false;
  final bool isHide = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints) {
      return SizedBox(
        // color: context.theme.backgroundChatContent,
        width: MediaQuery.of(context).size.width,
        child: TextField(
          style: TextStyle(color: context.theme.textColor),
          onTap: () async {
            // var copyData = (await Clipboard.getData('text/plain'))?.text;
            // if (messagePaste != null ||  (copyData != null && copyData != 'null')/* && messagePaste?.type!=MessageType.text*/) {
            //   isHide = true;
            // } else {
            //   isHide = false;
            // }
            // overlayState ??= navigatorKey.currentState?.overlay;
            // OverlayEntry overlayEntry = OverlayEntry(
            //     builder: (context) => Positioned(
            //       left: 10,
            //       right: AppDimens.width - 70,
            //       bottom: MediaQuery.of(context).viewInsets.bottom + 60,
            //       child: GestureDetector(
            //         onTap: () async {
            //           isHide = false;
            //
            //           if ((!copyData.isBlank && copyData != 'null') || (messagePaste?.message.isBlank == false)) {
            //             copyData ??=messagePaste?.message??'';
            //             controller!.value = controller!.value.copyWith(
            //               text: controller!.text + (copyData!),
            //               selection: TextSelection.collapsed(offset: (controller!.text + copyData!).length),
            //             );
            //             return;
            //           }
            //           if (messagePaste?.type == MessageType.image) {
            //             onTapPaste?.call(true);
            //             return;
            //           }
            //         },
            //         child: Container(
            //             alignment: Alignment.center,
            //             padding: EdgeInsets.all(10),
            //             decoration: BoxDecoration(
            //                 color: Colors.black.withOpacity(.5),
            //                 borderRadius: BorderRadius.circular(10)),
            //             child: Text(
            //               'Dán',
            //               style: TextStyle(
            //                   fontSize: 18,
            //                   color: Colors.white,
            //                   fontWeight: FontWeight.w400,
            //                   decoration: TextDecoration.none),
            //             )),
            //       ),
            //     ));
            // if (isHide) {
            //   overlayState?.insert(overlayEntry);
            //   Future.delayed(Duration(milliseconds: 1500), overlayEntry.remove);
            // } else {
            //   overlayEntry.remove;
            // }
          },
          cursorColor: context.theme.textColor,
          autofocus: true,
          keyboardType: TextInputType.multiline,
          cursorHeight: 18,
          onChanged: onChanged,
          controller: controller,
          focusNode: focusNode,
          maxLines: 5,
          onEditingComplete: callback,
          onSubmitted: (value) {
            callback;
          },
          // Set maxLines thành null để tự động mở rộng chiều cao
          minLines: 1,
          enableSuggestions: false,
          autocorrect: false,
          textInputAction: TextInputAction.continueAction,
          toolbarOptions: const ToolbarOptions(
              copy: true, cut: true, selectAll: true, paste: true),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.enterMessage ??'',
            hintStyle: TextStyle(fontSize: 14,color: context.theme.hitnTextColorInputBar),
            contentPadding: const EdgeInsets.all(20),
            isDense: true,
            prefixIcon: InkWell(
              onTap: () {
                isShow = !isShow;
                onTapEmoji.call(isShow);
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: WeightedIcon(
                  Icons.emoji_emotions_outlined,
                  size: 25,
                  weight: FontWeight.w100,
                  color: context.theme.hitnTextColorInputBar,
                ),
              ),
            ),
            filled: true,
            fillColor:const Color.fromARGB(15, 244, 244, 244),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: const BorderSide(color: Colors.transparent, width: 0.3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: const BorderSide(color: Colors.transparent, width: 0.3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: const BorderSide(color: Colors.transparent, width: 0.3),
            ),
          ),
        ),
      );
    });
  }
}
