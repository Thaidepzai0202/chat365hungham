// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
// import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
// import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
// import 'package:app_chat365_pc/common/repos/auth_repo.dart';
// import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
// import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
// import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
// import 'package:app_chat365_pc/router/app_route_observer.dart';
// import 'package:app_chat365_pc/service/app_service.dart';
// import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
// import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
// import 'package:app_chat365_pc/utils/helpers/logger.dart';
// import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:sp_util/sp_util.dart';
// import 'package:uuid/uuid.dart';

// ValueNotifier<bool> checkVideoCall = ValueNotifier(false);
// Timer? notificationDebounce;
// var channels = MethodChannel("appchat365");
// void startCall() async {
//   try {
//     bool check = await channels.invokeMethod("startCall");
//     if (check) {
//       checkVideoCall.value = !checkVideoCall.value;
//     }
//   } on PlatformException {
//     print("lỗi vãi ae ơi ");
//   }
// }

// void endCall() async {
//   try {
//     await channels.invokeMethod("endCall");
//   } on PlatformException {
//     print("lỗi vãi ae ơi ");
//   }
// }

// class FirebaseService {
//   static final FirebaseService _instance = FirebaseService._internal();

//   factory FirebaseService() => _instance;

//   FirebaseService._internal() {
//     initNotification();
//     _repository = new AuthRepo();
//   }

//   late AuthRepo _repository;

//   static final FirebaseMessaging messaging = FirebaseMessaging.instance;
//   //static final localNotification = FlutterLocalNotificationsPlugin();

//   static final StreamController<bool> _notiPermissionStream =
//       StreamController.broadcast();

//   Stream<bool> get notiPermissionStream => _notiPermissionStream.stream;

//   static Future<NotificationSettings> requestNotiPermisson() async {
//     var response = await messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//     if (response.authorizationStatus == AuthorizationStatus.authorized) {
//       _notiPermissionStream.sink.add(true);
//       // print('Người dùng đã cấp quyền');
//     } else if (response.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       _notiPermissionStream.sink.add(true);
//       print('Người dùng đã cấp quyền tạm thời');
//     } else {
//       _notiPermissionStream.sink.add(false);
//       print('Người dùng đã từ chối');
//     }
//     return response;
//   }

//   // config, get token, send token to sever
//   static Future<void> initNotification() async {
//     var response = await requestNotiPermisson();
//     messaging.setAutoInitEnabled(true);
//     messaging.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     const DarwinInitializationSettings macOSInitializationSettings =
//         DarwinInitializationSettings();
//     const InitializationSettings initializationSettings =
//         InitializationSettings(macOS: macOSInitializationSettings);

//     if (response.authorizationStatus == AuthorizationStatus.authorized) {
//       print('Authenticate');
//     } else if (response.authorizationStatus == AuthorizationStatus.denied) {
//       print('Notification has denied');
//     }

//     // chạy hàm khi click vào thông báo
//     // localNotification.initialize(
//     //   initializationSettings,
//     //   onDidReceiveNotificationResponse: (e) async {
//     //     String? payload = e.payload;
//     //     if (payload != null) {
//     //       var decodedPayload = jsonDecode(payload);
//     //       logger.log("selectNotification ==> $decodedPayload");
//     //       onSelectNotification(decodedPayload);
//     //       // _changePage(payload);
//     //     }
//     //   },
//     // );
//     // if (!Platform.isIOS)
//     FirebaseMessaging.onMessage.listen((event) {
//       // return;
//       logger.log(event.toMap(), color: StrColor.magenta);
//       if (event.notification != null) {
//         showNotification(event.notification!.title!, event.notification!.body!,
//             jsonEncode(event.data));
//       }
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((event) {
//       if (event.notification != null) {
//         onSelectNotification(event.data);
//       } else {
//         print('Lỗi');
//       }
//     });
//   }

//   void initMessage() {
//     FirebaseMessaging.instance.getInitialMessage().then((event) {
//       if (event != null) {
//         logger.log("selectNotification ==> ${event.data}");
//         onSelectNotification(event.data);
//       }
//     });
//   }

//   // when click notification
//   static onSelectNotification(Map payloadData) {
//     try {
//       var notificationPayloadData = payloadData;
//       logger.log(payloadData, name: 'notification log');
//       int conversationId =
//           int.parse(notificationPayloadData['converstation_id']);
//       String? notType = notificationPayloadData["not_type"];
//       if (notType == NOTIFICATION_TYPE.Chat.toShortString()) {
//         String? fromSource = notificationPayloadData["from_source"];
//         String? urlLauncher = notificationPayloadData["url_launcher"];
//         if (fromSource == 'chat365') {
//           if (SpUtil.getString(LocalStorageKey.token) != null) {
//             var context = AppService().navigatorKey.currentContext!;
//             logger.log(routeObserver.navigator?.widget, name: 'CheckWidget');
//             ChatItemModel? chatItemModel;
//             IUserInfo? chatInfo;
//             try {
//               var chatConversationBloc = context.read<ChatConversationBloc>();
//               chatItemModel = chatConversationBloc.chatsMap[conversationId];
//             } catch (e) {}
//             if (chatItemModel == null &&
//                 notificationPayloadData["isGroup"] != null) {
//               final bool isGroup =
//                   notificationPayloadData["isGroup"] == 0 ? false : true;
//               try {
//                 chatInfo = ConversationBasicInfo(
//                   name: notificationPayloadData["sender_name"],
//                   conversationId: conversationId,
//                   isGroup: isGroup,
//                   userId: notificationPayloadData["sender_id"],
//                   avatar: notificationPayloadData["sender_avatar"],
//                 );
//               } catch (e, s) {
//                 logger.logError(
//                     e, s, 'CreateConversationBasicInfo From Noti Error');
//               }
//             }
//             try {
//               // context.read<ChatBloc>().tryToChatScreen(
//               //       conversationId:
//               //           chatItemModel == null ? conversationId : null,
//               //       chatInfo: chatItemModel ?? chatInfo,
//               //       isNeedToFetchChatInfo: chatInfo != null ? false : true,
//               //     );
//             } catch (e, s) {
//               logger.logError(e, s, 'NotificationNavError');
//             }
//             // AppRouter.replaceAllWithPage(
//             //   navigatorKey.currentContext!,
//             //   AppPages.Navigation,
//             //   // append model and send to navigation, after check data at navigation and go to detail chat
//             //   // arguments: {
//             //   //   'chatInfo':
//             //   //   ChatCommonInfoModel(
//             //   //       chatId: notificationPayloadData["room_id"],
//             //   //       candidateId: notificationPayloadData["sender_id"],
//             //   //       candidateAvatarUrl: notificationPayloadData["sender_avatar"],
//             //   //       candidateName: notificationPayloadData["sender_name"]),
//             //   // },
//             // );
//           }
//         } else {
//           // SystemUtils.launchUrl(urlLauncher!);
//           // launch to webview if need
//         }

//         //
//         bool isUnRead = SystemUtils.checkRoomIsUnReadByUser(
//             notificationPayloadData["converstation_id"]);
//         if (isUnRead) {
//           SystemUtils.increaseListMessageUnreadWithBadge();
//         }
//       } else {}
//     } catch (error, s) {
//       print("Error opening Notification ==> $error");
//       logger.logError(error, s, 'NotificationNavError');
//     }
//   }

//   void fcmUnSubscribe() {
//     messaging.unsubscribeFromTopic('all');
//   }

//   setUpFirebaseToken(int id, UserType userType) {
//     String? accessToken = SpUtil.getString(LocalStorageKey.token);
//     String? firebaseToken = SpUtil.getString(LocalStorageKey.firebase_token);
//     if (accessToken != null) {
//       if (firebaseToken == null) {
//         addFCMTokenForUser(id, userType);
//       } else {
//         updateFCMTokenForUser(id, userType);
//       }
//     } else {
//       print("setUpFirebaseToken : Not login");
//     }
//   }

//   void addFCMTokenForUser(int id, UserType userType) {
//     FirebaseMessaging.instance.getToken().then((firebaseToken) {
//       if (firebaseToken != "" && firebaseToken != null) {
//         _repository
//             .updateFirebaseToken(id.toString(), firebaseToken, userType)
//             .then((value) {
//           if (value) {
//             SpUtil.putString(LocalStorageKey.firebase_token, firebaseToken);
//           }
//         });
//       }
//     });
//   }

//   void updateFCMTokenForUser(int id, UserType userType) async {
//     FirebaseMessaging.instance.getToken().then((firebaseToken) {
//       if (firebaseToken != "" && firebaseToken != null) {
//         String? storeFirebaseToken =
//             SpUtil.getString(LocalStorageKey.firebase_token);
//         if (storeFirebaseToken != null) {
//           _repository
//               .updateFirebaseToken(id.toString(), firebaseToken, userType)
//               .then((value) {
//             if (value) {
//               SpUtil.putString(LocalStorageKey.firebase_token, firebaseToken);
//             }
//           });
//         }
//       }
//     });
//   }

//   logoutFirebase() {
//     // messaging.unsubscribeFromTopic("all");
//     FirebaseMessaging.instance.deleteToken();
//     // localNotification.cancelAll();
//     //call to API delete columns ft_token with id and device if need
//   }

//   // show notification
//   static void showNotification(
//       String title, String body, String payload) async {
//     logger.log('title: $title, body: $body, payload: $payload',
//         name: 'show noti log');

//     ///dùng cho cuộc gọi
//     // showCallkitIncoming('${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(4294967296)}');
//     if (title.isNotEmpty && body.isNotEmpty) {
//       const macOSPlatformChannelSpecifics = DarwinNotificationDetails();
//       const platformChannelSpecifics = NotificationDetails(
//         macOS: macOSPlatformChannelSpecifics,
//       );
//       // localNotification.show(0, title, body, platformChannelSpecifics,
//       //     payload: payload);
//     }
//   }

//   static void _changePage(String payload) {
//     if (payload.isNotEmpty) {
//       // TODO: change to detail page here
//     }
//   }
// }

// enum NOTIFICATION_TYPE { Chat, Job }

// extension ParseToString on NOTIFICATION_TYPE {
//   String toShortString() {
//     return this.toString().split('.').last;
//   }
// }
