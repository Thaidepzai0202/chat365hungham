
// import 'package:app_chat365_pc/utils/data/enums/auth_mode.dart';
// import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../utils/helpers/logger.dart';
// import 'app_pages.dart';
// import 'app_router.dart';

// /// Required các arguments cần thiết khi navigate giữa các màn cần tham số
// class AppRouterHelper {
//   static toLoginPage(
//     BuildContext context, {
//     required UserType userType,
//     AuthMode? authMode,
//   }) async {
//     // if (userType != null) {
//     context.read<AuthRepo>().userType = userType;
//     // }
//     return AppRouter.toPage(
//       context,
//       AppPages.Auth_Login,
//       arguments: {
//         LoginScreen.userTypeArg: context.read<AuthRepo>().userType,
//         LoginScreen.authMode: authMode,
//       },
//     );
//     // ..then(
//     //     (value) => context.read<AuthRepo>().userType = UserType.unAuth,
//     //   );
//   }

//   static toRegisterPage(
//     BuildContext context, {
//     UserType? userType,
//   }) async {
//     if (userType != null) {
//       context.read<AuthRepo>().userType = userType;
//     }
//     return AppRouter.toPage(
//       context,
//       AppPages.Auth_Register,
//       arguments: {
//         RegisterScreen.userTypeArg: context.read<AuthRepo>().userType,
//       },
//     )..then(
//         (value) => context.read<AuthRepo>().userType = UserType.unAuth,
//       );
//   }

// ///////
//   static toCreatePoll(
//     BuildContext context, {
//     int? conversationId,
//   }) =>
//       AppRouter.toPage(context, AppPages.CreatePoll,
//           arguments: {'conversationId': conversationId, "isCreate": true});

//   static toCreateAppointmentPage(
//     BuildContext context, {
//     bool isCreate = true,
//     int? conversationId,
//     Reminder? reminder,
//   }) =>
//       AppRouter.toPage(context, AppPages.Utils_CreateAppointment, arguments: {
//         CreateAppointmentScreen.argIsCreate: isCreate,
//         'conversationId': conversationId,
//         'reminder': reminder,
//       });

//   static toAppointmentPage(
//     BuildContext context, {
//     bool isAdmin = true,
//     required Reminder reminder,
//     required IUserInfo userInfo,
//   }) =>
//       AppRouter.toPage(context, AppPages.Utils_AppointmentScreen, arguments: {
//         AppointmentScreen.argIsAdmin: isAdmin,
//         'reminder': reminder,
//         'userInfo': userInfo,
//       });
//   static toGroupCalendarPage(
//     BuildContext context, {
//     required List<Reminder> listReminders,
//     required IUserInfo userInfo,
//     required int conversationId,
//   }) =>
//       AppRouter.toPage(context, AppPages.Utils_GroupCalendarScreen, arguments: {
//         'listReminders': listReminders,
//         'userInfo': userInfo,
//         'conversationId': conversationId,
//       });
//   static toAuthOptionPage(
//     BuildContext context, {
//     required AuthMode authMode,
//   }) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Auth_option,
//         arguments: {
//           AuthOptionScreen.authModeArg: authMode,
//         },
//       );

//   static toNavigationPage(BuildContext context, {bool fadeIn = false}) {
//     return AppRouter.replaceAllWithPage(context, AppPages.Navigation,
//         transition: fadeIn ? trans.Transition.fadeIn : null);
//   }

//   /// - Pop until [AppPages.Navigation] trước sau đó push đến màn [AppPages.Chat_Detail]
//   static toChatPage(
//     BuildContext context, {
//     required UserInfoBloc userInfoBloc,
//     required bool isGroup,
//     required int senderId,
//     required int conversationId,
//     ChatItemModel? chatItemModel,
//     UnreadMessageCounterCubit? unreadMessageCounterCubit,
//     TypingDetectorBloc? typingDetectorBloc,
//     int? messageDisplay,
//     ChatFeatureAction? action,
//     String? name,
//     bool backToNavigation = true,
//     String? groupType,
//     String? deleteTime,
//     String? messageId,
//   }) {
//     var chatConversationBloc = context.read<ChatConversationBloc>();
//     var _unreadMessageCounterCubit =
//         chatConversationBloc.unreadMessageCounterCubits.putIfAbsent(
//             conversationId,
//             () =>
//                 unreadMessageCounterCubit ??
//                 UnreadMessageCounterCubit(
//                   conversationId: conversationId,
//                   countUnreadMessage: 0,
//                 ));
//     var _typingDetectorBloc = typingDetectorBloc ??
//         chatConversationBloc.typingBlocs[conversationId] ??
//         TypingDetectorBloc(conversationId);

//     chatItemModel?.lastMessages ??=
//         chatConversationBloc.chatsMap[conversationId]?.lastMessages;
//     logger.log(userInfoBloc.userInfo.id, name: "userInfoLogger");
//     if (backToNavigation)
//       AppRouter.backToPage(navigatorKey.currentContext!, AppPages.Navigation);
//     AppRouter.toPage(
//       context,
//       AppPages.Chat_Detail,
//       blocProviders: [
//         BlocProvider<UserInfoBloc>(create: (context) => userInfoBloc),
//         BlocProvider<UnreadMessageCounterCubit>.value(
//             value: _unreadMessageCounterCubit),
//         BlocProvider<TypingDetectorBloc>.value(value: _typingDetectorBloc),
//         BlocProvider(create: (context) => TransVoiceToTextCubit()),
//       ],
//       arguments: {
//         ChatScreen.isGroupArg: isGroup,
//         ChatScreen.conversationIdArg: conversationId,
//         ChatScreen.senderIdArg: senderId,
//         ChatScreen.messageDisplayArg: messageDisplay,
//         ChatScreen.chatItemModelArg: chatItemModel,
//         ChatScreen.actionArg: action,
//         'nickname': name,
//         'groupType': groupType,
//         'deleteTime': deleteTime,
//         ChatScreen.messageIdArg: messageId,
//       },
//     );
//   }

//   static toForwardMessagePage(
//     BuildContext context, {
//     required SocketSentMessageModel message,
//     required IUserInfo senderInfo,
//   }) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Forward_Message,
//         arguments: {
//           ForwardMessageScreen.messageArg: message,
//           ForwardMessageScreen.senderInfoArg: senderInfo,
//         },
//       );
//   // man hinh chon gui nhieu tin nhan cho 1 nguoi
//   static Future<dynamic> toForwardMultiMessagePage(
//     BuildContext context, {
//     required List<SocketSentMessageModel> messages,
//     required IUserInfo senderInfo,
//   }) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Forward_Multi_Message,
//         arguments: {
//           ForwardMessageScreen.messageArg: messages,
//           ForwardMessageScreen.senderInfoArg: senderInfo,
//         },
//       );

//   static toProfilePage(
//     BuildContext context, {
//     required IUserInfo userInfo,
//     required bool isGroup,
//     ChatDetailBloc? bloc,
//     bool self = false,
//     int? conversationId,
//     String? nickname,
//   }) async =>
//       await AppRouter.toPage(
//         context,
//         self ? AppPages.Profile_Self : AppPages.Profile_Chat,
//         arguments: {
//           ProfileChatScreen.userInfoArg: userInfo,
//           ProfileChatScreen.isGroupArg: isGroup,
//           'nickname': nickname,
//         },
//         blocValue: bloc,
//       );

//   static toCalenderPhoneCallPage(
//     BuildContext context, {
//     required IUserInfo userInfo,
//     required bool isGroup,
//   }) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Calender_Phone_Call,
//         arguments: {
//           ProfileScreen.userInfoArg: userInfo,
//           ProfileScreen.isGroupArg: isGroup,
//         },
//       );
//   static toGeneralDiaryPage(
//     BuildContext context,
//   ) =>
//       AppRouter.toPage(
//         context,
//         AppPages.General_Diary,
//       );

//   static toHaveDiaryPage(
//     BuildContext context,
//   ) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Have_Diary,
//       );

//   static toPostDiaryPage(
//     BuildContext context,
//   ) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Post_Diary,
//       );

//   static toCreateNewAlbumPersonal(
//     BuildContext context,
//   ) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Create_New_Album_Personal,
//       );

//   static toEditInfoPersonal(
//     BuildContext context,
//   ) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Edit_Info_Personal,
//       );

//   static toImagePersonal(
//     BuildContext context,
//   ) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Image_Personal,
//       );
//   static toInfoPersonal(
//     BuildContext context,
//   ) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Info_Personal,
//       );
//   static toPersonalPage(
//     BuildContext context,
//   ) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Personal_Page,
//       );
//   static toPostPersonal(
//     BuildContext context,
//   ) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Post_Personal,
//       );
//   static toSeeAllAlbumPersonal(
//     BuildContext context,
//   ) =>
//       AppRouter.toPage(
//         context,
//         AppPages.See_All_Album_Personal,
//       );
//   static toShowInfoPersonal(
//     BuildContext context,
//   ) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Show_Info_Personal,
//       );
//   static toSendContactPage(
//     BuildContext context, {
//     required int conversationBasicInfo,
//   }) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Send_Contact,
//         arguments: {
//           SendContactScreen.conversationBasicInfoArg: conversationBasicInfo,
//         },
//       );

//   static toSendLocationPage(
//     BuildContext context, {
//     required ChatDetailBloc chatDetailBloc,
//   }) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Send_Location,
//         blocValue: chatDetailBloc,
//       );

//   // static toProfileSelfPage(
//   //   BuildContext context, {
//   //   required IUserInfo userInfo,
//   //   required bool isGroup,
//   // }) =>
//   //     AppRouter.toPage(
//   //       context,
//   //       AppPages.Profile_Self,
//   //       arguments: {
//   //         ProfileScreen.userInfoArg: userInfo,
//   //         ProfileScreen.isGroupArg: isGroup,
//   //       },
//   //     );

//   static toSelectListUserCheckBox(
//     BuildContext context, {
//     String? title,
//     required ErrorCallback<List<IUserInfo>> onSubmitted,
//     required ValueChanged<List<IUserInfo>> onSuccess,
//     ValueChanged<ExceptionError>? onError,
//     dynamic repo,
//     dynamic bloc,
//     List<IUserInfo> existContact = const [],
//   }) =>
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (_) {
//             var selectListUserCheckBox = SelectListUserCheckBox(
//               onSubmitted: onSubmitted,
//               onSuccess: onSuccess,
//               onError: onError,
//               title: title,
//               existContact: existContact,
//             );
//             if (repo != null)
//               return RepositoryProvider.value(
//                 value: repo,
//                 child: selectListUserCheckBox,
//               );
//             return selectListUserCheckBox;
//           },
//         ),
//       );

//   static toInviteContactPage(
//     BuildContext context, {
//     required IUserInfo userInfo,
//   }) {
//     return AppRouter.toPage(context, AppPages.Invite_Contact, arguments: {
//       InviteContactScreen.userInfoArg: userInfo,
//     });
//   }

//   static toSearchContactPage(
//     BuildContext context, {
//     required ContactListCubit contactListCubit,
//     Function(ConversationBasicInfo)? trailingBuilder,
//     required bool showSearchCompany,
//     String? search,
//   }) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Search,
//         arguments: {
//           SearchContactScreen.contactListCubitArg: contactListCubit,
//           SearchContactScreen.trailingBuilderArg: trailingBuilder,
//           SearchContactScreen.showSearchCompanyArg: showSearchCompany,
//           'keyword': search ?? '',
//         },
//       );

//   static toShareContactPage(
//     BuildContext context, {
//     String? initSearch,
//     bool showMoreButton = true,
//     List<FilterContactsBy> filters = const [
//       FilterContactsBy.none,
//       FilterContactsBy.conversations,
//       FilterContactsBy.myContacts,
//     ],
//   }) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Share_Contact,
//         arguments: {
//           ShareContactScreen.filtersArg: filters,
//           ShareContactScreen.showMoreButtonArg: showMoreButton,
//           ShareContactScreen.initSearchArg: initSearch,
//         },
//       );

//   static toPreviewFile(
//     BuildContext context, {
//     required String link,
//   }) =>
//       AppRouter.toPage(context, AppPages.Preview, arguments: {
//         FilePrevewScreen.linkFileArg: link,
//       });

//   static toLibraryPage(
//     BuildContext context, {
//     MessageType messageType = MessageType.image,
//     required IUserInfo userInfo,
//     required ChatLibraryCubit libraryCubit,
//   }) {
//     AppRouter.toPage(
//       context,
//       AppPages.Library,
//       arguments: {
//         LibraryScreen.userInfoArg: userInfo,
//         LibraryScreen.initMessageTypeArg: messageType,
//         LibraryScreen.libraryCubitArg: libraryCubit,
//       },
//     );
//   }

//   static toImageSlidePage(
//     BuildContext context, {
//     required List<SocketSentMessageModel> imageMessages,
//     int initIndex = -1,
//   }) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Image_Slide,
//         arguments: {
//           ImageMessageSliderScreen.imagesArg: imageMessages,
//           ImageMessageSliderScreen.initIndexArg: initIndex,
//         },
//       );

//   static toPhoneContactPage(
//     BuildContext context, {
//     required SuggestContactCubit suggestContactCubit,
//   }) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Phone_Contact,
//         blocValue: suggestContactCubit,
//       );

//   static toFriendRequestPage(
//     BuildContext context, {
//     required SuggestContactCubit suggestContactCubit,
//     required ContactListCubit contactListCubit,
//   }) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Recieved_AddFriend_Request,
//         blocProviders: [
//           BlocProvider<SuggestContactCubit>.value(
//             value: suggestContactCubit,
//           ),
//           BlocProvider<ContactListCubit>.value(
//             value: contactListCubit,
//           ),
//         ],
//       );
//   static toSuggestContactPage(
//     BuildContext context, {
//     required ContactListCubit contactListCubit,
//   }) =>
//       AppRouter.toPage(
//         context,
//         AppPages.Suggest_Contact,
//         blocProviders: [
//           BlocProvider<ContactListCubit>.value(
//             value: contactListCubit,
//           ),
//         ],
//       );

//   static toCallScreen(BuildContext context,
//       {required String idRoom,
//       required String idCaller,
//       required List<int> idCallee,
//       String? idConversation,
//       String? avatarAnother,
//       String? nameAnother,
//       bool checkCallee = true,
//       bool accepted = false,
//       required bool checkCall}) async {
//     overlayState ??= navigatorKey.currentState!.overlay;
//     if (videocallEntry != null) {
//       signaling.connected.value = true;
//       return;
//       videocallEntry!.remove();
//     }
//     ValueNotifier<bool> scale = ValueNotifier<bool>(false);
//     Offset offset = Offset(
//         AppDimens.width - AppDimens.width * 0.70, -AppDimens.height * 0.23);
//     Offset offset1 = Offset(0, 84);
//     AnimationController controller = AnimationController(
//       vsync: overlayState!,
//       duration: Duration(milliseconds: 300),
//     );
//     final animation = Tween(begin: offset, end: 2 * 3.14).animate(controller);
//     videocallEntry = OverlayEntry(
//       builder: (_) => ValueListenableBuilder(
//           valueListenable: scale,
//           builder: (context, check, _) => ValueListenableBuilder(
//               valueListenable: callType,
//               builder: (context, value, _) => AnimatedBuilder(
//                     animation: animation,
//                     builder: (context, child) {
//                       double padding = 8;
//                       double startX =
//                           -(AppDimens.width - AppDimens.width * 0.35) * 0.5 +
//                               padding;
//                       double endX =
//                           (AppDimens.width - AppDimens.width * 0.35) * 0.5 -
//                               padding;
//                       double startY =
//                           -(AppDimens.height - AppDimens.height * 0.35) * 0.5 +
//                               70;
//                       double endY =
//                           (AppDimens.height - AppDimens.height * 0.35) * 0.5 -
//                               46;
//                       return Positioned(
//                         left: scale.value
//                             ? (callType.value ? offset.dx : offset1.dx)
//                             : null,
//                         top: scale.value
//                             ? (callType.value ? offset.dy : offset1.dy)
//                             : null,
//                         child: GestureDetector(
//                           onPanEnd: scale.value
//                               ? ((details) {
//                                   if (offset.dx < 20) {
//                                     offset = Offset(startX, offset.dy);
//                                     videocallEntry!.markNeedsBuild();
//                                   } else {
//                                     offset = Offset(endX, offset.dy);
//                                     videocallEntry!.markNeedsBuild();
//                                   }
//                                 })
//                               : null,
//                           onPanUpdate: scale.value
//                               ? (details) {
//                                   print('vị trí là :x: ${offset.dx}' +
//                                       '${offset.dy}');
//                                   if (offset.dx <= startX ||
//                                       offset.dx >= endX ||
//                                       offset.dy <= startY ||
//                                       offset.dy >= endY) {
//                                     //góc trên bên trái
//                                     if (offset.dx <= startX &&
//                                         offset.dy <= startY) {
//                                       offset = Offset(startX, startY);
//                                     }
//                                     //góc trên bên phải
//                                     else if (offset.dx >= endX &&
//                                         offset.dy <= startY) {
//                                       offset = Offset(endX, startY);
//                                     }
//                                     //góc dưới bên trái
//                                     else if (offset.dx <= startX &&
//                                         offset.dy >= endY) {
//                                       offset = Offset(startX, endY);
//                                     }
//                                     //góc dưới bên phải
//                                     else if (offset.dx >= endX &&
//                                         offset.dy >= endY) {
//                                       offset = Offset(endX, endY);
//                                     }
//                                     //chạm ở cạnh trái
//                                     else if (offset.dx <= startX) {
//                                       offset = Offset(startX, offset.dy);
//                                     }
//                                     //chạm cảnh phải
//                                     else if (offset.dx >= endX) {
//                                       offset = Offset(endX, offset.dy);
//                                     }
//                                     //chạm cạnh trên
//                                     else if (offset.dy <= startY) {
//                                       offset = Offset(offset.dx, startY);
//                                     }
//                                     //chạm cảnh dưới
//                                     else if (offset.dy >= endY) {
//                                       offset = Offset(offset.dx, endY);
//                                     }
//                                     // nếu nằm ở giữa

//                                     videocallEntry!.markNeedsBuild();
//                                   }
//                                   offset += details.delta;
//                                   videocallEntry!.markNeedsBuild();
//                                 }
//                               : null,
//                           child: SizedBox(
//                             height: callType.value ? AppDimens.height : null,
//                             width: callType.value ? AppDimens.width : null,
//                             child: MainPhoneVideoScreen(
//                               scale: scale,
//                               checkCall: checkCall,
//                               userInfo: AuthRepo().userInfo!,
//                               idRoom: idRoom,
//                               idCaller: idCaller,
//                               idCallee: idCallee,
//                               idConversation: idConversation ?? '',
//                               avatarAnother: avatarAnother,
//                               checkCallee: checkCallee,
//                               accepted: accepted,
//                               nameAnother: nameAnother,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ))),
//     );

//     overlayState?.insert(videocallEntry!);
//   }

//   static toVoiceCallScreen(
//     BuildContext context, {
//     IUserInfo? userInfo,
//     required String idCaller,
//     required List<int> idCallee,
//     String? idConversation,
//     required String idRoom,
//     String? avatarAnother,
//     String? nameAnother,
//     ValueNotifier<bool>? scale,
//     bool checkCallee = true,
//     bool accepted = false,
//   }) async {
//     overlayState ??= navigatorKey.currentState!.overlay;

//     // Offset offset = Offset(
//     //     AppDimens.width - AppDimens.width * 0.70, -AppDimens.height * 0.23);
//     // AnimationController controller = AnimationController(
//     //   // vsync: overlayVoiceCallState!,
//     //   vsync: overlayState!,
//     //   duration: Duration(milliseconds: 300),
//     // );

//     if (videocallEntry != null) {
//       signaling.connected.value = true;
//       // return;
//       videocallEntry!.remove();
//     }

//     Offset offset = Offset(0, 84);
//     // AppDimens.height - AppDimens.height * 0.9
//     ValueNotifier<bool> scale = ValueNotifier<bool>(false);
//     videocallEntry = OverlayEntry(
//       builder: (_) => ValueListenableBuilder(
//           valueListenable: scale,
//           builder: (context, check, _) {
//             return Positioned(
//               left: scale.value ? offset.dx : null,
//               top: scale.value ? offset.dy : null,
//               child: GestureDetector(
//                 onTap: () {
//                   scale.value = false;
//                 },
//                 child: SizedBox(
//                   // height: AppDimens.height,
//                   // width: AppDimens.width,
//                   child: MainPhoneCallScreen(
//                     userInfo: AuthRepo().userInfo!,
//                     idRoom: idRoom,
//                     idConversation: idConversation ?? '',
//                     avatarAnother: avatarAnother,
//                     nameAnother: nameAnother,
//                     idCaller: idCaller,
//                     idCallee: idCallee,
//                     checkCallee: checkCallee,
//                     scale: scale,
//                     accepted: accepted,
//                   ),
//                 ),
//               ),
//             );
//           }),
//     );
//     overlayState?.insert(videocallEntry!);
//   }
// }




import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/call/phone_call/screens/call_screen.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

class AppRouterHelper{
  static toCallScreen(
      {required String idRoom,
    required String idCaller,
        // required WindowController window,
    required String idCallee,
    String? idConversation,
    String? avatarAnother,
    String? nameAnother,
    required bool checkCallee,
    bool accepted = false,
    required bool checkCall,
    bool initialized = false,
    DateTime? startedAt,}) {
    if (overlayState1 != null || overlayState != null) {
      try {
        callEntry1?.remove();
        callEntry?.remove();
      } catch (e) {}
      callEntry1 = null;
      callEntry = null;
    }

    overlayState ??= navigatorKey.currentState!.overlay;

    // Offset offset = Offset(
    //     AppDimens.width - AppDimens.width * 0.70, -AppDimens.height * 0.23);

    ValueNotifier<bool> scale = ValueNotifier<bool>(false);
    Offset offset = Offset(
        (AppDimens.width - AppDimens.width * 0.8)/2,
      (AppDimens.height - AppDimens.height * 0.8)/2,
    );

    AnimationController controller = AnimationController(
      vsync: overlayState!,
      duration: Duration(milliseconds: 300),
    );

    final animation = Tween(begin: offset, end: 2 * 3.14).animate(controller);




    callEntry = OverlayEntry(
        builder: (_){
          return ValueListenableBuilder(
              valueListenable: scale,
              builder: (context,value,_){
                return AnimatedBuilder(
                    animation: animation,
                    builder: (context,_){

                      // if (overlayState1 != null) {
                      //   try {
                      //     callEntry1?.remove();
                      //   } catch (e) {}
                      //   callEntry1 = null;
                      // }
                      print('vị trí là :x: ${offset.dx} /// ${offset.dy}');

                      return Positioned(
                        // left:  offset.dx > 0 ? offset.dx : 0,
                        // top: offset.dy > 0 ? offset.dy : 0,

                        left:  offset.dx ,
                        top: offset.dy ,
                        child: GestureDetector(
                            onTap: (){
                              scale.value = false;
                            },
                            onPanUpdate: (details){
                              // print('vị trí là :x: ${offset.dx} /// ${offset.dy}');
                              offset += details.delta;
                              callEntry!.markNeedsBuild();
                            },
                            child: Transform.scale(
                              scaleX: scale.value ? 0.3 : 1,
                              scaleY: scale.value ? 0.3 : 1,
                              child: Container(
                                height: context.mediaQuerySize.height * 0.9,
                                width:  context.mediaQuerySize.width * 0.8,

                                child: CallScreen(
                                  checkCall: checkCall,
                                  userInfo: AuthRepo().userInfo!,
                                  idRoom: idRoom,
                                  idCaller: idCaller,
                                  idCallee: idCallee,
                                  idConversation: idConversation ?? '',
                                  avatarAnother: avatarAnother,
                                  checkCallee: checkCallee,
                                  accepted: accepted,
                                  nameAnother: nameAnother,
                                  initialized: initialized,
                                  startedAt: startedAt,
                                  scale: scale,
                                  // window: window,
                                ),
                              ),
                            )
                        ),
                      );
                    }
                );
              }
          );
        }
    );

    overlayState?.insert(callEntry!);
  }
}
