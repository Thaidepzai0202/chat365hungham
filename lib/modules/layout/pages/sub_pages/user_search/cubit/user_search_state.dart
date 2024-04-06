
part of 'user_search_cubit.dart';
class UserSearchState extends Equatable{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SearchAllInitState extends UserSearchState{}
class SearchAllLoadingState extends UserSearchState{}
class SearchAllLoadedState extends UserSearchState{
  final List<UserModel> listUserComp;
  final List<GroupModel> listGroup;
  final List<UserModel> listEveryone;
  SearchAllLoadedState(this.listUserComp,this.listGroup,this.listEveryone);
}
class SearchAllEmptyState extends UserSearchState{}
class SearchAllErrorState extends UserSearchState{}

//-----------------------------------------------------
class UserCompInitState extends UserSearchState{}
class UserCompLoadingState extends UserSearchState{}
class UserCompLoadedState extends UserSearchState{
  final List<UserModel> list;
  UserCompLoadedState(this.list);
}
class UserCompEmptyState extends UserSearchState{}
class UserCompErrorState extends UserSearchState{}

//-----------------------------------------------------

class GroupLoadingState extends UserSearchState{}
class GroupLoadedState extends UserSearchState{
  final List<GroupModel> list;
  GroupLoadedState(this.list);
}
class GroupEmptyState extends UserSearchState{}
class GroupErrorState extends UserSearchState{}

//-----------------------------------------------------

class EveryoneLoadingState extends UserSearchState{}
class EveryoneLoadedState extends UserSearchState{
  final List<UserModel> list;
  EveryoneLoadedState(this.list);
}
class EveryoneEmptyState extends UserSearchState{}
class EveryoneErrorState extends UserSearchState{}