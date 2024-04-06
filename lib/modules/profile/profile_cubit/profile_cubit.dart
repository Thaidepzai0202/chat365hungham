import 'dart:convert';
import 'dart:io';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_detail_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/profile/model/member_in_group_model.dart';
import 'package:app_chat365_pc/modules/profile/models/member_approval_model.dart';
import 'package:app_chat365_pc/modules/profile/profile_cubit/profile_state.dart';
import 'package:app_chat365_pc/modules/profile/repo/group_profile_repo.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this.chatId, {
    required this.isGroup,
  })  : profileRepo = GroupProfileRepo(
          chatId,
          true,
        ),
        detailRepo = ChatDetailRepo(
          senderId,
        ),
        super(ChangePasswordStateLoading()) {
    // loadProfile();
  }

  final ChatDetailRepo detailRepo;
  static int senderId = AuthRepo().userInfo!.id;
  final GroupProfileRepo profileRepo;
  final int chatId;
  final bool isGroup;

  /// TODO: Nên truyền chatRepo vào thay vì gắn biến global cho nó
  final ChatRepo chatRepo = navigatorKey.currentContext!.read<ChatRepo>();
  List<ModelMemberOfGroup> listMemberOfGroup = [];

  // Danh sách chờ duyệt vào
  List<MemberApproval> addRequests = [];
  // Yêu cầu xóa thành viên
  List<MemberApproval> deleteRequests = [];

  loadProfile() async {
    if (!isGroup) return;
    emit(ChangePasswordStateLoading());
    // TL 2/1/2024: Caching thông tin CTC
    var chatItemModel = await ChatRepo().getChatItemModel(chatId);
    if (chatItemModel != null) {
      emit(ProfileStateLoadDone(chatItemModel));
    } else {
      emit(ProfileStateLoadError(ExceptionError(
          "$runtimeType: Không lấy được thông tin từ ChatRepo. Có khi đang mất mạng.")));
    }
    // TL 2/1/2024: Nếu sau 2 tháng mà app vẫn chạy tốt, thì xóa cục này đi nhé
    // var res = await detailRepo.loadConversationDetail(chatId);
    // try {
    //   res.onCallBack(
    //     (_) => emit(
    //         ProfileStateLoadDone(ChatItemModel.fromConversationInfoJsonOfUser(
    //       detailRepo.userId,
    //       conversationInfoJson: json.decode(res.data)["data"]
    //           ["conversation_info"],
    //     ))),
    //   );
    // } on CustomException catch (e) {
    //   emit(ProfileStateLoadError(e.error));
    // }
  }

  void changeStatus(String text) async {
    await profileRepo.changeStatus(text);
  }

  void changeUserStatus(UserStatus status) async {
    await profileRepo.changeUserStatus(status);
  }

  changePassword(
      {required String newPassword, required String oldPassword}) async {
    // if (!isGroup) return;
    emit(ChangePasswordStateLoading());
    var res = await detailRepo.changePassword(
        email: navigatorKey.currentContext!.userInfo().email!,
        type365: navigatorKey.currentContext!.userType().id,
        newPassword: newPassword,
        oldPassword: oldPassword);
    try {
      res.onCallBack(
        (_) => emit(ChangePasswordStateDone()),
      );
    } on CustomException catch (e) {
      emit(ChangePasswordStateError(e.error));
    }
  }

  UpdateDoubleVerify({
    required int status,
    required int userId,
  }) {
    return detailRepo.UpdateDoubleVerify(
      status: status,
      userId: userId,
    );
  }

  Future<int> GetStatusDoubleVerify(int userId) async {
    var res = await detailRepo.GetStatusDoubleVerify(userId: userId);
    return res.onCallBack(
      (_) => int.parse(
          json.decode(res.data)['data']['data']['doubleVerify'].toString()),
    );
  }

  emitstate() {
    emit(RemoveMemberStateDone());
  }

  @Deprecated("Dùng ChatRepo().getConversationId() nhé")
  Future<int> getConversationId(int senderId, int chatId) async {
    return (await ChatRepo().getConversationId(chatId))!;
  }

  //Thay doi ca biet danh va ten cua nguoi dung
  // Trần Lâm note: DEPRECATE việc đổi tên nhóm bằng hàm này
  // Sử dụng changeGroupName() bên dưới
  changeNickName(
    String newNickName,
    IUserInfo userInfo,
    bool isGroup,
    int userMainId,
    int userMainType,
    List<int> members,
  ) async {
    emit(ChangeNameStateLoading());
    try {
      int conversationId = userInfo.id;
      if (userInfo.id != userMainId)
        conversationId = await getConversationId(
          userInfo.id,
          chatId,
        );
      if (newNickName.trim() != '') {
        var id = isGroup ? chatId : conversationId;
        var res = await ApiClient().fetch(
          isGroup
              ? ApiPath.changeGroupName
              : userInfo.id != userMainId
                  ? ApiPath.changeNickName
                  : ApiPath.changeUserName,
          data: isGroup
              ? {
                  'conversationId': isGroup ? chatId : conversationId,
                  'conversationName': newNickName,
                  'userId': userMainId,
                  // TL: trước "?" đã test isGroup == true mới vào được đây rồi
                  // Bây giờ cho cái if() này vào như không à
                  if (!isGroup)
                    'adminId': navigatorKey.currentContext!.userInfo().id,
                }
              : userInfo.id != userMainId
                  ? {
                      'conversationName': newNickName,
                      'conversationId': conversationId,
                      'adminId': userMainId,
                    }
                  : {
                      'ID': userMainId,
                      'UserName': newNickName,
                      'Type365': userMainType,
                    },
        );
        if (!res.hasError) {
          if (userInfo.id == userMainId) {
            chatRepo.emitChangeUserName(userMainId, newNickName);
          } else {
            chatRepo.emitNameChanged(
              id,
              newNickName,
              isGroup,
              members,
            );
          }
          emit(ChangeNameStateDone(newName: newNickName));
        }
      } else {
        emit(ChangeNameStateError(ExceptionError('')));
      }
    } on CustomException catch (e) {
      emit(ChangeNameStateError(e.error));
    }
  }

  /// @newName: Tên đổi mới cho nhóm
  /// @members: Các thành viên trong nhóm đó
  /// Bắt đầu: ChangeNameStateLoading()
  /// Thành công: ChangeNameStateDone()
  /// Thất bại: ChangeNameStateError()
  /// Trần Lâm note 12/12/2023:
  /// NOTE 1: Lẽ ra phải có cơ chế để tự động lookup thành viên nhóm trong này
  /// bằng ChatConversationBloc hay gì đấy luôn. Cơ mà eh, kệ đi
  /// NOTE 2: GroupProfileRepo cũng có changeName(), cũng gọi API tương tự
  /// nhưng có vẻ luồng changeName đã cũ rồi, toàn thiếu/thừa tham số
  Future<void> changeGroupName({
    required String newName,
    // Để tạm đây trong trường hợp cần/không cần dùng đến, thì bỏ đi cũng dễ
    List<int> members = const [],
  }) async {
    emit(ChangeNameStateLoading());
    try {
      var res = await ApiClient().fetch(ApiPath.changeGroupName, data: {
        'conversationId': chatId,
        'conversationName': newName,
        'userId': AuthRepo().userInfo!.id,
        // Hỏi anh Việt Anh, thì có vẻ adminId là luồng cũ rồi
        //'adminId': AuthRepo().userInfo!.id,
      });
      if (res.hasError) {
        emit(ChangeNameStateError(ExceptionError(res.error!.error)));
        return;
      }

      // TODO: Chưa đọc luồng này
      // chatRepo.emitNameChanged(
      //   chatId,
      //   newName,
      //   isGroup,
      //   members,
      // );
      emit(ChangeNameStateDone(newName: newName));
    } catch (e) {
      emit(ChangeNameStateError(ExceptionError(e.toString())));
    }
  }

  // TL 25/12/2023: Hay là gọi hàm này để xóa thành viên nhỉ?
  Future<ExceptionError?> leaveGroup(
    IUserInfo userInfo,
    List<int> members, {
    int? newAdminId,
  }) async {
    emit(RemoveMemberStateLoading());
    // int conversationId = await _getConversationId(
    //   userInfo.id,
    //   chatId,
    // );
    try {
      var adminId = navigatorKey.currentContext!.userInfo().id;
      var deleteMemberId = userInfo.id;
      var res = await ApiClient().fetch(
        ApiPath.leaveGroup,
        data: {
          'conversationId': chatId,
          'senderId': deleteMemberId,
          'adminId': newAdminId,
        },
      );
      print(res);
      if (!res.hasError) {
        print('emit thành công'.addColor(StrColor.green));
        emit(RemoveMemberStateDone());
        // WIO.EmitAsync("OutGroup", conversationId, userId, adminId, listMember);
        chatRepo.emitDeleteMember(
          chatId,
          deleteMemberId,
          adminId,
          members,
          userInfo.name,
        );
      }
    } on CustomException catch (e) {
      emit(RemoveMemberStateError(e.error));
      return e.error;
    }

    return null;
  }

  Future<void> addMemberToGroup(
    List<IUserInfo> userInfo,
    List<int> members, {
    int? newAdminId,
    required String conversationName,
  }) async {
    var addMemberId = userInfo.map((e) => e.id).toList();
    Map<int, IUserInfo> memberMap = {};
    for (var value in userInfo) {
      memberMap.addAll({value.id: value});
    }
    var res = await profileRepo.addNewMemberToGroup(
        newMemberIds: addMemberId,
        //oldMemberIds: members,
        conversationName: conversationName);
    emit(AddMemberStateDone(member: memberMap));
  }

  /// DEPRECATED:
  /// Ưu tiên sử dụng các hàm getListRequestAdmin* bên dưới
  // Future<List<MemberApproval>> getListRequestAdmin(String status) async {
  //   var listRequestAdmin = await profileRepo.getListRequestAdminAll(status);
  //   if (listRequestAdmin.hasError) return [];
  //   return listRequestAdmin.onCallBack(
  //     (_) {
  //       return List<MemberApproval>.from(
  //           (json.decode(listRequestAdmin.data)['data'][status] as List)
  //               .map((e) => MemberApproval.fromJson(e)));
  //     },
  //   );
  // }

  /// Lấy danh sách chờ duyệt vào nhóm + yêu cầu xóa thành viên
  void getListRequestAdminAll() async {
    emit(ProfileStateLoadingMemberApproval("all"));
    var listRequestAdmin = await profileRepo.getListRequestAdminAll();
    if (listRequestAdmin.hasError) {
      emit(ProfileStateLoadMemberApprovalError("all"));
      return;
    }

    addRequests = List<MemberApproval>.from(
        (json.decode(listRequestAdmin.data)['data']["add"] as List)
            .map((e) => MemberApproval.fromJson(e)));

    deleteRequests = List<MemberApproval>.from(
        (json.decode(listRequestAdmin.data)['data']["delete"] as List)
            .map((e) => MemberApproval.fromJson(e)));
    emit(ProfileStateLoadedMemberApproval("all"));
  }

  Future<void> addDeputyAdmin(List<int> memberId) async {
    emit(ProfileStateDeputyAdding());
    var res = await profileRepo.updateDeputyAdmin(memberId, 'add');
    if (res.hasError) {
      emit(ProfileStateDeputyAddError(errMsg: res.error!.error));
      return;
    }
    if (jsonDecode(res.data)["data"]["message"] ==
        "Cập nhật thông tin thành công") {
      emit(ProfileStateDeputyAdded(memberId: memberId));
      return;
    }
    emit(ProfileStateDeputyAddError(errMsg: "Unknown"));
  }

  Future<void> deleteDeputyAdmin(List<int> memberId) async {
    emit(ProfileStateDeputyDeleting());
    var res = await profileRepo.updateDeputyAdmin(memberId, 'delete');
    if (res.hasError) {
      emit(ProfileStateDeputyDeleteError(errMsg: res.error!.error));
      return;
    }
    if (jsonDecode(res.data)["data"]["message"] ==
        "Cập nhật thông tin thành công") {
      emit(ProfileStateDeputyDeleted(memberId: memberId));
      return;
    }
    emit(ProfileStateDeputyDeleteError(errMsg: "Unknown"));
  }

  //Doi avatar nguoi dung va group
  changeAvatar({
    required File fileAvatar,
    //Neu la nhom
    int? idConversation,

    /// Bỏ tham số này đi vẫn chạy được. Tham số thừa
    //required IUserInfo userInfo,
    required List<int> members,
  }) async {
    emit(ChangeAvatarStateLoading());
    try {
      late File newAvatar;

      /// Doi ten file va duoi anh
      // Doi mac dinh la jpg vi api doi anh nhom chi nhan jpg con anh nguoi dung gioi han 1 so dinh dang.
      if (isGroup && idConversation != null) {
        String dir = path.dirname(fileAvatar.path);
        String newPath = path.join(dir,
            '${DateTime.now().microsecondsSinceEpoch}_${idConversation}.${'jpg'}');
        newAvatar = await File(fileAvatar.path).copy(newPath);
      } else {
        String dir = path.dirname(fileAvatar.path);
        String newPath = path.join(dir,
            '${DateTime.now().microsecondsSinceEpoch}_${navigatorKey.currentContext!.userInfo().id}.${'jpg'}');
        newAvatar = await File(fileAvatar.path).copy(newPath);
      }

      /// TODO: Chỗ này có thể refactor lại
      /// Đặt ChatDetailRepo và GroupProfileRepo cùng kế thừa class X nào đấy
      /// Sau đó để X có hàm changeAvatar()
      var res = await ApiClient()
          .fetch(isGroup ? ApiPath.changeGroupAvatar : ApiPath.changeAvatarUser,
              data: {
                '': isGroup && idConversation != null
                    ? await MultipartFile.fromFile(
                        newAvatar.path,
                      )
                    : await MultipartFile.fromFile(newAvatar.path),
                if (!isGroup) 'ID': navigatorKey.currentContext!.userInfo().id,
              },
              options: Options(
                receiveTimeout: Duration(milliseconds: 30000),
                sendTimeout: Duration(milliseconds: 30000),
              ));
      print(res);
      if (!res.hasError) {
        if (isGroup && idConversation != null) {
          /// Thay anh nhom
          chatRepo.emitChangeAvatarGroup(idConversation,
              json.decode(res.data)["data"]["message"], members);
          // userInfo.avatar='https://mess.timviec365.vn/avatarGroup/$idConversation/${newAvatar.path.split('/').last}';
        } else {
          /// Thay anh nguoi dung
          chatRepo.emitChangeAvatarUser(
            navigatorKey.currentContext!.userInfo().id,
            json.decode(res.data)["data"]["message"],
          );
        }
        emit(ChangeAvatarStateDone());
      } else {
        emit(ChangeAvatarStateError(ExceptionError('')));
      }
    } on CustomException catch (e) {
      emit(ChangeAvatarStateError(e.error));
    }
  }

  // changeAdmin({int? conversationId, required int newAdminId}) async {
  //   emit(ChangeAdminLoadingState());
  //   var res = await profileRepo.changeAdminId(
  //       conversationId: conversationId, newAdminId: newAdminId);
  //   if (res.hasError) {
  //     emit(ChangeAdminFailureState());
  //     AppDialogs.toast('Bạn không phải là trưởng nhóm');
  //   } else {
  //     emit(ChangeAdminLoadDoneState(newAdminId));
  //     AppDialogs.toast('Chuyển quyền trưởng nhóm thành công');
  //   }
  // }

  disbandGroup({int? conversationId, List<int>? member}) async {
    var res = await profileRepo.disbandGroup(conversationId: conversationId);
    if (res.hasError) {
      emit(DisbandGroupFalseState());
      profileRepo.emitDisbandGroup(conversationId, member);
    } else {
      emit(DisbandGroupSuccessState());
    }
  }

  @Deprecated(
      "Dùng (await ChatRepo().getChatItemModel(conversationId)).memberList nhé")
  getListMemberOfGroup({int? conversationId, int? type}) async {
    if (type == 1) {
      emit(GetListMemberOfGroupLoading());
    } else {
      emit(GetListMemberOfGroupDifferentLoading());
    }
    var res =
        await profileRepo.getListMemberOfGroup(conversationId: conversationId);
    if (res.hasError) {
      emit(GetListMemberOfGroupFailed());
    } else {
      var data = json.decode(res.data);
      listMemberOfGroup = List<ModelMemberOfGroup>.from(
          data['data']['userList'].map((e) => ModelMemberOfGroup.fromJson(e)));
      if (type == 1) {
        emit(GetListMemberOfGroupLoaded(listMemberOfGroup));
      } else {
        emit(GetListMemberOfGroupDifferentLoaded(listMemberOfGroup));
      }
    }
  }

  // // chặn tin nhắn
  // blockMessage(int userBlocked) {
  //   return PrivacyRepo().blockMessage(senderId, userBlocked);
  // }

  Future<Map<int, List<int>>> _getConversation({int? conversationId}) async {
    var res = await profileRepo.getConversation(conversationId: conversationId);
    if (res.hasError) {
      return {};
    } else {
      var data = json.decode(res.data)['data'];
      var adminID = data['conversation_info']['adminId'] as int;
      var deputyAdminId =
          ((data['conversation_info']['deputyAdminId'] ?? []) as List)
              .cast<int>();

      var map = {adminID: deputyAdminId};
      return map;
    }
  }

  checkAdmin({int? conversationId}) async {
    Map<int, List<int>> listAdminId =
        await _getConversation(conversationId: conversationId);
    var memberApproval = await profileRepo.getMemberApproval();
    //logger.log('adminId: $adminId - userId: ${AuthRepo().userId}');
    if (listAdminId.isEmpty) {
      emit(CheckAdminFalseState(
          adminId: listAdminId.keys.first,
          deputyAdminId: listAdminId.values.first,
          memberApproval: memberApproval));
    } else {
      if (listAdminId.values.first.contains(AuthRepo().userId) ||
          listAdminId.keys.first == AuthRepo().userId)
        emit(CheckAdminTrueState(
            adminId: listAdminId.keys.first,
            deputyAdminId: listAdminId.values.first,
            memberApproval: memberApproval));
      else
        emit(CheckAdminFalseState(
            adminId: listAdminId.keys.first,
            deputyAdminId: listAdminId.values.first,
            memberApproval: memberApproval));
    }
  }
}
