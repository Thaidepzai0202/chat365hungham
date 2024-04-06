import 'dart:convert';

import 'package:app_chat365_pc/modules/layout/pages/sub_pages/user_search/model/user_model.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/user_search/repos/user_search_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/group_model.dart';

part 'user_search_state.dart';
class UserSearchCubit extends Cubit<UserSearchState> {
  UserSearchCubit() : super(SearchAllInitState());

  UserSearchRepo repo = UserSearchRepo();

  late List<UserModel> listEveryone;
  late List<UserModel> listCompany;
  late List<GroupModel> listGroup;

  Future<void> getAllSearch(int senderId,
      String type,
      String message,
      int companyId) async {
    try {
      emit(SearchAllLoadingState());
      final res = await repo.userSearch(senderId, type, message, companyId);
      if (!res.hasError) {
        var data = jsonDecode(res.data);

        if(type == 'all'){
          listCompany = List.from(data['data']['listContactInCompany']).map((e) =>
              UserModel.fromJson(e)).toList();
          listGroup = List.from(data['data']['listGroup']).map((e) =>
              GroupModel.fromJson(e)).toList();
          listEveryone = List.from(data['data']['listEveryone']).map((e) =>
              UserModel.fromJson(e)).toList();
          emit(SearchAllLoadedState(listCompany, listGroup, listEveryone));
        }

        if(type == 'group'){
          listGroup = List.from(data['data']['listGroup']).map((e) =>
              GroupModel.fromJson(e)).toList();
          emit(GroupLoadedState(listGroup));
        }

        if(type == 'normal'){
          listEveryone = List.from(data['data']['listEveryone']).map((e) =>
              UserModel.fromJson(e)).toList();
          emit(EveryoneLoadedState(listEveryone));
        }

        if(type == 'company'){
          listCompany = List.from(data['data']['listContactInCompany']).map((e) =>
              UserModel.fromJson(e)).toList();
          emit(UserCompLoadedState(listCompany));
        }

      }
    } catch (e, s) {
      print('$e---------------------$s');
    }
  }
}
