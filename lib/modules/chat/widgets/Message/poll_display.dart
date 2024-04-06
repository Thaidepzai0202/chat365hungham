// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../common/images.dart';
// import '../../../../core/theme/app_text_style.dart';
//
// class PollDisplay extends StatefulWidget {
//   final String? message;
//
//   PollDisplay(this.message);
//
//   PollData pollData = PollData('', '', 0, '', [], 0, '', '', '', 0);
//
//   @override
//   State<PollDisplay> createState() => _PollDisplayState();
// }
//
// class _PollDisplayState extends State<PollDisplay> {
//   late PollCubit pollCubit;
//   PollData pollData = PollData.empty();
//
//   @override
//   initState() {
//     pollCubit = context.read<PollCubit>();
//     super.initState();
//   }
//
//   void showModalDelete(BuildContext context, pollCubit, pollData) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           child: Container(
//             width: 345,
//             height: 90,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: Colors.white,
//             ),
//             child: Column(
//               children: [
//                 InkWell(
//                   onTap: () {
//                     // Navigator.of(context)
//                     //     .push(
//                     //   MaterialPageRoute(
//                     //     builder: (context) => BlocProvider(
//                     //         create: (context) => PollCubit(),
//                     //         child: DetailIdeaPollScreen(pollCubit, pollData)),
//                     //   ),
//                     // )
//                     //     .then((value) {
//                     //   Navigator.pop(context);
//                     // });
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     child: Text(
//                       'Xem chi tiết',
//                       style: AppTextStyles.contentInDetailIdeaPoll.copyWith(
//                         decoration: TextDecoration.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () {
//                     Navigator.pop(context);
//                     confirmDeletePoll(context);
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.only(bottom: 22),
//                     child: Text(
//                       'Xoá',
//                       style: AppTextStyles.contentInDetailIdeaPoll.copyWith(
//                         decoration: TextDecoration.none,
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void confirmDeletePoll(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           child: Container(
//               width: 345,
//               height: 200,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 color: Colors.white,
//               ),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 28),
//                     child: Text('Xoá thăm dò ý kiến',
//                         style: AppTextStyles.viewDetailPoll),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 30),
//                     child: Text('Bạn chắc chắn muốn xoá ý kiến ABC?',
//                         style: AppTextStyles.candidate_categoryItemName),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 45, bottom: 30),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         InkWell(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: Text('HUỶ',
//                                 style: AppTextStyles.BtnCancelDelete)),
//                         InkWell(
//                           onTap: () {
//                             pollCubit.onDelete(pollData.pollId ?? "");
//                             Navigator.pop(context);
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.only(right: 30, left: 35),
//                             child: Text('XOÁ',
//                                 style: AppTextStyles.BtnCancelDelete),
//                           ),
//                         )
//                       ],
//                     ),
//                   )
//                 ],
//               )),
//         );
//       },
//     );
//   }
//
//   int currentIndex = -1;
//   int numberVote = 2;
//
//   @override
//   Widget build(BuildContext context) {
//     final jsonMess = jsonDecode(widget.message ?? '');
//     PollData pollData = PollData.fromJson(jsonMess);
//
//     return GestureDetector(
//       onLongPress: () {
//         showModalDelete(context, pollCubit, pollData);
//       },
//       child: Padding(
//         padding: const EdgeInsets.only(right: 15),
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
//               decoration: BoxDecoration(
//                   color: Color(0xffF7F8FC),
//                   borderRadius:
//                       BorderRadius.only(topLeft: Radius.circular(15))),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding:
//                         const EdgeInsets.only(top: 17, bottom: 5, left: 18),
//                     child: pollData.valueTitle != ''
//                         ? Text(pollData.valueTitle!,
//                             style: AppTextStyles.viewDetailPoll)
//                         : Text('Không có tiêu đề',
//                             style: AppTextStyles.viewDetailPoll),
//                   ),
//                   Column(
//                     children: List.generate(
//                         pollData.listOptionModel!.length,
//                         (index) => IdeaInDisplay(() {
//                               currentIndex = index;
//                               setState(() {
//                                 pollCubit.onVote(
//                                     pollData.pollId ?? "",
//                                     pollData.listOptionModel![index].optionId ??
//                                         "");
//                               });
//                             },
//                                 index,
//                                 currentIndex == index
//                                     ? Colors.blue
//                                     : Colors.white,
//                                 pollData.listOptionModel![index])),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 7.5, horizontal: 18),
//                     child: pollData.expriDateTime != ''
//                         ? Row(
//                             children: [
//                               Text("Ngày hết hạn: ",
//                                   style: AppTextStyles.textIdeaPoll),
//                               Expanded(child: Text(pollData.expriDateTime!))
//                             ],
//                           )
//                         : Text("Không cập nhật ngày hết hạn: ",
//                             style: AppTextStyles.textIdeaPoll),
//                   ),
//                   Padding(
//                     padding:
//                         const EdgeInsets.only(top: 2.5, bottom: 16, left: 18),
//                     child: Row(
//                       children: [
//                         Image.asset(Images.pollImg),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 16),
//                           child: Text('Thăm dò ý kiến'),
//                         )
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             InkWell(
//               onTap: () {},
//               child: Container(
//                 margin: EdgeInsets.only(top: 2),
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Color(0xffF7F8FC),
//                   borderRadius:
//                       BorderRadius.only(bottomLeft: Radius.circular(15)),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Xem chi tiết',
//                     style: AppTextStyles.viewDetailPoll,
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget IdeaInDisplay(
//       Function choseIdea, int index, Color color, OptionModel IdeaContent) {
//     return InkWell(
//       onTap: () {
//         choseIdea();
//         print(index);
//       },
//       child: Container(
//           width: double.infinity,
//           margin: EdgeInsets.symmetric(horizontal: 17, vertical: 2.5),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(width: 1, color: Colors.black)),
//           child: Text(IdeaContent.optionMessage ?? '',
//               style: AppTextStyles.textIdeaPoll)),
//     );
//   }
// }
