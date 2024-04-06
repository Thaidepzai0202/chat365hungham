// import 'package:app_chat365_pc/common/images.dart';
// import 'package:app_chat365_pc/core/theme/app_colors.dart';
// import 'package:app_chat365_pc/core/theme/app_text_style.dart';
// import 'package:app_chat365_pc/modules/features/pages/phone_book/bloc/conversation_group_bloc/conversation_group_bloc.dart';
// import 'package:app_chat365_pc/modules/features/pages/phone_book/bloc/conversation_group_bloc/conversation_group_state.dart';
// import 'package:app_chat365_pc/modules/features/pages/phone_book/widget_custom/form_group.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// class GroupScreen extends StatefulWidget {
//   const GroupScreen({
//     super.key,
//   });
//
//   @override
//   State<GroupScreen> createState() => _GroupScreenState();
// }
//
// class _GroupScreenState extends State<GroupScreen> {
//   late ConversationGroupBloc conversationGroupBloc;
//
//   @override
//   void initState() {
//     conversationGroupBloc = context.read<ConversationGroupBloc>();
//     conversationGroupBloc.takeListConversationGroup();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.colorsappbar,
//       padding: const EdgeInsets.only(left: 14, top: 15),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           InkWell(
//             onTap: (){
//               print('oai vai chuong');
//             },
//             child: Row(
//               children: [
//                 Image.asset(Images.addGroupChat,height: 30,width: 30,),
//                 const SizedBox(width: 20,),
//                const Text(
//                   'Tạo nhóm mới',
//                  style: AppTextStyles.text,
//                 )
//               ],
//             ),
//           ),
//           const SizedBox(height: 15,),
//           Text(
//             'Tính năng nổi bật',
//             style: AppTextStyles.text.copyWith(fontWeight: FontWeight.w700),
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               skillContainer(image: Images.calendarPc, onTap: () {}),
//               skillContainer(image: Images.alarmPc, onTap: () {}),
//               skillContainer(image: Images.objective, onTap: () {}),
//             ],
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           BlocBuilder(
//             bloc: conversationGroupBloc,
//             builder: (context, state) {
//               if (state is LoadedConversationGroupState) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Nhóm đang tham gia (${state.listConversationGroup.length})',
//                       style: AppTextStyles.text
//                           .copyWith(fontWeight: FontWeight.w700),
//                     ),
//                     const SizedBox(
//                       height: 15,
//                     ),
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height - 400,
//                       width: 326,
//                       child: ListView.builder(
//                           itemCount: state.listConversationGroup.length,
//                           itemBuilder: (context, index) {
//                             return FormGroupContainer(
//                                 conversationGroup:
//                                     state.listConversationGroup[index],
//                                 onTap: () {});
//                           }),
//                     )
//                   ],
//                 );
//               } else {
//                 return Text(
//                   'Nhóm đang tham gia ...',
//                   style:
//                       AppTextStyles.text.copyWith(fontWeight: FontWeight.w700),
//                 );
//               }
//             },
//           )
//         ],
//       ),
//     );
//   }
// }
//
// Widget skillContainer({
//   required String image,
//   required Function() onTap,
// }) {
//   return InkWell(
//     onTap: onTap,
//     child: Container(
//       color: AppColors.white,
//       padding: const EdgeInsets.all(6),
//       child: Image.asset(
//         image,
//         height: 24,
//         width: 24,
//       ),
//     ),
//   );
// }
