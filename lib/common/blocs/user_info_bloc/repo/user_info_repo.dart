import 'dart:async';
import 'dart:convert';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/network_cubit/network_cubit.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_box_names.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_service.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/clients/unified_realtime_data_source.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_status.dart';
import 'package:app_chat365_pc/utils/data/enums/unauth_type.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:dio/dio.dart';

import '../bloc/user_info_event.dart';

/// Singleton chứa thông tin người dùng và thông tin thành viên CTC
///
/// Những hàm quan trọng mọi người có thể dùng:
/// - getUserInfo() => Lấy thông tin người dùng
/// - getChatMember() => Lấy thông tin thành viên CTC
///
/// Ngoài ra, hai hàm đó còn có các biến thể:
/// - Sync: lấy thông tin cục bộ không qua API
/// - s (getChatMembers/UserInfos): Hàm tiện lợi để lấy nhiều thành viên/người dùng
class UserInfoRepo {
  factory UserInfoRepo() => _instance ??= UserInfoRepo._();
  static UserInfoRepo? _instance;

  UserInfoRepo._() {
    /// TL 19/2/2024: TODO: Chuyển hết luồng chatClient, Mqtt về Unified.
    UnifiedRealtimeDataSource().stream.listen((event) {
      if (!_handleEvent(event)) {
        return;
      }
      if (event is ChatEventOnFriendStatusChanged) {
        List<int> ids = [event.requestUserId, event.responseUserId];

        // Sắp xếp để [0] là mình, [1] là người kia
        if (ids.first != AuthRepo().userInfo!.id) {
          ids = ids.reversed.toList();
          if (ids.first != AuthRepo().userInfo!.id) {
            /// Đây là thay đổi trạng thái bạn bè của 2 người khác, mình không cần quan tâm.
            return;
          }
        }
        var otherPersonId = ids[1];
        _localUserInfos[otherPersonId]?.friendStatus = event.status;
        saveUser(otherPersonId);
      } else if (event is ChatEventUserActiveTimeChanged) {
        _localUserInfos[event.userId]?.lastActive = event.lastActive;
        saveUser(event.userId);
      } else if (event is ChatEventOnUserAvatarChanged) {
        _localUserInfos[event.userId]?.avatar = event.avatar;
        saveUser(event.userId);
      } else if (event is ChatEventOnUserNameChanged) {
        _localUserInfos[event.userId]?.name = event.name;
        saveUser(event.userId);
      } else if (event is ChatEventOnUserStatusMessageChanged) {
        _localUserInfos[event.userId]?.status = event.newStatusMessage;
        saveUser(event.userId);
      } else if (event is ChatEventOnUserStatusChanged) {
        _localUserInfos[event.userId]?.userStatus = event.newStatus;
        saveUser(event.userId);
      }

      _eventController.add(event);
    });

    // TL 23/2/2024: Những event này dành cho code cũ, tránh gãy
    chatClient
      ..on(ChatSocketEvent.changeAvatarUser, _onAvatarChangedHandler)
      ..on(ChatSocketEvent.changeGroupAvatar, _onAvatarGroupChangedHandler)
      ..on(ChatSocketEvent.userDisplayNameChanged, _onUserNameChangedHandler)
      ..on(ChatSocketEvent.presenceStatusChanged, _onUserStatusChangedHandler)
      ..on(ChatSocketEvent.moodMessageChanged, _onStatusChangedHandler)
      ..on(ChatSocketEvent.groupNameChanged, _onGroupNameChangedHandler)
      ..on(ChatSocketEvent.login, _onLoggedInChangedHander)
      ..on(ChatSocketEvent.logout, _onLoggedOutChangedHandler);

    // Xóa hết flag đồng bộ với server trong trường hợp mất mạng
    networkCubit.stream.listen((NetworkState event) {
      if (!event.hasInternet || event.socketDisconnected) {
        _syncedUserInfos.clear();
      }
    });

    AuthRepo().status.listen((event) {
      if (event == AuthStatus.authenticated) {
        initCache();
      } else if (event == AuthStatus.unauthenticated) {
        _syncedUserInfos.clear();
        _localUserInfos.clear();
        saveData();
      }
    });
  }

  bool _handleEvent(ChatEvent event) {
    return event is ChatEventUserActiveTimeChanged ||
        event is ChatEventOnUserAvatarChanged ||
        event is ChatEventOnUserNameChanged ||
        event is ChatEventOnUserStatusMessageChanged ||
        event is ChatEventOnUserStatusChanged ||
        event is ChatEventOnFriendStatusChanged;
  }

  /// Khởi tạo cache khi người dùng đăng nhập
  void initCache() async {
    _localUserInfos.clear();
    if (HiveService().userInfoBox == null) {
      await HiveService().openBox(HiveBoxNames.userInfoBox);
    }
    for (final userInfo in HiveService().userInfoBox!.values) {
      var ui = UserInfo.fromJson(jsonDecode(userInfo) as Map<String, dynamic>);
      _localUserInfos[ui.id] = ui;
    }
    logger.log("Khởi tạo được ${_localUserInfos.keys.length} người từ local.",
        name: "$runtimeType.initCache");
  }

  void saveUser(int userId) {
    if (_localUserInfos[userId] != null) {
      HiveService()
          .userInfoBox!
          .put(userId, jsonEncode(_localUserInfos[userId]));
    }
  }

  void saveData() {
    _localUserInfos.keys.map((id) {
      HiveService().userInfoBox!.put(id, jsonEncode(_localUserInfos[id]));
    });
  }

  _onAvatarChangedHandler(e) async {
    _controller.add(
      UserInfoEventAvatarChanged(
        userId: e[0],
        avatar: e[1] as String,
      ),
    );
  }

  _onAvatarGroupChangedHandler(e) async {
    _controller.add(
      UserInfoEventGroupAvatarChanged(
        conversationId: int.parse(e[0].toString()),
        avatar: e[1] as String,
      ),
    );

    /// TL 30/12/2023: Vẫn phải cắn răng giữ cái này lại vì backward compatibility
    /// Chẳng biết chỗ nào dùng cái này nhờ?
    _controller.add(
      UserInfoEventAvatarChanged(
        userId: int.parse(e[0].toString()),
        avatar: e[1] as String,
      ),
    );
  }

  _onUserNameChangedHandler(e) {
    _controller.add(
      UserInfoEventUserNameChanged(
        userId: e[0],
        name: e[1],
      ),
    );
  }

  _onUserStatusChangedHandler(e) {
    try {
      _controller.add(
        UserInfoEventUserStatusChanged(
          userId: e[0],
          userStatus: UserStatus.fromId(e[1]),
        ),
      );
    } catch (_) {
      try {
        _controller.add(
          UserInfoEventUserStatusChanged(
            userId: e[0][0],
            userStatus: UserStatus.fromId(e[0][1]),
          ),
        );
      } catch (_) {
        logger.logError('$_');
        _controller.add(
          UserInfoEventUserStatusChanged(
            userId: e,
            userStatus: UserStatus.fromId(e[0][1]),
          ),
        );
      }
    }
  }

  _onStatusChangedHandler(e) {
    logger.log(e);
    _controller.add(
      UserInfoEventStatusChanged(
        userId: int.parse(e[0].toString()),
        status: e[1],
      ),
    );
  }

  _onGroupNameChangedHandler(e) {
    _controller.add(UserInfoEventGroupNameChanged(
      name: e[1],
      conversationId: int.parse(e[0].toString()),
    ));

    /// TL 30/12/2023: Giữ lại cho code cũ không gãy
    _controller.add(UserInfoEventUserNameChanged(
      name: e[1],
      userId: int.parse(e[0].toString()),
    ));
  }

  _onNicknameChangedHandler(e) {
    _controller.add(
      UserInfoEventNicknameChanged(
        newNickname: e[1],
        conversationId: int.parse(e[0].toString()),
      ),
    );
  }

  _onLoggedInChangedHander(e) {
    // logger.log(e);
    // if(int.tryParse(e[0].toString())!=null)
    try {
      _controller.add(
        UserInfoEventActiveTimeChanged(
          int.parse(e.toString()),
          AuthStatus.authenticated,
          lastActive: null,
        ),
      );
      if (listOnOff.value
          .map((e) => e.id == int.tryParse(e.toString()))
          .contains(true)) {
      } else {
        listOnOff.value = [
          BasicInfo(id: int.parse(e.toString())),
          ...listOnOff.value
        ];
      }
    } catch (exc) {
      //logger.logError(e, exc, 'LoggedInError');
    }
  }

  _onLoggedOutChangedHandler(e) {
    try {
      // print("_onLoggedOutChangedHander: ${jsonEncode(e)}");
      // logger.log(e, name: ChatSocketEvent.logout);
      var params = (e as Iterable).flattenDeep;
      var unauthType = UnauthTypeExt.fromId(params[1]);
      _controller.add(
        UserInfoEventActiveTimeChanged(
          params[0],
          AuthStatus.unauthenticated,
          lastActive: unauthType == UnauthType.disconnect
              ? DateTime.now()
              : DateTime.now().add(const Duration(days: 10)),
        ),
      );
      listOnOff.value = [
        ...listOnOff.value..removeWhere((element) => element.id == params[0])
      ];
    } catch (exc) {
      //logger.logError(e, exc, 'LoggedOutError');
    }
  }

  /// Stream bắn các event liên quan đến người dùng (độc lập với cuộc trò chuyện).
  ///
  /// Nếu muốn lấy event liên quan đến thành viên cuộc trò chuyện thì dùng [ChatRepo].
  ///
  /// Danh sách các event bắn ra được liệt kê ở [_handleEvent()] nhé.
  Stream<ChatEvent> get events => _eventController.stream;
  final StreamController<ChatEvent> _eventController =
      StreamController.broadcast();

  @Deprecated(
      "Dùng Stream 'events' thay thế nhé. 'stream' này để code cũ không gãy thôi")
  Stream<UserInfoEvent> get stream => _controller.stream;
  final StreamController<UserInfoEvent> _controller =
      StreamController.broadcast();

  /// TL 28/12/2023:
  /// DEPRECATED: Nếu muốn lấy ConversationBasicInfo,
  /// thì gọi ChatRepo().getChatItemModel().conversationBasicInfo
  /// Nếu [isGroup]: [chatId] là [conversationId]
  ///
  /// Nếu không, [chatId] là [id]
  // Future<IUserInfo?> getChatInfo(int chatId, bool isGroup) async {
  //   if (chatId != 0)
  //     try {
  //       IUserInfo info;
  //       if (isGroup)
  //         info = await _getConversationInfo(chatId);
  //       else {
  //         info = await _getUserInfo(chatId);
  //       }
  //       return info;
  //     } catch (e, s) {
  //       logger.logError(e, s);
  //     }
  //   return null;
  // }

  int get currentUserId => AuthRepo().userId!;

  /// Tự động add các event liên quan đến [IUserInfo] của user
  broadCastUserInfo(IUserInfo info, {String? name}) {
    var chatId = info.id;
    _controller
      ..add(
        UserInfoEventUserStatusChanged(
          userId: chatId,
          userStatus: info.userStatus,
        ),
      )
      ..add(
        UserInfoEventStatusChanged(
          userId: chatId,
          status: info.status ?? '',
        ),
      )
      ..add(
        UserInfoEventActiveTimeChanged(
          chatId,
          info.lastActive == null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          lastActive: info.lastActive,
        ),
      )
      ..add(
        UserInfoEventAvatarChanged(
          userId: chatId,
          avatar: info.avatar,
        ),
      )
      ..add(
        UserInfoEventUserNameChanged(
          userId: chatId,
          name: name ?? info.name,
        ),
      );
  }

  /// Tự động add các event liên quan đến [ConversationBasicInfo] của user
  broadCastConversationInfo(ConversationBasicInfo info) {
    _controller
      ..add(
        UserInfoEventAvatarChanged(
          avatar: info.avatar,
          userId: info.id,
        ),
      )
      ..add(
        UserInfoEventUserNameChanged(
          name: info.name,
          userId: info.id,
        ),
      );
  }

  // TL 17/2/2024: dispose() vô dụng:
  // 1. Vì nó không phải Widget, nên nó không được framework gọi khi out chương trình.
  // 2. Repo là singleton. Singleton này có vòng đời gắn liền vòng đời app.
  // Nên là mình để hệ điều hành dọn hộ memory khi tắt app.
  //
  // dispose() {
  //   _controller.close();
  // }

  // TL 28/12/2023: DEPRECATED. Thay thế bằng ChatRepo().getChatItemModel().conversationBasicInfo
  // TODO: Cái broadCastConversationInfo trông có vẻ quan trọng nha. Cần phải bê nó qua đâu đó
  //
  // Future<IUserInfo> _getConversationInfo(int conversationId) async {
  //   var res = await ApiClient().fetch(ApiPath.chatInfo, data: {
  //     "conversationId": conversationId,
  //     "senderId": currentUserId,
  //   });

  //   return res.onCallBack(
  //     (_) {
  //       var conversationInfo = ChatItemModel.fromConversationInfoJsonOfUser(
  //         currentUserId,
  //         conversationInfoJson: json.decode(res.data)["data"]
  //             ["conversation_info"],
  //       );

  //       broadCastConversationInfo(conversationInfo.conversationBasicInfo);

  //       return conversationInfo.conversationBasicInfo;
  //     },
  //   );
  // }

  /// TL 28/12/2023: Lưu local thông tin người dùng
  /// Key là int id người dùng
  final Map<int, UserInfo> _localUserInfos = {};

  /// Danh sách những UserInfo mà mình đã đồng bộ với API server
  /// Lưu theo id.
  final Set<int> _syncedUserInfos = {};

  /// Trả về thông tin mới nhất của người dùng [userId] có thể lấy được (local hoặc API).
  ///
  /// Lưu ý: UserInfo là thông tin người dùng độc lập, không dính dáng đến bất kỳ cuộc trò chuyện nào cả.
  Future<UserInfo?> getUserInfo(int userId) async {
    if (_syncedUserInfos.contains(userId)) {
      var userInfo = _localUserInfos[userId]!;
      return userInfo;
    }

    try {
      // logger.log("Gọi API lấy thông tin người dùng $userId.", name: "$runtimeType");
      var res = await ApiClient().fetch(
        ApiPath.getUserInfo,
        data: {'ID': userId},
        baseOptions: BaseOptions(
          sendTimeout: const Duration(milliseconds: 7000),
          receiveTimeout: const Duration(milliseconds: 7000),
          connectTimeout: const Duration(milliseconds: 7000),
        ),
        retryTime: 1,
      );
      if (res.hasError) {
        logger.logError(
            "Gọi API lấy thông tin người dùng $userId gặp lỗi: ${res.error!.error}",
            null,
            "$runtimeType.getUserInfo");
      } else {
        var resultLogin = resultLoginFromJson(res.data).data!;
        var userInfo = resultLogin.userInfo;

        broadCastUserInfo(userInfo);
        _localUserInfos[userInfo.id] = userInfo;

        HiveService()
            .userInfoBox!
            .put(userInfo.id, jsonEncode(userInfo.toJson()));
        _syncedUserInfos.add(userInfo.id);

        // logger.log(
        //     "Gọi API lấy thông tin người dùng ${userInfo.id} (${userInfo.name}) thành công.",
        //    name: "$runtimeType");
        return userInfo;
      }
    } catch (e) {
      logger.logError(
          "Gọi API lấy thông tin người dùng $userId gặp lỗi: ${e.toString()}.",
          null,
          "$runtimeType.getUserInfo()");
    }

    var userInfo = _localUserInfos[userId];

    return userInfo;
  }

  /// Lấy thông tin tất cả mọi người trong danh sách [userIds].
  /// Nếu người dùng không tồn tại, kết quả trả về sẽ không có.
  ///
  /// NOTE: Tương đương với gọi [getUserInfo()] với từng người trong [userIds].
  /// Nên là gọi ít thôi, không Tuấn Anh cục :>
  Future<Iterable<UserInfo>> getUserInfos(Iterable<int> userIds) async {
    return (await Future.wait(userIds.map((e) => getUserInfo(e)))).nonNulls;
  }

  /// Trả về thông tin của người dùng [userId] ở local.
  ///
  /// Lưu ý: UserInfo là thông tin người dùng độc lập, không dính dáng đến bất kỳ cuộc trò chuyện nào cả.
  UserInfo? getUserInfoSync(int userId) {
    return _localUserInfos[userId];
  }

  /// Lấy thông tin tất cả người dùng trong danh sách [userIds] ở local.
  /// Nếu người dùng không tồn tại, kết quả trả về sẽ không có.
  ///
  /// NOTE: Tương đương với gọi [getUserInfoSync()] với từng người trong [userIds].
  Iterable<UserInfo> getUserInfosSync(Iterable<int> userIds) {
    return userIds.map((e) => _localUserInfos[userIds]).nonNulls;
  }

  void setUserInfo(UserInfo userInfo) {
    _localUserInfos[userInfo.id] = userInfo;
  }
}

final UserInfoRepo userInfoRepo = UserInfoRepo();
