import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_box_names.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/zalo/models/user_model_zalo.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  makeListAccount() async {
    var box = await Hive.openBox(HiveBoxNames.saveListAccountZalo);
    var check = box.get(AuthRepo().userInfo!.id.toString());
    List<UserInfoZalo> allAccount = [];
    if (check.length >= 1) {
      check!.forEach((element) {
        allAccount.add(element);
      });
    }
    print(
        '--------------------Done save account Zalo-----------------------------');
    listUserInfoZalo = allAccount;
  }

  @override
  void initState() {
    super.initState();
    makeListAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: context.theme.backgroundColor,
            borderRadius: BorderRadius.circular(15)),
        height: 250,
        width: 560,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              height: 54,
              decoration: BoxDecoration(
                  gradient: context.theme.gradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quản lý tài khoản',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.close,
                      color: AppColors.white,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            Container(
              width: 560,
              height: 240 - 64,
              padding: const EdgeInsets.all(18),
              child: ListView.builder(
                itemCount: listUserInfoZalo.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      width: 560 - 32,
                      height: 60,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(listUserInfoZalo[index].ava),
                            ),
                          ),
                          Container(
                            width: 150,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            child: Text(
                              listUserInfoZalo[index].name,
                              style: AppTextStyles.nameProfile(context)
                                  .copyWith(fontSize: 17),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: 50,
                            height: 30,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: context.theme.hitnTextColor),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              'Off',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: context.theme.hitnTextColor),
                            ),
                          ),

                          //Đăng nhập lại
                          const SizedBox(width: 10),
                          GradientButton(
                            onTap: () {},
                            text: 'Đăng nhập lại',
                          ),

                          //Xóa tài khoản
                          const SizedBox(width: 10),
                          GradientButton(
                            onTap: () {},
                            text: 'Xóa tài khoản',
                          ),
                        ],
                      ));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GradientButton extends StatefulWidget {
  Function()? onTap;
  String text;

  GradientButton({super.key, required this.text, required this.onTap});

  @override
  _GradientButtonState createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (hovering) {
        setState(() {
          isHovered = hovering;
        });
      },
      child: Container(
          alignment: Alignment.center,
          width: 120,
          height: 30,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 1,
                  color: isHovered
                      ? Colors.transparent
                      : context.theme.text2Color),
              gradient: isHovered ? context.theme.gradient : null,
              borderRadius: BorderRadius.circular(12)),
          child: Text(
            widget.text,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color:
                    isHovered ? AppColors.white : context.theme.text2Color),
          )),
    );
  }
}
