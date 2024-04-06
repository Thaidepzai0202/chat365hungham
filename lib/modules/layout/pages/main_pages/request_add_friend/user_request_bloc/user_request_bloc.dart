import 'dart:convert';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/model/friend_model.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/model/user_in_com.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/model/user_request_model.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/repos/user_request_repos.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/user_request_bloc/user_request_state.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserRequestBloc extends Cubit<RequestState> {
  UserRequestBloc() : super(InitialRequestState()) {
    // chatClient.on('DeleteRequestAddFriend',(data){
    //   logger.log(data.toString());
    //   var deleteID = data;
    //   listSendRequest.removeWhere((element) => element.id365 == deleteID);
    //   changeState();
    // });
    // chatClient.on('SendRequestAddFriend',(data){
    //   logger.log(data.toString());
    //   changeState();
    // });
  }
  ChatRepo chatRepo = ChatRepo();

  Map<int, FriendModel> friendsRequest = {};

  changeState() {
    emit(InitialRequestState());
    emit(LoadedRequestState(listRequest, listSendRequest, listUserInCom));
  }

  UserRequestRepo repo = UserRequestRepo();
  List<UserRequest> listRequest = [];
  List<UserRequest> listSendRequest = [];
  List<UserInCom> listUserInCom = [];
  late List<int> listUserId = [];

  // take list request
  Future<void> takeListRequest(
    int idUSer,
    int idCom,
  ) async {
    emit(InitialRequestState());
    try {
      final response = await repo.getListRequest();
      final response1 = await repo.getListSendRequest();
      final response2 = await repo.getListUserInCom(idUSer, idCom);
      if (!response.hasError) {
        var data = json.decode(response.data);
        emit(LoadingRequestState());
        if (data['data'] == null) {
          emit(EmptyRequestState());
          return;
        }
        listRequest = List.from(data['data']['listUsers'])
            .map((e) => UserRequest.fromJson(e))
            .toList();
      }
      if (!response1.hasError) {
        var data = json.decode(response1.data);
        emit(LoadingRequestState());
        if (data['data'] == null) {
          emit(EmptyRequestState());
          return;
        }
        listSendRequest = List.from(data['data']['listUsers'])
            .map((e) => UserRequest.fromJson(e))
            .toList();
      }
      if (!response2.hasError) {
        var data = json.decode(response2.data);
        emit(LoadingRequestState());
        if (data['data'] == null) {
          emit(EmptyRequestState());
          return;
        }
        listUserInCom = List.from(data['data']['user_list'])
            .map((e) => UserInCom.fromJson(e))
            .toList();
      }
      emit(LoadedRequestState(listRequest, listSendRequest, listUserInCom));
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorRequestState(e.toString()));
    }
  }
  /// [friendStatus] 1: đồng ý kết bạn , 2: huy ket ban
// tu choi, dong y loi moi ket ban
  Future<void> requestAddFriend(
    int idUser,
    int idContact,
    int friendStatus,
  ) async {
    emit(InitialRequestState());
    try {
      final response =
          await repo.requestAddFriend(idUser, idContact, friendStatus);
      if (!response.hasError) {
        listRequest.removeWhere((element) => element.uid == idContact);
        listUserId = [idUser, idContact];
        friendStatus == 1
            ? chatClient.emit('AcceptRequestAddFriend',[idUser,idContact])
            : chatClient.emit('DecilineRequestAddFriend',[idUser,idContact]);
        emit(LoadedRequestState(listRequest, listSendRequest, listUserInCom));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorRequestState(e.toString()));
    }
  }

// thu hồi lời mời kết bạn
  Future<void> deleteRequestAddFriend(
    int idUser,
    int idContact,
  ) async {
    emit(InitialRequestState());

    try {
      var response = await repo.deleteRequestAddFriend(idUser, idContact);
      if (!response.hasError) {
        listSendRequest.removeWhere((element) => element.uid == idContact);
        chatClient.emit('DeleteRequestAddFriend', [idContact, listUserId]);
        emit(LoadedRequestState(listRequest, listSendRequest, listUserInCom));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorRequestState(e.toString()));
    }
  }

// Gửi lời mời kết bạn
  Future<void> sendRequestAddFriend(
    int idUser,
    int idContact,
    int type365,
  ) async {
    try {
      final response = await repo.sendRequestAddFriend(idUser, idContact);
      if (!response.hasError) {
        chatClient.emit('AddFriend', [idUser, idContact, type365]);
        // chatRepo.emitAddFriend(idUser, idContact);
        print('ao vkl');
      } else {
        emit(ErrorAddFriendState('dm deo chay'));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorAddFriendState(e.toString()));
    }
  }
}
