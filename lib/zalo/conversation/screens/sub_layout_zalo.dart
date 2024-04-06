import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_box_names.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_service.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/zalo/clients/chat_client_zalo.dart';
import 'package:app_chat365_pc/zalo/conversation/one_account.dart';
import 'package:app_chat365_pc/zalo/features_zalo/add_friend_zalo/add_friend_zalo_screen.dart';
import 'package:app_chat365_pc/zalo/features_zalo/send_message/send_message_to_stranger_screen.dart';
import 'package:app_chat365_pc/zalo/models/conversation_item_model.dart';
import 'package:app_chat365_pc/zalo/models/friend_zalo_model.dart';
import 'package:app_chat365_pc/zalo/models/user_model_zalo.dart';
import 'package:app_chat365_pc/zalo/zalo_qr/login_cubit_zalo/login_cubit_zalo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

class AppSubLayoutZalo extends StatefulWidget {
  AppSubLayoutZalo({super.key, required this.userInfoZalo});

  UserInfoZalo userInfoZalo;

  @override
  State<AppSubLayoutZalo> createState() => _AppSubLayoutZaloState();
}

class _AppSubLayoutZaloState extends State<AppSubLayoutZalo> {
  List<FriendZalo> _listFriendZalo = [];
  late final LoginCubitZalo _loginCubitZalo;
  ValueNotifier<List<ConversationItemZaloModel>> _listConversationZalo =
      ValueNotifier([]);
  ValueNotifier<bool> isSearch = ValueNotifier(false);
  ValueNotifier<bool> isStranger = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    makeListFriendZalo();
    makeListAccount();
    _loginCubitZalo = context.read<LoginCubitZalo>();
    _loginCubitZalo.getDataConversation();

    chatClientZalo.stream.listen((event) {
      if (event is UpdateListZalo) {
        _listFriendZalo = event.listFriend;
        print(
            '--------------freind have ${event.listFriend.length} ----------');
        HiveService().saveFriendZaloList('000000', _listFriendZalo);
      } else if (event is ListConversationZalo) {
        print(
            '--------list-chat--------${event.listConversationZalo.toString()}');
        _listConversationZalo.value = event.listConversationZalo;
      } else {
        print('vainho------${event.toString()}');
      }
    });
  }

  makeListFriendZalo() async {
    var box = await Hive.openBox(HiveBoxNames.locallySavedFriendZaloList);
    var check = box.get('000000');
    List<FriendZalo> allFriend = [];
    check!.forEach((element) {
      allFriend.add(element);
      // print(element.name);
    });
    print('done save firendlist for zalo------${check.length}');
    _listFriendZalo = allFriend;
  }

  makeListAccount() async {
    var box = await Hive.openBox(HiveBoxNames.saveListAccountZalo);
    var check = box.get(AuthRepo().userInfo!.id.toString());
    List<UserInfoZalo> allAccount = [];
    if (check.length >= 1) {
      check!.forEach((element) {
        allAccount.add(element);
      });
    }
    print(
        '--------------------Done get account Zalo-----------------------------');
    listUserInfoZalo = allAccount;
  }

  @override
  void dispose() {
    super.dispose();
    _loginCubitZalo.close();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isStranger,
      builder: (context, value, child) => ValueListenableBuilder(
        valueListenable: isSearch,
        builder: (context, value, child) => ValueListenableBuilder(
            valueListenable: changeTheme,
            builder: (context, value, child) => Container(
                height: MediaQuery.of(context).size.height - 42,
                width: 326,
                color: context.theme.backgroundListChat,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          var box = await Hive.openBox(
                              HiveBoxNames.saveListAccountZalo);
                          box.put(AuthRepo().userInfo!.id.toString(), []);
                          listUserInfoZalo = [];
                        },
                        child: Container(
                          child: Text('delete list Accout'),
                          color: AppColors.red,
                        ),
                      ),
                      // for (int i = 0; i < listUserInfoZalo.length; i++)
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: listUserInfoZalo.length ,
                          itemBuilder: (context, index) {
                            return ValueListenableBuilder(
                              valueListenable: _listConversationZalo,
                              builder: (context, value, child) =>
                                  OneAccountZaloScreen(
                                      listConversationZalo:
                                          _listConversationZalo.value,
                                      listFriendZalo: _listFriendZalo,
                                      userInfoZalo: listUserInfoZalo[index]),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ))),
      ),
    );
  }
}
