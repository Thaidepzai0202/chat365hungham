import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/modules/profile/model/member_in_group_model.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileStateLoading extends ProfileState {}

class ProfileStateLoadError extends ProfileState {
  final ExceptionError error;

  ProfileStateLoadError(this.error);

  @override
  List<Object?> get props => [DateTime.now()];
}

class ProfileStateLoadDone extends ProfileState {
  final ChatItemModel profile;

  ProfileStateLoadDone(this.profile);

  @override
  List<Object?> get props => [DateTime.now()];
}

//Change password
class ChangePasswordStateLoading extends ProfileState {}

class ChatDetailStateAddmemberLoadDone extends ProfileState {}

class ChangePasswordStateDone extends ProfileState {
  @override
  List<Object?> get props => [DateTime.now()];
}

class ChangePasswordStateError extends ProfileState {
  final ExceptionError error;

  ChangePasswordStateError(this.error);

  @override
  List<Object?> get props => [DateTime.now()];
}

//Change name (group, nickName)
class ChangeNameStateLoading extends ProfileState {}

class ChangeNameStateDone extends ProfileState {
  final String newName;

  ChangeNameStateDone({required this.newName});
  @override
  List<Object?> get props => [DateTime.now()];
}

class ChangeNameStateError extends ProfileState {
  final ExceptionError error;

  ChangeNameStateError(this.error);

  @override
  List<Object?> get props => [DateTime.now()];
}

// Add
class AddMemberStateLoading extends ProfileState {}

class AddMemberStateDone extends ProfileState {
  AddMemberStateDone({required this.member});

  final Map<int, IUserInfo> member;

  @override
  List<Object?> get props => [DateTime.now()];
}

class AddMemberStateError extends ProfileState {
  final ExceptionError error;

  AddMemberStateError(this.error);

  @override
  List<Object?> get props => [DateTime.now()];
}

//Remove
class RemoveMemberStateLoading extends ProfileState {}

class RemoveMemberStateDone extends ProfileState {
  @override
  List<Object?> get props => [DateTime.now()];
}

class RemoveMemberStateError extends ProfileState {
  final ExceptionError error;

  RemoveMemberStateError(this.error);

  @override
  List<Object?> get props => [DateTime.now()];
}

//Change avatar
class ChangeAvatarStateLoading extends ProfileState {}

class ChangeAvatarStateDone extends ProfileState {
  @override
  List<Object?> get props => [DateTime.now()];
}

class ChangeAvatarStateError extends ProfileState {
  final ExceptionError error;

  ChangeAvatarStateError(this.error);

  @override
  List<Object?> get props => [DateTime.now()];
}

class ProfileAdminState extends ProfileState {}

class ChangeAdminLoadingState extends ProfileAdminState {}

class ChangeAdminLoadDoneState extends ProfileAdminState {
  final int newAdminId;

  ChangeAdminLoadDoneState(this.newAdminId);
}

class ChangeAdminFailureState extends ProfileAdminState {}

class CheckAdminFalseState extends ProfileAdminState {
  final int adminId;
  final List<int> deputyAdminId;
  final int memberApproval;
  CheckAdminFalseState({
    required this.adminId,
    required this.deputyAdminId,
    required this.memberApproval,
  });
}

class CheckAdminTrueState extends ProfileAdminState {
  final int adminId;
  final List<int> deputyAdminId;
  final int memberApproval;
  CheckAdminTrueState({
    required this.adminId,
    required this.deputyAdminId,
    required this.memberApproval,
  });
}

class DisbandGroupFalseState extends ProfileAdminState {}

class DisbandGroupSuccessState extends ProfileAdminState {}

class GetListMemberOfGroupFailed extends ProfileState {}

class GetListMemberOfGroupLoading extends ProfileState {}

class GetListMemberOfGroupDifferentLoading extends ProfileState {}

class GetListMemberOfGroupLoaded extends ProfileState {
  final List<ModelMemberOfGroup> listMemberOfGroup;
  GetListMemberOfGroupLoaded(this.listMemberOfGroup);
}

class GetListMemberOfGroupDifferentLoaded extends ProfileState {
  final List<ModelMemberOfGroup> listMemberOfGroup;
  GetListMemberOfGroupDifferentLoaded(this.listMemberOfGroup);
}

class ProfileStateLoadingMemberApproval extends ProfileState {
  /// "add": duyệt người vào nhóm
  /// "delete": yêu cầu xóa người khỏi nhóm
  /// "all": Cả hai cái trên
  final String type;
  ProfileStateLoadingMemberApproval(this.type);
}

class ProfileStateLoadedMemberApproval extends ProfileState {
  /// "add": duyệt người vào nhóm
  /// "delete": yêu cầu xóa người khỏi nhóm
  /// "all": Cả hai cái trên
  final String type;
  ProfileStateLoadedMemberApproval(this.type);
}

class ProfileStateLoadMemberApprovalError extends ProfileState {
  final String type;
  ProfileStateLoadMemberApprovalError(this.type);
}

// State thêm phó nhóm
class ProfileStateDeputyAdding extends ProfileState {}

class ProfileStateDeputyAdded extends ProfileState {
  final List<int> memberId;

  ProfileStateDeputyAdded({required this.memberId});
}

class ProfileStateDeputyAddError extends ProfileState {
  final String errMsg;

  ProfileStateDeputyAddError({required this.errMsg});
}

// State bỏ phó nhóm

class ProfileStateDeputyDeleting extends ProfileState {}

class ProfileStateDeputyDeleted extends ProfileState {
  final List<int> memberId;

  ProfileStateDeputyDeleted({required this.memberId});
}

class ProfileStateDeputyDeleteError extends ProfileState {
  final String errMsg;

  ProfileStateDeputyDeleteError({required this.errMsg});
}
