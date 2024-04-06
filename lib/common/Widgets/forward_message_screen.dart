import 'dart:convert';

import 'package:app_chat365_pc/common/Widgets/confirm_dialog.dart';
import 'package:app_chat365_pc/common/Widgets/ellipsized_text.dart';
import 'package:app_chat365_pc/common/Widgets/forward_listview_builder.dart';
import 'package:app_chat365_pc/common/Widgets/send_message_search_forward.dart';
import 'package:app_chat365_pc/common/Widgets/user_list_tile.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/friend_cubit/cubit/friend_cubit.dart';
import 'package:app_chat365_pc/common/blocs/theme_cubit/theme_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/api_contact.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/message_box.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/contact/cubit/contact_list_cubit.dart';
import 'package:app_chat365_pc/modules/contact/cubit/contact_list_state.dart';
import 'package:app_chat365_pc/modules/contact/model/filter_contact_by.dart';
import 'package:app_chat365_pc/modules/contact/repo/contact_list_repo.dart';
import 'package:app_chat365_pc/modules/debouncer/text_editing_controller_debouncer.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/chat_feature_action.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:sp_util/sp_util.dart';

class ForwardMessageScreen extends StatefulWidget {
  ForwardMessageScreen({
    Key? key,
    this.itemBuilder,
    required this.message,
    required this.senderInfo,
    this.isShare = false,
    this.keyword = '',
  }) : super(key: key);
  final Widget Function(ConversationBasicInfo, String)? itemBuilder;

  // static const String messageArg = 'messageArg';
  // static const String senderInfoArg = 'senderInfoArg';
  final bool isShare;
  final String? keyword;

  final SocketSentMessageModel message;

  /// Thông tin của chủ tin nhắn đang forward
  final IUserInfo senderInfo;

  @override
  State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  late final ChatConversationBloc _chatConversationBloc;
  final ValueNotifier<String> _newMessage = ValueNotifier('');
  final TextEditingController _controller = TextEditingController();
  List<String> listKeySearch = [];
  List<ApiContact> listMember = [];
  List<ApiContact> listContact = [];
  late final IUserInfo _currentUser;
  late final ChatBloc _chatBloc;
  Map<int, DialogState> _buttons = {};
  var _list;
  late SocketSentMessageModel _originMessage;
  late final IUserInfo _senderInfo;
  final ValueNotifier<DialogState> _state = ValueNotifier(DialogState.init);
  late final TextEditingControllerDebouncer _debouncer;
  late ContactListCubit searchContactCubits;

  @override
  void initState() {
    // TODO: implement initState
    _chatBloc = context.read<ChatBloc>();
    _currentUser = context.userInfo();

    searchContactCubits = ContactListCubit(
        ContactListRepo(
          AuthRepo().userInfo!.id,
          companyId: AuthRepo().userInfo!.companyId!,
        ),
        initFilter: FilterContactsBy.conversations,
        fromSource: 'ForWardMessageScreen');

    _chatConversationBloc = context.read<ChatConversationBloc>();
    _controller.text = widget.keyword ?? '';
    _debouncer = TextEditingControllerDebouncer(
      () => searchContactCubits.searchAll(_controller.text),
      controller: _controller,
    );
    //list conversation
    _list = _chatConversationBloc.chats
        .map(
          (e) => e.conversationBasicInfo,
        )
        .toList();
    _originMessage = widget.message;
    _senderInfo = widget.senderInfo;
    if (widget.message.type == MessageType.document) {
      _newMessage.value = widget.message.message!;
      _originMessage = _originMessage.copyWith(
        infoLink: InfoLink(
          link: _originMessage.linkNotification,
          haveImage: false,
        ),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _debouncer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_originMessage.type?.isSpecialType == true) {
      _newMessage.value = _originMessage.message ?? '';
    }
    var listUserInfoBlocs = <int, UserInfoBloc>{};
    var quoteIcon = SvgPicture.asset(
      Images.ic_quote,
      // color: AppColors.white,
      color: context.theme.textColor,
      height: 16,
      width: 18,
    );
    return AlertDialog(
      backgroundColor: context.theme.backgroundColor,
      actionsAlignment: MainAxisAlignment.center,
      contentPadding: EdgeInsets.zero,
      content: BlocProvider.value(
        value: searchContactCubits,
        child: BlocConsumer<ContactListCubit, ContactListState>(
          listener: (_, state) {
            if (state is LoadingState) {
              _state.value = DialogState.processing;
            } else if (state is LoadSuccessState)
              _state.value = DialogState.success;
            else
              _state.value = DialogState.init;
          },
          buildWhen: (_, current) => current is LoadSuccessState,
          builder: (context, state) {
            if (state is LoadSuccessState) {
              logger.log(state.allContact[FilterContactsBy.none],
                  name: 'deo co gi');
              logger.log(state.allContact[FilterContactsBy.myContacts],
                  name: 'lh cua toi');
              logger.log(state.allContact[FilterContactsBy.allInCompany],
                  name: 'ttrong cong ty');
              logger.log(state.allContact[FilterContactsBy.conversations],
                  name: 'cuoc tro chuyen');

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: context.theme.backgroundColor,
                ),
                height: AppDimens.heightPC / 1.5,
                width: AppDimens.widthPC / 2,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                          // color: AppColors.indigo,
                          gradient: context.theme.gradient,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            StringConst.forward,
                            style: AppTextStyles.forwardText,
                          ),
                          InkWell(
                            onTap: () {
                              AppRouter.back(context);
                            },
                            child: SvgPicture.asset(Images.ic_close_PC),
                          )
                        ],
                      ),
                    ),
                    SizedBoxExt.h10,
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: context.theme.backgroundOnForward,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                quoteIcon,
                                SizedBoxExt.w10,
                                Expanded(
                                  child: _originMessage.type?.isText == true
                                      ? EllipsizedText(
                                          _originMessage.hasRelyMessage
                                              ? _originMessage
                                                  .relyMessage!.message!
                                              : _originMessage.message ?? '',
                                          maxLines: 3,
                                          style: context.theme.messageTextStyle,
                                        )
                                      : AbsorbPointer(
                                          absorbing: true,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: MessageBox(
                                              hasReplyMessage: false,
                                              messageModel: _originMessage,
                                              isSentByCurrentUser: false,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              listUserInfoBlocs:
                                                  listUserInfoBlocs,
                                              emotionBarSize: ValueNotifier(0),
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 20,
                              thickness: 1,
                              color: context.theme.text2Color,
                            ),
                            // từ từ thì xử lý
                            // const TextField(
                            //   decoration: InputDecoration.collapsed(
                            //       hintText: StringConst.inputMessage,
                            //       hintStyle: TextStyle(color: AppColors.white)),
                            // )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: SendMessageSearchForward(
                        controller: _controller,
                        onSubmit: searchContactCubits.searchAll,
                        stateNotifier: _state,
                      ),

                      // child: NavigatorSearchField(onNavigate: () {}),
                    ),
                    Expanded(
                        child: _controller.text == ''
                            ? SendMessageListConversationBuilder(
                                list: _list,
                                apiMessageModelBuilder: (item) {
                                  return _msgModel(item);
                                },
                                sendIds: _buttons,
                                message: _originMessage,
                                newMessage: widget.isShare == true
                                    ? ValueNotifier(
                                        widget.message.message ?? '')
                                    : ValueNotifier(''),
                              )
                            : CustomScrollView(
                                physics: BouncingScrollPhysics(),
                                slivers: [
                                  if (_controller.text != '')
                                    _groupBuilder(
                                      state.allContact[
                                              FilterContactsBy.allInCompany] ??
                                          [],
                                      _buttons,
                                      _originMessage,
                                      widget.isShare == true
                                          ? ValueNotifier(
                                              widget.message.message ?? '')
                                          : ValueNotifier(''),
                                      (item) {
                                        return _msgModel(item);
                                      },
                                      header: FilterContactsBy.allInCompany
                                          .searchContactHeaderDisplayName,
                                      filter: FilterContactsBy.allInCompany,
                                    ),
                                  if (_controller.text != '')
                                    _groupBuilder(
                                      state.allContact[
                                              FilterContactsBy.conversations] ??
                                          [],
                                      _buttons,
                                      _originMessage,
                                      widget.isShare == true
                                          ? ValueNotifier(
                                              widget.message.message ?? '')
                                          : ValueNotifier(''),
                                      (item) {
                                        return _msgModel(item);
                                      },
                                      header: FilterContactsBy.conversations
                                          .searchContactHeaderDisplayName,
                                      filter: FilterContactsBy.conversations,
                                    ),
                                  _controller.text == ''
                                      ? SizedBoxExt.shrink
                                      : _groupBuilder(
                                          state.allContact[
                                                  FilterContactsBy.none] ??
                                              [],
                                          _buttons,
                                          _originMessage,
                                          widget.isShare == true
                                              ? ValueNotifier(
                                                  widget.message.message ?? '')
                                              : ValueNotifier(''),
                                          (item) {
                                            return _msgModel(item);
                                          },
                                          header: FilterContactsBy.none
                                              .searchContactHeaderDisplayName,
                                          filter: FilterContactsBy.none,
                                        ),
                                  SliverToBoxAdapter(
                                    child: SizedBox(height: 80),
                                  )
                                ],
                              )),
                  ],
                ),
              );
            }

            return SizedBox();
          },
        ),
      ),
      actions: [
        InkWell(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          onTap: () {
            AppRouter.back(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 30),
            decoration: BoxDecoration(
                gradient: context.theme.gradient,
                borderRadius: BorderRadius.circular(20)),
            child: const Text(
              'Xong',
              style: TextStyle(
                  color: AppColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500),
            ),
          ),
        )
      ],
    );
  }

  _groupBuilder(
    List<ConversationBasicInfo> users,
    Map<int, DialogState> sendIds,
    SocketSentMessageModel message,
    ValueNotifier<String>? newMessage,
    ApiMessageModel Function(ConversationBasicInfo) apiMessageModelBuilder, {
    required String header,
    required FilterContactsBy filter,
  }) {
    return SliverList(
      delegate: SliverChildListDelegate(
        users.isNotEmpty
            ? [
                // SmallHeader(
                //   text: header,
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 15,
                //     vertical: 8,
                //   ),
                // ),
                ...users.map((e) {
                  return Builder(builder: (context) {
                    return InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: UserListTile(
                                avatar: DisplayAvatar(
                                  isGroup: e.isGroup,
                                  model: e,
                                  size: 40,
                                  enable: false,
                                ),
                                userName: e.name,
                                bottom: Text(
                                  e.isGroup
                                      ? '${e.totalGroupMemebers!} thành viên'
                                      : e.status ?? '',
                                  style: context.theme.userStatusTextStyle,
                                ),
                                //onTapUserName: () async {},
                              ),
                            ),
                            if (!e.isGroup &&
                                e.companyId != context.userInfo().companyId)
                              SendButton(
                                key: ValueKey(e.id),
                                apiMessageModel: apiMessageModelBuilder(e),
                                newMessage: newMessage ?? ValueNotifier(null),
                                infoLink: message.infoLink,
                                dialogState: sendIds[e.id] ?? DialogState.init,
                                senderInfo: e.id,
                                onSendSuccess: () =>
                                    sendIds[e.id] = DialogState.success,
                                onSending: () =>
                                    sendIds[e.id] = DialogState.processing,
                                // senderInfo: senderInfo,
                              ),
                            if (e.isGroup &&
                                e.companyId != context.userInfo().companyId)
                              SendButton(
                                key: ValueKey(e.id),
                                apiMessageModel: apiMessageModelBuilder(e),
                                newMessage: newMessage ?? ValueNotifier(null),
                                infoLink: message.infoLink,
                                dialogState: sendIds[e.id] ?? DialogState.init,
                                senderInfo: e.id,
                                onSendSuccess: () =>
                                    sendIds[e.id] = DialogState.success,
                                onSending: () =>
                                    sendIds[e.id] = DialogState.processing,
                                // senderInfo: senderInfo,
                              ),
                          ],
                        ),
                      ),
                    );
                  });
                  // if (widget.itemBuilder == null)
                  //   return kDefaultItemBuilder(e, key: _controller.text);
                  // return widget.itemBuilder!(e, _controller.text);
                })
                // _showMoreButton(filter),
              ]
            : [],
      ),
    );
  }

  _msgModel(ConversationBasicInfo item) {
    ApiReplyMessageModel? _quoteMsg;
    if (widget.isShare == true) {
      _quoteMsg = null;
      return ApiMessageModel(
        senderId: _currentUser.id,
        conversationId: item.conversationId,
        messageId: widget.message.messageId,
        files: widget.message.files,
        contact: widget.message.contact,
        replyMessage: _quoteMsg,
        // message: ,
        type: widget.message.type ?? MessageType.link,
      );
    }
    if (_originMessage.message.isBlank && _originMessage.type?.isText == true) {
      if (_originMessage.relyMessage != null) {
        _quoteMsg = ApiReplyMessageModel(
          messageId: _originMessage.relyMessage!.messageId,
          senderId: _originMessage.relyMessage!.senderId,
          senderName: _originMessage.relyMessage!.senderName,
          message: _originMessage.relyMessage?.message,
          type: _originMessage.relyMessage?.type ?? MessageType.text,
          createAt: _originMessage.relyMessage!.createAt,
        );
      }
    } else {
      _quoteMsg = _originMessage.hasRelyMessage
          ? _originMessage.relyMessage
          : _originMessage.type?.isText == true
              ? ApiReplyMessageModel(
                  messageId: _originMessage.messageId,
                  senderId: _senderInfo.id,
                  senderName: _senderInfo.name,
                  message: _originMessage.message,
                  type: _originMessage.type ?? MessageType.text,
                  createAt: _originMessage.createAt,
                )
              : null;
    }
    if (_originMessage.type?.isText == true) {
      return ApiMessageModel(
        senderId: _currentUser.id,
        conversationId: item.conversationId,
        messageId: _originMessage.messageId,
        files: _originMessage.files,
        contact: _originMessage.contact,
        replyMessage: _quoteMsg,
        // message: ,
        type: _originMessage.type ?? MessageType.text,
      );
    }
    return ApiMessageModel(
      messageId: _originMessage.messageId,
      conversationId: item.conversationId,
      senderId: navigatorKey.currentContext!.userInfo().id,
      files: _originMessage.files,
      contact: _originMessage.contact,
      infoLink: _originMessage.infoLink,
      type: _originMessage.type ?? MessageType.text,
      message: _originMessage.message
          .valueIfNull(_originMessage.infoLink?.fullLink ?? ''),
    );
  }
}

class SmallHeader extends StatelessWidget {
  const SmallHeader({
    Key? key,
    required this.text,
    this.padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
  }) : super(key: key);

  final String text;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return Text(
            text,
            style: state.theme.chatConversationDropdownTextStyle,
          );
        },
      ),
    );
  }
}

Widget kDefaultItemBuilder(ConversationBasicInfo user, {String key = ''}) {
  List<ApiContact> listMember = [];
  listMember =
      (jsonDecode(SpUtil.getString('searched', defValue: null) ?? '[{}]'))
          .toList()
          .map<ApiContact>((e) => ApiContact.fromMyContact(e))
          .toList();
  int indexNull = listMember.indexWhere((e) => e.name == '');
  if (indexNull != -1) {
    listMember.removeAt(indexNull);
  }
  List<String> listKey = [];
  String oldKey = SpUtil.getString('oldKey', defValue: null) ?? '';
  if (oldKey != '') {
    listKey = oldKey.split(',');
  }
  return Builder(builder: (context) {
    // s bảo ấn vào không được và bấm vào avt ra 1 kiểu bấm vào tên ra 1 kiểu
    // nên đặt inkwell ngoài này và disable cái avatar
    return InkWell(
      onTap: () async {
        logger.log(user.runtimeType);

        //check user đã có trong local hay chưa, nếu chưa thì nhét cmn vào thôi
        if (listMember
            .map((e) =>
                e.id ==
                (user.runtimeType == ConversationBasicInfo
                    ? user.conversationId
                    : (user as ApiContact).id))
            .contains(true)) {
          listMember.removeWhere((element) =>
              element.id ==
              (user.runtimeType == ConversationBasicInfo
                  ? user.conversationId
                  : (user as ApiContact).id));
        }
        // convert từ conversationbasicInfo sang apiContact
        if (user.runtimeType == ConversationBasicInfo) {
          ApiContact group = ApiContact(
              id: user.conversationId,
              name: user.name,
              avatar: user.avatar,
              lastActive: DateTime.now(),
              companyId: -99);
          listMember.add(group);
        } else {
          listMember.add(user as ApiContact);
        }
        String value = '';
        value = jsonEncode(listMember
            .map<Map<String, dynamic>>((e) => e.toHiveObjectMap())
            .toList());
        SpUtil.putString('searched', value);
        // cái này không khác gì cái trên, check key tìm kiếm vậy thôi
        if (listKey.length > 0 && listKey.map((e) => e == key).contains(true)) {
          listKey.removeWhere((element) => element == key);
          oldKey = listKey.join(',');
        }
        if (oldKey == '') {
          oldKey += key;
        } else {
          oldKey += ',' + key;
        }
        SpUtil.putString('oldKey', oldKey);
        var conversationId = user.conversationId != -1
            ? user.conversationId
            : await context.read<ChatBloc>().getConversationId(
                  context.userInfo().id,
                  user.id,
                );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        child: Row(
          children: [
            Expanded(
              child: UserListTile(
                avatar: DisplayAvatar(
                  isGroup: user.isGroup,
                  model: user,
                  size: 40,
                  enable: false,
                ),
                userName: user.name,
                bottom: Text(
                  user.isGroup
                      ? '${user.totalGroupMemebers!} thành viên'
                      : user.status ?? '',
                  style: context.theme.userStatusTextStyle,
                ),
                //onTapUserName: () async {},
              ),
            ),
            if (!user.isGroup && user.companyId != context.userInfo().companyId)
              Text('cccc')
            // FriendButton(
            //   contact: user,
            // ),
          ],
        ),
      ),
    );
  });
}

class FriendButton extends StatefulWidget {
  const FriendButton({
    Key? key,
    required this.contact,
  }) : super(key: key);

  final IUserInfo contact;

  @override
  State<FriendButton> createState() => _FriendButtonState();
}

class _FriendButtonState extends State<FriendButton> {
  late FriendStatus _status;
  late VoidCallback _onTap;
  DialogState _state = DialogState.init;

  @override
  void initState() {
    super.initState();
    _status = widget.contact.friendStatus ?? FriendStatus.accept;
  }

  @override
  void didUpdateWidget(covariant FriendButton oldWidget) {
    if (widget.contact.friendStatus != null) {
      _status = widget.contact.friendStatus!;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color color;
    final Color textColor;

    /// Mình gửi lời mời đi
    /// Hiển thị trạng thái bạn bè ở phần tìm kiếm
    if (_status == FriendStatus.send) {
      text = StringConst.cancelAddFriend;
      color = AppColors.orange;
      textColor = AppColors.white;
      _onTap = () async {
        setState(() {
          _state = DialogState.processing;
        });
        var isSuccess =
            await context.read<FriendCubit>().deleteRequestAddFriend(
                  context.userInfo().id,
                  widget.contact.id,
                );
        setState(() {
          if (isSuccess) {
            _state = DialogState.success;
            widget.contact.friendStatus = _status = FriendStatus.unknown;
          } else {
            _state = DialogState.init;
          }
        });
      };
    }

    // /// Đã là bạn bè
    // else if (_status == FriendStatus.send) {
    //   text = StringConst.cancelFriend;
    //   color = Color(0xFFD6D9F5);
    //   textColor = AppColors.primary;
    // }

    /// Chưa có tương tác bạn bè
    else if (_status == FriendStatus.unknown) {
      text = StringConst.addFriend;
      color = AppColors.primary;
      textColor = AppColors.white;
      _onTap = () async {
        // context.read<ChatBloc>().tryToChatScreen(
        //       chatInfo: widget.contact,
        //       isNeedToFetchChatInfo: true,
        //       action: ChatFeatureAction.sendAddfriend,
        //     );

        setState(() {
          _state = DialogState.processing;
        });
        var error = await context.read<FriendCubit>().addFriend(widget.contact);
        setState(() {
          if (error == null) {
            _state = DialogState.success;
            widget.contact.friendStatus = _status = FriendStatus.send;
          } else {
            _state = DialogState.init;
          }
        });
      };
    }

    /// Người khác gửi lời mời
    // else if (_status == FriendStatus.request) {
    //   text = StringConst.agree;
    //   color = AppColors.lawnGreen;
    //   textColor = AppColors.white;
    // }

    /// Khác
    else {
      text = '';
      color = Colors.transparent;
      textColor = Colors.transparent;
    }

    return SizedBox(
      height: 30,
      child: text.isEmpty
          ? null
          : _state == DialogState.processing
              ? SizedBox.square(
                  dimension: 15,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : ElevatedButton(
                  onPressed: _onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.regularW500(
                      context,
                      size: 14,
                      lineHeight: 16,
                      color: textColor,
                    ),
                  ),
                ),
    );
  }
}
