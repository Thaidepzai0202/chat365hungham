import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:side_navigation/side_navigation.dart';

enum SideBarItemType {
  message,
  contact,
  feature,
  phone,
  notification,
  addFriend,
  markMessage,
  news,
  meeting,
  profile,
  personalStorage,
}

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late final ChatBloc chatBloc;
  late List<Widget> _items;
  late int selectedIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatBloc = context.read<ChatBloc>();
    selectedIndex = 0;
  }

  itemSideBar(
    String svg,
    SideBarItemType type, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      child: SvgPicture.asset(
        svg,
        width: 20,
        height: 20,
        color: AppColors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _items = [
      itemSideBar(AssetPath.chat, SideBarItemType.message),
      itemSideBar(AssetPath.contact, SideBarItemType.contact),
      itemSideBar(AssetPath.ic_utilities_outline, SideBarItemType.feature),
      itemSideBar(AssetPath.phone, SideBarItemType.phone),
      itemSideBar(AssetPath.bell, SideBarItemType.notification),
      Spacer(),
      itemSideBar(AssetPath.add_friend, SideBarItemType.addFriend),
      itemSideBar(AssetPath.massage_tick, SideBarItemType.markMessage),
      itemSideBar(AssetPath.news, SideBarItemType.news),
      itemSideBar(AssetPath.video, SideBarItemType.meeting),
      itemSideBar(AssetPath.clound, SideBarItemType.personalStorage),
    ];
    final current = Container(
      height: MediaQuery.of(context).size.height,
      width: 56,
      color: AppColors.indigo,
      child: Column(
        children: [
          SizedBoxExt.h40,
          ..._items,
          SizedBoxExt.h40,
        ],
      ),
    );
    return MultiBlocProvider(providers: [
      BlocProvider<ChatBloc>.value(value: chatBloc),
    ], child: current);
  }
}
