import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/widgets/popup_menu/custom_popup_menu_divider.dart';
import 'package:app_chat365_pc/common/widgets/weighted_icon.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat_conversations/screen/chat_conversation_screen.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/conversation_item.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages.dart';
import 'package:app_chat365_pc/modules/layout/views/setting/setting.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:sp_util/sp_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class AppSubLayout extends StatefulWidget {
  AppSubLayout({super.key, required this.userInfo});

  IUserInfo userInfo;

  @override
  State<AppSubLayout> createState() => _AppSubLayoutState();
}

class _AppSubLayoutState extends State<AppSubLayout> {
  late final AppLayoutCubit _appLayoutCubit;
  final ValueNotifier<Widget> _layout = ValueNotifier(ChatConversationScreen());
  late final IUserInfo _userInfo;

  @override
  void initState() {
    super.initState();
    _appLayoutCubit = context.read<AppLayoutCubit>();
    _userInfo = widget.userInfo;
  }

  profileChat() {
    PopupMenuEntry<String> buildDivider({double? indent}) 
      => CustomPopupMenuDivider(color: context.theme.colorLine, endIndent: indent, indent: indent, thickness: 0.5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              PopupMenuButton<String>(
                offset: const Offset(45, 0),
                shadowColor: context.theme.textColor,
                color: context.theme.backgroundColor,
                constraints: const BoxConstraints.tightFor(width: 350),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                tooltip: '',
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 40,
                  height: 40,
                  child: DisplayAvatarOnly(avatar: userInfo?.avatar??''),
                ),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(context.theme.timviec365Logo, width: 100),
                          TextButton(
                            onPressed: () {
                              showLogoutDialog();
                            },
                            child: Text(AppLocalizations.of(context)?.log_out ??'',
                              style: TextStyle(color: context.theme.text2Color),
                            )
                          )
                        ],
                      ),
                    )
                  ),
                  buildDivider(),
                  PopupMenuItem(
                    enabled: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,  
                        children: [
                          Stack(
                            children: [
                              SizedBox(width: 50, child: DisplayAvatarOnly(avatar: userInfo?.avatar??'')),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: ClipOval(
                                  clipBehavior: Clip.antiAlias,
                                  child: Container(
                                    color: AppColors.E0Gray,
                                    width: 20,
                                    height: 20,
                                    child: const Icon(Icons.camera_alt, size: 15, color: Colors.black),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _userInfo.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.nameProfile(context),
                              ),
                              const SizedBox(height: 4),
                              _userInfo.status != ''
                                  ? Text(_userInfo.status!, style: AppTextStyles.nameProfile(context).copyWith(fontWeight: FontWeight.normal))
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                    )
                  ),
                  PopupMenuItem(
                    height: 0,
                    enabled: false,
                    child: ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 4),
                      leading: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white),
                            borderRadius: BorderRadius.circular(90.0),
                            color: AppColors.lima)),
                      trailing: Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: 25,
                        color: context.theme.text2Color,
                      ),
                      title: ListTile(
                        title: Text(
                          "Đang hoạt động",
                          style: TextStyle(color: context.theme.textColor, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  buildDivider(indent: 16),
                  PopupMenuItem(
                    height: 0,
                    enabled: false,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Icon(
                        Icons.emoji_emotions_outlined,
                        size: 25,
                        color: context.theme.textColor,
                      ),
                      trailing: Icon(
                        Icons.edit_outlined,
                        size: 25,
                        color: context.theme.text2Color,
                      ),
                      title: Text(
                        _userInfo.status??'',
                        style: TextStyle(color: context.theme.textColor, fontSize: 16),
                      ),
                    ),
                  ),
                  buildDivider(indent: 16),
                  PopupMenuItem(
                    height: 0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Icon(
                        Icons.supervisor_account_outlined,
                        size: 25,
                        color: context.theme.text2Color,
                      ),
                      title: Text(
                        "Mời bạn",
                        style: TextStyle(color: context.theme.textColor, fontSize: 16),
                      ),
                    ),
                  ),
                  buildDivider(indent: 16),
                  PopupMenuItem(
                    height: 0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Icon(
                        Icons.qr_code,
                        size: 25,
                        color: context.theme.text2Color,
                      ),
                      title: Text(
                        "Mã QR đăng nhập",
                        style: TextStyle(color: context.theme.textColor, fontSize: 16),
                      ),
                    ),
                  ),
                  buildDivider(indent: 16),
                  PopupMenuItem(
                    enabled: false,
                    height: 0,
                    child: Text("Quản lý", style: TextStyle(color: context.theme.text2Color, fontWeight: FontWeight.bold))
                  ),
                  PopupMenuItem(
                    height: 0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Icon(
                        Icons.person_outline,
                        size: 25,
                        color: context.theme.text2Color,
                      ),
                      title: Text(
                        "Hồ sơ Chat365",
                        style: TextStyle(color: context.theme.textColor, fontSize: 16),
                      ),
                    ),
                  ),
                  buildDivider(indent: 16),
                   PopupMenuItem(
                    height: 0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Icon(
                        Icons.security,
                        size: 25,
                        color: context.theme.text2Color,
                      ),
                      title: Text(
                        "Bảo mật",
                        style: TextStyle(color: context.theme.textColor, fontSize: 16),
                      ),
                    ),
                  ),
                  buildDivider(indent: 16),
                   PopupMenuItem(
                    height: 0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Icon(
                        Icons.lock_outline_rounded,
                        size: 25,
                        color: context.theme.text2Color,
                      ),
                      title: Text(
                        "Quyền riêng tư",
                        style: TextStyle(color: context.theme.textColor, fontSize: 16),
                      ),
                    ),
                  ),
                  buildDivider(indent: 16),
                   PopupMenuItem(
                    height: 0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: WeightedIcon(
                        Icons.settings_outlined,
                        size: 25,
                        weight: FontWeight.w100,
                        color: context.theme.text2Color,
                      ),
                      title: Text(
                        "Cài đặt",
                        style: TextStyle(color: context.theme.textColor, fontSize: 16),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SettingLocal();
                        });
                      },
                    ),
                  ),
                ]
              ),
              Positioned(
                  right: 10,
                  bottom: 0,
                  child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.white),
                          borderRadius: BorderRadius.circular(90.0),
                          color: AppColors.lima)))
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _userInfo.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.nameProfile(context),
                ),
                _userInfo.status != '' ? SizedBoxExt.shrink : SizedBoxExt.h5,
                Row(
                  children: [
                    _userInfo.status != ''
                        ? Text(_userInfo.status!, style: TextStyle(color: context.theme.textColor))
                        : const SizedBox.shrink(),
                    // Text(
                    //   _userInfo.email!,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: AppTextStyles.subTextProfile(context),
                    // ),
                  ],
                )
              ],
            ),
          ),
          PopupMenuButton<String>(
              tooltip: '',
              offset: Offset(30, 00),
              shadowColor: context.theme.textColor,
              color: context.theme.backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              icon: SvgPicture.asset(
                AssetPath.ic_3_dot,
                width: 20,
                height: 20,
                color: context.theme.colorTextNameProfile,
              ),
              onSelected: (String? value) {
                setState(() async {
                  if (value == AppLocalizations.of(context)?.log_out) {
                    //Logout Dialog
                    showLogoutDialog();
                  } else if(value == StringConst.support_and_feedback) {
                    print('-------------changtheme ----${changeTheme.value}--------------');
                  }

                  else {
                    showSelectedOptionDialog(value!);
                  }
                });
              },
              itemBuilder: (BuildContext context) => [
                    buildPopupProfileItem(AppLocalizations.of(context)?.setting ??'',
                        AssetPath.setting, context.theme.item3DotColor),
                    buildPopupProfileItem(AppLocalizations.of(context)?.support_and_feedback ??'',
                        AssetPath.stranger, context.theme.item3DotColor),
                    buildPopupProfileItem(
                        AppLocalizations.of(context)?.log_out ??'', AssetPath.log_out, AppColors.red),
                  ]),
        ],
      ),
    );
  }

  showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          //shadowColor: context.theme.backgroundColor,
          child: Container(
            height: 320,
            width: 380,
            decoration: BoxDecoration(
                color: context.theme.backgroundColor,
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                ),
                GradientIcon(
                  icon: Icons.logout,
                  size: 120,
                  gradient: context.theme.gradient,
                ),
                SizedBox(
                  height: 12,
                ),
                GradientText(AppLocalizations.of(context)?.log_out ??'',
                    gradient: context.theme.gradient,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
                GradientText(AppLocalizations.of(context)?.doYouWantToSignOut ??'',
                    gradient: context.theme.gradient,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    buttonWhite(AppLocalizations.of(context)?.cancel ??'', 108,
                        () => AppRouter.back(context), context),
                    buttonBlue(StringConst.signOut, 108,
                        () async {
                      SystemUtils.logout(context);
                      await AppRouter.toPage(
                          context, AppPages.logIn);
                      print(
                          'ccccccccccccccccc${SpUtil.getString(LocalStorageKey.userInfo)}');

                      var initialSize = const Size(450, 690);
                      appWindow.minSize = initialSize;
                      appWindow.maxSize = initialSize;
                      appWindow.size = initialSize;
                      appWindow.alignment = Alignment.center;
                    }, context)
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  searchInSubLayOut() {
    return InkWell(
      onTap: () {
        _appLayoutCubit.toSubLayout(AppSubPages.userSearchScreen);
      },
      mouseCursor: SystemMouseCursors.text,
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 36,
          width: AppDimens.widthPC,
          decoration: BoxDecoration(
            color: context.theme.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: context.theme.hitnTextColorInputBar, width: 0.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 18,
                width: 18,
                child: SvgPicture.asset(
                  Images.ic_ep_search,
                  color: context.theme.hitnTextColorInputBar,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                AppLocalizations.of(context)?.hintTextSearch ??'',
                style: TextStyle(
                    color: context.theme.hitnTextColorInputBar,
                    fontSize: 12,
                    height: 20 / 18),
              ),
            ],
          )),
    );
  }

  buildPopupMenuItem(String value) {
    return PopupMenuItem<String>(
      height: 30,
      value: value,
      child: Text(
        value,
        style: const TextStyle(fontSize: 12), // Điều chỉnh font size ở đây
      ),
      onTap: () {
        //print(HomeScreen().selectmenu);
      },
    );
  }

  buildPopupProfileItem(String value, String path, Color color) {
    return PopupMenuItem<String>(
      value: value,
      height: 0,
      child: ListTile(
        leading: SvgPicture.asset(
          path,
          width: 25,
          height: 25,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        minLeadingWidth: 40,
        title: Text(
          value,
          style: TextStyle(color: color, fontSize: 13),
        ),
      ),
    );
  }

  showSelectedOptionDialog(String selectedOption) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return AlertDialog(
        //   title: const Text('Bạn đã chọn:'),
        //   content: Text(selectedOption),
        //   actions: [
        //     TextButton(
        //       onPressed: () {
        //         Navigator.of(context).pop();
        //       },
        //       child: const Text('Đóng'),
        //     ),
        //   ],
        // );
        return SettingLocal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: checkSearchUser,
          builder: (context, value, _) {
            return Container(
              height: MediaQuery.of(context).size.height - 42,
              width: 326,
              color: context.theme.backgroundListChat,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    profileChat(),
                    !checkSearchUser.value
                        ? searchInSubLayOut()
                        : const SizedBox(),
                    !checkSearchUser.value
                        ?  Column(
                          children: [
                            SizedBox(height: 20,),
                            Container(
                                height: 1,
                                color: context.theme.colorLine,
                              ),
                              SizedBox(height: 20,)
                          ],
                        )
                        : const SizedBox(),
                    Expanded(
                      child: BlocListener(
                        bloc: _appLayoutCubit,
                        listener: (context, state) {
                          if (state is AppSubLayoutNavigation) {
                            _layout.value = state.layout;
                            if (state.page == AppSubPages.userSearchScreen) {
                              checkSearchUser.value = true;
                            } else {
                              checkSearchUser.value = false;
                            }
                          }
                        },
                        child: ValueListenableBuilder(
                            valueListenable: _layout,
                            builder: (_, __, ___) => _layout.value),
                      ),
                    )
                  ]),
            );
          },
        );
      },
    );
  }
}
