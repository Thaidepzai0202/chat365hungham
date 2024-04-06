
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/model/contact_model.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/model/list_account_model.dart';
import 'package:equatable/equatable.dart';

class ContactState extends Equatable{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
// lấy danh sách bạn bè
class InitialContactState extends ContactState{}
class  LoadingContactState extends ContactState{}
class LoadedContactState extends ContactState{
  LoadedContactState(this.listMyContact,this.listAccount);
 final List<ContactModel>? listMyContact;
  final List<ListAccount>? listAccount;
}
class EmptyContactState extends ContactState{}
class ErrorContactState extends ContactState{
  ErrorContactState(this.mess);
 final String mess;
}

// danh sách bạn mới
class InitialNewFriendState extends ContactState{}
class  LoadingNewFriendState extends ContactState{}
class  LoadedNewFriendState extends ContactState{
}
class EmptyNewFriendState extends ContactState{}
class ErrorNewFriendState extends ContactState {
  ErrorNewFriendState(this.mess);
  final String mess;
}