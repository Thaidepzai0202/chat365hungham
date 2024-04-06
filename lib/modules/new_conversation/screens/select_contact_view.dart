// import 'package:app_chat365_pc/common/models/api_contact.dart';
// import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
// import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
// import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class SelectContactView extends StatefulWidget {
//   SelectContactView({
//     Key? key,
//     this.mulipleContactItemBuilder,
//     required this.onChanged,
//     this.userInfo,
//     this.existContact=const [],
//   }) : super(key: key);
//   final Widget Function(ApiContact)? mulipleContactItemBuilder;
//   final ValueChanged<List<IUserInfo>> onChanged;
//   final IUserInfo? userInfo;
//   final List<IUserInfo> existContact;
//   @override
//   State<SelectContactView> createState() => _SelectContactViewState();
// }
//
// class _SelectContactViewState extends State<SelectContactView> {
//   final ValueNotifier<String> searchKey = ValueNotifier('');
//   final ValueNotifier<List<IUserInfo>> _selectedContact = ValueNotifier([]);
//   late final ContactListCubit contactListCubit;
//   late final FriendCubit _friendCubit;
//   final GlobalKey<State<StatefulWidget>> _key =
//   GlobalKey<State<StatefulWidget>>();
//   bool loadFirst = true;
//   List<ConversationBasicInfo> _friends = [];
//   List<ConversationBasicInfo> _searchedFriends = [];
//   // text file name group
//   bool _isEdit = false;
//   final FocusNode _focusNode = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//     var userInfo = context.userInfo();
//     _friendCubit = context.read<FriendCubit>();
//     contactListCubit = ContactListCubit(
//       ContactListRepo(
//         userInfo.id,
//         companyId: userInfo.companyId ?? userInfo.id,
//       ),
//       initFilter: FilterContactsBy.allInCompany,
//     );
//     _selectedContact.addListener(_selectedContactListener);
//   }
//
//   _onChangeCheckBox(bool value, IUserInfo item) {
//     if (value) {
//       _selectedContact.value = [..._selectedContact.value, item];
//     } else {
//       _selectedContact.value = [
//         ..._selectedContact.value..removeWhere((e) => item.id == e.id),
//       ];
//     }
//   }
//
//   _selectedContactListener() {
//     widget.onChanged(_selectedContact.value);
//   }
//
//   @override
//   void dispose() {
//     _selectedContact.removeListener(_selectedContactListener);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loadFirst) {
//       if (widget.userInfo != null) {
//         _onChangeCheckBox(true, widget.userInfo!);
//       }
//       loadFirst = false;
//     }
//     late final Widget suggestionText = Padding(
//       padding: AppPadding.paddingHorizontal15,
//       child: Text(
//         StringConst.recommend,
//         style: AppTextStyles.recommend(context),
//       ),
//     );
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBoxExt.h10,
//         //  CustomTextFieldTheme(
//         //     keyText: formKey,
//         //     isTitle: false,
//         //     // validator: (value) =>
//         //     //     Validator.validateStringBlank(value, ' tên nhóm'),
//         //     hintText: StringConst.groupName,
//         //     isShowIcon: true,
//         //     iconSuffix: Images.ic_pencil,
//         //     onChanged: (val) {
//         //       context.read<CreateConversationCubit>().model.name.value = val;
//         //     },
//         //   ),
//         //
//
//         //
//         SizedBoxExt.h10,
//         Padding(
//           padding: AppPadding.paddingHorizontal15,
//           child: SearchField(
//             callBack: (value) {
//               contactListCubit.searchAll(value);
//               _searchedFriends =
//                   SystemUtils.searchFunction<ConversationBasicInfo>(
//                     value,
//                     _friends,
//                     toEng: true,
//                     delegate: (item) => item.name,
//                   ).toList();
//             },
//           ),
//         ),
//         Container(
//           margin: EdgeInsets.symmetric(vertical: 15),
//           height: 40,
//           child: ValueListenableBuilder<List<IUserInfo>>(
//               valueListenable: _selectedContact,
//               builder: (context, value, child) {
//                 var data = value..removeWhere((element) => widget.existContact.contains(element));
//                 print('\x1b[33m$data\x1b[m');
//                 return ListView.separated(
//                   itemCount: data.length,
//                   shrinkWrap: true,
//                   scrollDirection: Axis.horizontal,
//                   padding: EdgeInsets.only(left: 20),
//                   separatorBuilder: (_, __) => const SizedBox(width: 10),
//                   itemBuilder: (_, index) {
//                     var item = data[index];
//                     return Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         DisplayAvatar(
//                           isGroup: false,
//                           model: item,
//                         ),
//                         Positioned(
//                           top: -2,
//                           right: -4,
//                           child: InkWell(
//                             onTap: () {
//                               _selectedContact.value = [
//                                 ..._selectedContact.value
//                                   ..removeWhere((e) => item.id == e.id),
//                               ];
//                               _key.currentState?.setState(() {});
//                             },
//                             child: Icon(
//                               Icons.cancel,
//                               size: 15,
//                               color: AppColors.red,
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               }),
//         ),
//         suggestionText,
//         Expanded(
//           child: BlocBuilder<FriendCubit, FriendState>(
//             buildWhen: (previous, current) =>
//             _friends.isEmpty && !_friendCubit.listFriends.isBlank,
//             builder: (context, friendState) {
//               if (!_friendCubit.listFriends.isBlank)
//                 _friends = _friendCubit.listFriends!
//                     .map(
//                       (e) => ConversationBasicInfo(
//                     conversationId: -1,
//                     name: e.name,
//                     isGroup: false,
//                     userId: e.id,
//                     avatar: e.avatar,
//                   ),
//                 )
//                     .toList();
//               _searchedFriends = (_friendCubit.listFriends??{}).map(
//                     (e) => ConversationBasicInfo(
//                   conversationId: -1,
//                   name: e.name,
//                   isGroup: false,
//                   userId: e.id,
//                   avatar: e.avatar,
//                 ),
//               )
//                   .toList();
//               ;
//               return BlocBuilder<ContactListCubit, ContactListState>(
//                 bloc: contactListCubit,
//                 builder: (context, state) {
//                   if (state is LoadSuccessState) {
//                     return StatefulBuilder(
//                       key: _key,
//                       builder: (context, setState) {
//                         var ids = _selectedContact.value.map((e) => e.id);
//                         var listUsers = {
//                           // xử lí thêm key khi gọi _searched
//                           //..._searchedFriends,
//                           ...state.contactList,
//                           ...state.allContact[FilterContactsBy.allInCompany] ??
//                               [],
//                           ...state.allContact[FilterContactsBy.none] ?? [],
//                         };
//
//                         listUsers = listUsers
//                           ..toSet().toList()
//                           ..removeWhere((element) => element.name.isBlank||widget.existContact.map<int>((e)=>e.id).toList().contains(element.id));
//                         print('\x1b[33mdanh sách: $listUsers\x1b[m');
//                         return ListContactView(
//                           userInfos: listUsers,
//                           itemBuilder: (context, index, child) {
//                             var item = listUsers.elementAt(index);
//                             return CheckBoxUserListTile(
//                               value: ids.contains(item.id),
//                               userListTile: child,
//                               onChanged: (value) =>
//                                   _onChangeCheckBox(value, item),
//                             );
//                           },
//                         );
//                       },
//                     );
//                   }
//                   if (state is LoadFailedState) {
//                     return AppErrorWidget(error: state.message);
//                   }
//                   if (state is LoadingState) {
//                     return WidgetUtils.centerLoadingCircle;
//                   }
//                   return Center(child: Text('DS trong'));
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class CheckBoxUserListTile extends StatefulWidget {
//   const CheckBoxUserListTile({
//     Key? key,
//     this.value = false,
//     required this.onChanged,
//     required this.userListTile,
//   }) : super(key: key);
//   final bool value;
//   final ValueChanged<bool> onChanged;
//   final Widget userListTile;
//   @override
//   State<CheckBoxUserListTile> createState() => _CheckBoxUserListTileState();
// }
//
// class _CheckBoxUserListTileState extends State<CheckBoxUserListTile>
//     with AutomaticKeepAliveClientMixin {
//   late bool _value;
//   late Widget _userListTile;
//   @override
//   void initState() {
//     super.initState();
//     _value = widget.value;
//     _userListTile = widget.userListTile;
//   }
//
//   @override
//   void didUpdateWidget(covariant CheckBoxUserListTile oldWidget) {
//     if (widget.value != _value) _value = widget.value;
//     if (widget.userListTile != _userListTile)
//       _userListTile = widget.userListTile;
//     super.didUpdateWidget(oldWidget);
//   }
//
//   _onChanged() {
//     setState(() {
//       _value = !_value;
//     });
//     widget.onChanged(_value);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return InkWell(
//       onTap: _onChanged,
//       child: Row(
//         children: [
//           Expanded(child: _userListTile),
//           Checkbox(
//             onChanged: (_) => _onChanged(),
//             value: _value,
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   bool get wantKeepAlive => true;
// }
