import 'dart:convert';
import 'dart:isolate';

import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/pagination_mixin.dart';
import 'package:app_chat365_pc/data/services/sp_utils_service/sp_utils_services.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/widgets.dart';
import 'package:sp_util/sp_util.dart';

class ChatConversationsRepo with PaginationMixin {
  int userId;
  final ApiClient _apiClient = ApiClient();
  ValueNotifier<int> _totalRecords =
      ValueNotifier(spService.totalConversation ?? 0);

  ChatConversationsRepo(
    this.userId, {
    required int total,
  }) {
    _totalRecords.addListener(() {
      spService.saveTotalConversation(totalRecords);
      // totalRecords = total;
    });
    totalRecords = total;
  }

  int get totalRecords => _totalRecords.value;

  set totalRecords(int value) {
    if (value != 0) {
      _totalRecords.value = value;
      logger.log(value, name: 'Set totalRecords');
    }
  }

  Future<RequestResponse> getUnreadConversation() async {
    return _apiClient.fetch(ApiPath.ConversationUnreader, data: {
      'userId': userId,
    });
  }

  // @countConversationLoad: Nếu = 0, trả về Toàn Bộ cuộc trò chuyện yêu thích
  // và nhiều nhất 20 cuộc trò chuyện thường đầu danh sách
  // Nếu > 0: Trả về nhiều nhất 20 cuộc trò chuyện thường trong danh sách, bỏ qua
  // số lượng trò chuyện ở đầu danh sách bằng @countConversationLoad
  // "Nhiều nhất" khi danh sách còn lại còn ít nhất 20 cuộc trò chuyện
  @Deprecated("Dùng ChatRepo().getConversationList() nhé.")
  Future<RequestResponse> loadListConversation({
    required int countConversationLoad,
    int limit = AppConst.limitOfListDataLengthForEachRequest,
    bool useFastApi = false,
  }) async {
    var total = totalRecords.clamp(1, double.infinity).toInt();
    logger.log('$total - ${countConversationLoad.clamp(0, total)}',
        name: 'GET LIST CONVERSATION LOG');
    return _apiClient.fetch(
      !useFastApi ? ApiPath.chatList : ApiPath.fastChatList,
      data: {
        'userId': AuthRepo().userInfo!.id, // TODO: sửa thành userId,
        'countConversationLoad': countConversationLoad,
        // 'token': AuthRepo.authToken, // TODO: Đúng token này không ta?
        'companyId': AuthRepo().userInfo?.companyId ?? 0,
      },
      retryTime: 3,
    );
  }

  // Lấy danh sách nhóm chung
  Future<RequestResponse> getCommonConversation({
    required int userId,
    required int contactId,
  }) {
    return _apiClient.fetch(
      ApiPath.GetCommonConversation,
      data: {
        'userId': userId,
        'contactId': contactId,
      },
      retryTime: 2,
    );
  }

  // lấy sanh sách id người quen
  Future<List<int>> getListUserIdFamiliar({required int companyId}) async {
    var token = await SpUtil.getString(LocalStorageKey.authToken);
    final RequestResponse res =
        await _apiClient.fetch(ApiPath.getListUserIdFamiliar, data: {
      'token': token,
      'UserId': userId,
      'CompanyId': companyId,
    });
    if (res.hasError) return [];
    return (json.decode(res.data)['data']['listFamiliar'] as List).cast<int>();
  }

  // hiện tại không dùng
  // Future<List<int>> getAllContactsInCompany(
  //   int companyId,
  // ) async {
  //   if (companyId == 0) return [];
  //   final RequestResponse res = await _apiClient.fetch(
  //     ApiPath.allContactsInCompany2,
  //     data: {
  //       'ID': userId,
  //       'CompanyID': companyId,
  //     },
  //   );
  //   var listUserInCompany = (json.decode(res.data)['data']['user_list'] as List)
  //       .map((e) => ApiContact.fromMyContact(e))
  //       .toList();
  //   List<int> listUidInCompany = listUserInCompany.map((e) => e.id).toList();
  //
  //   return listUidInCompany;
  // }

  /// lấy danh sách cuộc trò chuyện với người lạ
  Future<RequestResponse> getListConversationStrange(
      {required int companyId}) async {
    // if()await getListUserIdFamiliar(companyId: companyId);

    // List<int> listUidInCompany = await getAllContactsInCompany(companyId);
    // var newList = new List.from(_listUserIdFamiliar)..addAll(listUidInCompany);
    // var total = totalRecords.clamp(1, double.infinity).toInt();
    return _apiClient.fetch(ApiPath.getListConversationStrange, data: {
      'userId': userId,
      'CompanyId': companyId,
      // 'countConversationLoad': 0,
      //'listUserFamiliar': '[84608,27783,124]',
      // 'listUserFamiliar': newList.toSet().toList()
    });
  }

  Future<RequestResponse> deleteAllMessageConversation(int conversationId) =>
      _apiClient.fetch(
        ApiPath.deleteAllMessage,
        data: {
          'conversationId': conversationId,
          'senderId': userId,
        },
      );

  /// TL 18/1/2024 TODO: Chuyển dịch qua xóa bên ChatRepo()
  Future<RequestResponse> deleteAllMessageOneSide(int conversationId) async {
    // TODO: Trần Lâm: Hiện tại gọi ở đây để chống chế có token. Cần phải refresh token chỗ nào đấy hợp lí hơn
    await AuthRepo().refreshTokenApp();

    return _apiClient.fetch(
      ApiPath.deleteAllMessageOneSide,
      data: {
        'conversationId': conversationId,
        'userId': userId,
        'token': AuthRepo.authToken ?? '',
      },
    );
  }

  Future<RequestResponse> deleteFileConversation(int conversationId) =>
      _apiClient.fetch(
        ApiPath.deleteFileConversation,
        data: {
          'conversationId': conversationId,
          'userId': AuthRepo().userId,
        },
      );
  Future<RequestResponse> changeHiddenConversationStatus(
    int conversationId, {
    required int hidden,
  }) =>
      _apiClient.fetch(
        ApiPath.toogleHiddenChat,
        data: {
          'conversationId': conversationId,
          'senderId': userId,
          'isHidden': hidden,
        },
      );
  // tắt thông báo cuộc trò chuyện
  Future<RequestResponse> changeNotificationStatus({
    required int conversationId,
    required int userId,
    required List<int> membersIds,
  }) {
    //bắn socket thông báo trc quên chưa ghép
    // if (membersIds.isNotEmpty)
    //   chatClient.emit(
    //       ChatSocketEvent.checkNotification, {conversationId, 1, membersIds});
    // logger.log({conversationId, 0, membersIds},
    //     name: ChatSocketEvent.checkNotification);
    return _apiClient.fetch(
      ApiPath.changeNotiChat,
      data: {
        'userId': userId,
        'conversationId': conversationId,
      },
    );
  }

  /// [favorite] 1: true, 0: false
  @Deprecated("Dùng ChatRepo().changeFavoriteStatus() nhé")
  Future<RequestResponse> changeFavoriteConversationStatu(
    int conversationId, {
    required int favorite,
  }) =>
      _apiClient.fetch(
        ApiPath.toogleFavoriteChat,
        data: {
          'conversationId': conversationId,
          'senderId': userId,
          'isFavorite': favorite,
        },
      );

  // @ListConvId: danh sách Id của những CTC cần lấy
  // @displayMessage: Không dùng. Để là list rỗng nhé
  Future<
      Map<int,
          List<SocketSentMessageModel>>> getListLastMessagesOfListConversations(
      List<int> conversationIds, List<int> displayMessage,
      // TL 26/12/2023: Anh Việt Anh bảo có cả adminId nữa, nhưng để làm gì thì chịu
      {int? adminId}) async {
    // logger.log('$conversationIds / [${conversationIds.length}]',
    //     name: 'CheckListMsgAPI');

    // @userId: Id của...?
    // @ListConvId: danh sách Id của những CTC cần lấy
    //
    var res = await ApiClient().fetch(
      ApiPath.messageOfAllConversation,
      data: {
        'UserId': userId,
        'ListConvId': json.encode(conversationIds),
        'token': AuthRepo.authToken,
        if (adminId != null) 'adminId': adminId,
        // 'displayMessage': json.encode(displayMessage),
      },
    );

    return res.onCallBack((_) async {
      /// TL 20/2/2024: Thử bỏ Isolate xem TimerRepo có bị sinh 2 lần không

      final ReceivePort receivePort = ReceivePort();

      final BuildContext context = navigatorKey.currentContext!;

      // final isolate = await Isolate.spawn(_computeListLastMessage, [
      //   res,
      //   receivePort.sendPort,
      //   context.userInfo(),
      //   context.userType(),
      // ]);

      // final result =
      //     (await receivePort.first) as Map<int, List<SocketSentMessageModel>>;

      // isolate.kill(priority: Isolate.immediate);

      final result = _computeListLastMessage([
        res,
        receivePort.sendPort,
        context.userInfo(),
        context.userType(),
      ]) as Map<int, List<SocketSentMessageModel>>;

      return result;
    });
  }

  static _computeListLastMessage(
    List param,
  ) {
    final RequestResponse res = param[0];
    final SendPort sendPort = param[1];
    var listConversationInfo = List.from(json.decode(res.data)['data']['data']);

    /// TL 20/2/2024: Thử bỏ Isolate xem TimerRepo có bị sinh 2 lần không
    // Isolate.exit(
    //   sendPort,
    //   Map<int, List<SocketSentMessageModel>>.fromIterable(
    //     listConversationInfo,
    //     key: (value) => value['conversationId'],
    //     value: (value) => List<SocketSentMessageModel>.from(
    //       (value['listMessages'] as List).map(
    //         (e) => SocketSentMessageModel.fromMap(
    //           e,
    //           userInfo: param[2],
    //           userType: param[3],
    //         ),
    //       ),
    //     ),
    //   ),
    // );

    return Map<int, List<SocketSentMessageModel>>.fromIterable(
      listConversationInfo,
      key: (value) => value['conversationId'],
      value: (value) => List<SocketSentMessageModel>.from(
        (value['listMessages'] as List).map(
          (e) => SocketSentMessageModel.fromMap(
            e,
            userInfo: param[2],
            userType: param[3],
          ),
        ),
      ),
    );
  }
}

///
