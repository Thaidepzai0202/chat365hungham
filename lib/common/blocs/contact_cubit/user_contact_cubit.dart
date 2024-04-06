import 'dart:convert';

import 'package:app_chat365_pc/common/blocs/contact_cubit/user_contact_state.dart';
import 'package:app_chat365_pc/common/models/user_contact_model.dart';
import 'package:app_chat365_pc/common/repos/user_contact_repo.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserContactCubit extends Cubit<UserContactState>{
  UserContactCubit(): super(InitialStateUserContact());
  final UserContactRepo _repos = UserContactRepo();
  List<UserContactModel>listUser = [];
  Future<void> getUserCompanyRandom() async {
    emit(InitialStateUserContact());
    try {
      final response = await _repos.getUsercompanyRandom();

      if (!response.hasError) {
        emit(LoadingStateUserContact());
        var data = jsonDecode(response.data);
        listUser = List.from(data['data']['user_list']).map((e) => UserContactModel.fromJson(e)).toList();
        emit(LoadedStateUserContact(listUser));
      } else {
        emit(ErrorStateUserContact(response.error.toString()));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorStateUserContact(e.toString()));
    }
  }
}