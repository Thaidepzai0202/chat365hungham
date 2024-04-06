import 'dart:convert';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_box_names.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/zalo/clients/chat_client_zalo.dart';
import 'package:app_chat365_pc/zalo/zalo_qr/login_cubit_zalo/login_cubit_zalo.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ZaloQRScreen extends StatefulWidget {
  const ZaloQRScreen({super.key});

  @override
  State<ZaloQRScreen> createState() => _ZaloQRScreenState();
}

class _ZaloQRScreenState extends State<ZaloQRScreen> {
  late final LoginCubitZalo _loginCubitZalo;
  ValueNotifier<String> dataQR = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    _loginCubitZalo = context.read<LoginCubitZalo>();
    _loginCubitZalo.listenForQRLoginSocket();

    chatClientZalo.stream.listen((event) {
      if (event is ChatEventOnQRLoginZalo) {
        dataQR.value = event.base6QR.split(',')[1];
        dataQR.value = dataQR.value.split('}')[0];
      } else if (event is ChatEventLoginSuccessZalo) {
        userInfoZalo = event.userInfoZalo;
        if (!listUserInfoZalo
            .any((check) => check.idZalo == event.userInfoZalo.idZalo)) {
          listUserInfoZalo.add(event.userInfoZalo);
        }
        saveAccountZalo();
        saveListAccountZalo();

        Navigator.of(context).pop();
        isZalo.value = true;
      } else if (event is CheckLoginZalo) {
        print('-------Check-login-zalo---${event.checkcheck}');
      }
    });
  }

  saveAccountZalo() async {
    var box = await Hive.openBox(HiveBoxNames.saveAccountZalo);
    await box.put('accountZalo', userInfoZalo);
  }

  //Lưu nhiều tài khản Zalo
  saveListAccountZalo() async {
    var box = await Hive.openBox(HiveBoxNames.saveListAccountZalo);
    await box.put(AuthRepo().userInfo!.id.toString(), listUserInfoZalo);
  }

  @override
  void dispose() {
    super.dispose();
    // dataQR.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: BlocListener<LoginCubitZalo, LoginStateZalo>(
        bloc: _loginCubitZalo,
        listener: (context, state) async {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 50),
          height: 1000,
          width: 500,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: context.theme.backgroundColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                SizedBox(
                  height: 40,
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GradientText(
                        'Đăng nhập Zalo',
                        gradient: context.theme.gradient,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        height: 2,
                        decoration:
                            BoxDecoration(gradient: context.theme.gradient),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  height: 40,
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GradientText(
                        'Đăng nhập Facebook',
                        gradient: context.theme.swichoffgraident,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                            gradient: context.theme.swichoffgraident),
                      )
                    ],
                  ),
                )
              ]),
              const SizedBox(
                height: 50,
              ),
              Text(
                'Vui lòng quét QR để đăng nhập tài khoản Zalo',
                style: TextStyle(fontSize: 17, color: context.theme.text2Color),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                height: 300,
                width: 300,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: ValueListenableBuilder(
                  valueListenable: dataQR,
                  builder: (context, value, child) {
                    if (dataQR.value != '') {
                      return SizedBox(
                          width: 270,
                          height: 270,
                          child: Image.memory(base64Decode(dataQR.value)));
                    } else {
                      return const ShimmerLoading(size: Size(270, 270));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
