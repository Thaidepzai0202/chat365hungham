import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_conversations_repo.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_box_names.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/create_new_group_chat_dialog.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages.dart';
import 'package:app_chat365_pc/zalo/zalo_qr/account_management/account_management_screen.dart';
import 'package:app_chat365_pc/zalo/zalo_qr/login_cubit_zalo/login_cubit_zalo.dart';
import 'package:app_chat365_pc/zalo/zalo_qr/zalo_qr_screen.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/service/app_service.dart';
import 'package:app_chat365_pc/service/injection.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:badges/badges.dart' as badges;
import 'package:hive/hive.dart';
import '../../../utils/data/enums/bottom_bar_item_type.dart';

class AppFeatures extends StatefulWidget {
  const AppFeatures({super.key});

  @override
  State<AppFeatures> createState() => _AppFeaturesState();
}

class _AppFeaturesState extends State<AppFeatures> {
  late final AppLayoutCubit _appLayoutCubit;
  final ValueNotifier _selectedFeatureItem = ValueNotifier<int>(1);
  late final MyTheme _myTheme;
  late final _unreadConversationStream;
  late final AppService _appService;
  late final _countUnreadNotiStream;
  late final ChatConversationBloc _chatConversationBloc;

  @override
  void initState() {
    super.initState();
    _appLayoutCubit = context.read<AppLayoutCubit>();
    _myTheme = context.theme;
    _appService = getIt.get<AppService>();
    _unreadConversationStream = _appService.unreadConversationStream;
    _countUnreadNotiStream = _appService.countUnreadNotiStream;
    _chatConversationBloc = context.read<ChatConversationBloc>();
    _selectedFeatureItem.addListener(() {
      switch (_selectedFeatureItem.value) {
        case 1:
          _appLayoutCubit.toSubLayout(AppSubPages.conversationPage);
          _appLayoutCubit.toMainLayout(AppMainPages.chatScreen);
          break;
        case 2:
          _appLayoutCubit.toSubLayout(AppSubPages.contactPage);
          break;
        case 3:
          _appLayoutCubit.toSubLayout(AppSubPages.utilityPage);
          break;
        case 4:
          _appLayoutCubit.toSubLayout(AppSubPages.callPage);
          break;
        case 5:
          _appLayoutCubit.toSubLayout(AppSubPages.notificationPage);
        case 6:
          _appLayoutCubit.toSubLayout(AppSubPages.zaloScreen);

          break;
      }
    });
  }

  PopupMenuItem<String> buildMenuItem(String value, String path,
      {void Function()? onTap}) {
    return PopupMenuItem<String>(
      onTap: onTap,
      value: value,
      child: SizedBox(
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              path,
              width: 16,
              height: 16,
              colorFilter:
                  const ColorFilter.mode(AppColors.gray, BlendMode.srcIn),
            ),
            const SizedBox(width: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFirstFeaturesColumn() {
    return SizedBox(
      width: 56,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 2.2),
          buildFeatureButton(
            onTap: () {
              isZalo.value = false;
              logger.log('Dcm bao h mới xong mệt lắm rồi ');
              _chatConversationBloc.refresh();
            },
            iconBefore: AssetPath.chat,
            iconAfter: AssetPath.chat_filled,
            position: 1,
          ),
          buildFeatureButton(
              onTap: () {
                isZalo.value = false;
                checkSearchUser.value = false;
              },
              iconBefore: AssetPath.contact,
              iconAfter: AssetPath.contact_filled,
              position: 2),
          buildFeatureButton(
              onTap: () {
                isZalo.value = false;
                checkSearchUser.value = false;
              },
              iconBefore: AssetPath.ic_utilities_outline,
              iconAfter: AssetPath.ic_utilities,
              position: 3),
          buildFeatureButton(
              onTap: () {
                isZalo.value = false;
                checkSearchUser.value = false;
              },
              iconBefore: AssetPath.phone,
              iconAfter: AssetPath.phone_filled,
              position: 4),
          buildFeatureButton(
              onTap: () {
                isZalo.value = false;
                checkSearchUser.value = false;
              },
              iconBefore: AssetPath.bell,
              iconAfter: AssetPath.bell_filled,
              position: 5),
          buildFeatureButton(
              onTap: () {
                checkSearchUser.value = false;
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Container(
                          height: 200,
                          width: 700,
                          decoration: BoxDecoration(
                              color: context.theme.backgroundColor,
                              borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                width: 700,
                                decoration: BoxDecoration(
                                    gradient: context.theme.gradient,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    )),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const Text(
                                      StringConst.zalo365,
                                      style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: AppColors.white,
                                        )),
                                    const SizedBox(
                                      width: 20,
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 150,
                                width: 600,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildSelectInZalo(
                                        ontap: () {
                                          Navigator.of(context).pop();
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return BlocProvider<
                                                    AppLayoutCubit>(
                                                  create: ((context) =>
                                                      AppLayoutCubit()),
                                                  child: ZaloQRScreen(),
                                                );
                                              });
                                        },
                                        text: "Login QR",
                                        pathIcon: Images.ic_login),
                                    buildSelectInZalo(
                                        ontap: () {
                                          Navigator.of(context).pop();
                                          showDialog(context: context, builder:(context) {
                                            return AccountManagementScreen();
                                          },);
                                        },
                                        text: "Quản lý TK",
                                        pathIcon: Images.account_box),
                                    buildSelectInZalo(
                                        ontap: () async {
                                          var box = await Hive.openBox(
                                              HiveBoxNames.saveAccountZalo);
                                          userInfoZalo = box.get('accountZalo');
                                          if (userInfoZalo.idZalo == '-1') {
                                            Navigator.of(context).pop();
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: context.theme
                                                              .backgroundColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      height: 120,
                                                      width: 400,
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient: context
                                                                  .theme
                                                                  .gradient,
                                                              borderRadius: const BorderRadius
                                                                  .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          15)),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                const SizedBox(
                                                                    width: 24),
                                                                const Text(
                                                                  'Quản lý tài khoản Zalo',
                                                                  style: TextStyle(
                                                                      color: AppColors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                Spacer(),
                                                                IconButton(
                                                                  icon:
                                                                      const Icon(
                                                                    Icons.close,
                                                                    color: AppColors
                                                                        .white,
                                                                    size: 20,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                const SizedBox(
                                                                    width: 10)
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                              child: Center(
                                                                  child: Text(
                                                            'Bạn chưa đăng nhập tài khoản Zalo nào',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: context
                                                                    .theme
                                                                    .text2Color),
                                                          )))
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                          } else {
                                            isZalo.value = true;
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        text: "Hội thoại",
                                        pathIcon: Images.ic_messages3),
                                    buildSelectInZalo(
                                        ontap: () {
                                          print("dd");
                                        },
                                        text: "Gửi tự đông",
                                        pathIcon: Images.message_tick_msg),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
              iconBefore: Images.ic_zalo,
              iconAfter: Images.ic_zalo,
              position: 6),
          // buildIcon(AssetPath.bell, ),
        ],
      ),
    );
  }

  Widget buildSecondFeaturesColumn() {
    return SizedBox(
      width: 56,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildFeatureMenu(icon: AssetPath.add_friend, menuItems: [
            buildMenuItem('Thêm bạn', Images.ic_fluent_people_add),
            buildMenuItem('Thêm bạn bằng mã QR', Images.ic_qr_code),
            buildMenuItem('Cuộc trò chuyện nhóm mới', Images.message_2,
                onTap: () {
              showDialog(
                  context: context,
                  builder: (dialogContext) {
                    // Mở ra màn tạo chat nhóm, với người mình
                    // đang chat cùng hiện tại đã có sẵn trong dialog
                    return CreateNewGroupChatDialog(
                      originContext: context,
                    );
                  });
            }),
            buildMenuItem('Cuộc trò chuyện mới', Images.ic_add_message),
            buildMenuItem('Lịch sử đăng nhập', Images.monitor_mobile),
          ]),
          buildFeatureMenu(icon: AssetPath.massage_tick, menuItems: [
            buildMenuItem('Tin đánh dấu', Images.star_msg),
          ]),
          buildFeatureMenu(icon: AssetPath.notification_status, menuItems: [
            buildMenuItem('Chưa cập nhật', Images.ic_error_lock)
          ]),
          buildFeatureMenu(icon: AssetPath.video, menuItems: [
            buildMenuItem('Chưa cập nhật', Images.ic_error_lock)
          ]),
          buildFeatureMenu(icon: AssetPath.clound, menuItems: [
            buildMenuItem('Chưa cập nhật', Images.ic_error_lock)
          ]), //buildIcon(AssetPath.bell, ),
        ],
      ),
    );
  }

  // Widget buildFeatureButton2(
  //     {required String iconBefore,
  //       required String iconAfter,
  //       required int position,
  //       Function()? onTap}) {
  //
  //   return _bottomNavigationBarItemIcon(
  //
  //   )
  // }

  /// TL note 14/12/2023:
  /// Các nút ở thanh chức năng (cuộc trò chuyện, danh bạ, cuộc gọi, thông báo,...)
  Widget buildFeatureButton(
      {required String iconBefore,

      /// Icon khi không bị bấm
      required String iconAfter,

      /// Icon khi bị bấm
      required int position,

      /// Trò chuyện: 1. Danh bạ: 2. Công cụ: 3,...
      Function()? onTap}) {
    final Widget itemWidget = ValueListenableBuilder(
      valueListenable: _selectedFeatureItem,
      builder: (context, value, child) => SizedBox.fromSize(
        size: const Size.square(AppConst.kBottomNavigationBarItemIconSize),
        child: _selectedFeatureItem.value == position
            ? ShaderMask(
                child: SvgPicture.asset(
                  iconAfter,
                  color: Colors.white,
                  fit: BoxFit.contain,
                  height: AppConst.kBottomNavigationBarItemIconSize,
                  width: AppConst.kBottomNavigationBarItemIconSize,
                ),
                shaderCallback: (Rect bounds) =>
                    _myTheme.gradient.createShader(bounds),
              )
            : SvgPicture.asset(
                iconAfter,
                color: Colors.white,
                fit: BoxFit.contain,
                height: AppConst.kBottomNavigationBarItemIconSize,
                width: AppConst.kBottomNavigationBarItemIconSize,
              ),
      ),
    );
    Widget res;
    if (position == 5) {
      res = StreamBuilder<int>(
          stream: _countUnreadNotiStream,
          initialData: _appService.countUnreadNoti,
          builder: (context, sns) {
            var isShow = _appService.countUnreadNoti > 0;
            // hiện số lượng thông báo chưa đọc
            var length = _appService.countUnreadNoti;
            print('______________$length');
            return badges.Badge(
              showBadge: isShow,
              badgeStyle: const BadgeStyle(
                shape: BadgeShape.circle,
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              ),
              position: BadgePosition.topEnd(top: -15),
              // borderRadius: BorderRadius.circular(100),
              badgeContent: !isShow
                  ? const SizedBox()
                  : Text(
                      length > 99 ? '99+' : length.toString(),
                      style: AppTextStyles.regularW400(
                        context,
                        size: 10,
                        color: AppColors.white,
                      ),
                      textHeightBehavior: TextHeightBehavior(
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
              child: itemWidget,
            );
          });
    } else if (position == 1) {
      res = StreamBuilder<Set<int>>(
          stream: _unreadConversationStream,
          initialData: _appService.unreadConversationIds,
          builder: (context, sns) {
            var isShow = !sns.data.isBlank;
            // hiện thông báo cuộc hội thoại chưa đọc
            var length = sns.data?.length;
            return badges.Badge(
              showBadge: isShow,
              badgeStyle: const BadgeStyle(
                shape: BadgeShape.circle,
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              ),
              position: BadgePosition.topEnd(top: -9),
              // borderRadius: BorderRadius.circular(100),
              badgeContent: !isShow
                  ? const SizedBox()
                  : Text(
                      length! > 99 ? '99+' : length.toString(),
                      style: AppTextStyles.regularW400(
                        context,
                        size: 10,
                        color: AppColors.white,
                      ),
                      textHeightBehavior: const TextHeightBehavior(
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
              child: itemWidget,
            );
          });
    } else {
      res = itemWidget;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: InkWell(
          onTap: () {
            _selectedFeatureItem.value = position;
            if (onTap != null) onTap();
          },
          child: ValueListenableBuilder(
              valueListenable: _selectedFeatureItem,
              builder: (context, value, child) => Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: (_selectedFeatureItem.value == position)
                        ? AppColors.white
                        : null,
                  ),
                  child: res))),
    );
  }

  Widget buildFeatureMenu(
      {required String icon, required List<PopupMenuItem<String>> menuItems}) {
    return PopupMenuButton<String>(
        padding: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: SvgPicture.asset(
          icon,
          width: 22,
          height: 22,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        ),
        onSelected: (String? value) {
          setState(() {});
        },
        tooltip: "",
        itemBuilder: (BuildContext context) => menuItems);
  }

  Widget buildSelectInZalo(
      {required Function()? ontap,
      required String pathIcon,
      required String text}) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: 90,
        width: 130,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: context.theme.text2Color,
            borderRadius: BorderRadius.circular(15)),
        child: Container(
          height: 90,
          width: 127,
          decoration: BoxDecoration(
            color: context.theme.backgroundColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              SvgPicture.asset(
                pathIcon,
                width: 50,
                height: 50,
                color: context.theme.text2Color,
              ),
              Text(
                text,
                style: TextStyle(
                    color: context.theme.text2Color,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              )
            ],
          ),
        ),
      ),
    );
  }

  void setStateSetting() {
    setState(() {
      print('${context.theme.appTheme.gradient}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(gradient: context.theme.gradient),
          child: Column(children: [
            const SizedBox(height: 40),
            buildFirstFeaturesColumn(),
            buildSecondFeaturesColumn(),
            const Expanded(
                child: SizedBox(
              height: 16,
            )),
          ]),
        );
      },
    );
  }
}
