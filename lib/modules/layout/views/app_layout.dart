import 'dart:io';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/theme_cubit/theme_cubit.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'dart:convert';

import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_conversations_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_service.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/data/services/sp_utils_service/sp_utils_services.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/auth/linkweb/model/link_web_model.dart';
import 'package:app_chat365_pc/modules/chat/notification/notificationChat.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages.dart';
import 'package:app_chat365_pc/modules/layout/views/features.dart';
import 'package:app_chat365_pc/modules/layout/views/main_layout.dart';
import 'package:app_chat365_pc/modules/layout/views/sub_layout.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/clients/interceptors/mqtt_client_5.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/zalo/conversation/screens/sub_layout_zalo.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:sp_util/sp_util.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(),
        MaximizeWindowButton(),
        CloseWindowButton(
          onPressed: () {
            appWindow.hide();
          },
        )
      ],
    );
  }
}

class AppLayout extends StatefulWidget {
  int receiveID;
  AppLayout(
      {super.key,
      // required this.userInfo
      required this.receiveID});

  // IUserInfo userInfo;

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> with WindowListener {
  final AppLayoutCubit _appLayoutCubit = AppLayoutCubit();

  late final AuthRepo _authRepo;
  @override
  void onWindowFocus() {
    logger.log(mqttClient.client?.connectionStatus?.state.name, name: "MQTT CON STATE");
    chatClient.emit(ChatSocketEvent.login,
        [_authRepo.userId, StringConst.fromChat365]);
    if (mqttClient.client?.connectionStatus?.state != MqttConnectionState.connected) {
      logger.log("Mqtt disconnected, attempt reconnection...", name: "MQTT CON STATE");
      logger.log(_authRepo.userId.toString(), name: "MQTT CON STATE");
      mqttClient.connectMqttClient(userId: _authRepo.userId.toString());
    }
  }

  @override
  void initState() {
    windowManager.addListener(this);
    context.theme.themeMode = changeTheme.value < 10 ? ThemeMode.light : ThemeMode.dark;
    int checkTheme = changeTheme.value % 10;
    switch (checkTheme) {
      case 0:
        context.theme.appTheme = AppThemeColor.blueTheme;
        break;
      case 1:
        context.theme.appTheme = AppThemeColor.greenTheme;
        break;
      case 2:
        context.theme.appTheme = AppThemeColor.orangeTheme;
        break;
      case 3:
        context.theme.appTheme = AppThemeColor.purpleTheme;
        break;
      case 4:
        context.theme.appTheme = AppThemeColor.purple2Theme;
        break;
      case 5:
        context.theme.appTheme = AppThemeColor.orange2Theme;
        break;
      case 6:
        context.theme.appTheme = AppThemeColor.primaryTheme;
        break;

      default:
    }

    doWhenWindowReady(() async {
      var initialSize = const Size(1000, 500);
      appWindow.minSize = initialSize;
      appWindow.maxSize = const Size(2000, 1200);
      appWindow.size = Size(preferedWidth, preferedHeight);
      appWindow.alignment = Alignment.center;
      await FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    });
    _authRepo = context.read<AuthRepo>();
    context.read<ChatConversationsRepo>().userId =
        SpUtil.getInt(LocalStorageKey.userId2)!;
    _appLayoutCubit.toSubLayout(AppSubPages.conversationPage);
    context.read<ChatConversationBloc>().loadData();
    // mqttClient.connectMqttClient(userId: _authRepo.userId.toString());
    chatClient.emit(ChatSocketEvent.login,
        [_authRepo.userId, StringConst.fromChat365]);
    super.initState();

  }

  Widget buildLogo() {
    return SizedBox(
      height: 29,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(
          width: 10,
        ),
        SvgPicture.asset(
          AssetPath.logo_non_text, width: 29, // Điều chỉnh kích thước nếu cần
          height: 29,
        ),
        Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            SvgPicture.asset(
              AssetPath.chat365,
              height: 13,
            ),
            SvgPicture.asset(
              AssetPath.timviec365,
              height: 9,
            ),
          ],
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    Offset? mouseOrigin;
    return Scaffold(
        body: BlocProvider(
      create: (context) => _appLayoutCubit,
      child: BlocListener(
          bloc: _appLayoutCubit,
          listener: (context, state) {
            print(state);
          },
          child: ValueListenableBuilder(
            valueListenable: changeTheme,
            builder: (context, value, child) => ValueListenableBuilder(
              valueListenable: isZalo,
              builder: (context, value, child) => Container(
                color: context.theme.backgroundColor,
                child: Row(
                  children: [
                    const AppFeatures(),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width - 56,
                            color: context.theme.backgroundListChat,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                appWindow.position = Offset(
                                  appWindow.position.dx +
                                      details.globalPosition.dx -
                                      (mouseOrigin?.dx ?? 0),
                                  appWindow.position.dy +
                                      details.globalPosition.dy -
                                      (mouseOrigin?.dy ?? 0),
                                );
                              },
                              onPanDown: (details) {
                                mouseOrigin = details.globalPosition;
                              },
                              child: Row(children: [
                                buildLogo(),
                                Expanded(
                                    child: Container(
                                  color: context.theme.backgroundListChat,
                                )),
                                const WindowButtons()
                              ]),
                            ),
                          ),
                          Container(
                            height: 1,
                            color: context.theme.colorLine,
                          ),
                          isZalo.value == false
                              ? Expanded(
                                  child: Row(
                                    children: [
                                      AppSubLayout(
                                          userInfo: AuthRepo().userInfo!),
                                      Container(
                                        width: 1,
                                        color: context.theme.colorLine,
                                      ),
                                      Expanded(
                                          child: AppMainLayout(
                                        receiveID: widget.receiveID,
                                      ))
                                    ],
                                  ),
                                )
                              : Expanded(
                                  child: Row(
                                    children: [
                                      AppSubLayoutZalo(
                                          userInfoZalo: userInfoZalo),
                                      Container(
                                        width: 1,
                                        color: context.theme.colorLine,
                                      ),
                                      Expanded(
                                          child: AppMainLayout(
                                        receiveID: widget.receiveID,
                                      ))
                                    ],
                                  ),
                                )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    ));
  }
}
