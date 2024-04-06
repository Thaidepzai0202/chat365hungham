import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:equatable/equatable.dart';

class UserInfoState extends Equatable {
  const UserInfoState(this.userInfo,{this.event});

  final IUserInfo userInfo;
  final String? event;

  @override
  List<Object> get props => [event??DateTime.now()];
}

class UserInfoStateActiveTimeChanged extends UserInfoState {
  final DateTime? lastActive;

  UserInfoStateActiveTimeChanged(this.lastActive, IUserInfo userInfo)
      : super(userInfo);
}
