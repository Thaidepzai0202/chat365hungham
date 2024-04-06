import 'package:app_chat365_pc/core/error_handling/app_error_state.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/model/list_account_model.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/widget_custom/form_user.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class FormNewFriend extends StatelessWidget {
  const FormNewFriend({super.key, required this.listAccount,required this.onTap});
  final ListAccount listAccount;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 324,
        color: context.theme.friendBoxColor,
        padding:const EdgeInsets.symmetric(horizontal: 13,vertical: 12),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  image: DecorationImage(
                      image: NetworkImage(listAccount.avatarUser),
                      fit: BoxFit.cover
                  )
              ),
              child: Container(
                  alignment: Alignment.bottomRight,
                  child: listAccount.isOnline == 1 ? iconStatus(AppColors.online,)
                      : iconStatus(AppColors.grey666, )
              ),
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: Text(
                listAccount.userName,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}