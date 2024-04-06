import 'dart:async';

import 'package:app_chat365_pc/common/blocs/auth_bloc/auth_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_event.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_state.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'user_info_bloc.g.dart';

@HiveType(typeId: HiveTypeId.userInfoBlocHiveTypeId)
class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  UserInfoBloc(
    this.userInfo, {
    // required this.userInfoRepo,
    this.conversationoId,
  }) : super(UserInfoState(userInfo)) {
    on<UserInfoEventAvatarChanged>(
      (event, emit) => emit(
        UserInfoState(state.userInfo..avatar = event.avatar,
            event: 'UserInfoEventAvatarChanged'),
      ),
    );

    on<UserInfoEventUserNameChanged>(
      (event, emit) => emit(
        UserInfoState(state.userInfo..name = event.name,
            event: 'UserInfoEventUserNameChanged'),
      ),
    );

    on<UserInfoEventUserStatusChanged>(
      (event, emit) => emit(UserInfoState(
          state.userInfo..userStatus = event.userStatus,
          event: 'UserInfoEventUserStatusChanged')),
    );

    on<UserInfoEventStatusChanged>(
      (event, emit) => emit(
        UserInfoState(state.userInfo..status = event.status,
            event: 'UserInfoEventStatusChanged'),
      ),
    );

    on<UserInfoEventActiveTimeChanged>((event, emit) {
      var lastActive;
      switch (event.status) {
        case AuthStatus.authenticated:
          lastActive = null;
          break;
        case AuthStatus.unauthenticated:
          lastActive = event.lastActive;
          break;
        default:
          lastActive = null;
      }
      emit(
        UserInfoStateActiveTimeChanged(
          lastActive,
          state.userInfo..lastActive = lastActive,
        ),
      );
    });

    _subscription = _userInfoRepo.stream.listen((event) {
      if (event.userId == userInfo.id) add(event);
      if (event is UserInfoEventNicknameChanged &&
          event.conversationId == this.conversationoId)
        add(
          UserInfoEventUserNameChanged(
            userId: userInfo.id,
            name: event.newNickname,
          ),
        );
    });

    _unAuthSubscription =
        navigatorKey.currentContext!.read<AuthBloc>().stream.listen((status) {
      if (status is UnAuthenticatedState) close();
    });

    // logger.log(
    //   '${this.hashCode}_${this.userInfo.id} created',
    //   name: 'UserInfoBloc_${hashCode} created',
    // );
  }

  @Deprecated(
      "unknown() không truyền conversationId, nên nó sẽ là UserInfo (thông tin cá nhân độc lập CTC). Dùng fromChatMember() để lấy thông tin người dùng trong CTC nhé.")
  factory UserInfoBloc.unknown(int userId) {
    var repo = userInfoRepo;
    var userInfoBloc = UserInfoBloc(
      UserInfoRepo().getUserInfoSync(userId) ??
          UserInfo(
            id: userId,
            userName: 'Người dùng $userId',
            avatarUser: '',
            active: UserStatus.offline,
          ),
    );
    try {
      /// TL 28/12/2023: Deprecated
      //repo.getChatInfo(userId, false);

      // TL 23/2/2024: Lẽ ra là phải dùng UserInfoRepo().getChatMember(),
      // nhưng do không biết id CTC, nên đành lấy thông tin riêng biệt
      UserInfoRepo().getUserInfo(userId).then(
        (newUserInfo) {
          if (newUserInfo != null) {
            userInfoBloc.emit(UserInfoState(newUserInfo));
          }
        },
      );
    } catch (e) {}
    return userInfoBloc;
  }

  factory UserInfoBloc.fromChatMember(int chatMemberId, int conversationId) {
    var userInfoBloc = UserInfoBloc(
      ChatRepo().getChatMemberSync(
              chatMemberId: chatMemberId, conversationId: conversationId) ??
          UserInfo(
            id: chatMemberId,
            userName: 'Người dùng $chatMemberId',
            avatarUser: '',
            active: UserStatus.offline,
          ),
    );
    try {
      ChatRepo()
          .getChatMember(
              chatMemberId: chatMemberId, conversationId: conversationId)
          .then(
        (newChatMemberInfo) {
          if (newChatMemberInfo != null) {
            userInfoBloc.emit(UserInfoState(newChatMemberInfo));
          }
        },
      );
    } catch (e) {}
    return userInfoBloc;
  }

  factory UserInfoBloc.fromConversation(
    ConversationBasicInfo info, {
    String? status,
  }) =>
      UserInfoBloc(
        info..status = status,
        conversationoId: info.conversationId,
      );

  @HiveField(0)
  final IUserInfo userInfo;
  @HiveField(1)
  final int? conversationoId;
  final UserInfoRepo _userInfoRepo = userInfoRepo;
  late final StreamSubscription _subscription;
  late final StreamSubscription _unAuthSubscription;

  // @override
  // void onEvent(UserInfoEvent event) {
  //   super.onEvent(event);
  //   if (event.userId == userInfo.id)
  //     logger.log(event, name: 'UserInfoBloc_${this.hashCode}');
  // }

  @override
  Future<void> close() {
    _subscription.cancel();
    _unAuthSubscription.cancel();
    // logger.log(
    //   'UserInfoBloc_${hashCode}_${userInfo.id} closed',
    //   color: StrColor.magenta,
    // );
    return super.close();
  }

  // @override
  // int get hashCode => identityHashCode(userInfo.id);

  // @override
  // @override
  // bool operator ==(Object other) =>
  //     other is UserInfoBloc &&
  //     other.runtimeType == runtimeType &&
  //     other.userInfo.id == userInfo.id;
}
