import 'package:app_chat365_pc/common/models/user_contact_model.dart';
import 'package:equatable/equatable.dart';

class UserContactState extends Equatable{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
class InitialStateUserContact extends UserContactState {}
class LoadingStateUserContact extends UserContactState{}
class LoadedStateUserContact extends UserContactState{
  LoadedStateUserContact(this.listUser);
 final List<UserContactModel> listUser;
}
class ErrorStateUserContact extends UserContactState{
  ErrorStateUserContact(this.mess);
  final String mess;
}