import 'dart:convert';
import 'dart:io';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';
import 'package:app_chat365_pc/utils/helpers/file_utils.dart';
import 'package:dio/dio.dart';

class GroupProfileRepo {
  final ApiClient _apiClient;

  /// Nếu là group infoId = conversationId
  ///
  /// Nếu là user infoId = id của user đó
  final int infoId;

  final int currentUserId = navigatorKey.currentContext!.userInfo().id;

  /// DEPRECATED
  /// Chẳng để làm gì, nhưng bỏ đi thì code cũ gãy
  final bool isGroup;
  List<int>? deputeAdmin;
  int? memberApproval;
  GroupProfileRepo(this.infoId, this.isGroup) : _apiClient = ApiClient();
  //GroupProfileRepo(this.infoId) : _apiClient = ApiClient();

  Future<void> changeName({
    required String newName,
    required List<int> memberIds,
  }) async {
    final RequestResponse res = await _apiClient.fetch(
      ApiPath.changeGroupName,
      data: {
        'conversationId': infoId,
        'conversationName': newName,
      },
    );

    if (res.hasError) throw res.error!.messages!;

    chatClient.emit(
      ChatSocketEvent.changeGroupName,
      [infoId, newName, memberIds],
    );
  }

  Future<void> changeAvatar({
    required File file,
    required List<int> memberIds,
  }) async {
    final RequestResponse res = await _apiClient.upload(
      ApiPath.changeGroupAvatar,
      [await MultipartFile.fromFile(file.path)],
    );

    if (res.hasError) throw res.error!.messages!;

    chatClient.emit(
      ChatSocketEvent.changeGroupAvatar,
      [infoId, file.nameOnly, memberIds],
    );
  }

  Future<int> getMemberApproval() async {
    var res = await _apiClient.fetch(
      ApiPath.getMemberApproval,
      data: {
        'senderId': currentUserId,
        'conversationId': infoId,
        'status': 'gì cũng đc',
      },
    );
    ;
    return res.onCallBack(
      (_) => json.decode(res.data)['data']['memberApproval'],
    );
  }

  Future<ExceptionError?> updateMemberApproval() async {
    var res = await _apiClient.fetch(
      ApiPath.updateMemberApproval,
      data: {
        'senderId': currentUserId,
        'conversationId': infoId,
      },
    );
    ;
    try {
      res.onCallBack((_) {});
      return null;
    } on CustomException catch (e) {
      return e.error;
    }
  }

  // Thêm/Xóa phó nhóm
  // @senderId: Chính là người dùng hiện tại
  // @conversationId: Id cuộc trò chuyện
  // @memberId: Id của những người mình muốn thêm/bớt phó nhóm
  // @type: "add" hoặc "delete".
  Future<RequestResponse> updateDeputyAdmin(
      List<int> memberId, String type) async {
    return _apiClient.fetch(
      ApiPath.updateDeputyAdmin,
      data: {
        'senderId': currentUserId,
        'conversationId': infoId,
        'memberId': memberId.toString(),
        'type': type,
      },
    );
  }

  /// Trần Lâm note 23/12/2023: Bỏ @status
  /// Dùng hàm này khi:
  /// - Bạn là dân thường muốn thêm người vào nhóm. Khi ấy:
  /// -- Nếu nhóm không bị kiểm duyệt: Người đó được thêm luôn
  /// -- Nếu nhóm không bị kiểm duyệt: Người đó vào hàng chờ kiểm duyệt
  /// - Trưởng/phó nhóm muốn thêm người vào nhóm. Vào luôn
  Future<ExceptionError?> addNewMemberToGroup({
    required Iterable<int> newMemberIds,
    required String conversationName,
  }) async {
    try {
      final RequestResponse res = await _apiClient.fetch(
        ApiPath.addNewMemberToGroup,
        data: {
          'memberList': newMemberIds.toString(),
          'senderId': currentUserId,
          'conversationId': infoId,
          'conversationName': conversationName,
          'status': 'add',
        },
      );

      ChatRepo().streamController.add(ChatEventOnNewMemberAddedToGroup(
          infoId, (await UserInfoRepo().getUserInfos(newMemberIds)).toList()));

      //res.onCallBack((_) {});
      return null;
    } on CustomException catch (e) {
      return e.error;
    }
  }

  /// Trần Lâm note 23/12/2023: Bỏ @status
  /// Dùng hàm này khi:
  /// - Bạn là dân thường muốn xóa người khỏi nhóm. Người đó vào yêu cầu chờ xóa kiểm duyệt
  /// - Trưởng/phó nhóm muốn xóa người khỏi danh sách chờ duyệt, hoặc xóa thẳng khỏi nhóm.
  Future<ExceptionError?> deleteMemberToGroup({
    required Iterable<int> members,
    String deleteReason = "",
  }) async {
    try {
      await ApiClient().fetch(
        ApiPath.deleteMemberToGroup,
        data: {
          'memberList': members.toString(),
          'senderId': currentUserId,
          'conversationId': infoId,
          'reasonForDelete': deleteReason,
          'status': 'delete',
        },
      );
    } on CustomException catch (e) {
      return e.error;
    }
    return null;
  }

  /// Lấy tất cả người duyệt vào nhóm và yêu cầu xóa thành viên
  Future<RequestResponse> getListRequestAdminAll() {
    return ApiClient().fetch(ApiPath.getListRequestAdmin, data: {
      'userId': currentUserId,
      'conversationId': infoId,
    });
  }

  /// Lấy tất cả yêu cầu xóa thành viên
  Future<RequestResponse> getListRequestAdminAdd() =>
      ApiClient().fetch(ApiPath.getListRequestAdmin, data: {
        'userId': currentUserId,
        'conversationId': infoId,
        'status': 'add',
      });

  /// Lấy tất cả yêu cầu duyệt vào nhóm
  Future<RequestResponse> getListRequestAdminDelete() =>
      ApiClient().fetch(ApiPath.getListRequestAdmin, data: {
        'userId': currentUserId,
        'conversationId': infoId,
        'status': 'delete',
      });

  Future leaveGroup({
    required int deleteMemberId,
    required List<int> memberIds,
  }) async {
    final RequestResponse res = await _apiClient.fetch(
      ApiPath.leaveGroup,
      data: {
        'conversationId': infoId,
        'senderId': deleteMemberId,
        'adminId': -1,
      },
    );

    if (res.hasError) throw res.error!.messages!;

    chatClient.emit(
      ChatSocketEvent.outGroup,
      [infoId, deleteMemberId, -1, memberIds],
    );
  }

  changeStatus(String text) async {
    // TODO: Không có api https đổi status
    chatClient.emit(ChatSocketEvent.changeMoodMessage, [infoId, text]);
  }

  changeUserStatus(UserStatus status) {
    _apiClient.fetch(ApiPath.changePresenceStatus, data: {
      'ID': infoId,
      'Active': status.id,
    });
    chatClient.emit(ChatSocketEvent.changePresenceStatus, [infoId, status.id]);
  }

  Future<RequestResponse> changeAdminId(
      {int? conversationId, required int newAdminId}) async {
    return await _apiClient.fetch(ApiPath.changeAdmin, data: {
      'senderId': navigatorKey.currentContext?.userInfo().id,
      'alternative': newAdminId,
      'conversationId': conversationId,
      'token': AuthRepo.authToken,
    });
  }

  Future<RequestResponse> disbandGroup({int? conversationId}) async {
    return await _apiClient.fetch(ApiPath.disbandGroup, data: {
      'AdminId': navigatorKey.currentContext?.userInfo().id,
      'conversationId': conversationId,
    });
  }

  Future<RequestResponse> getConversation({int? conversationId}) async {
    return await _apiClient.fetch(ApiPath.chatInfo, data: {
      'senderId': navigatorKey.currentContext?.userInfo().id,
      'conversationId': conversationId,
    });
  }

  Future<RequestResponse> getListMemberOfGroup({int? conversationId}) async {
    return await _apiClient.fetch(ApiPath.getListMemberOfGroup, data: {
      'conversationId': conversationId,
    });
  }

  void emitDisbandGroup(int? conversationId, List<int>? memberList) {
    chatClient.emit(ChatSocketEvent.disbandGroup, [conversationId, memberList]);
  }
}
