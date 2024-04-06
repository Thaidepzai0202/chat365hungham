import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/user_request_bloc/user_request_bloc.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/bloc/contact_bloc/contact_bloc.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/model/contact_model.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/model/list_account_model.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/widget_custom/form_new_friend.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/widget_custom/form_user.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/lib/section_view/sectionView.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/lib/section_view/sectionViewModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen(
      {super.key, required this.listContact, required this.listAccount});

  final List<ContactModel> listContact;
  final List<ListAccount> listAccount;

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  late ContactBloc contactBloc;
  late UserRequestBloc userRequestBloc;
  late AppLayoutCubit _appLayoutCubit;
  late ChatDetailBloc _chatDetailBloc;
  late TypingDetectorBloc _typingDetectorBloc;
  late final ChatConversationBloc _chatConversationBloc;
  List<ContactModel> listFriendOnline = [];
  List<AlphabetHeader<ContactModel>> filterMyContact = [];
  List<AlphabetHeader<ListAccount>> filterNewFriend = [];
  List<AlphabetHeader<ContactModel>> filterFriendOnline = [];

  _constructAlphabet(Iterable<ContactModel> data) {
    var myContact = convertListToAlphaHeader<ContactModel>(
        data, (item) => (item.userName).substring(0, 1).toUpperCase());
    setState(() {
      filterMyContact = myContact;
    });
  }

  void _showPopupMenu(BuildContext context, Offset position,
      {required Function() onTapDel}) {
    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
            position.dx, position.dy, position.dx + 1, position.dy + 1),
        items: [
          // PopupMenuItem(
          //   child: const Text('Thêm vào yêu thích'),
          //   onTap: () {},
          // ),
          // PopupMenuItem(
          //   child: const Text('Xem hồ sơ'),
          //   onTap: () {},
          // ),
          // PopupMenuItem(
          //   child: const Text('Chỉnh sửa liên hệ'),
          //   onTap: () {},
          // ),
          PopupMenuItem(
            child: const Text('Xoá liên hệ'),
            onTap: onTapDel,
          ),
        ]);
  }

  _constructAlphabetListNewFriend(Iterable<ListAccount> data) {
    var newFriend = convertListToAlphaHeader<ListAccount>(
        data, (item) => (item.userName).substring(0, 1).toUpperCase());
    setState(() {
      filterNewFriend = newFriend;
    });
  }

  _constructAlphabetListFriendOnline(Iterable<ContactModel> data) {
    listFriendOnline =
        List.from(widget.listContact.where((element) => element.active == 1));
    var friendOnline = convertListToAlphaHeader<ContactModel>(listFriendOnline,
        (item) => (item.userName).substring(0, 1).toUpperCase());
    setState(() {
      filterFriendOnline = friendOnline;
    });
  }

  @override
  void initState() {
    contactBloc = context.read<ContactBloc>();
    userRequestBloc = context.read<UserRequestBloc>();
    _constructAlphabet(widget.listContact);
    _constructAlphabetListNewFriend(widget.listAccount);
    _constructAlphabetListFriendOnline(widget.listContact);
    _appLayoutCubit = context.read<AppLayoutCubit>();
    _chatConversationBloc = context.read<ChatConversationBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String> typeContact =
        ValueNotifier(AppLocalizations.of(context)?.newFriend ??'' );
    return Container(
        color: context.theme.backgroundListChat,
        child: ListView(children: [
          Container(
            padding: const EdgeInsets.all(13),
            child: InkWell(
              onTap: () async {
                await userRequestBloc.takeListRequest(
                    AuthRepo().userInfo!.id, AuthRepo().userInfo!.companyId!);
                _appLayoutCubit.toMainLayout(AppMainPages.requestPages);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 64),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: context.theme.hitnTextColorInputBar),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: context.theme.chatInputBarColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Images.ic_fluent_people_add,
                      width: 20,
                      height: 20,
                      color: context.theme.hitnTextColorInputBar,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(AppLocalizations.of(context)?.friendRequest ?? '',
                        style: TextStyle(
                          color: context.theme.hitnTextColorInputBar,
                          fontSize: 14,
                        ))
                  ],
                ),
              ),
            ),
          ),
          ValueListenableBuilder(
              valueListenable: typeContact,
              builder: (_, __, ___) => Row(children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        typeContact.value,
                        style: TextStyle(
                            color: context.theme.text2Color,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: context.theme.backgroundChatContent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      icon: SvgPicture.asset(
                        AssetPath.drop_button_down,
                        height: 14,
                        width: 14,
                        color: context.theme.text2Color,
                      ),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          height: 30,
                          child: Text(
                            AppLocalizations.of(context)?.newFriend ??"" ,
                            style: TextStyle(
                                fontSize: 12,
                                color: context.theme
                                    .text2Color), // Điều chỉnh font size ở đây
                          ),
                          onTap: () async {
                            typeContact.value = AppLocalizations.of(context)!.newFriend ;
                            // await contactBloc.getListNewFriend();
                          },
                        ),
                        PopupMenuItem<String>(
                          height: 30,
                          child: Text(
                            AppLocalizations.of(context)?.myContacts ??"" ,
                            style: TextStyle(
                                fontSize: 12,
                                color: context.theme
                                    .text2Color), // Điều chỉnh font size ở đây
                          ),
                          onTap: () async {
                            typeContact.value = AppLocalizations.of(context)!.myContacts ;
                            // await contactBloc.takeMyContact();
                          },
                        ),
                        PopupMenuItem<String>(
                          height: 30,
                          child: Text(
                            AppLocalizations.of(context)?.recentlyOlFriend ??'',
                            style: TextStyle(
                                fontSize: 12,
                                color: context.theme
                                    .text2Color), // Điều chỉnh font size ở đây
                          ),
                          onTap: () {
                            typeContact.value = AppLocalizations.of(context)!.recentlyOlFriend ;
                          },
                        ),
                      ],
                    ),
                  ])),
          ValueListenableBuilder(
              valueListenable: typeContact,
              builder: (_, __, ___) => SizedBox(
                  height: MediaQuery.of(context).size.height - 270,
                  width: 326,
                  child: typeContact.value == AppLocalizations.of(context)?.myContacts
                      ? SectionView<AlphabetHeader<ContactModel>, ContactModel>(
                          source: filterMyContact,
                          onFetchListData: (header) => header.items,
                          enableSticky: true,
                          alphabetAlign: Alignment.center,
                          alphabetInset: const EdgeInsets.all(4.0),
                          headerBuilder: getDefaultHeaderBuilder(
                              (d) => d.alphabet,
                              bkColor: context.theme.abcfriendBoxColor,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: context.theme.text2Color)),
                          alphabetBuilder:
                              getDefaultAlphabetBuilder((d) => d.alphabet),
                          tipBuilder: getDefaultTipBuilder((d) => d.alphabet),
                          itemBuilder: (BuildContext context,
                              ContactModel itemData,
                              int itemIndex,
                              AlphabetHeader<ContactModel> headerData,
                              int headerIndex) {
                            return InkWell(
                              onSecondaryTapUp: (TapUpDetails details) {
                                // Gọi hàm hiển thị menu tại vị trí được nhấn
                                _showPopupMenu(context, details.globalPosition,
                                    onTapDel: () async {
                                  contactBloc.deleteContact(itemData.id);
                                });
                              },
                              child: FormUserContainer(
                                  contactModel: itemData,
                                  onTap: () async {
                                    var conversationId = await context
                                        .read<ChatBloc>()
                                        .getConversationId(
                                            AuthRepo().userInfo!.id,
                                            itemData.id);
                                    var chatItemModel = await ChatRepo()
                                        .getChatItemModel(conversationId);
                                    var userInfoBloc =
                                        UserInfoBloc.fromConversation(
                                      chatItemModel!.conversationBasicInfo,
                                      status: chatItemModel.status,
                                    );
                                    _typingDetectorBloc = _chatConversationBloc
                                            .typingBlocs[conversationId] ??
                                        TypingDetectorBloc(conversationId);

                                    _chatDetailBloc = ChatDetailBloc(
                                        conversationId: conversationId,
                                        senderId: context.userInfo().id,
                                        // userInfoRepo:
                                        //     context.read<UserInfoRepo>(),
                                        // chatRepo: context.read<ChatRepo>(),
                                        isGroup: false,
                                        initMemberHasNickname: [
                                          userInfoBloc.userInfo
                                        ],
                                        messageDisplay: -1,
                                        chatItemModel: chatItemModel,
                                        unreadMessageCounterCubit:
                                            UnreadMessageCounterCubit(
                                          conversationId: conversationId,
                                          countUnreadMessage: 0,
                                        ),
                                        // _unreadMessageCounterCubit,
                                        deleteTime: -1,
                                        otherDeleteTime: chatItemModel
                                                .firstOtherMember(
                                                    context.userInfo().id)
                                                .deleteTime ??
                                            -1,
                                        myDeleteTime: -1,
                                        messageId: '',
                                        typeGroup: chatItemModel!.typeGroup)
                                      ..add(
                                          const ChatDetailEventLoadConversationDetail())
                                      ..getDetailInfo(
                                          uInfo: userInfoBloc.userInfo)
                                      ..conversationName.value = chatItemModel
                                          .conversationBasicInfo.name;
                                    _appLayoutCubit.toMainLayout(
                                        AppMainPages.chatScreen,
                                        providers: [
                                          BlocProvider<UserInfoBloc>(
                                              create: (context) =>
                                                  userInfoBloc),
                                          BlocProvider<
                                                  TypingDetectorBloc>.value(
                                              value: _typingDetectorBloc),
                                        ],
                                        agruments: {
                                          'chatType': ChatType.SOLO,
                                          'conversationId': conversationId,
                                          'senderId': context.userInfo().id,
                                          'chatItemModel': chatItemModel,
                                          'name': chatItemModel
                                              .conversationBasicInfo.name,
                                          'chatDetailBloc': _chatDetailBloc,
                                          'messageDisplay': -1,
                                        });
                                  }),
                            );
                          })
                      : typeContact.value == AppLocalizations.of(context)?.newFriend
                          ? SectionView<AlphabetHeader<ListAccount>,
                                  ListAccount>(
                              source: filterNewFriend,
                              onFetchListData: (header) => header.items,
                              enableSticky: true,
                              alphabetAlign: Alignment.center,
                              alphabetInset: const EdgeInsets.all(4.0),
                              headerBuilder: getDefaultHeaderBuilder(
                                  (d) => d.alphabet,
                                  bkColor: context.theme.abcfriendBoxColor,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: context.theme.text2Color)),
                              alphabetBuilder:
                                  getDefaultAlphabetBuilder((d) => d.alphabet),
                              tipBuilder:
                                  getDefaultTipBuilder((d) => d.alphabet),
                              itemBuilder: (BuildContext context,
                                  ListAccount itemData,
                                  int itemIndex,
                                  AlphabetHeader<ListAccount> headerData,
                                  int headerIndex) {
                                return InkWell(
                                    onSecondaryTapUp: (TapUpDetails details) {
                                      // Gọi hàm hiển thị menu tại vị trí được nhấn
                                      _showPopupMenu(
                                          context, details.globalPosition,
                                          onTapDel: () async {
                                        contactBloc.deleteContact(itemData.id);
                                      });
                                    },
                                    child: FormNewFriend(
                                        listAccount: itemData,
                                        onTap: () async {
                                          var conversationId = await context
                                              .read<ChatBloc>()
                                              .getConversationId(
                                                  AuthRepo().userInfo!.id,
                                                  itemData.id);
                                          var chatItemModel = await ChatRepo()
                                              .getChatItemModel(conversationId);
                                          var userInfoBloc =
                                              UserInfoBloc.fromConversation(
                                            chatItemModel!
                                                .conversationBasicInfo,
                                            status: chatItemModel.status,
                                          );
                                          _typingDetectorBloc =
                                              _chatConversationBloc.typingBlocs[
                                                      conversationId] ??
                                                  TypingDetectorBloc(
                                                      conversationId);

                                          _chatDetailBloc = ChatDetailBloc(
                                              conversationId: conversationId,
                                              senderId: context.userInfo().id,
                                              // userInfoRepo:
                                              //     context.read<UserInfoRepo>(),
                                              // chatRepo:
                                              //     context.read<ChatRepo>(),
                                              isGroup: false,
                                              initMemberHasNickname: [
                                                userInfoBloc.userInfo
                                              ],
                                              messageDisplay: -1,
                                              chatItemModel: chatItemModel,
                                              unreadMessageCounterCubit:
                                                  UnreadMessageCounterCubit(
                                                conversationId: conversationId,
                                                countUnreadMessage: 0,
                                              ),
                                              // _unreadMessageCounterCubit,
                                              deleteTime: -1,
                                              otherDeleteTime: chatItemModel
                                                      ?.firstOtherMember(
                                                          context.userInfo().id)
                                                      .deleteTime ??
                                                  -1,
                                              myDeleteTime: -1,
                                              messageId: '',
                                              typeGroup:
                                                  chatItemModel!.typeGroup)
                                            ..add(
                                                const ChatDetailEventLoadConversationDetail())
                                            ..getDetailInfo(
                                                uInfo: userInfoBloc.userInfo)
                                            ..conversationName.value =
                                                chatItemModel
                                                    .conversationBasicInfo.name;
                                          _appLayoutCubit.toMainLayout(
                                              AppMainPages.chatScreen,
                                              providers: [
                                                BlocProvider<UserInfoBloc>(
                                                    create: (context) =>
                                                        userInfoBloc),
                                                BlocProvider<
                                                        TypingDetectorBloc>.value(
                                                    value: _typingDetectorBloc),
                                                BlocProvider<
                                                        UnreadMessageCounterCubit>.value(
                                                    value: _chatConversationBloc
                                                            .unreadMessageCounterCubits[
                                                        conversationId] ?? UnreadMessageCounterCubit(conversationId: conversationId, countUnreadMessage: 0)),
                                              ],
                                              agruments: {
                                                'chatType': ChatType.SOLO,
                                                'conversationId':
                                                    conversationId,
                                                'senderId':
                                                    context.userInfo().id,
                                                'chatItemModel': chatItemModel,
                                                'name': chatItemModel
                                                    .conversationBasicInfo.name,
                                                'chatDetailBloc':
                                                    _chatDetailBloc,
                                                'messageDisplay': -1,
                                              });
                                        }));
                              })
                          : SectionView<AlphabetHeader<ContactModel>,
                                  ContactModel>(
                              source: filterFriendOnline,
                              onFetchListData: (header) => header.items,
                              enableSticky: true,
                              alphabetAlign: Alignment.center,
                              alphabetInset: const EdgeInsets.all(4.0),
                              headerBuilder: getDefaultHeaderBuilder(
                                  (d) => d.alphabet,
                                  bkColor: context.theme.abcfriendBoxColor,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: context.theme.text2Color)),
                              alphabetBuilder:
                                  getDefaultAlphabetBuilder((d) => d.alphabet),
                              tipBuilder:
                                  getDefaultTipBuilder((d) => d.alphabet),
                              itemBuilder: (BuildContext context,
                                  ContactModel itemData,
                                  int itemIndex,
                                  AlphabetHeader<ContactModel> headerData,
                                  int headerIndex) {
                                return FormUserContainer(
                                    contactModel: itemData,
                                    onTap: () async {
                                      var conversationId = await context
                                          .read<ChatBloc>()
                                          .getConversationId(
                                              AuthRepo().userInfo!.id,
                                              itemData.id);
                                      print(
                                          '_________${conversationId.toString()}');
                                      var chatItemModel = await ChatRepo()
                                          .getChatItemModel(conversationId);
                                      var userInfoBloc =
                                          UserInfoBloc.fromConversation(
                                        chatItemModel!.conversationBasicInfo,
                                        status: chatItemModel.status,
                                      );
                                      _typingDetectorBloc =
                                          _chatConversationBloc.typingBlocs[
                                                  conversationId] ??
                                              TypingDetectorBloc(
                                                  conversationId);

                                      _chatDetailBloc = ChatDetailBloc(
                                          conversationId: conversationId,
                                          senderId: context.userInfo().id,
                                          // userInfoRepo:
                                          //     context.read<UserInfoRepo>(),
                                          // chatRepo: context.read<ChatRepo>(),
                                          isGroup: false,
                                          initMemberHasNickname: [
                                            userInfoBloc.userInfo
                                          ],
                                          messageDisplay: -1,
                                          chatItemModel: chatItemModel,
                                          unreadMessageCounterCubit:
                                              UnreadMessageCounterCubit(
                                            conversationId: conversationId,
                                            countUnreadMessage: 0,
                                          ),
                                          // _unreadMessageCounterCubit,
                                          deleteTime: -1,
                                          otherDeleteTime: chatItemModel
                                                  ?.firstOtherMember(
                                                      context.userInfo().id)
                                                  .deleteTime ??
                                              -1,
                                          myDeleteTime: -1,
                                          messageId: '',
                                          typeGroup: chatItemModel!.typeGroup)
                                        ..add(
                                            const ChatDetailEventLoadConversationDetail())
                                        ..getDetailInfo(
                                            uInfo: userInfoBloc.userInfo)
                                        ..conversationName.value = chatItemModel
                                            .conversationBasicInfo.name;
                                      _appLayoutCubit.toMainLayout(
                                          AppMainPages.chatScreen,
                                          providers: [
                                            BlocProvider<UserInfoBloc>(
                                                create: (context) =>
                                                    userInfoBloc),
                                            BlocProvider<
                                                    TypingDetectorBloc>.value(
                                                value: _typingDetectorBloc),
                                          ],
                                          agruments: {
                                            'chatType': ChatType.SOLO,
                                            'conversationId': conversationId,
                                            'senderId': context.userInfo().id,
                                            'chatItemModel': chatItemModel,
                                            'name': chatItemModel
                                                .conversationBasicInfo.name,
                                            'chatDetailBloc': _chatDetailBloc,
                                            'messageDisplay': -1,
                                          });
                                    });
                              }))),
        ]));
  }
}
