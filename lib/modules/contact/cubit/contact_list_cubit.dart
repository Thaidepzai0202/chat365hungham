import 'dart:async';
import 'dart:convert';

import 'package:app_chat365_pc/common/models/api_contact.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/core/error_handling/app_error_state.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/contact/model/filter_contact_by.dart';
import 'package:app_chat365_pc/modules/contact/model/result_search_all_model.dart';
import 'package:app_chat365_pc/modules/contact/repo/contact_list_repo.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'contact_list_state.dart';

const FilterContactsBy _initialFilter = FilterContactsBy.myContacts;

const String _myContactsKey = 'my-contacts';
const String allContactsInCompanyKey = 'all-contacts-in-company';

class ContactListCubit extends Cubit<ContactListState> {
  ContactListCubit(
      this.repo, {
        required FilterContactsBy? initFilter,
        this.searchGroupConversationOnly = false,
        this.initSearch,
        bool firstLoad = true,
        String fromSource = '',
      })  : _filterContactsBy = ValueNotifier(initFilter),
        super(LoadingState(_initialFilter)) {
    if (firstLoad) {
      loadContact(initSearch);
      logger.log(fromSource, name: 'Source');
    }

    _filterContactsBy.addListener(_listener);
  }

  final bool searchGroupConversationOnly;
  final String? initSearch;

  List<ConversationBasicInfo> get initConversation =>
      chatConversationBloc.chats.map((e) => e.conversationBasicInfo).toList();
  List<ConversationBasicInfo>? newConversationBasicInfo;
  ValueNotifier<FilterContactsBy?> _filterContactsBy;

  ValueNotifier<FilterContactsBy?> get filterContactsBy => _filterContactsBy;
  final Map<String, List<ConversationBasicInfo>?> _contacts = {
    _myContactsKey: null,
    allContactsInCompanyKey: null,
  };
  int loadedContact = 0;
  final ContactListRepo repo;
  final Map<FilterContactsBy, List<ConversationBasicInfo>> countLoaded =
  Map.fromIterable(
    FilterContactsBy.values,
    value: (element) => [],
  );

  bool _canLoadMore = true;

  bool get canLoadMore => _canLoadMore;

  Map<String, List<ConversationBasicInfo>?> get contacts => _contacts;

  _listener() => loadContact();

  setPreSearchAllData() {
    if (searchAllPreSearchData != null)
      _emitSuccessState([], searchAllData: searchAllPreSearchData!);
  }

  setSendMessagePreSearchData() {
    if (sendMessagePreSearchData.isEmpty)
      _emitSuccessState(sendMessagePreSearchData);
  }

  loadContact([String? initSearch]) {
    _canLoadMore = true;
    var keyword = initSearch ?? '';
    emit(LoadingState(_filterContactsBy.value));
    if (_filterContactsBy.value == null)
      searchAll(keyword);
    else if (_filterContactsBy.value == FilterContactsBy.myContacts) {
      logger.log('vaof ddaay nhe', name: 'aaaaaaaaaa');
      loadMyContacts();
    } else if (_filterContactsBy.value == FilterContactsBy.conversations) {
      searchInListConversation(keyword);
    } else if (_filterContactsBy.value == FilterContactsBy.none)
      searchContact(keyword);
    else {
      keyword.isEmpty
          ? (_loadAllContactsInCompany(repo.userId.toString()))
          : search(keyword);
    }
  }

  loadMoreContact() async {
    logger.log('load more nef ahihi $loadedContact');
    await loadMyContacts(skip: loadedContact);
  }

  loadMyContacts({int skip = 0, String? query}) async {
    if (skip == 0) _canLoadMore = true;
    try {
      logger.log('$skip');
      List<ConversationBasicInfo> _listFriend =
      await repo.getMyContact(skip: skip);

      if (_listFriend.isBlank) {
        _canLoadMore = false;
      }
      loadedContact =
      skip == 0 ? _listFriend.length : (loadedContact + _listFriend.length);
      _contacts[_myContactsKey] = _listFriend;

      if (query == null) {
        _emitSuccessState(_contacts[_myContactsKey]!);
      } else {
        List<ConversationBasicInfo> _myContact = [];
        _contacts[_myContactsKey]!.forEach((contact) {
          if (contact.name.toLowerCase().contains(query.toLowerCase())) {
            _myContact.add(contact);
          }
        });
        _emitSuccessState(_myContact);
      }
    } catch (e, s) {
      logger.logError(e, s);
      emit(LoadFailedState(
        _filterContactsBy.value,
        AppErrorStateExt.getFriendlyErrorString(e),
      ));
    }
  }

  _loadAllContactsInCompany(String companyId) async {
    if (sendMessagePreSearchData.isNotEmpty)
      _emitSuccessState(sendMessagePreSearchData);
    try {
      if (_contacts[allContactsInCompanyKey]?.isEmpty != false)
        _contacts[allContactsInCompanyKey] =
        await repo.getAllContactsInCompany(repo.companyId);
      if (sendMessagePreSearchData.isEmpty)
        _emitSuccessState(_contacts[allContactsInCompanyKey]!);
      sendMessagePreSearchData = _contacts[allContactsInCompanyKey]!;
    } catch (e, s) {
      logger.logError(e, s);
      emit(LoadFailedState(
        _filterContactsBy.value,
        e.toString(),
      ));
    }
  }

  _emitSuccessState(
      List<ConversationBasicInfo> data, {
        Map<FilterContactsBy, List<ConversationBasicInfo>> searchAllData = const {},
        bool isLoadMore = false,
      }) =>
      emit(LoadSuccessState(
        _filterContactsBy.value,
        contactList: [
          if (isLoadMore) ...countLoaded[_filterContactsBy.value]!,
          ...data
        ],
        allContact: searchAllData,
      ));

  Future _loadContactsDelegate(
      Future<void> Function() loader,
      String key,
      ) async {
    if (_contacts[key] != null) {
      _emitSuccessState(_contacts[key]!);
      return;
    }

    try {
      await loader();
      _emitSuccessState(_contacts[key]!);
    } catch (e, s) {
      logger.logError(e, s);
      emit(LoadFailedState(
        _filterContactsBy.value,
        AppErrorStateExt.getFriendlyErrorString(e),
      ));
    }
  }

  /// Search ứng với [_filterContactsBy.value]
  ///
  /// Không có search theo [FilterContactsBy.myContacts]
  search(
      String keyword, {
        bool isLoadMore = false,
      }) async {
    var filter = _filterContactsBy.value;

    if (_filterContactsBy.value == null) return searchAll(keyword);

    if (_filterContactsBy.value == FilterContactsBy.conversations)
      return searchInListConversation(
        keyword,
        isLoadMore: isLoadMore,
      );

    if (keyword.isEmpty) return loadContact();

    emit(LoadingState(_filterContactsBy.value));

    if (filter == FilterContactsBy.myContacts)
      return loadMyContacts(query: keyword);

    var futureRes = await Future.wait(
      [
        if (filter == FilterContactsBy.none)
          _searchContact(keyword)
        else if (filter == FilterContactsBy.allInCompany)
          _searchContactInCompany(keyword)
      ],
    );
    if (state is LoadingState) {
      var res = futureRes.expand((i) => i).toList();
      logger.log(filter, name: "LOADING");
      _emitSuccessState(res);
    }
  }

  Future<List<ApiContact>> _searchContactInCompany(String keyword) async {
    var res = await repo.searchContactInCompany(keyword);
    try {
      return await res.onCallBack(
        __computeSearchContactInCompany,
        multiThread: true,
      );
    } catch (_) {
      return [];
    }
  }

  static List<ApiContact> __computeSearchContactInCompany(
      RequestResponse res,
      ) =>
      List.from(
        json.decode(res.data)['data']['user_list'].map(
              (e) => ApiContact.fromMyContact(e),
        ),
      );

  /// Gọi đến api [searchContactInHomePage]
  Future<List<ApiContact>> _searchContact(String keyword) async {
    var res = await repo.searchContact(keyword);
    try {
      return res.onCallBack((_) =>
          (json.decode(res.data)['data']['user_list'] as List)
              .map((e) => ApiContact.fromMyContact(e))
              .toList());
    } on CustomException catch (_) {
      return [];
    }
  }

  searchContact(String keyword) async {
    try {
      _emitSuccessState(await _searchContact(keyword));
    } on CustomException catch (_) {
      return [];
    }
  }

  Future<List<ConversationBasicInfo>> _search(
      String keyword, {
        bool groupOnly = false,
        bool isLoadMore = false,
      }) async {
    if (keyword.isEmpty && conversations != null) {
      if (isLoadMore) return [];
      return conversations!;
    }
    var res = await repo.searchConversations(
      keyword,
      countLoaded:
      isLoadMore ? countLoaded[_filterContactsBy.value!]?.length ?? 0 : 0,
      // chunk: 40,
    );

    try {
      return res.onCallBack(
            (_) => List.from(
          json.decode(res.data)['data']['listCoversation'].map(
                (e) => ConversationBasicInfo(
              conversationId: e['conversationId'],
              userId: e['contactId'],
              isGroup: e['isGroup'] == 1,
              name: e['conversationName'],
              avatar: e['avatarConversation'],
            ),
          ),
        ),
      );
    } on CustomException catch (e, s) {
      logger.logError(e, s);
      return [];
    }
  }

  removeContact(int chatId) {
    _emitSuccessState(
        _contacts[_myContactsKey]!..removeWhere((e) => e.id == chatId));
  }

  searchInListConversation(
      String keyword, {
        bool isLoadMore = false,
      }) async {
    emit(LoadingState(_filterContactsBy.value));

    if (searchGroupConversationOnly) {
      try {
        _emitSuccessState(await repo.searchGroup(keyword));
      } on CustomException catch (e) {
        return emit(
            LoadFailedState(_filterContactsBy.value, e.error.toString()));
      }
    } else {
      try {
        if (conversations == null)
          conversations = await repo.getAllContact(
            groupOnly: searchGroupConversationOnly,
            initCoversation: initConversation,
          );
      } on CustomException catch (e) {
        return emit(
            LoadFailedState(_filterContactsBy.value, e.error.toString()));
      }
      _emitSuccessState(
        await _search(
          keyword,
          groupOnly: searchGroupConversationOnly,
          isLoadMore: isLoadMore,
        ),
        isLoadMore: isLoadMore,
      );
    }
  }

  searchAll(String keyword) async {
    if (keyword.isEmpty && searchAllPreSearchData != null) {
      _emitSuccessState([], searchAllData: searchAllPreSearchData!);
      _tryUpdateSearchAllPreSearchData(keyword);
      return;
    }
    emit(LoadingState(null));
    var res = await repo.searchAll(keyword);
    try {
      res.onCallBack((_) {
        logger.log(res.data.toString(), name: "data logger");
        var data = resultSearchAllModelFromJson(res.data).data!;
        var mapData = {
          FilterContactsBy.allInCompany: data.listContactInCompany,
          FilterContactsBy.conversations: data.listGroup,
          FilterContactsBy.none: data.listEveryone,
        };

        if (keyword.isEmpty) searchAllPreSearchData = mapData;

        _emitSuccessState(
          [],
          searchAllData: mapData,
        );
      });
    } on CustomException catch (e) {
      logger.logError('$e');
      return emit(LoadFailedState(_filterContactsBy.value, e.error.toString()));
    }
  }

  Future<List<ApiContact>> searchPhoneNumber(String keyword) async {
    var res = await repo.searchAll(keyword);
    try {
      return res.onCallBack((_) =>
          (json.decode(res.data)['data']['listEveryone'] as List)
              .map((e) => ApiContact.fromMyContact(e))
              .toList());
    } on CustomException catch (_) {
      return [];
    }
  }

  // try {
  //   res.onCallBack((_) {
  //     var data1 = resultSearchAllModelFromJson(res.data).data!;
  //     return data1.listEveryone;
  //   });
  // } on CustomException {
  //   return [];
  // }
  // var data = resultSearchAllModelFromJson(res.data).data!;
  // List<ApiContact> res1 = data.listEveryone;
  // return res1;
  _tryUpdateSearchAllPreSearchData(String keyword) async {
    if (keyword.isEmpty) {
      var res = await repo.searchAll(keyword);
      try {
        res.onCallBack((_) {
          var data = resultSearchAllModelFromJson(res.data).data!;
          var mapData = {
            FilterContactsBy.allInCompany: data.listContactInCompany,
            FilterContactsBy.conversations: data.listGroup,
            FilterContactsBy.none: data.listEveryone,
          };

          searchAllPreSearchData = mapData;
        });
      } catch (e, s) {
        logger.logError(e, s);
      }
    }
  }

  @override
  void onChange(Change<ContactListState> change) {
    if (change.nextState is LoadSuccessState &&
        _filterContactsBy.value != null) {
      countLoaded[_filterContactsBy.value!] =
          (change.nextState as LoadSuccessState).contactList;
    }
    super.onChange(change);
  }

  @override
  Future<void> close() {
    _filterContactsBy.removeListener(_listener);
    if (newConversationBasicInfo != null)
      sendMessagePreSearchData = newConversationBasicInfo!;
    return super.close();
  }
}
