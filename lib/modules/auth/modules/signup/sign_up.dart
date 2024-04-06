import 'dart:io';

import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/modules/auth/modules/login/login_singup.dart';
import 'package:flutter/material.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'sign_up_company.dart';
import 'sign_up_employee_id_company.dart';
import 'sign_up_personal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class InPutSignUp extends StatefulWidget {
  final String yourchoose;
  InPutSignUp({required this.yourchoose});
  @override
  _InPutSignUpState createState() => _InPutSignUpState();
}

class _InPutSignUpState extends State<InPutSignUp> {
  Offset position = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        color: AppColors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (Platform.isMacOS) const SizedBox(height: 20),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                onPanUpdate: (details) {
                  appWindow.position = Offset(
                    appWindow.position.dx + details.localPosition.dx,
                    appWindow.position.dy + details.localPosition.dy,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LogoCompany(),
                    WindowButtonSmall(),
                  ],
                ),
              ),
              color: AppColors.white,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    Images.ic_back,
                    width: 70,
                    height: 70,
                    color: AppColors.primary,
                  ),
                  iconSize: 50,
                  onPressed: () {
                    AppRouter.back(context);
                    //AppRouter.toPage(context, AppPages.logIn);
                  },
                ),
                SizedBox(
                  width: 110,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: SvgPicture.asset(
                    Images.big_chat365,
                    width: 100,
                    height: 100,
                  ),
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height -165,
              color: AppColors.white,
              child: widget.yourchoose == AppLocalizations.of(context)!.company2
                  ? InputSignUpCompany()
                  : widget.yourchoose == AppLocalizations.of(context)!.employee2
                      ? InputSignUpEmployeeIDCompany()
                      : InputSignUpPersonal(),
            )
          ],
        ),
      ),
    );
  }
}
