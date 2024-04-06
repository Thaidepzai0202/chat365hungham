import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/debouncer.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/chat_conversations/screen/chat_conversation_screen.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/user_request_bloc/user_request_bloc.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/user_search/cubit/user_search_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/user_search/widget/list_group.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/user_search/widget/list_user.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen>
    with TickerProviderStateMixin {
  ValueNotifier<bool> all = ValueNotifier(true);
  ValueNotifier<bool> everyone = ValueNotifier(false);
  ValueNotifier<bool> company = ValueNotifier(false);
  ValueNotifier<bool> group = ValueNotifier(false);
  ValueNotifier<TextEditingController> controller =
      ValueNotifier(TextEditingController());

  /// TL 4/1/2024:
  /// 1 là Tất cả
  /// 2 là Mọi người
  /// 3 là Công ty
  /// 4 là Nhóm
  ValueNotifier<int> index = ValueNotifier(1);

  late UserSearchCubit searchCubit;
  late UserRequestBloc userRequestBloc;
  late final AppLayoutCubit _appLayoutCubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appLayoutCubit = context.read<AppLayoutCubit>();
    userRequestBloc = context.read<UserRequestBloc>();
    searchCubit = context.read<UserSearchCubit>()
      ..getAllSearch(AuthRepo().userInfo!.id, 'all', controller.value.text,
          AuthRepo().userInfo!.companyId!);
  }

  final Debouncer _debouncer =
      Debouncer(delay: const Duration(milliseconds: 300));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // padding: EdgeInsets.symmetric(horizontal: 4),
            margin: EdgeInsets.symmetric(horizontal: 4),
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: context.theme.colorPirimaryNoDarkLight,
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 85,
                  child: Container(
                    alignment: Alignment.center,
                    height: 25,
                    child: ValueListenableBuilder(
                        valueListenable: index,
                        builder: (context, value, _) {
                          return TextField(
                            cursorColor: AppColors.white,
                            autofocus: true,
                            onChanged: (value) {
                              /// TL: Tưởng ở bên dưới đã gọi từ lúc bấm rồi mà?
                              _debouncer.call(() {
                                index.value == 1
                                    ? searchCubit.getAllSearch(
                                        AuthRepo().userInfo!.id,
                                        'all',
                                        value,
                                        AuthRepo().userInfo!.companyId!)
                                    : index.value == 2
                                        ? searchCubit.getAllSearch(
                                            AuthRepo().userInfo!.id,
                                            'normal',
                                            value,
                                            AuthRepo().userInfo!.companyId!)
                                        : index.value == 2
                                            ? searchCubit.getAllSearch(
                                                AuthRepo().userInfo!.id,
                                                'company',
                                                value,
                                                AuthRepo().userInfo!.companyId!)
                                            : searchCubit.getAllSearch(
                                                AuthRepo().userInfo!.id,
                                                'group',
                                                value,
                                                AuthRepo()
                                                    .userInfo!
                                                    .companyId!);
                              });
                            },
                            controller: controller.value,
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)?.searchOnChat365??'',
                              hintStyle: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          );
                        }),
                  ),
                ),
                Expanded(
                  flex: 15,
                  child: InkWell(
                    onTap: () {
                      checkSearchUser.value = false;
                      _appLayoutCubit.subLayoutBack();
                    },
                    child: Container(
                      height: 17,
                      width: 17,
                      child: SvgPicture.asset(
                        Images.ic_x,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 30,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ValueListenableBuilder(
                      valueListenable: all,
                      builder: (context, value, _) {
                        return InkWell(
                          onTap: () {
                            all.value = true;
                            company.value = false;
                            everyone.value = false;
                            group.value = false;
                            index.value = 1;
                            searchCubit
                              ..getAllSearch(
                                  AuthRepo().userInfo!.id,
                                  'all',
                                  controller.value.text,
                                  AuthRepo().userInfo!.companyId!);
                          },
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  AppLocalizations.of(context)?.all ??'',
                                  style: TextStyle(
                                      color: all.value == true
                                          ? context.theme.text2Color
                                          : context.theme.textSelectInSearch),
                                ),
                              ),
                              const Spacer(),
                              all.value == true
                                  ? Container(
                                      height: 1,
                                      color: context.theme.text2Color,
                                    )
                                  : Container()
                            ],
                          ),
                        );
                      }),
                ),
                Expanded(
                  flex: 2,
                  child: ValueListenableBuilder(
                      valueListenable: everyone,
                      builder: (context, value, _) {
                        return InkWell(
                          onTap: () {
                            all.value = false;
                            company.value = false;
                            everyone.value = true;
                            group.value = false;
                            index.value = 2;
                            searchCubit
                              ..getAllSearch(
                                  AuthRepo().userInfo!.id,
                                  'normal',
                                  controller.value.text,
                                  AuthRepo().userInfo!.companyId!);
                          },
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  AppLocalizations.of(context)?.people ??'',
                                  style: TextStyle(
                                      color: everyone.value == true
                                          ? context.theme.text2Color
                                          : context.theme.textSelectInSearch),
                                ),
                              ),
                              const Spacer(),
                              everyone.value == true
                                  ? Container(
                                      height: 1,
                                      color: context.theme.text2Color,
                                    )
                                  : Container()
                            ],
                          ),
                        );
                      }),
                ),
                Expanded(
                  flex: 2,
                  child: ValueListenableBuilder(
                      valueListenable: company,
                      builder: (context, value, _) {
                        return InkWell(
                          onTap: () {
                            all.value = false;
                            company.value = true;
                            everyone.value = false;
                            group.value = false;
                            index.value = 3;
                            searchCubit
                              ..getAllSearch(
                                  AuthRepo().userInfo!.id,
                                  'company',
                                  controller.value.text,
                                  AuthRepo().userInfo!.companyId!);
                          },
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  AppLocalizations.of(context)?.company ??'',
                                  style: TextStyle(
                                      color: company.value == true
                                          ? context.theme.text2Color
                                          : context.theme.textSelectInSearch),
                                ),
                              ),
                              const Spacer(),
                              company.value == true
                                  ? Container(
                                      height: 1,
                                      color: context.theme.text2Color,
                                    )
                                  : Container()
                            ],
                          ),
                        );
                      }),
                ),
                Expanded(
                  flex: 2,
                  child: ValueListenableBuilder(
                      valueListenable: group,
                      builder: (context, value, _) {
                        return InkWell(
                          onTap: () {
                            all.value = false;
                            company.value = false;
                            everyone.value = false;
                            group.value = true;
                            index.value = 4;
                            searchCubit
                              ..getAllSearch(
                                  AuthRepo().userInfo!.id,
                                  'group',
                                  controller.value.text,
                                  AuthRepo().userInfo!.companyId!);
                          },
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  AppLocalizations.of(context)?.group ??'',
                                  style: TextStyle(
                                      color: group.value == true
                                          ? context.theme.text2Color
                                          : context.theme.textSelectInSearch),
                                ),
                              ),
                              const Spacer(),
                              group.value == true
                                  ? Container(
                                      height: 1,
                                      color: context.theme.text2Color)
                                  : Container()
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
          ValueListenableBuilder(
            valueListenable: changeTheme,
            builder: (context, value, child) => ValueListenableBuilder(
                valueListenable: all,
                builder: (context, value, _) {
                  return ValueListenableBuilder(
                      valueListenable: everyone,
                      builder: (context, value, _) {
                        return ValueListenableBuilder(
                          valueListenable: company,
                          builder: (context, value, _) {
                            return ValueListenableBuilder(
                                valueListenable: group,
                                builder: (context, value, _) {
                                  return all.value == true
                                      ? SingleChildScrollView(
                                          child: BlocBuilder(
                                              bloc: searchCubit,
                                              builder: (context, state) {
                                                if (state
                                                    is SearchAllLoadedState) {
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      state.listUserComp
                                                                  .length >
                                                              0
                                                          ? Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: Text(
                                                                AppLocalizations.of(context)?.company ??'',
                                                                style: TextStyle(
                                                                    color: context
                                                                        .theme
                                                                        .text2Color,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      ListUser(
                                                        listUser:
                                                            state.listUserComp,
                                                        check: false,
                                                        userRequestBloc:
                                                            userRequestBloc,
                                                      ),
                                                      state.listUserComp
                                                                  .length >
                                                              5
                                                          ? Row(
                                                              children: [
                                                                const Spacer(),
                                                                InkWell(
                                                                  onTap: () {
                                                                    all.value =
                                                                        false;
                                                                    company.value =
                                                                        true;
                                                                    everyone.value =
                                                                        false;
                                                                    group.value =
                                                                        false;
                                                                    index.value =
                                                                        3;
                                                                    searchCubit
                                                                      ..getAllSearch(
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .id,
                                                                          'company',
                                                                          controller
                                                                              .value
                                                                              .text,
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .companyId!);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10,
                                                                        top:
                                                                            10),
                                                                    child: Text(
                                                                      AppLocalizations.of(context)
                                                                              ?.seeMore ??
                                                                          '',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: context
                                                                              .theme
                                                                              .colorPirimaryNoDarkLight),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            )
                                                          : const SizedBox(),
                                                      state.listGroup.length > 0
                                                          ? Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: Text(
                                                                AppLocalizations.of(context)?.group??'',
                                                                style: TextStyle(
                                                                    color: context
                                                                        .theme
                                                                        .textColor,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      ListGroup(
                                                        listGroup:
                                                            state.listGroup,
                                                        check: false,
                                                      ),
                                                      state.listGroup.length > 5
                                                          ? Row(
                                                              children: [
                                                                const SizedBox(),
                                                                const Spacer(),
                                                                InkWell(
                                                                  onTap: () {
                                                                    all.value =
                                                                        false;
                                                                    company.value =
                                                                        false;
                                                                    everyone.value =
                                                                        false;
                                                                    group.value =
                                                                        true;
                                                                    index.value =
                                                                        4;
                                                                    searchCubit
                                                                      ..getAllSearch(
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .id,
                                                                          'group',
                                                                          controller
                                                                              .value
                                                                              .text,
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .companyId!);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10,
                                                                        top:
                                                                            10),
                                                                    child: Text(
                                                                      AppLocalizations.of(context)?.seeMore??'',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: context
                                                                              .theme
                                                                              .colorPirimaryNoDarkLight),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            )
                                                          : const SizedBox(),
                                                      state.listEveryone
                                                                  .length >
                                                              0
                                                          ? Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: Text(
                                                                AppLocalizations.of(context)?.people??'',
                                                                style: TextStyle(
                                                                    color: context
                                                                        .theme
                                                                        .textColor,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      ListUser(
                                                        listUser:
                                                            state.listEveryone,
                                                        check: false,
                                                        userRequestBloc:
                                                            userRequestBloc,
                                                      ),
                                                      state.listEveryone
                                                                  .length >
                                                              5
                                                          ? Row(
                                                              children: [
                                                                const SizedBox(),
                                                                const Spacer(),
                                                                InkWell(
                                                                  onTap: () {
                                                                    all.value =
                                                                        false;
                                                                    company.value =
                                                                        false;
                                                                    everyone.value =
                                                                        true;
                                                                    group.value =
                                                                        false;
                                                                    index.value =
                                                                        2;
                                                                    searchCubit
                                                                      ..getAllSearch(
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .id,
                                                                          'normal',
                                                                          controller
                                                                              .value
                                                                              .text,
                                                                          AuthRepo()
                                                                              .userInfo!
                                                                              .companyId!);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10,
                                                                        top:
                                                                            10),
                                                                    child: Text(
                                                                      AppLocalizations.of(context)?.seeMore??'',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: context
                                                                              .theme
                                                                              .colorPirimaryNoDarkLight),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  );
                                                } else {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                              }))
                                      : everyone.value == true
                                          ? Container(
                                              child: BlocBuilder(
                                                  bloc: searchCubit,
                                                  builder: (context, state) {
                                                    if (state
                                                        is EveryoneLoadedState) {
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          state.list.length > 0
                                                              ? Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                  child: Text(
                                                                    AppLocalizations.of(context)?.people??'',
                                                                    style: TextStyle(
                                                                        color: context
                                                                            .theme
                                                                            .text2Color,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                )
                                                              : const SizedBox(),
                                                          ListUser(
                                                            listUser:
                                                                state.list,
                                                            check: true,
                                                            userRequestBloc:
                                                                userRequestBloc,
                                                          ),
                                                        ],
                                                      );
                                                    } else {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    }
                                                  }),
                                            )
                                          : company.value == true
                                              ? Container(
                                                  child: BlocBuilder(
                                                    bloc: searchCubit,
                                                    builder: (context, state) {
                                                      if (state
                                                          is UserCompLoadedState) {
                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            state.list.length >
                                                                    0
                                                                ? Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            10),
                                                                    child: Text(
                                                                      AppLocalizations.of(context)?.company ??'',
                                                                      style: TextStyle(
                                                                          color: context
                                                                              .theme
                                                                              .text2Color,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  )
                                                                : const SizedBox(),
                                                            ListUser(
                                                              listUser:
                                                                  state.list,
                                                              check: true,
                                                              userRequestBloc:
                                                                  userRequestBloc,
                                                            ),
                                                          ],
                                                        );
                                                      } else {
                                                        return const Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                )
                                              : group.value == true
                                                  ? Container(
                                                      child: BlocBuilder(
                                                          bloc: searchCubit,
                                                          builder:
                                                              (context, state) {
                                                            if (state
                                                                is GroupLoadedState) {
                                                              return Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  state.list.length >
                                                                          0
                                                                      ? Container(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              10),
                                                                          child:
                                                                              Text(
                                                                            AppLocalizations.of(context)?.group??'',
                                                                            style: TextStyle(
                                                                                color: context.theme.text2Color,
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                        )
                                                                      : const SizedBox(),
                                                                  ListGroup(
                                                                    listGroup:
                                                                        state
                                                                            .list,
                                                                    check: true,
                                                                  ),
                                                                ],
                                                              );
                                                            } else {
                                                              return const Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              );
                                                            }
                                                          }),
                                                    )
                                                  : const SizedBox();
                                });
                          },
                        );
                      });
                }),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    ));
  }
}
