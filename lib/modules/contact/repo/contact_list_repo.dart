import 'dart:convert';

import 'package:app_chat365_pc/common/models/api_contact.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/repos/chat_conversations_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/data/services/sp_utils_service/sp_utils_services.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ContactListRepo {
  final ApiClient _client;
  final ChatConversationsRepo _conversationsRepo;

  final int userId;
  final int companyId;

  ContactListRepo(
    this.userId, {
    required this.companyId,
  })  : _conversationsRepo = ChatConversationsRepo(userId,
            total: spService.totalConversation ?? 0),
        _client = ApiClient();

  Future<List<ApiContact>> getMyContact({int skip = 0}) async {
    final RequestResponse res = await _client.fetch(
      ApiPath.myContacts,
      data: {
        'ID': userId,
        'countContact': skip,
      },
      retryTime: 4,
      options: Options(
        receiveTimeout: Duration(milliseconds: 7000),
      ),
    );

    return (json.decode(res.data)['data']['user_list'] as List)
        .map((e) => ApiContact.fromMyContact(e))
        .toList();
  }

  //get data request status from api checkStatus
  Future<List<ApiContact>> checkStatus(int id) async {
    final RequestResponse res = await _client.fetch(
      ApiPath.checkStatus,
      data: {
        'userId': userId,
        'contactId': id,
      },
    );
    return (json.decode(res.data)['data']['request']);
  }

  static final emptyContactRequestResponse = RequestResponse(
    '"data":{"user_list": []}',
    true,
    200,
  );

  Future<List<ApiContact>> getAllContactsInCompany(
    int companyId,
  ) async {
    if (companyId == 0) return [];
    final RequestResponse res = await _client.fetch(
      ApiPath.allContactsInCompany2,
      data: {
        'ID': userId,
        'CompanyID': companyId,
      },
      // ApiPath.searchAll2,
      // data: {
      //   'senderId': userId,
      //   'companyId': companyId,
      //   'type': 'company',
      // },
    );

    return await compute(_computeGetAllContactsInCompany, res);
  }

  static List<ApiContact> _computeGetAllContactsInCompany(
          RequestResponse res) =>
      (json.decode(res.data)['data']['user_list'] as List)
          .map((e) => ApiContact.fromMyContact(e))
          .toList();

  Future<RequestResponse> searchContactInCompany(String keyword) =>
      companyId == 0
          ? Future.value(emptyContactRequestResponse)
          : _client.fetch(
              ApiPath.searchContactInCompany2,
              data: {
                'message': keyword,
                'senderId': userId,
                'companyId': companyId,
              },
            );

  Future<RequestResponse> searchContact(String keyword) => _client.fetch(
        ApiPath.searchContact2,
        data: {
          'message': keyword,
          'senderId': userId,
          // 'companyId': companyId,
        },
      );

  /// Gọi tất cả các cuộc trò chuyện hiện tại api [GetListConversation]
  Future<List<ConversationBasicInfo>> getAllContact({
    bool groupOnly = false,
    List<ConversationBasicInfo> initCoversation = const [],
  }) async {
    var list = initCoversation;

    while (list.length < _conversationsRepo.totalRecords) {
      var res = await _conversationsRepo.loadListConversation(
        countConversationLoad: list.length,
      );
      try {
        list.addAll(await res.onCallBack((_) {
          var listResult = <ConversationBasicInfo>[];
          for (var e
              in (json.decode(res.data)['data']['listCoversation'] as List)) {
            final model = ChatItemModel.fromConversationInfoJsonOfUser(
              _conversationsRepo.userId,
              conversationInfoJson: e,
            );
            listResult.add(model.conversationBasicInfo);
          }
          return listResult;
        }));
      } on CustomException catch (e) {
        if (e.error.isExceedListConversation) break;
        rethrow;
      }
    }
    if (groupOnly) list.removeWhere((e) => !e.isGroup);
    return list;
  }

  Future<List<ConversationBasicInfo>> searchGroup(String keyword) async {
    var list = <ConversationBasicInfo>[];

    var res = await _client.fetch(
      ApiPath.searchListConversation2,
      data: {
        'senderId': userId,
        'message': keyword,
      },
    );
    try {
      list.addAll(await res.onCallBack((_) {
        var listResult = <ConversationBasicInfo>[];
        for (var e
            in (json.decode(res.data)['data']['listCoversation'] as List)) {
          final model = ChatItemModel.fromConversationInfoJsonOfUser(
            _conversationsRepo.userId,
            conversationInfoJson: e,
          );
          listResult.add(model.conversationBasicInfo);
        }
        return listResult;
      }));
    } on CustomException catch (_) {
      rethrow;
    }
    return list;
  }

  // Dùng trong chuyển tiếp tin nhắn
  Future<RequestResponse> searchAll(
    String keyword,
  ) =>
      ApiClient().fetch(
        ApiPath.searchAll2,
        data: {
          'message': keyword,
          'senderId': userId,
          'companyId': companyId,
          'type': 'all',
        },
      );

  Future<RequestResponse> searchConversations(
    String keyword, {
    int chunk = 20,
    int countLoaded = 0,
  }) =>
      ApiClient().fetch(
        ApiPath.searchConversations,
        data: {
          'userId': userId,
          'companyId': companyId,
          'message': keyword,
          'countConversation': chunk,
          'countConversationLoad': countLoaded,
        },
      );
}

// class SearchContactWithConversation {
//   final String keywords;
//   final ConversationBasicInfo contact;

//   SearchContactWithConversation(
//     this.keywords,
//     this.contact,
//   );

//   factory SearchContactWithConversation.fromConversation(ChatItemModel model) =>
//       SearchContactWithConversation(
//         model.conversationBasicInfo.name.toEngAlphabetString(),
//         model.conversationBasicInfo,
//       );

//   @override
//   String toString() => contact.name.toEngAlphabetString();
// }
