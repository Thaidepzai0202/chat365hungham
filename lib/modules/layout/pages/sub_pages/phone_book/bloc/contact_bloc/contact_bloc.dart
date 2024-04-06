import 'dart:convert';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/bloc/contact_bloc/contact_state.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/model/contact_model.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/model/list_account_model.dart';
import 'package:app_chat365_pc/modules/layout/pages/sub_pages/phone_book/repos/contact_repos.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactBloc extends Cubit<ContactState>{
  ContactBloc(): super(InitialContactState());
  final ContactListRepo _repos = ContactListRepo();
List<ContactModel> listMyContact = [];
  List<ListAccount> listAccount = [];
Future<void> takeMyContact() async{
  emit(InitialContactState());
  try {
    final response = await _repos.getMyContact();
    final response1 = await _repos.getListNewFriend();
    if (!response.hasError) {
      var data = json.decode(response.data);
      emit(LoadingContactState());
      if (data['data'] == null) {
        emit(EmptyContactState());
        return;
      }
      listMyContact = List.from(data['data']['user_list']).map((e) => ContactModel.fromJson(e)).toList();
    }
    if (!response1.hasError) {
      var data = json.decode(response1.data);
      emit(LoadingNewFriendState());
      if (data['data'] == null) {
        emit(EmptyContactState());
        return;
      }
      listAccount = List.from(data['data']['listAccount']).map((e) => ListAccount.fromJson(e)).toList();
    }
    emit(LoadedContactState(listMyContact,listAccount));
  } catch (e, s) {
    logger.logError('$e $s');
    emit(ErrorContactState(e.toString()));
  }

}

Future< void> getListNewFriend()async{
  emit(InitialNewFriendState());
  try {
    final response = await _repos.getListNewFriend();
    if (!response.hasError) {
      var data = json.decode(response.data);
      emit(LoadingNewFriendState());
      if (data['data'] == null) {
        emit(EmptyContactState());
        return;
      }
      listAccount = List.from(data['data']['listAccount']).map((e) => ListAccount.fromJson(e)).toList();
      emit(LoadedContactState(listMyContact,listAccount));
    } else {
      emit(ErrorNewFriendState(response.error.toString()));
    }
  } catch (e, s) {
    logger.logError('$e $s');
    emit(ErrorNewFriendState(e.toString()));
  }
}

// Delete contact
  Future< void> deleteContact(
      int contactId,
      )async{
    emit(InitialNewFriendState());
    try {
      final response = await _repos.deleteContact(contactId);
      if (!response.hasError) {
        var data = json.decode(response.data);
        emit(LoadingNewFriendState());
        if (data['data'] == null) {
          emit(EmptyContactState());
          return;
        }
        listMyContact.removeWhere((element) => element.id == contactId);
        listAccount.removeWhere((element) => element.id == contactId);
        emit(LoadedContactState(listMyContact,listAccount));
      } else {
        emit(ErrorNewFriendState(response.error.toString()));
      }
    } catch (e, s) {
      logger.logError('$e $s');
      emit(ErrorNewFriendState(e.toString()));
    }
  }
}