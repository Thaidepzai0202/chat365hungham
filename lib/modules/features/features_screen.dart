// //import 'dart:js';
//
// import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
// import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
// import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
// import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
// import 'package:app_chat365_pc/common/repos/chat_repo.dart';
// import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
// import 'package:app_chat365_pc/modules/navigations/widget/feature_item.dart';
// import 'package:app_chat365_pc/modules/navigations/widget/utilities_dialog.dart';
// import 'package:app_chat365_pc/modules/auth/modules/login/login_singup.dart';
// import 'package:app_chat365_pc/router/app_pages.dart';
// import 'package:app_chat365_pc/router/app_router.dart';
// import 'package:app_chat365_pc/utils/helpers/logger.dart';
// import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:app_chat365_pc/common/images.dart';
//
// import 'package:app_chat365_pc/main.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:app_chat365_pc/core/theme/app_colors.dart';
// import 'package:app_chat365_pc/core/constants/asset_path.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
// import 'package:app_chat365_pc/core/constants/string_constants.dart';
//
// class FeaturesScreen extends StatefulWidget {
//   @override
//   _FeaturesScreenState createState() => _FeaturesScreenState();
// }
//
// class _FeaturesScreenState extends State<FeaturesScreen> {
//   String inputData = '';
//   String featuresChatValue = 'Cuộc trò chuyện gần đây';
//   String featuresFriendValue = 'Bạn bè mới';
//   String featuresNotificationValue = 'Tất cả';
//   String classify = 'Phân loại';
//   bool isRead = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height - 42,
//       width: 326,
//       color: AppColors.colorsappbar,
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         buildMyProfile(),
//         search(),
//         const SizedBox(
//           height: 28,
//         ),
//         Container(
//           color: AppColors.greyD9,
//           height: 1,
//         ),
//         //build_row_center(HomeScreen().selectmenu),
//         ValueListenableBuilder(
//           valueListenable: selectMenu,
//           builder: (context, value, child) {
//             print(value);
//             return build_row_center(value);
//           },
//         )
//
//         // build_row_center(HomeScreen().selectmenu),
//       ]),
//     );
//   }
//
//   Widget build_row_center(int? selectMenu) {
//     switch (selectMenu!) {
//       case 1:
//         return chatFeatures();
//         print(selectMenu);
//         break;
//       case 2:
//         return phoneBook();
//         print(selectMenu);
//         break;
//       case 3:
//         return features();
//         print(selectMenu);
//         break;
//       case 4:
//         return phone();
//         print(selectMenu);
//         break;
//       case 5:
//         return notification();
//         print(selectMenu);
//         break;
//       default:
//         return chatFeatures();
//         print(selectMenu);
//     }
//   }
//
//   Widget buildMyProfile() {
//     return Container(
//       child: Row(
//         //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//               margin: const EdgeInsets.fromLTRB(13, 8, 10, 8),
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 border: Border.all(width: 2, color: AppColors.white),
//                 borderRadius: BorderRadius.circular(46),
//                 image: const DecorationImage(
//                   image: AssetImage(AssetPath.avatar_demo),
//                 ),
//               )),
//           Column(
//             children: [
//               const Text(
//                 'Nguyễn Thế Thái',
//                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//               ),
//               Row(
//                 children: [
//                   Container(
//                     child: Image.asset(
//                       AssetPath.icon_smile,
//                       height: 15,
//                       width: 15,
//                     ),
//                     padding: const EdgeInsets.all(0),
//                   ),
//                   const SizedBox(
//                     width: 5,
//                   ),
//                   const Text(
//                     'Thai handsome',
//                     style: TextStyle(fontSize: 12),
//                   ),
//                 ],
//               )
//             ],
//           ),
//           Expanded(child: Container()),
//           PopupMenuButton<String>(
//               padding: const EdgeInsets.only(right: 15),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20)),
//               icon: SvgPicture.asset(
//                 AssetPath.ic_3_dot,
//                 width: 20,
//                 height: 20,
//                 color: AppColors.gray,
//               ),
//               onSelected: (String? value) {
//                 setState(() async {
//                   if (value == StringConst.signOut) {
//                     await AppRouter.toPage(context, AppPages.logIn);
//                     var initialSize = const Size(450, 690);
//                     appWindow.minSize = initialSize;
//                     appWindow.maxSize = initialSize;
//                     appWindow.size = initialSize;
//                     appWindow.alignment = Alignment.center;
//                     // Navigator.push(
//                     //     context,
//                     //     MaterialPageRoute(
//                     //         builder: (context) => LogInOrSignUp()));
//                   } else
//                     showSelectedOptionDialog(value!);
//                 });
//               },
//               itemBuilder: (BuildContext context) => [
//                     buildPopupProfileItem(
//                         StringConst.setting, AssetPath.setting, AppColors.gray),
//                     buildPopupProfileItem(StringConst.support_and_feedback,
//                         AssetPath.stranger, AppColors.gray),
//                     buildPopupProfileItem(
//                         StringConst.signOut, AssetPath.log_out, AppColors.red),
//                   ]),
//         ],
//       ),
//     );
//   }
//
//   Widget search() {
//     return Container(
//       padding: const EdgeInsets.only(left: 15),
//       height: 36,
//       width: 310,
//       child: TextField(
//         onChanged: (value) {
//           setState(() {
//             inputData = value;
//           });
//         },
//         onSubmitted: (value) {
//           //
//         },
//         style: const TextStyle(fontSize: 14),
//         decoration: InputDecoration(
//           hintText: 'Tìm kiếm với Chat365',
//           hintStyle: const TextStyle(fontSize: 14),
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//           prefixIcon: const Icon(Icons.search),
//           filled: true,
//           fillColor: AppColors.whiteLilac,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(20.0),
//             borderSide: const BorderSide(color: Colors.white, width: 1),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(20.0),
//             borderSide: const BorderSide(
//                 color: AppColors.blueBorder, width: 1), // Màu khi focus
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(20.0),
//             borderSide: const BorderSide(
//                 color: AppColors.greyD9, width: 1), // Màu khi không focus
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget chatFeatures() {
//     return Column(
//       children: [
//         Container(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               //----------Trò chuyện gần đây và bị ẩn
//               Container(
//                 padding: const EdgeInsets.only(left: 10),
//                 child: Text(
//                   featuresChatValue,
//                   style: const TextStyle(
//                       color: AppColors.gray,
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//               PopupMenuButton<String>(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20)),
//                 icon: SvgPicture.asset(AssetPath.drop_button_down,
//                     height: 14, width: 14),
//                 onSelected: (String? newvalue) {
//                   setState(() {
//                     if (newvalue != 'Đánh dấu tất cả đã đọc') {
//                       featuresChatValue = newvalue!;
//                     }
//                   });
//                 },
//                 itemBuilder: (BuildContext context) => [
//                   buildPopupMenuItem('Cuộc trò chuyện gần đây'),
//                   buildPopupMenuItem('Cuộc trò chuyện bị ẩn'),
//                   const PopupMenuDivider(),
//                   buildPopupMenuItem('Đánh dấu tất cả đã đọc'),
//                 ],
//               ),
//
//               //Phân loại ----------------------
//               Container(
//                 padding: const EdgeInsets.only(left: 10),
//                 child: const Text(
//                   'Phân loại',
//                   style: TextStyle(
//                       color: AppColors.gray,
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//               PopupMenuButton<String>(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20.0)),
//                 onSelected: (String? newvalue) {
//                   setState(() {
//                     if (newvalue == 'Quản lí phân loại') {
//                       showSelectedOptionDialog(newvalue!);
//                     } else {
//                       classify = newvalue!;
//                     }
//                   });
//                 },
//                 icon: SvgPicture.asset(
//                   AssetPath.drop_button_down,
//                   height: 14,
//                   width: 14,
//                 ),
//                 itemBuilder: (BuildContext context) => [
//                   buildPopupMenuItem('Tin nhắn từ người lạ'),
//                   const PopupMenuDivider(),
//                   buildPopupMenuItem('Quản lí phân loại')
//                 ],
//               )
//             ],
//           ),
//         ),
//         isReaded(),
//         const SizedBox(
//           height: 5,
//         ),
//         Container(
//           color: AppColors.greyD9,
//           height: 1,
//         ),
//         const SizedBox(
//           height: 15,
//         ),
//         SizedBox(
//             height: MediaQuery.of(context).size.height - 248,
//             width: MediaQuery.of(context).size.width,
//             child: ConversationList()),
//       ],
//     );
//   }
//
//   Widget isReaded() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               isRead = true;
//             });
//           },
//           child: Text(
//             'Tất cả',
//             style: TextStyle(
//               color: isRead ? AppColors.blueD4 : AppColors.dialogBarrier,
//               decoration:
//                   isRead ? TextDecoration.underline : TextDecoration.none,
//               fontWeight: isRead ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               isRead = false;
//             });
//           },
//           child: Text(
//             'Chưa đọc',
//             style: TextStyle(
//               color: isRead ? AppColors.dialogBarrier : AppColors.blueD4,
//               decoration:
//                   isRead ? TextDecoration.none : TextDecoration.underline,
//               fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   void showSelectedOptionDialog(String selectedOption) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Bạn đã chọn:'),
//           content: Text(selectedOption),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Đóng'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   PopupMenuItem<String> buildPopupMenuItem(String value) {
//     return PopupMenuItem<String>(
//       height: 30,
//       value: value,
//       child: Text(
//         value,
//         style: const TextStyle(fontSize: 12), // Điều chỉnh font size ở đây
//       ),
//       onTap: () {
//         //print(HomeScreen().selectmenu);
//       },
//     );
//   }
//
//   PopupMenuItem<String> buildPopupProfileItem(
//       String value, String path, Color color) {
//     return PopupMenuItem<String>(
//       value: value,
//       height: 0,
//       child: ListTile(
//         leading: SvgPicture.asset(
//           path,
//           width: 25,
//           height: 25,
//           color: color,
//         ), // Biểu tượng ở đây
//         title: Text(
//           value,
//           style: TextStyle(color: color, fontSize: 13),
//         ),
//       ),
//     );
//   }
//
//   Widget phoneBook() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(13),
//           child: ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.whiteLilac,
//                 fixedSize: const Size(300, 30),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20.0),
//                   side: const BorderSide(
//                     color: AppColors.greyDD, // Màu của đường biên
//                     width: 1.0, // Độ dày của đường biên
//                   ),
//                   // Đặt độ cong của khung bo
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SvgPicture.asset(
//                     Images.ic_fluent_people_add,
//                     width: 20,
//                     height: 20,
//                     color: AppColors.grey666,
//                   ),
//                   const SizedBox(
//                     width: 5,
//                   ),
//                   const Text(StringConst.friend_request,
//                       style: TextStyle(
//                         color: AppColors.grey666,
//                         fontSize: 12,
//                       ))
//                 ],
//               )),
//         ),
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.only(left: 10),
//               child: Text(
//                 featuresFriendValue,
//                 style: const TextStyle(
//                     color: AppColors.gray,
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold),
//               ),
//             ),
//             PopupMenuButton<String>(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20)),
//               icon: SvgPicture.asset(AssetPath.drop_button_down,
//                   height: 14, width: 14),
//               onSelected: (String? newvalue) {
//                 setState(() {
//                   featuresFriendValue = newvalue!;
//                 });
//               },
//               itemBuilder: (BuildContext context) => [
//                 buildPopupMenuItem('Bạn bè mới'),
//                 buildPopupMenuItem('Các liên hệ của tôi'),
//                 buildPopupMenuItem('Bạn bè mới truy cập'),
//               ],
//             ),
//           ],
//         )
//       ],
//     );
//   }
//
//   Widget features() {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.only(
//               left: 14,
//               top: 15,
//             ),
//             child: const Text(
//               StringConst.message,
//               style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.tundora),
//             ),
//           ),
//           const SizedBox(
//             height: 12,
//           ),
//           Row(
//             children: [
//               FeatureItem(
//                   assetPath: AssetPath.trash,
//                   gradient:
//                       const LinearGradient(colors: AppColors.colorGeneral6),
//                   label: StringConst.autoDeleteMessage,
//                   onTap: () {
//                     showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AutoDeleteMessageDialog();
//                         });
//                   }),
//               FeatureItem(
//                   assetPath: Images.message_tick_msg,
//                   gradient:
//                       const LinearGradient(colors: AppColors.colorGeneral9),
//                   label: StringConst.contemponary_message,
//                   onTap: () {
//                     showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return ContemponaryMessage();
//                         });
//                   }),
//               FeatureItem(
//                   assetPath: Images.flash_circle,
//                   gradient:
//                       const LinearGradient(colors: AppColors.colorGeneral7),
//                   label: StringConst.fastMessage,
//                   onTap: () {}),
//               FeatureItem(
//                   assetPath: Images.star_msg,
//                   gradient:
//                       const LinearGradient(colors: AppColors.colorGeneral8),
//                   label: StringConst.bookmarkMessage,
//                   onTap: () {}),
//             ],
//           ),
//           Container(
//             padding: const EdgeInsets.only(
//               left: 14,
//               top: 15,
//             ),
//             child: const Text(
//               StringConst.tools,
//               style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.tundora),
//             ),
//           ),
//           const SizedBox(
//             height: 12,
//           ),
//           Row(
//             children: [
//               FeatureItem(
//                   assetPath: Images.ic_poll,
//                   gradient:
//                       const LinearGradient(colors: AppColors.colorGeneral10),
//                   label: StringConst.searchExploration,
//                   onTap: () {}),
//               FeatureItem(
//                   assetPath: Images.ic_screen_capture,
//                   gradient:
//                       const LinearGradient(colors: AppColors.colorGeneral11),
//                   label: StringConst.screenCapture,
//                   onTap: () {}),
//             ],
//           ),
//           Container(
//             padding: const EdgeInsets.only(
//               left: 14,
//               top: 15,
//             ),
//             child: const Text(
//               StringConst.content,
//               style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.tundora),
//             ),
//           ),
//           const SizedBox(
//             height: 12,
//           ),
//           Row(
//             children: [
//               FeatureItem(
//                   assetPath: Images.alarm_clock_01,
//                   gradient:
//                       const LinearGradient(colors: AppColors.colorGeneral12),
//                   label: StringConst.create_reminders,
//                   onTap: () {}),
//               FeatureItem(
//                   assetPath: Images.ic_fluent_contact_card,
//                   gradient:
//                       const LinearGradient(colors: AppColors.colorGeneral13),
//                   label: StringConst.sendContactCard,
//                   onTap: () {}),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget phone() {
//     return Container(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(13),
//             child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.whiteLilac,
//                   fixedSize: const Size(300, 30),
//                   shape: RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(20.0), // Đặt độ cong của khung bo
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SvgPicture.asset(
//                       Images.ic_phone_add,
//                       width: 20,
//                       height: 20,
//                       color: AppColors.grey666,
//                     ),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     const Text(StringConst.call_new,
//                         style: TextStyle(
//                           color: AppColors.grey666,
//                           fontSize: 12,
//                         ))
//                   ],
//                 )),
//           ),
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.only(left: 10),
//                 child: const Text(
//                   'Tất cả',
//                   style: TextStyle(
//                       color: AppColors.gray,
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//               PopupMenuButton<String>(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20)),
//                 icon: SvgPicture.asset(AssetPath.drop_button_down,
//                     height: 14, width: 14),
//                 onSelected: (String? newvalue) {
//                   setState(() {
//                     featuresFriendValue = newvalue!;
//                   });
//                 },
//                 itemBuilder: (BuildContext context) => [
//                   // buildPopupMenuItem('Bạn bè mới'),
//                   // buildPopupMenuItem('Các liên hệ của tôi'),
//                   // buildPopupMenuItem('Bạn bè mới truy cập'),
//                 ],
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget notification() {
//     return Container(
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.only(left: 10),
//                 child: Text(
//                   featuresNotificationValue,
//                   style: const TextStyle(
//                       color: AppColors.gray,
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//               PopupMenuButton<String>(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20)),
//                 icon: SvgPicture.asset(AssetPath.drop_button_down,
//                     height: 14, width: 14),
//                 onSelected: (String? newvalue) {
//                   setState(() {
//                     if (newvalue != 'Đọc tất cả' && newvalue != 'Xóa tất cả') {
//                       featuresNotificationValue = newvalue!;
//                     }
//                   });
//                 },
//                 itemBuilder: (BuildContext context) => [
//                   buildPopupMenuItem('Tất cả'),
//                   buildPopupMenuItem('Chuyển đổi số'),
//                   const PopupMenuDivider(),
//                   buildPopupMenuItem('Đọc tất cả'),
//                   buildPopupMenuItem('Xóa tất cả'),
//                 ],
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class ConversationList extends StatefulWidget {
//   @override
//   State<ConversationList> createState() => ConversationListState();
// }
//
// class ConversationListState extends State<ConversationList> {
//   List<ChatItemModel> cims = [];
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<ChatConversationBloc>().loadData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ChatConversationBloc, ChatConversationState>(
//       buildWhen: (previous, current) {
//         return current is ChatConversationStateLoadDone;
//       },
//       builder: (context, state) {
//         // state.doAffect(context, this);
//         logger.log("$runtimeType building conv list: ${cims.length}");
//         return ListView.builder(
//           itemCount: cims.length,
//           itemBuilder: (BuildContext context, int index) {
//             return MultiBlocProvider(
//               providers: [
//                 BlocProvider(
//                     create: (context) => UnreadMessageCounterCubit(
//                           conversationId: cims[index].conversationId,
//                           countUnreadMessage: cims[index].numberOfUnreadMessage,
//                         )),
//                 BlocProvider(
//                   create: (context) => ChatDetailBloc(
//                     senderId: 623176, // TODO: userInfo?.id ?? 0,
//                     conversationId: cims[index].conversationId,
//                     userInfoRepo: context.read<UserInfoRepo>(),
//                     chatRepo: context.read<ChatRepo>(),
//                     isGroup: cims[index].isGroup,
//                     unreadMessageCounterCubit:
//                         context.read<UnreadMessageCounterCubit>(),
//                     chatItemModel: cims[index],
//                   ),
//                 ),
//               ],
//               child: BlocBuilder<UnreadMessageCounterCubit,
//                   UnreadMessageCounterState>(builder: (context, value) {
//                 return BlocBuilder<ChatDetailBloc, ChatDetailState>(
//                     builder: (context, value) {
//                   return ConversationItem(message: cims[index]);
//                 });
//               }),
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
// class Notification {
//   final String nameUser;
//   final String time;
//   final String avatarUrl;
//   final String notification;
//
//   Notification({
//     required this.nameUser,
//     required this.time,
//     required this.avatarUrl,
//     required this.notification,
//   });
// }
//
// // TODO: Create new class for group conversation item
// class ConversationItem extends StatelessWidget {
//   final ChatItemModel message;
//
//   const ConversationItem({super.key, required this.message});
//
//   @override
//   Widget build(BuildContext context) {
//     ImageProvider avatar;
//     avatar = CachedNetworkImageProvider(
//       message.conversationBasicInfo.avatar,
//       maxHeight: 50,
//       maxWidth: 50,
//       errorListener: (obj) {
//         // TODO: Not rebuilding because this is Stateless
//         // Make it rebuild
//         avatar = Image.asset(
//           AssetPath.avatar_demo,
//         ).image;
//       },
//     );
//
//     return ListTile(
//       leading: Stack(
//         alignment: Alignment.bottomRight,
//         children: [
//           // Hình ảnh đại diện
//           CircleAvatar(
//             foregroundImage: avatar,
//             radius: 20,
//           ),
//
//           // TODO: Sửa chấm xanh hoạt động cho đúng trạng thái
//           Container(
//             width: 14.0,
//             height: 14.0,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.green, // Màu chấm xanh
//               border: Border.all(color: Colors.white, width: 1.0),
//             ),
//           ),
//         ],
//       ),
//       title: Padding(
//         padding: const EdgeInsets.only(left: 8.0),
//         child: Text(
//           message.conversationBasicInfo.name,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(
//               fontSize: 16,
//               color: AppColors.grey666,
//               fontWeight: FontWeight.w600),
//         ),
//       ),
//       subtitle: Padding(
//         padding: const EdgeInsets.only(left: 8.0),
//         child: Text(
//           message.message,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//       trailing: Padding(
//         padding: const EdgeInsets.only(left: 10.0),
//         child: Text(
//           getLastChatDateRepresentation(),
//           style: const TextStyle(color: AppColors.grey666, fontSize: 11),
//         ),
//       ),
//       onTap: () {
//         context.read<ConversationItemClickedCubit>().toConversation(context);
//         // Tải danh sách tin nhắn
//         context.read<ChatDetailBloc>().add(ChatDetailEventFetchListMessages());
//       },
//       contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
//     );
//   }
//
//   String getLastChatDateRepresentation() {
//     var t = message.conversationBasicInfo.lastConversationMessageTime;
//     if (t == null) {
//       return "";
//     }
//
//     // TODO: Dữ liệu bị làm sao ý. Thế khỉ nào mà lần cuối nhắn tin toàn ở tương lai.
//     var duration = DateTime.now().difference(t);
//
//     //print(
//     //    "Now: ${DateTime.now().millisecondsSinceEpoch}\nLast: ${t.millisecondsSinceEpoch}\nDuration: $duration");
//
//     // Hiển thị dưới 1 phút
//     var timeDiff = duration.inSeconds;
//     if (timeDiff < 60) {
//       return "Mới đây";
//     }
//
//     // Hiển thị từ 1 - 60 phút trước
//     timeDiff = duration.inMinutes;
//     if (timeDiff < 60) return "$timeDiff phút";
//
//     // Hiển thị từ 1 - 24 tiếng trước
//     timeDiff = duration.inHours;
//     if (timeDiff < 24) return "$timeDiff giờ";
//
//     // Hiển thị từ 1 - 7 ngày trước
//     timeDiff = duration.inDays;
//     if (timeDiff < 7) return "$timeDiff ngày";
//
//     // Hiển thị từ 1 - 4 tuần trước
//     timeDiff = (timeDiff / 7).floor();
//     if (timeDiff < 4) return "$timeDiff tuần";
//
//     // Hơi xa rồi đấy
//     if (DateTime.now().year == t.year) {
//       return "${t.day}/${t.month}";
//     }
//
//     // Ngày xửa ngày xưa, có một kĩ sư IT-E7 Bách Khoa
//     // mòn mỏi đợi 1 năm để test dòng này
//     return "${t.month}/${t.year}";
//   }
// }
//
// class ConversationItemClickedCubit extends Cubit<ConversationItemClickedState> {
//   ConversationItemClickedCubit(super.initialState);
//   late ChatDetailBloc msgItemCdb;
//   late UnreadMessageCounterCubit msgItemUmcc;
//
//   void toConversation(BuildContext context) {
//     msgItemCdb = context.read<ChatDetailBloc>();
//     msgItemUmcc = context.read<UnreadMessageCounterCubit>();
//     emit(ConversationItemClickedState(
//         msgItemCdb: msgItemCdb, msgItemUmcc: msgItemUmcc));
//   }
// }
//
// // The attributes are null when the app is first built
// class ConversationItemClickedState {
//   final ChatDetailBloc? msgItemCdb;
//   final UnreadMessageCounterCubit? msgItemUmcc;
//
//   ConversationItemClickedState(
//       {required this.msgItemCdb, required this.msgItemUmcc});
// }
