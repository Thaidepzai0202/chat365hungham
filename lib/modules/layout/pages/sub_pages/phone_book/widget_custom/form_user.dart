import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/model/contact_model.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class FormUserContainer extends StatelessWidget {
    const FormUserContainer({super.key, required this.contactModel,required this.onTap});
 final ContactModel contactModel;
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
                  image: NetworkImage(contactModel.avatarUser),
                  fit: BoxFit.cover
                )
              ),
              child: Container(
                alignment: Alignment.bottomRight,
                child: contactModel.active == 1 ? iconStatus(AppColors.online, )
                    : contactModel.active == 2
                 ? iconStatus(AppColors.offline, )
                    : contactModel.active == 3 ? iconStatus(AppColors.red, )
                : iconStatus(AppColors.grey666, )
              ),
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: Text(
                contactModel.userName,
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
Widget iconStatus(
    Color backGroundColor,
    ){
  return Container(
      height: 12,
      width: 12,
      decoration: BoxDecoration(
      color: backGroundColor,
      borderRadius: BorderRadius.circular(12),
  border: Border.all(color: AppColors.white,width: 2)
      ));
}