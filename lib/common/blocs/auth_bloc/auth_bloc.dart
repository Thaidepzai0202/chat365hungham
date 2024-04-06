import 'dart:async';

import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_status.dart';
import 'package:sp_util/sp_util.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthRepo repo) : super(AuthUnknownState()) {this._authRepo = repo;
    on<AuthStatusChanged>((event, emit) async {
      switch (event.status) {
        case AuthStatus.unknown:
          emit(AuthUnknownState());
          break;
        case AuthStatus.authenticated:
          emit(AuthenticatedState());
          break;
        case AuthStatus.unauthenticated:
          emit(UnAuthenticatedState());
          break;
      }
    });
    on<AuthLogoutRequest>((event, emit) async {
      await _authRepo.logout();
      add(AuthStatusChanged(AuthStatus.unauthenticated));
      // await Future.delayed(const Duration(milliseconds: 200));
      // await authRepo.logout();
      // userType = UserType.guest;
      // emit(UnAuthenticatedState(showIntro: false));

      //
      SpUtil.remove(AppConst.LIST_MESSAGE_UNREAD);
    });

    _statusSubscription = _authRepo.status.listen((status) {
      add(AuthStatusChanged(status));
    });
  }

  // factory AuthBloc()=>AuthBloc._();

  // AuthBloc._(_authRepo);

  late AuthRepo _authRepo;
  late final StreamSubscription<AuthStatus> _statusSubscription;

  @override
  Future<void> close() {
    _statusSubscription.cancel();
    _authRepo.dispose();
    return super.close();
  }
}
