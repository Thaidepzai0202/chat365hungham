import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/friend_cubit/cubit/friend_state.dart';
import 'package:app_chat365_pc/common/blocs/friend_cubit/model/result_friend_model.dart';
import 'package:app_chat365_pc/common/blocs/friend_cubit/repo/friend_repo.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/api_contact.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/contact/repo/contact_list_repo.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:bloc/bloc.dart';

class FriendCubit extends Cubit<FriendState> {
  FriendCubit({
    required this.chatRepo,
    // required this.contactListRepo,
  }) : super(FriendStateLoading()) {
    _subscription = chatRepo.stream.listen((event) async {
      if (event is ChatEventOnFriendStatusChanged) {
        await fetchFriendData();
        // if (friendsRequest == null) return;
        var status = event.status;
        var senderId = event.requestUserId;
        var recieveId = event.responseUserId;

        changeStatus(senderId, recieveId, status);
      } else if (event is ChatEventOnDeleteContact) {
        var otherId;
        if (userId == event.userId)
          otherId = event.chatId;
        else
          otherId = event.userId;
        friendsRequest.remove(otherId);
        listFriends?.removeWhere(
          (element) => element.id == otherId,
        );
        emit(FriendStateDeleteContact(event.userId, event.chatId));
        // emit(FriendStateLoadSuccess());
      }
    });
  }

  int get userId => navigatorKey.currentContext!.userInfo().id;

  int? get companyId => navigatorKey.currentContext!.userInfo().companyId;

  final FriendRepo _friendRepo = FriendRepo();
  final ChatRepo chatRepo;
  late final StreamSubscription _subscription;

  /// Trạng thái kết bạn giữa mình và người ta
  /// Key - Value: ID người ta - Friend model của mình với họ
  Map<int, FriendModel> friendsRequest = {};
  // TL Note 16/12/2023:
  // Đây KHÔNG PHẢI danh sách những người đã kết bạn thành công
  // Đây hình như là những người mình đã nói chuyện cùng thì phải?
  Set<IUserInfo>? listFriends;

  /// TL note 16/12/2023:
  /// @senderId: Chắc là chính người dùng hiện tại chứ ai
  /// @responseId: Id người mà mình muốn sửa status
  /// @status: status mới
  changeStatus(int senderId, int responseId, FriendStatus status) async {
    print(status);
    if (status == FriendStatus.accept) {
      friendsRequest.remove(responseId);
    } else {
      friendsRequest[responseId] = FriendModel(
        userId: userId,
        contactId: responseId,
        status: status,
      );
    }
    emit(
      FriendStateLoadSuccess(),
    );
  }

  Future fetchListFriend() async {
    var contactListRepo = ContactListRepo(
      userId,
      companyId: companyId ?? 0,
    );
    try {
      listFriends = <IUserInfo>{
        ...(await contactListRepo.getMyContact()),
        ...await getListNewsFriends()
      };
    } catch (e, s) {
      logger.logError(e, s, 'FetchListFriendError');
    }
  }

  checkFriendStatus(int contactId) async {
    try {
      emit(FriendStateLoading());
      var res = await _friendRepo.checkFriendStatus(contactId);
      if (!res.hasError) {
        var data = json.decode(res.data)['data']['request'];
        if (data['contactId'] != contactId) {
          data['userId'] = AuthRepo().userId;
          data['contactId'] = contactId;
          if (data['status'] == 'send') data['status'] = 'request';
        }
        var model = FriendModel.fromJson(data);
        friendsRequest[model.contactId] = model;
        print(friendsRequest[model.contactId]);
        emit(FriendStateLoadSuccess());
      } else {
        emit(FriendStateLoadError(
          res.error!,
        ));
      }
    } catch (e) {
      emit(FriendStateLoadError(ExceptionError(e.toString())));
    }
  }

  /// TL note 16/12/2023:
  /// Lấy hết mọi dữ liệu về bạn, bao gồm:
  /// - Danh sách bạn bè
  /// - Trạng thái những lời mời kết bạn (cả mình và người ta)
  Future<void> fetchFriendData() async {
    try {
      await Future.wait([
        getListFriendRequest(),
        fetchListFriend(),
      ]);
      if (friendsRequest == null)
        throw CustomException(
          ExceptionError(
            'Lấy danh sách lời mời kết bạn thất bại, vui lòng thử lại !',
          ),
        );
      else if (listFriends == null)
        throw CustomException(
          ExceptionError(
            'Lấy danh sách bạn bè thất bại, vui lòng thử lại !',
          ),
        );
      emit(FriendStateLoadSuccess());
    } on CustomException catch (e) {
      if (e.error.error == 'User không có lời mời nào') {
        friendsRequest = {};
        return emit(FriendStateLoadSuccess());
      }

      emit(FriendStateLoadError(e.error, markNeedBuild: true));
    }
  }

  Future getListFriendRequest() async {
    var res = await _friendRepo.getListRequest(userId);
    try {
      res.onCallBack((_) {
        var models = [
          ...resultFriendModelFromJson(res.data).data!.listRequestContact
        ];
        friendsRequest = Map<int, FriendModel>.fromIterable(
          models,
          key: (item) => (item as FriendModel).contactId,
        );
      });
    } on CustomException catch (_) {
      rethrow;
    }
  }

  Future<List<ApiContact>> getListNewsFriends() async {
    var res = await _friendRepo.getListNewFriends(userId);
    try {
      return res.onCallBack((_) {
        return List<ApiContact>.from(
            jsonDecode(res.data)['data']['listAccount'].map((e) => ApiContact(
                  avatar: e['avatarUser'],
                  name: e['userName'],
                  id: e['_id'],
                  companyId: null,
                  lastActive: DateTime.tryParse(e['lastActive']),
                )));
      });
    } on CustomException catch (_) {
      return [];
    }
  }

  Future<bool> _deleteRequestAddFriend(int senderId, int recieveId) async {
    var deleteRequest =
        await _friendRepo.deleteRequestAddFriend(senderId, recieveId);
    try {
      return await deleteRequest.onCallBack(
        (_) {
          var decode = json.decode(deleteRequest.data)['data'];
          var isExist = false;
          try {
            if (json.decode(deleteRequest.data)['error']['message'] ==
                "Lời mời không tồn tại") {
              isExist = true;
            }
          } catch (_) {}
          return isExist || decode['result'];
        },
      );
    } on CustomException catch (e) {
      if (e.error.error == "Lời mời không tồn tại") return true;
      return false;
    } catch (e, s) {
      logger.logError(e, s);
      return false;
    }
  }

  Future<bool> deleteRequestAddFriend(int senderId, int recieveId) async {
    var res = await _deleteRequestAddFriend(senderId, recieveId);
    if (res) {
      friendsRequest.remove(recieveId);
      emit(FriendStateLoadSuccess());
    }
    return res;
  }

  Future<ExceptionError?> addFriend(IUserInfo receive) async {
    var senderId = navigatorKey.currentContext!.userInfo().id;
    var receiveId = receive.id;
    emit(FriendStateAddFriendLoading(chatId: receiveId));
    try {
      if (friendsRequest[receiveId]?.status == FriendStatus.decline) {
        var isDeleteSuccess = await deleteRequestAddFriend(senderId, receiveId);
        if (isDeleteSuccess) {
          return _addFriend(senderId, receive);
        } else
          throw CustomException(
            ExceptionError('Kết bạn thất bại, vui lòng thử lại'),
          );
      } else
        return _addFriend(senderId, receive);
    } on CustomException catch (e) {
      emit(FriendStateAddFriendError(receiveId, e.error));
      return e.error;
    }
  }

  Future<ExceptionError?> _addFriend(int senderId, IUserInfo receiver) async {
    try {
      var res = await _friendRepo.addFriend(senderId, receiver.id);
      // res.onCallBack((_) => res.result);
      log('${res.error}', name: 'LogError');
      if (res.error == null) {
        friendsRequest[receiver.id]?.changeStatus(FriendStatus.send);
        emit(FriendStateAddFriendSuccess(receiver));
        chatRepo.emitAddFriend(senderId, receiver.id);
        return null;
      } else {
        emit(FriendStateAddFriendError(
            receiver.id, ExceptionError(res.error!.error)));
        return ExceptionError(res.error!.error);
      }
    } on CustomException catch (e) {
      if (e.error.error == 'User đã tồn tại lời mời') {
        emit(FriendStateAddFriendSuccess(receiver));
        // chatRepo.emitAddFriend(senderId, receiver.id);
        return null;
      }
      emit(FriendStateAddFriendError(receiver.id, e.error));
      return e.error;
    }
  }

  /// TL 16/12/2023 note:
  /// Phản hồi lời mời kết bạn
  /// @responseId: Chính là người dùng hiện tại.
  /// @requestUser: Người gửi lời mời tới mình
  /// @status: FriendStatus.accept nếu là chấp nhận lời mời. Các status khác đều là từ chối.
  /// Định sửa @status thành bool @accepted, nhưng nghĩ lại, thôi. Chả biết liệu có
  /// điều gì lẩn khuất sau các status khác ngoài accept và decline không
  responseAddFriend(
    int responseId,
    IUserInfo requestUser,
    FriendStatus status,
  ) async {
    var requestId = requestUser.id;
    emit(FriendStateResponseAddFriendLoading(requestId));

    try {
      var res = await chatRepo.responseAddFriend(
        responseId,
        requestId,
        status,
      );

      if (res) {
        if (status == FriendStatus.accept)
          listFriends?.add(requestUser);
        else
          listFriends?.removeWhere((e) => e.id == responseId);
        emit(FriendStateResponseAddFriendSuccess(
          requestId,
          status,
          requestInfo: requestUser,
        ));
      }
    } on CustomException catch (e) {
      emit(FriendStateResponseAddFriendError(e.error, requestId));
    } catch (e, s) {
      logger.logError(e, s);
      emit(FriendStateResponseAddFriendError(
          ExceptionError.unknown(), requestId));
    }
  }

  /// Xóa liên hệ
  Future<ExceptionError?> deleteContact(int contact) async {
    var res = await _friendRepo.deleteContact(userId, contact);
    try {
      res.onCallBack((_) {
        if (res.result == true) {
          chatRepo.emitDeleteContact(userId, contact);
          emit(FriendStateDeleteContact(userId, contact));
        }
      });
    } on CustomException catch (e) {
      return e.error;
    }
    return null;
  }

  @override
  void onChange(Change<FriendState> change) async {
    if (change.nextState is FriendStateAddFriendSuccess) {
      var chatId = (change.nextState as FriendStateAddFriendSuccess).chatId;
      // if(friendsRequest[chatId]==null)friendsRequest.addAll({})
      friendsRequest[chatId] = FriendModel(
        userId: userId,
        contactId: chatId,
        status: FriendStatus.send,
      );
    } else if (change.nextState is FriendStateResponseAddFriendSuccess) {
      var nextState = (change.nextState as FriendStateResponseAddFriendSuccess);
      var chatId = nextState.requestId;
      var senderId = navigatorKey.currentContext!.userInfo().id;

      try {
        var userInfo;
        if (nextState.requestInfo == null) {
          userInfo = await UserInfoRepo().getUserInfo(chatId);
          // var res = await AuthRepo().getUserInfo(chatId);
          // var resultLoginData = resultLoginFromJson(res.data).data!;
          // userInfo = resultLoginData.userInfo;
        } else
          userInfo = nextState.requestInfo!;

        if (nextState.status == FriendStatus.accept) listFriends?.add(userInfo);

        changeStatus(
          senderId,
          chatId,
          (change.nextState as FriendStateResponseAddFriendSuccess).status,
        );
      } catch (e, s) {
        logger.logError(e, s);
      }
    }
    super.onChange(change);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
