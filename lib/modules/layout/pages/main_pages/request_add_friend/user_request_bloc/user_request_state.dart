
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/model/user_in_com.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages/request_add_friend/model/user_request_model.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:equatable/equatable.dart';


class RequestState extends Equatable{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
// take list request
class InitialRequestState extends RequestState{}
class  LoadingRequestState extends RequestState{}
class LoadedRequestState extends RequestState{
  LoadedRequestState(this.listMyRequest,this.listSendRequest,this.listUserInCom);
  final List<UserRequest>? listMyRequest;
  final List<UserRequest>? listSendRequest;
  final List<UserInCom>? listUserInCom;
}
class EmptyRequestState extends RequestState{}
class ErrorRequestState extends RequestState{
  ErrorRequestState(this.mess);
  final String mess;
}

// take user in company
class InitialUserInComState extends RequestState{}
class  LoadingUserInComState extends RequestState{}
class EmptyUserInComState extends RequestState{}
class ErrorUserInComState extends RequestState{
  ErrorUserInComState(this.mess);
  final String mess;
}

// add friend
class InitialAddFriendState extends RequestState{}
class  LoadingAddFriendState extends RequestState{}
class  LoadedAddFriendState extends RequestState{}
class EmptyAddFriendState extends RequestState{}
class ErrorAddFriendState extends RequestState{
  ErrorAddFriendState(this.mess);
  final String mess;
}

// Add friend ==================================================================

class FriendStateAddFriend extends RequestState {
  final int? senderId;
  final int chatId;

  FriendStateAddFriend({
    this.senderId,
    required this.chatId,
  });
}

class FriendStateAddFriendLoading extends FriendStateAddFriend {
  FriendStateAddFriendLoading({required int chatId}) : super(chatId: chatId);
}

class FriendStateAddFriendSuccess extends FriendStateAddFriend {
  final IUserInfo userInfo;

  FriendStateAddFriendSuccess(this.userInfo) : super(chatId: userInfo.id);
}

class FriendStateAddFriendError extends FriendStateAddFriend {
  final int chatId;
  final ExceptionError error;

  FriendStateAddFriendError(this.chatId, this.error) : super(chatId: chatId);
}

