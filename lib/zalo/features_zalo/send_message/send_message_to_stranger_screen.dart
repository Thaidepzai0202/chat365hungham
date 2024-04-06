import 'package:flutter/material.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';

class SendMessageToStranger extends StatefulWidget {
  const SendMessageToStranger({super.key});

  @override
  State<SendMessageToStranger> createState() => _SendMessageToStrangerState();
}

class _SendMessageToStrangerState extends State<SendMessageToStranger> {
  final TextEditingController _textPhoneToAddFriendZalo =
      TextEditingController();
  final TextEditingController _textMessToStranger = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.theme.backgroundColor,
      child: SizedBox(
        width: 500,
        height: 300,
        child: Column(
          children: [
            Container(
                height: 50,
                width: 500,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    gradient: context.theme.gradient,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12))),
                child: const Text(
                  StringConst.sendMessToStrnager,
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                )),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
              child: TextFormField(
                  cursorColor: context.theme.colorPirimaryNoDarkLight,
                  controller: _textPhoneToAddFriendZalo,
                  style: TextStyle(color: context.theme.text2Color),
                  decoration: InputDecoration(
                    hintStyle: context.theme.hintStyle,
                    hintText: StringConst.inputPhoneNumber,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: context.theme.colorPirimaryNoDarkLight,
                            width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: context.theme.hitnTextColor, width: 1)),
                  )),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              child: TextFormField(
                  cursorColor: context.theme.colorPirimaryNoDarkLight,
                  maxLines: 3,
                  controller: _textMessToStranger,
                  style: TextStyle(color: context.theme.text2Color),
                  decoration: InputDecoration(
                    hintStyle: context.theme.hintStyle,
                    hintText: StringConst.inputMessage,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: context.theme.colorPirimaryNoDarkLight,
                            width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: context.theme.hitnTextColor, width: 1)),
                  )),
            ),
            const SizedBox(height: 10,),
            InkWell(
              onTap: () {
                
              },
              child: Container(
                width: 120,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    gradient: context.theme.gradient,
                    borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  StringConst.send,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}