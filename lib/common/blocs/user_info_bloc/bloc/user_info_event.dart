import 'package:app_chat365_pc/utils/data/enums/auth_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:equatable/equatable.dart';

abstract class UserInfoEvent extends Equatable {
  final int userId;

  const UserInfoEvent(this.userId);

  @override
  List<Object?> get props => [];
}

class UserInfoEventAvatarChanged extends UserInfoEvent {
  final String? avatar;

  const UserInfoEventAvatarChanged({
    required int userId,
    required this.avatar,
  }) : super(userId);

  @override
  List<Object?> get props => [avatar, userId];
}

class UserInfoEventGroupAvatarChanged extends UserInfoEvent {
  final String? avatar;

  const UserInfoEventGroupAvatarChanged({
    /// Nó là super.userId
    required int conversationId,
    required this.avatar,
  }) : super(conversationId);

  @override
  List<Object?> get props => [avatar, userId];
}

@Deprecated("Dùng ChatEventOnGroupNameChanged nhé")
class UserInfoEventGroupNameChanged extends UserInfoEvent {
  final String name;

  const UserInfoEventGroupNameChanged({
    /// Nó là super.userId
    required int conversationId,
    required this.name,
  }) : super(conversationId);

  @override
  List<Object?> get props => [name, userId];
}

class UserInfoEventUserNameChanged extends UserInfoEvent {
  final String name;

  const UserInfoEventUserNameChanged({
    required int userId,
    required this.name,
  }) : super(userId);

  @override
  List<Object?> get props => [name, userId];
}

class UserInfoEventUserStatusChanged extends UserInfoEvent {
  final UserStatus userStatus;

  const UserInfoEventUserStatusChanged({
    required int userId,
    required this.userStatus,
  }) : super(userId);

  @override
  List<Object?> get props => [userStatus, userId];
}

class UserInfoEventStatusChanged extends UserInfoEvent {
  final String status;

  const UserInfoEventStatusChanged({
    required int userId,
    required this.status,
  }) : super(userId);

  @override
  List<Object?> get props => [userId, status];
}

class UserInfoEventNicknameChanged extends UserInfoEvent {
  final String newNickname;
  final int conversationId;

  const UserInfoEventNicknameChanged({
    required this.newNickname,
    required this.conversationId,
  }) : super(-1);

  @override
  List<Object?> get props => [userId, newNickname, conversationId];
}

class UserInfoEventActiveTimeChanged extends UserInfoEvent {
  final AuthStatus status;
  final DateTime? lastActive;

  const UserInfoEventActiveTimeChanged(
    int userId,
    this.status, {
    required this.lastActive,
  }) : super(userId);

  @override
  List<Object?> get props => [status, userId, lastActive];
}
