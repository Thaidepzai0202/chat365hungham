import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/bloc/contact_bloc/contact_bloc.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/bloc/contact_bloc/contact_state.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/screen/friend_screen.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PhoneBookScreen extends StatefulWidget {
  const PhoneBookScreen({super.key});

  @override
  State<PhoneBookScreen> createState() => _PhoneBookScreenState();
}

class _PhoneBookScreenState extends State<PhoneBookScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late ContactBloc contactBloc;
  // late ConversationGroupBloc conversationGroupBloc;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    contactBloc = context.read<ContactBloc>();
    contactBloc.takeMyContact();
    // conversationGroupBloc = context.read<ConversationGroupBloc>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) {
        return SizedBox(
          height: MediaQuery.of(context).size.height - 170,
          width: 326,
          child: DefaultTabController(
              initialIndex: 1,
              length: 2,
              child: Scaffold(
                backgroundColor: context.theme.backgroundListChat,
                  appBar: AppBar(
                    backgroundColor: context.theme.backgroundColor,
                    title: Text(
                      AppLocalizations.of(context)?.friend ??'',
                      style: TextStyle(color: context.theme.text2Color),
                    ),
                    // toolbarHeight: 0,
                    automaticallyImplyLeading: false,
                    // bottom: TabBar(
                    //   indicatorColor: AppColors.indigo,
                    //   controller: _tabController,
                    //   tabs: const <Widget>[
                    //     Tab(
                    //       text: 'Bạn bè',
                    //     ),
                    //     Tab(
                    //       text: 'Nhóm',
                    //     ),
                    //   ],
                    // ),
                  ),
                  body: BlocBuilder(
                    bloc: contactBloc,
                    // buildWhen: (previous, current) =>  current is LoadedContactState,
                    builder: (context, state) {
                      if (state is LoadedContactState) {
                        var listContact = state.listMyContact ?? [];
                        listContact
                            .sort((a, b) => (a.userName).compareTo(b.userName));
                        state.listAccount?.sort(
                            (a, b) => (a.userName).compareTo(b.userName));
                        return FriendScreen(
                          listContact: listContact,
                          listAccount: state.listAccount ?? [],
                        );
                      } else {
                        return Center(
                              child: CircularProgressIndicator(
                                backgroundColor:
                                    context.theme.backgroundListChat,
                                valueColor: AlwaysStoppedAnimation(
                                    context.theme.colorPirimaryNoDarkLight),
                              ),
                            );
                        // ValueListenableBuilder(
                        //   valueListenable: changeTheme,
                        //   builder: (context, value, child) {
                        //     return Center(
                        //       child: CircularProgressIndicator(
                        //         backgroundColor:
                        //             context.theme.backgroundListChat,
                        //         valueColor: AlwaysStoppedAnimation(
                        //             context.theme.colorPirimaryNoDarkLight),
                        //       ),
                        //     );
                        //   },
                        // );
                      }
                    },
                  ))),
        );
      },
    );
  }
}
