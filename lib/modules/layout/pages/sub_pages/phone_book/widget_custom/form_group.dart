// import 'package:app_chat365_pc/core/theme/app_colors.dart';
// import 'package:app_chat365_pc/core/theme/app_text_style.dart';
// import 'package:flutter/material.dart';
//
// class FormGroupContainer extends StatelessWidget {
//   const FormGroupContainer({
//     super.key,
//     required this.conversationGroup,
//     required this.onTap,
//   });
//   final ConversationGroup conversationGroup;
//   final Function() onTap;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 60,
//         width: 324,
//         color: AppColors.whiteLilac,
//         padding:const EdgeInsets.only(left: 13,right: 13, top: 12),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               height: 40,
//               width: 40,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(40),
//                   image: DecorationImage(
//                     image: NetworkImage(conversationGroup.avatarConversation),
//                     fit: BoxFit.cover
//                   )
//               ),
//             ),
//             const SizedBox(width: 10,),
//             Container(
//               width: 236,
//               padding:const EdgeInsets.only(bottom: 12),
//               decoration:  BoxDecoration(
//                 border: Border(bottom: BorderSide(
//                   color: AppColors.grey666.withOpacity(0.4),
//                   width: 1,
//                 )
//               ),),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                       Expanded(
//                         child: Text(
//                           conversationGroup.conversationName,
//                           overflow: TextOverflow.ellipsis,
//
//                           style: AppTextStyles.text,
//                         ),
//                       ),
//                       Text(
//                         '${conversationGroup.listMember.length} thành viên',
//                         style: AppTextStyles.text.copyWith(fontSize: 14),
//                       ),
//                     ],
//                   ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
