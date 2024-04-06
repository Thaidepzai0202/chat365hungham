import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:app_chat365_pc/common/blocs/auth_bloc/auth_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/contact_cubit/user_contact_cubit.dart';
import 'package:app_chat365_pc/common/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:app_chat365_pc/common/blocs/friend_cubit/cubit/friend_cubit.dart';
import 'package:app_chat365_pc/common/blocs/network_cubit/network_cubit.dart';
import 'package:app_chat365_pc/common/blocs/reaction_cubit/reaction_cubit.dart';
import 'package:app_chat365_pc/common/blocs/sticker_bloc/sticker_bloc.dart';
import 'package:app_chat365_pc/common/blocs/sticker_bloc/sticker_state.dart';
import 'package:app_chat365_pc/common/blocs/theme_cubit/theme_cubit.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_conversations_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/common/repos/get_token_repo.dart';
import 'package:app_chat365_pc/common/widgets/live_chat/timer_repo.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/constants/status_code.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_client_events.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_client_service.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_session_service.dart';
import 'package:app_chat365_pc/data/services/device_info_service/device_info_services.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_service.dart';
import 'package:app_chat365_pc/data/services/network_service/network_service.dart';
import 'package:app_chat365_pc/data/services/sp_utils_service/sp_utils_services.dart';
import 'package:app_chat365_pc/modules/auth/linkweb/model/link_web_model.dart';
import 'package:app_chat365_pc/modules/auth/modules/login/cubit/login_cubit.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/cubit/signup_cubit.dart';
import 'package:app_chat365_pc/modules/call/phone_call/screens/call_screen.dart';
import 'package:app_chat365_pc/modules/call/phone_call/screens/ringing_call_screen.dart';
import 'package:app_chat365_pc/modules/call/phone_call/widget/setting_call_screen.dart';
import 'package:app_chat365_pc/modules/chat/chat_cubit/chat_cubit.dart';
import 'package:app_chat365_pc/modules/chat/sticker/cubit/sticker_cubit.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_cubit.dart';
import 'package:app_chat365_pc/modules/contact/cubit/contact_list_cubit.dart';
import 'package:app_chat365_pc/modules/contact/model/filter_contact_by.dart';
import 'package:app_chat365_pc/modules/contact/repo/contact_list_repo.dart';
import 'package:app_chat365_pc/modules/features/features_screen.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/user_request_bloc/user_request_bloc.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/notification_screen/bloc/notification_bloc.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/bloc/contact_bloc/contact_bloc.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/user_search/cubit/user_search_cubit.dart';
import 'package:app_chat365_pc/modules/layout/views/app_layout.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_route_observer.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/router/app_router_helper.dart';
import 'package:app_chat365_pc/service/app_service.dart';
import 'package:app_chat365_pc/service/injection.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/clients/interceptors/call_client.dart';
import 'package:app_chat365_pc/utils/data/clients/interceptors/mqtt_client_5.dart';
import 'package:app_chat365_pc/utils/data/clients/mqtt_client.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_status.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/modules/auth/modules/login/login_singup.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/object_extension.dart';
import 'package:app_chat365_pc/utils/data/video_call/device_info.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/zalo/clients/chat_client_zalo.dart';
import 'package:app_chat365_pc/zalo/models/conversation_item_model.dart';
import 'package:app_chat365_pc/zalo/models/friend_zalo_model.dart';
import 'package:app_chat365_pc/zalo/models/user_model_zalo.dart';
import 'package:app_chat365_pc/zalo/zalo_qr/login_cubit_zalo/login_cubit_zalo.dart';
import 'package:app_links/app_links.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:sp_util/sp_util.dart';
import 'package:system_tray/system_tray.dart';
import 'package:uuid/uuid.dart';
import 'package:windows_single_instance/windows_single_instance.dart';
import 'common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:system_tray/system_tray.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:uni_links_desktop/uni_links_desktop.dart';

/// TL 21/2/2024: Bắt buộc dùng TimerRepo ở main này nhé.
/// Nếu không thì TimerRepo sẽ bị sinh 2 lần,
/// một lần ở ChatBloc, một lần ở LiveChatMessageDisplay
final TimerRepo timerRepo = TimerRepo();
double preferedWidth = 1024;
double preferedHeight = 720;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = _cert;
  }

  bool _cert(X509Certificate cert, String host, int port) => true;
}

final navigatorKey = getIt.get<AppService>().navigatorKey;
final scaffoldKey = getIt.get<AppService>().scaffoldKey;
DownloadManager downloadManager = DownloadManager();
DownloaderRepo downloaderRepo = DownloaderRepo();
final SystemTray systemTray = SystemTray();
Uuid uuid = const Uuid();
String sessid = uuid.v4();
IUserInfo? userInfo;
UserType? userType;
UserInfoZalo userInfoZalo = UserInfoZalo(
    ava: '-1', idZalo: '-1', name: '-1', numPhoneZalo: '-1', status: false);
List<UserInfoZalo> listUserInfoZalo = [];
final Set<String> latestMsgIds = {};
final Map<String, String> userNameMap = {};
ValueNotifier<int> changeTheme = ValueNotifier(SpUtil.getInt('changeTheme')!);
ValueNotifier<String> changeLanguage = ValueNotifier('vi');
ValueNotifier<bool> isZalo = ValueNotifier(false);
bool notificationChatting = SpUtil.getBool('notificationSetting') ?? true;
bool autoStart = SpUtil.getBool('autoStart') ?? true;
late final ChatConversationsRepo chatConversationsRepo;
late ReactionCubit reactionCubit;
late final ChatConversationBloc chatConversationBloc;
List<ChatItemModel> listConversationStrange = [];
late Map<dynamic, ValueNotifier<Duration>> listDeleteTime = {};
final NetworkCubit networkCubit = NetworkCubit();
bool canRead = true;
var appLinks = AppLinks();
List<String> errorMessage = [];
ValueNotifier<List<IUserInfo>> listOnOff = ValueNotifier([]);
ValueNotifier<bool> checkSearchMess = ValueNotifier(false);
ValueNotifier<bool> checkClear = ValueNotifier(false);
ValueNotifier<bool> checkSearchUser = ValueNotifier(false);

/// Hiện tại: ds người trong Công ty
List<ConversationBasicInfo> sendMessagePreSearchData = [];
List<ConversationBasicInfo>? conversations;
late ContactListCubit searchContactCubits;

/// Dữ liệu sẵn có trong màn tìm kiếm
Map<FilterContactsBy, List<ConversationBasicInfo>>? searchAllPreSearchData;

OverlayState? overlayState = navigatorKey.currentState?.overlay;
OverlayEntry? callEntry;

OverlayState? overlayState1 = navigatorKey.currentState?.overlay;
OverlayEntry? callEntry1;

ValueNotifier<List<String>> listArgs = ValueNotifier([]);

CallClientService ccService = CallClientService();

int idConversation = 0;

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();
  changeTheme.value = await SpUtil.getInt('changeTheme') ?? 0;

  // changeLanguage.value = await SpUtil.getString('changeLanguage') ?? 'vi';

  print("-----changeTheme - - - - - ${changeLanguage.value}");
  await ensureSingleInstance(args);
  DeviceInfoService().init();
  configureDependencies();
  await localNotifier.setup(appName: 'Chat365 PC');
  initSystemTray();
  // runMigrationProcess();
  launchAtStartup.setup(
    appName: "Chat365 PC",
    appPath: Platform.resolvedExecutable,
  );
  if (autoStart) {
    await launchAtStartup.enable();
  } else {
    await launchAtStartup.disable();
  }

  screenRetriever.getPrimaryDisplay().then((primaryDisplay) {
    preferedWidth = primaryDisplay.size.width * 0.85;
    preferedHeight = primaryDisplay.size.height * 0.85;
  });

  StreamSubscription<Uri>? _linkSubscription;

  _linkSubscription = appLinks.uriLinkStream.listen((uri) async {
    print('linkwebtoappapplayout : $uri');
    LinkWebModel checkweb = await makeInformationFromApp(uri.toString());
    print(
        'onAppLinkApplyaout: ${checkweb.id} ${checkweb.idEmployer} ${checkweb.positionType} ${checkweb.idConversation} ${AuthRepo().userId}');
    idConversation = checkweb.idConversation;
  });


  //-------------------------- Zalo---------------------------
  Hive
    ..registerAdapter(FriendZaloAdapter())
    ..registerAdapter(ConversationItemZaloModelAdapter())
    ..registerAdapter(UserInfoZaloAdapter());

  /// TL 22/2/2024: LÀM ƠN BỎ CÁI NÀY ĐI, gãy hết cache đấy.
  /// HiveService BẮT BUỘC phải init sau AuthRepo(), để còn có thông tin người dùng
  /// mà biết có những cuộc trò chuyện nào cần lấy
  // try {
  //   //
  //   await HiveService().init();
  // } catch (e, s) {
  //   logger.logError(e, s, 'HiveServiceInitError');
  // }
  try {
    await SPService().getInstance();
  } catch (e) {
    print(e);
  }

  /// TL 8/1/2024: Đặt HiveService dưới init AuthRepo, để còn có thể lấy data theo id người dùng
  /// NOTE: Có thể sẽ có nhiều log của các Repo ý ới thất bại. Nhưng chưa chắc đã thật sự thế đâu.
  /// Hãy check log từ đoạn "Khởi tạo dữ liệu local." dưới đây trở xuống đến "Khởi tạo dữ liệu local thành công."
  try {
    logger.log("Khởi tạo dữ liệu local.", name: "main.dart");
    await HiveService().init();
    logger.log("Khởi tạo dữ liệu local thành công.", name: "main.dart");
  } catch (e, s) {
    logger.logError("Khởi tạo dữ liệu local gặp lỗi: $e", s, 'main.dart');
  }
  var check = AuthRepo.checkInfoInLocalStorage();

  if (check) {
    try {
      userType = UserType.fromJson(json.decode(spService.userType!));
      userInfo = IUserInfo.fromLocalStorageJson(
        json.decode(spService.userInfo!),
        userType: userType!,
      );
      getIt.get<AppService>().setupUnreadConversationId();
      AuthRepo().userInfo = userInfo;
      logger.log(
          "Lấy thông tin local người dùng thành công: ${AuthRepo().userInfo}",
          name: "main.dart");
    } catch (e, s) {
      logger.logError(
          "Lấy thông tin local người dùng thất bại: ${e}", s, "main.dart");
    }
  } else {
    logger.log("Người dùng không có thông tin local", name: "main.dart");
  }

  chatConversationsRepo = ChatConversationsRepo(
    userInfo != null ? userInfo!.id : 0,
    total: spService.totalConversation ?? 0,
  );
  chatConversationBloc = ChatConversationBloc(chatConversationsRepo);

  if (userInfo != null) AuthRepo().userInfo = userInfo;

  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;

    Map windows1 = {
      "setting": SettingCall(
        windowController: WindowController.fromWindowId(windowId),
      ),
    };
    if (argument['args'] == 'setting') {
      runApp(windows1[argument['args']]);
    }
  } else {
    runApp(const MyApp());
  }
}

Future<void> initSystemTray() async {
  String path =
      Platform.isWindows ? Images.systemtray_windows : Images.systemtray_macos;

  final AppWindow appWindow = AppWindow();
  final SystemTray systemTray = SystemTray();

  // We first init the systray menu
  await systemTray.initSystemTray(
    iconPath: path,
  );

  // create context menu
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(
        label: 'Mở Chat365', onClicked: (menuItem) => appWindow.show()),
    MenuItemLabel(
        label: 'Ẩn Chat365', onClicked: (menuItem) => appWindow.hide()),
    MenuItemLabel(
        label: 'Thoát Chat365', onClicked: (menuItem) => appWindow.close()),
  ]);

  // set context menu
  await systemTray.setContextMenu(menu);

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) {
    if (eventName == kSystemTrayEventClick) {
      Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
    } else if (eventName == kSystemTrayEventRightClick) {
      Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
    }
  });
}

// void runMigrationProcess() {
//   //This function is used to make changes to the user installed app after version changes
//   if (migrationIdentifier < 1) {
//     //Migration to fix default notification settings on older version
//     logger.log("Older migration level detected, running migration.", name: "Migration");
//     notificationChatting = true;
//     SpUtil.putBool('notificationSetting', true);
//     SpUtil.putInt('migrationIdentifier', 1);
//   }
// }

void initializeNotificationChannel() {
  const DarwinInitializationSettings initializationSettingsMacOS =
      DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);
  const InitializationSettings initializationSettings =
      InitializationSettings(macOS: initializationSettingsMacOS);
  FlutterLocalNotificationsPlugin().initialize(initializationSettings,
      onDidReceiveNotificationResponse: (details) {
    logger.log(details.payload);
  });
}

Future<void> ensureSingleInstance(args) async {
  if (Platform.isWindows) {
    await WindowsSingleInstance.ensureSingleInstance(
        args, "timviec365.vn.chat365pc");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // This widget is the root of your application.
  // final AuthRepo authRepo = AuthRepo.instance!;

  NavigatorState get navigator => navigatorKey.currentState!;

  BuildContext get navigatorContext => navigator.context;

  // final AuthRepo authRepo = AuthRepo();
  final AuthRepo authRepo = AuthRepo();
  ThemeMode _themeMode = ThemeMode.light;
  StreamSubscription<Uri>? _linkSubscription;
  int idConversation = 0;

  // late final DownloaderCubit _downloaderCubit;
  late final AppService _appService;
  final botToastBuilder = BotToastInit(); //1. call BotToastInit
  Future<void> _loadThemeMode() async {
    int? savedThemeMode = SpUtil.getInt(LocalStorageKey.themeChange);
    if (savedThemeMode != null) {
      setState(() {
        _themeMode = ThemeMode.values[savedThemeMode];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    reactionCubit = ReactionCubit('', chatRepo: chatRepo, initEmotions: {});
    // _downloaderCubit = DownloaderRepo();
    _appService = getIt.get<AppService>();
    chatClient.socket.onDisconnect((value) => _onSocketDisconnected());
    chatClientZalo.socket.onDisconnect((value) => _onSocketDisconnectedZalo());
    _loadThemeMode();
    // callClient.socket.onDisconnect((value) => _onCallSocketDisconnected());
    _linkSubscription = appLinks.uriLinkStream.listen((uri) async {
      print('linkwebtoappapplayout : $uri');
      LinkWebModel checkweb = await makeInformationFromApp(uri.toString());
      print(
          'onAppLinkApplyaout: ${checkweb.id} ${checkweb.idEmployer} ${checkweb.positionType} ${checkweb.idConversation} ${AuthRepo().userId}');
      idConversation = checkweb.idConversation;
    });
    callIncoming();
  }

  callIncoming() {
    callClient.on(CallClientEvents.CALL_INCOMING, (response) async {
      print("aaaaaaaaaaaa");
      var idRoom = response['roomId'];
      var idCaller = response['callerId'];
      var nameCaller = response['callerName'];
      var avatarCaller = response['callerAvatar'];
      var callType = response['callType'];
      await ccService.waitForLoggedIn();
      await ccService.onCallIncoming(response);

      overlayState1 ??= navigatorKey.currentState!.overlay;
      callEntry1 = OverlayEntry(builder: (_) {
        return Positioned(
          top: (context.mediaQuerySize.height - 400) / 2,
          left: (context.mediaQuerySize.width - 400) / 2,
          child: Transform.scale(
            // scaleX: 0.5,
            // scaleY: 0.5,
            scaleX: 1,
            scaleY: 1,
            child: Container(
                // width: context.mediaQuerySize.height,
                // height: context.mediaQuerySize.height,

                width: 400,
                height: 400,
                child: RingingCall(
                  idRoom: idRoom,
                  idCaller: idCaller,
                  idCallee: AuthRepo().userId!.toString(),
                  checkCall: true,
                  nameAnother: nameCaller,
                  avatarAnother: avatarCaller,
                  payload: response,
                )),
          ),
        );
      });
      overlayState1?.insert(callEntry1!);
    });
  }

  _onSocketDisconnected() async {
    logger.logError('****** Socket disconnected *******');
    while (chatClient.socket.disconnected) {
      await Future.delayed(const Duration(seconds: 1));
      if ((await networkCubit.check) == DataConnectionStatus.connected) {
        await Future.delayed(const Duration(seconds: 1));
        if (chatClient.socket.disconnected) {
          // print('Has Internet: Reconnected failure');
          networkCubit.emit(NetworkState(
            true,
            socketDisconnected: true,
          ));
        } else {
          networkCubit.emit(NetworkState(true));
          if (authRepo.userInfo != null) {
            if (authRepo.userId != null &&
                authRepo.userId != 0 &&
                !AuthRepo.authToken.isBlank) {
              logger.log('LoggedIn', name: 'Login Message Log');
              chatClient.emit(ChatSocketEvent.login, [
                authRepo.userInfo!.id,
                StringConst.fromChat365,
              ]);
            }
          }
        }
      } else {
        // print('Internet failure: Reconnected failure');
        networkCubit.emit(NetworkState(
          false,
          socketDisconnected: true,
        ));
      }
    }
  }

  _onSocketDisconnectedZalo() async {
    logger.logError('****** Socket disconnected *******');
    while (chatClientZalo.socket.disconnected) {
      await Future.delayed(const Duration(seconds: 1));
      if ((await networkCubit.check) == DataConnectionStatus.connected) {
        await Future.delayed(const Duration(seconds: 1));
        if (chatClientZalo.socket.disconnected) {
          // print('Has Internet: Reconnected failure');
          networkCubit.emit(NetworkState(
            true,
            socketDisconnected: true,
          ));
        } else {
          networkCubit.emit(NetworkState(true));
          if (authRepo.userInfo != null) {
            if (authRepo.userId != null &&
                authRepo.userId != 0 &&
                !AuthRepo.authToken.isBlank) {
              logger.log('LoggedIn', name: 'Login Message Log');
              chatClientZalo.emit(ChatSocketEvent.login, [
                authRepo.userInfo!.id,
                StringConst.fromChat365,
              ]);
            }
          }
        }
      } else {
        // print('Internet failure: Reconnected failure');
        networkCubit.emit(NetworkState(
          false,
          socketDisconnected: true,
        ));
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (primaryFocus?.hasFocus == true) {
        logger.log(state, name: 'focus status');
        primaryFocus?.unfocus();
        logger.log(state, name: 'focus status');
      }
      chatClient.emit(ChatSocketEvent.logout, authRepo.userId);
      canRead = false;
    }
    if (state == AppLifecycleState.resumed) {
      if (authRepo.userId != null &&
          authRepo.userId != 0 &&
          !AuthRepo.authToken.isBlank) {
        chatClient.emit(
            ChatSocketEvent.login, [authRepo.userId, StringConst.fromChat365]);

        /// bỏ kênh login v2 theo y/c d/c Tuấn Anh
        // chatClient.emit(ChatSocketEvent.login_v2,
        //     {"userId": AuthRepo().userId, 'fromWeb': 'timviec365'});
        logger.log('tokennnn: ${AuthRepo.authToken}');
      }
      canRead = true;
    } else if (state == AppLifecycleState.detached) {}
    super.didChangeAppLifecycleState(state);
  }

  /// TL 8/1/2024: Theo docs, có nhiều lý do mà hàm này không được gọi khi exit,
  /// ví dụ như tháo pin, hết pin, nổ điện thoại,...
  /// Vì thế nên không nên lưu dữ liệu tối quan trọng trong hàm này
  /// Mình dùng cái này để lưu dữ liệu Hive khi tắt app. Hên xui vậy
  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await HiveService().saveData();
    return AppExitResponse.exit;
  }

  @override
  Widget build(BuildContext context) {
    AppDimens.widthPC = MediaQuery.of(context).size.width;
    AppDimens.heightPC = MediaQuery.of(context).size.height;
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(
            value: authRepo,
          ),
          RepositoryProvider.value(
            value: userInfoRepo,
          ),
          RepositoryProvider.value(
            value: chatRepo,
          ),
          RepositoryProvider.value(
            value: chatConversationsRepo,
          ),
          RepositoryProvider(create: (_) => GetTokenRepo(authRepo)),
        ],
        child: MultiBlocProvider(
            providers: [
              BlocProvider<ReactionCubit>(
                create: (context) => reactionCubit,
              ),
              BlocProvider<UserSearchCubit>(
                create: (context) => UserSearchCubit(),
              ),
              BlocProvider<NotificationBloc>(
                create: (context) => NotificationBloc(),
              ),
              BlocProvider<LoginCubit>(
                create: (context) => LoginCubit(),
              ),
              BlocProvider<LoginCubitZalo>(
                create: (context) => LoginCubitZalo(),
              ),
              BlocProvider<SignUpCubit>(create: (context) => SignUpCubit()),
              BlocProvider<StickerCubit>(create: (context) => StickerCubit()),
              BlocProvider<AuthBloc>(
                create: (context) => AuthBloc(authRepo),
              ),
              BlocProvider<LoginCubitZalo>(
                create: (context) => LoginCubitZalo(),
              ),
              // BlocProvider<DownloaderCubit>.value(value: _downloaderCubit),
              BlocProvider<ChatBloc>(
                create: (context) => ChatBloc(context.read<ChatRepo>()),
              ),
              BlocProvider<NetworkCubit>.value(value: networkCubit),
              BlocProvider<ThemeCubit>(
                  create: (context) => ThemeCubit(context)),
              BlocProvider<ChatConversationBloc>.value(
                value: chatConversationBloc,
              ),
              // BlocProvider(create: (_)=> UnreadMessageCounterCubit(
              //     conversationId: null, countUnreadMessage: null)),
              BlocProvider(create: (_) => UserContactCubit()),
              BlocProvider(create: (_) => ContactBloc()),
              BlocProvider(create: (_) => ChatConversationCubit()),
              BlocProvider(create: (_) => UserRequestBloc()),
              BlocProvider(create: (_) => ChatCubit()),
              BlocProvider(create: (_) => UserInfoBloc(authRepo.userInfo!)),
              BlocProvider<FriendCubit>(
                create: (context) {
                  // Vừa khởi tạo vừa fetch data luôn
                  var friendCubit =
                      FriendCubit(chatRepo: context.read<ChatRepo>());
                  friendCubit.fetchFriendData();
                  return friendCubit;
                },
              ),
            ],
            child: BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, themeState) {
              final botToastBuilder = BotToastInit();
              return ValueListenableBuilder(
                valueListenable: changeLanguage,
                builder: (BuildContext context, String value, Widget? child) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    navigatorKey: navigatorKey,
                    scaffoldMessengerKey: scaffoldKey,
                    title: AppConst.appName,
                    theme: themeState.theme.theme,
                    themeMode: MyTheme(context).themeMode,
                    // themeMode: ThemeMode.light,
                    navigatorObservers: [
                      routeObserver,
                      BotToastNavigatorObserver()
                    ],
                    // supportedLocales: const [
                    //   Locale('vi', 'VN'),
                    //   Locale('en', 'US')
                    // ],
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    locale: Locale(changeLanguage.value),
                    localeResolutionCallback: ((locale, supportedLocales) {
                      for (var supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode ==
                                locale!.languageCode &&
                            supportedLocale.countryCode == locale.countryCode) {
                          return supportedLocale;
                        }
                      }
                      return supportedLocales.first;
                    }),
                    supportedLocales: AppLocalizations.supportedLocales,
                    builder: (context, child) {
                      var authRepo = context.read<AuthRepo>();
                      var authBloc = context.read<AuthBloc>();
                      child = botToastBuilder(context, child);
                      return BlocListener<AuthBloc, AuthState>(
                        listener: (context, state) async {
                          if (state is AuthenticatedState) {
                            // print('ccccccccccccc$state');
                            // print(
                            //     'ccccccccccccccccc${SpUtil.getString(LocalStorageKey.userInfo)}');
                            AppRouter.removeAllDialog(navigatorContext);

                            var totalConversation = spService.totalConversation;

                            ccService.login(
                                AuthRepo().userInfo!.id,
                                AuthRepo().userInfo!.name,
                                AuthRepo().userInfo!.avatar);

                            if (totalConversation == null) {
                              BotToast.showText(
                                text:
                                    'Đã có sự cố xảy ra, vui lòng đăng nhập lại',
                              );
                              logger.logError(
                                'Lỗi: totalConversation is null',
                              );
                              return authBloc.add(AuthStatusChanged(
                                AuthStatus.unauthenticated,
                              ));
                            }

                            // final ContactListRepo contactListRepo = ContactListRepo(
                            //   authRepo.userId!,
                            //   companyId: authRepo.userInfo!.companyId ?? 0,
                            // );
                            context.read<ChatConversationsRepo>().totalRecords =
                                totalConversation;
                            var userId = authRepo.userInfo!.id;
                            // mqttClient.connectMqttClient();
                            SpUtil.putInt(LocalStorageKey.userId, userId);
                            chatConversationBloc.useFastApi = true;
                            if (_appService.countUnreadConversation == 0) {
                              _appService.setupUnreadConversationId();
                            }

                            // await AppRouter.toPage(context, AppPages.appLayOut,
                            //     arguments: {'UserInfo': userInfo});
                          } else if (state is UnAuthenticatedState) {
                            try {
                              getIt.get<AppService>().reset();
                            } catch (e) {}
                            userInfo = null;
                            userType = null;
                            sendMessagePreSearchData.clear();
                            searchAllPreSearchData = null;
                            conversations = null;
                            chatConversationBloc.resetToLogout();
                          }
                        },
                        child: BlocListener<LoginCubit, LoginState>(
                            listener: (BuildContext context, LoginState state) {
                              if (state is LoginStateLoad) {
                                // AppDialogs.showLoadingCircle(
                                //   navigatorContext,
                                //   barrierDismissible: false,
                                // );
                              } else if (state is LoginStateSuccess) {
                                var loggedInUserInfo = state.userInfo;
                                chatConversationsRepo
                                  ..userId = loggedInUserInfo.id
                                  ..totalRecords = state.countConversation;
                                // context.read<ChatConversationsRepo>().userId = AuthRepo().userInfo!.id;
                                chatConversationBloc.loadData(
                                    countLoaded: 0, reset: true);
                                authRepo
                                  ..userInfo = loggedInUserInfo
                                  ..userType = state.userType;
                                spService.saveTotalConversation(
                                  state.countConversation,
                                );

                                if (!loggedInUserInfo.email.isBlank)
                                  spService.saveLoggedInEmail(
                                    loggedInUserInfo.email!,
                                  );
                                // SpUtil.putObject('cc', AuthRepo().userInfo!);
                                //
                                // print('---${SpUtil.getObject('cc')}');

                                try {
                                  spService.saveLoggedInInfo(
                                    info: AuthRepo().userInfo!,
                                    userType: AuthRepo().userInfo!.userType!,
                                  );
                                } catch (e, s) {
                                  return logger.logError(e, s);
                                }

                                authBloc.add(
                                  AuthStatusChanged(
                                    AuthStatus.authenticated,
                                  ),
                                );
                              } else if (state is LoginStateError) {
                                if (state.errorRes != null) {
                                  logger.log(state.errorRes?.code);
                                  //Kiem tra khong la code 200
                                  //va sai ko phai lien quan xac thuc cong ty thi hien toast
                                  if (!StatusCode.wrongAuthStatusCodes
                                          .contains(state.errorRes!.code) &&
                                      state.errorRes!.code != 200 &&
                                      state.errorRes!.messages != null &&
                                      !state.errorRes!.messages!
                                          .contains('chưa xác thực')) {
                                    BotToast.showText(text: state.error);
                                  }
                                }
                              }
                            },
                            child: child),
                      );
                    },
                    home: userInfo != null
                        ? AppLayout(
                            receiveID: idConversation,
                          )
                        : LogInOrSignUp(),
                  );
                },
              );
            })));
  }
}
