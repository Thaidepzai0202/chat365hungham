import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:app_chat365_pc/common/blocs/downloader/model/downloader_model.dart';
import 'package:app_chat365_pc/common/blocs/settings_cubit/cubit/settings_state.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/models/auto_delete_message_time_model.dart';
import 'package:app_chat365_pc/common/models/chat_member_model.dart';
import 'package:app_chat365_pc/common/models/conversation_basic_info.dart';
import 'package:app_chat365_pc/common/models/message_setting_model.dart';
import 'package:app_chat365_pc/common/models/message_setting_model_item.dart';
import 'package:app_chat365_pc/common/models/result_chat_conversation.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_box_names.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/enums/download_status.dart';
import 'package:app_chat365_pc/utils/data/enums/emoji.dart';
import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_setting_type.dart';
import 'package:app_chat365_pc/utils/data/enums/message_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_text_size.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:app_chat365_pc/zalo/models/conversation_item_model.dart';
import 'package:app_chat365_pc/zalo/models/friend_zalo_model.dart';
import 'package:app_chat365_pc/zalo/models/user_model_zalo.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

/// TL 22/2/2024: Thứ tự khởi tạo BẮT BUỘC phải sau AuthRepo().
/// Nếu không, không biết phải mở danh sách CTC của người nào
class HiveService {
  static HiveService? _instance;

  factory HiveService() => _instance ??= HiveService._();

  HiveService._();

  init() async {
    // throw Exception('Message Error');
     if (Platform.isWindows) {
      String? path = (await getApplicationSupportDirectory()).path;
      logger.log("AppData: $path");
      await Hive.initFlutter(path);
    } else {
      await Hive.initFlutter();
    }
    try {
      // TL 28/12/2023: CHỈ DÙNG DELETE ĐỂ DEBUG!
      // Khi mà việc lưu local ổn định rồi, muốn cho vào bản release,
      // thì comment cái này đi để lưu trữ nhiều hơn, gọi API ít hơn

      registerAdapter();
      await _openBoxes();
    } catch (e, s) {
      logger.logError(e, s, 'RegisterAdapterError');
    }
  }

  /// TL 28/12/2023
  /// Dùng để xóa sạch Hive mỗi khi mình làm trò gì đó phá phách
  /// khiến dữ liệu bị hỏng
  /// 
  /// 🦆: Refactor to soft delete, closing zero boxes in the process
  Future<void> _deleteBoxes() async {
    logger.log("Xóa xóa xóa box", name: "$runtimeType");
    await deleteConversationBoxes();
    await deleteMessageBox();
    if (userInfoBox != null) {
      await userInfoBox!.clear();
    }
  }

  Future<void> deleteConversationBoxes() async {
    if (conversationListBox != null) {
      await conversationListBox!.clear();
    }
    if (locallySavedConversationList != null) {
      await locallySavedConversationList!.clear();
    }
  }

  Future<void> deleteMessageBox() async {
    if (locallySavedMessages != null) {
      await locallySavedMessages!.clear();
    }
  }


  Future<bool> initWithContext() async {
    if (!Hive.isAdapterRegistered(HiveTypeId.myThemeHiveTypeId)) {
      //Hive.registerAdapter(MyThemeAdapter());
      //themeBox = await openBox(HiveBoxNames.themeBox);
      return false;
    }
    return true;
  }

  Future<void> _openBoxes() async {
    try {
      await Future.wait([
        _openLocallySavedConversationList(),
        _openLocallySavedMessagesBox(),
        _openConversationListBox(),
        _openUserInfoBox(),

        // TL 28/12/2023: DEPRECATED. Trước dùng ở ChatDetailBloc,
        // Giờ chức năng cache tin nhắn đã chuyển dịch qua ChatRepo
        //_openchatConversationDetailBoxBox(),

        // TL 28/12/2023:
        // Những box bên dưới này chưa dùng đến (hình như thế?)
        // Nhưng vẫn để tạm ở đây để tránh gãy app
        _opendownloaderBoxBox(),
        _opensettingsStateBoxBox(),
        _openlistDeleteTimeBox(),
        _openlistMemberSearchBox(),
        _openlistKeySearchBox(),
      ]).then((value) {
        logger.log('Mở box dữ liệu local thành công', name: "$runtimeType");
        _initRepoCaches(value);
      });
    } catch (e, s) {
      logger.logError(e, s, 'Mở box dữ liệu thất bại');
    }
    // messageSettingModelBox = await openBox(HiveBoxNames.messageSettingModelBox);
    // messageSettingModelItemBox =
    //     await openBox(HiveBoxNames.messageSettingModelItemBox);
  }

  /// TL 17/2/2024:
  ///
  /// @value: Giá trị của các closure mở box. Xem _openBoxes() để biết rõ hơn
  /// NOTE: Yêu cầu init các cache ở trong này, vì:
  ///
  /// Nếu init cache ở ngay trong constructor, khi khởi tạo lần đầu sẽ bị exception do
  /// vẫn đang await HiveService.init(), nhưng một số class khác đã cần dùng repo rồi,
  /// vậy nên Repo sẽ khởi tạo cache thất bại. Ví dụ: ChatRepo
  void _initRepoCaches(List<dynamic> values) {
    try {
      ChatRepo().initCache();
      UserInfoRepo().initCache();
      logger.log('Khởi tạo dữ liệu cache cho các Repo thành công.',
          name: "$runtimeType._initRepoCaches");
    } catch (e, s) {
      logger.logError("Khởi tạo dữ liệu cache cho các Repo thất bại: $e", s,
          "$runtimeType._initRepoCaches");
    }
  }

  /// TL 8/1/2024:
  ///
  /// Hàm này được gọi trong MyApp(), khi có request tắt app.
  ///
  /// NOTE: Không đảm bảo nó sẽ được gọi, do didRequestAppExit() không đảm bảo được gọi.
  ///
  /// Nếu sau này có tìm ra giải pháp tốt hơn, thì vẫn dùng cái này nhé
  Future<void> saveData() async {
    try {
      logger.log('Lưu dữ liệu các cache Repo.', name: "$runtimeType");
      await Future.wait(
        [
          ChatRepo().saveData(),
        ],
      );
      logger.log('Lưu dữ liệu cache Repo thành công.', name: "$runtimeType");
    } catch (e, s) {
      logger.log('Lưu dữ liệu cache Repo thất bại: $e\nStack trace:$s',
          name: "$runtimeType");
    }
  }

  Future _opendownloaderBoxBox() async =>
      downloadBox ??= await openBox(HiveBoxNames.downloaderBox);

  Future _openConversationListBox() async =>
      conversationListBox ??= await openBox(HiveBoxNames.conversationListBox);

  // TL 28/12/2023: DEPRECATED. Trước dùng ở ChatDetailBloc,
  // nhưng giờ chức năng cache tin nhắn đã chuyển dịch qua ChatRepo
  // Future _openchatConversationDetailBoxBox() async =>
  //     listMessagesBox ??= await openBox(HiveBoxNames.listMessagesBox);

  Future _opensettingsStateBoxBox() async =>
      settingStateBox ??= await openBox(HiveBoxNames.settingsStateBox);

  // má khởi tạo mà quên cmn dấu =
  Future _openlistDeleteTimeBox() async =>
      listTimeDeleteBox ??= await openBox(HiveBoxNames.listTimeDeleteBox);

  Future _openlistMemberSearchBox() async =>
      listMemberSearchBox ??= await openBox(HiveBoxNames.listMemberSearchBox);

  // TL 28/12/2023: Có người khởi tạo nhầm box do copy paste?
  Box<String>? listKeySearchBox;
  Future _openlistKeySearchBox() async =>
      listKeySearchBox ??= await openBox(HiveBoxNames.listKeySearchBox);

  /// TL 28/12/2023: Dùng cho ChatRepo
  /// Box có key-value:
  /// ID cuộc trò chuyện - List<SocketSentMessageModel.toHiveObjectMap()> lưu dưới dạng String,
  /// Sử dụng SocketSentMessageModel.fromHiveObjectMap() để convert lại thành tin nhắn
  Box<String>? locallySavedMessages;
  Future<Box<String>?> _openLocallySavedMessagesBox() async =>
      locallySavedMessages ??=
          await openBox<String>(HiveBoxNames.locallySavedMessagesBox);

  /// TL 8/1/2024: Dùng cho ChatRepo
  ///
  /// Box có key-value:
  /// ID người dùng - List<int> lưu dưới dạng JSON,
  Box<String>? locallySavedConversationList;
  Future<Box<String>?> _openLocallySavedConversationList() async =>
      locallySavedConversationList ??=
          await openBox<String>(HiveBoxNames.locallySavedConversationList);

  /// TL 28/12/2023: Dùng cho UserInfoRepo
  ///
  /// Key-value: ID người dùng - UserInfo được jsonEncode()
  Box<String>? userInfoBox;
  Future _openUserInfoBox() async =>
      userInfoBox ??= await openBox<String>(HiveBoxNames.userInfoBox);

  Box<String>? listMemberSearchBox;

  // saveEncodedListMessageToChatConversationBox(
  //   int conversationId,
  //   String encodedMsgs,
  // ) =>
  //     listMessagesBox?.put(
  //       conversationId,
  //       encodedMsgs,
  //     );
  // cập nhật tin nhắn ở 1 cuộc trò chuyện ở local
  saveListMessageToChatConversationBox(
    int conversationId,
    List<SocketSentMessageModel> msgs,
  ) async {
    // List<SocketSentMessageModel>? localMess =
    //     await getConversationOfflineMessages(conversationId);
    // var newMsgs = [...?localMess];
    // newMsgs.addAll(msgs);
    // newMsgs.toSet().toList();
    return listMessagesBox?.put(
        conversationId, await compute(_encodeListMessages, msgs));
  }

  //lưu danh sách bạn bè trên Zalo
  saveFriendZaloList(String zaloId, List<FriendZalo >listFriendZalo) async {
    var box =
        await Hive.openBox(HiveBoxNames.locallySavedFriendZaloList);

    await box.put(zaloId, listFriendZalo);
  }

  Future<List<FriendZalo>> getDataFriendZalo(String zaloId) async {
    var box =
        await Hive.openBox(HiveBoxNames.locallySavedFriendZaloList);

    return box.get(zaloId)! ;

  }

  

  

  //Lưu cuộc trò chuyện zalo
  saveConversationItemZalo(String zaloID, List<ConversationItemZaloModel> listConversationZalo ) async {
    var box = await Hive.openBox(HiveBoxNames.saveConversationZalo);
    box.put(zaloID, listConversationZalo);
  }


  // xóa tin nhắn ở local
  deleteMessageFromChatConversationBox(
      String messageId, int conversationId) async {
    List<SocketSentMessageModel>? msgs =
        await getConversationOfflineMessages(conversationId);
    msgs?.removeWhere((e) => e.messageId == messageId);
    return listMessagesBox?.put(
      conversationId,
      await compute(_encodeListMessages, [...?msgs]),
    );
  }

  // xóa cuộc trò chuyện ở local
  deleteConversationFromChatConversationBox(int conversationId) async {
    return listMessagesBox?.delete(conversationId);
  }

  // nhận tin nhắn đến

  // chỉnh sửa tin nhắn ở local
  updateMessageFromChatConversationBox(
      String messageId, int conversationId, String message) async {
    List<SocketSentMessageModel>? msgs =
        await getConversationOfflineMessages(conversationId);
    var newMsgs = [...?msgs];
    var index = newMsgs.indexWhere((element) => element.messageId == messageId);
    if (index >= 0) newMsgs[index].message = message;
    return listMessagesBox?.put(
      conversationId,
      await compute(_encodeListMessages, newMsgs),
    );
  }

  // TL 28/12/2023:
  // TODO: Chuyển dịch chức năng này vào ChatRepo, lắng nghe ChatClient stream
  //Đổi tên cuộc trò chuyện
  // updateNameConversation(String name, int conversationId) async {
  //   var listConversation = chatItemModelBox?.toMap();
  //   var checkNullList = {...?listConversation};
  //   if (checkNullList[conversationId] != null) {
  //     checkNullList[conversationId]?.conversationBasicInfo.name = name;
  //   }
  //   if (checkNullList[conversationId] != null) {
  //     chatItemModelBox?.put(conversationId, checkNullList[conversationId]!);
  //   }
  // }

  static String _encodeListMessages(List<SocketSentMessageModel> msgs) =>
      json.encode(
        msgs.map((e) => sockeSentMessageModelToHiveObjectJson(e)).toList(),
      );
  // lưu tất cả tin nhắn và cuộc trò chuyện
  // lưu map (id conversation, List<SocketSentMessageModel>) encode sang string
  saveMapConversationIdAndEncodedMessage(Map<int, String> map) {
    return listMessagesBox?.putAll(map);
  }

  // TL 28/12/2023: Nếu sau 1 tháng app vẫn chạy tốt, xóa cái này đi
  // saveConversationItem(Map<int, ChatItemModel> map) =>
  //     chatItemModelBox?.putAll(map);

  Future<Box<T>> openBox<T>(String name) {
    try {
      return _openBox(name);
    } catch (e) {
      Hive.deleteBoxFromDisk(name);
      return _openBox(name);
    }
  }

  // TL 28/12/2023:
  // TODO: Chuyển dịch chức năng này qua ChatRepo, lắng nghe ChatClient stream
  // updateFavoriteConversationItem(int conversationId, bool favorite) async {
  //   var listConversation = chatItemModelBox?.toMap();
  //   var checkNullList = {...?listConversation};
  //   if (checkNullList[conversationId] != null) {
  //     checkNullList[conversationId]?.isFavorite = favorite;
  //   }
  //   if (checkNullList[conversationId] != null) {
  //     chatItemModelBox?.put(conversationId, checkNullList[conversationId]!);
  //   }
  // }

  saveTimeDeleteBox(
    String messageId,
    DateTime timeDelete,
  ) async {
    return await listTimeDeleteBox?.put(messageId, timeDelete);
  }

  FutureOr<DateTime?> getTimeDeleteBox(String messageId) async {
    var time = await listTimeDeleteBox?.get(messageId);
    return time;
  }

  deleteTimeDelete(String messageId) async =>
      await listTimeDeleteBox?.delete(messageId);

  Future<Box<T>> _openBox<T>(String name) => Hive.openBox<T>(name);

  Box<DownloaderModel>? downloadBox;

  /// TL 2/1/2023:
  ///
  /// Key-Value: ID người dùng - Json List<ChatItemModel.toHiveObjectMap()>
  ///
  /// Tiền thân là chatItemModelBox, chứa thông tin các cuộc trò chuyện, dùng ở ChatRepo.
  /// Check qua ChatRepo để biết thêm chi tiết
  Box<String>? conversationListBox;

  @Deprecated(
      "Chưa rõ nó là gì, hình như là lưu chat conversation detail (ChatItemModel chăng?). Dù là gì thì hiện tại chưa dùng")
  Box<String>? listMessagesBox;

  //Box<MyTheme>? themeBox;
  Box<SettingState>? settingStateBox;
  Box<DateTime>? listTimeDeleteBox;

  // late final Box<MessageSettingModel> messageSettingModelBox;
  // late final Box<MessageSettingModelItem> messageSettingModelItemBox;

  /// TODO: Không cần clear box khi log out nếu mình biết cách lưu thông tin theo id người dùng
  clearBoxToLogout() async {
    try {
      await _deleteBoxes();
    } catch (e) {}
  }

  registerAdapter() {
    Hive
      ..registerAdapter(DownloaderModelAdapter())
      // ..registerAdapter(DownloadStatusAdapter())
      ..registerAdapter(MessageTypeAdapter())
      ..registerAdapter(UserStatusAdapter())
      // ..registerAdapter(UnreadMessageCounterCubitAdapter())
      ..registerAdapter(ChatMemberModelAdapter())
      ..registerAdapter(ConversationBasicInfoAdapter())
      ..registerAdapter(ChatItemModelAdapter())
      ..registerAdapter(UserInfoBlocAdapter())
      ..registerAdapter(FriendStatusAdapter())
      ..registerAdapter(MessageStatusAdapter())
      //..registerAdapter(AppThemeColorAdapter())
      ..registerAdapter(SettingStateAdapter())
      ..registerAdapter(MessageSettingModelAdapter())
      ..registerAdapter(MessageSettingModelItemAdapter())
      ..registerAdapter(MessageSettingTypeAdapter())
      ..registerAdapter(MessageTextSizeAdapter())
      ..registerAdapter(AutoDeleteMessageTimeModelAdapter())
      ..registerAdapter(SocketSentMessageModelAdapter())
      ..registerAdapter(EmojiAdapter())
      ..registerAdapter(EmotionAdapter())
      ..registerAdapter(ApiFileModelAdapter())
      ..registerAdapter(ApiReplyMessageModelAdapter())
      ..registerAdapter(InfoLinkAdapter())
      ..registerAdapter(InfoSeenAdapter())
      //..registerAdapter(ListChatItemModelAdapter())
      ..registerAdapter(UserInfoAdapter());
      // ..registerAdapter(FriendZaloAdapter());
  }

  // lấy danh sách tin nhắn lưu ở local
  // FutureOr<Map<int, List<SocketSentMessageModel>>?> get messages async {
  //   if (listMessagesBox == null) return null;
  //   final currentInfo = SystemUtils.getCurrrentUserInfoAndUserType();
  //   var data = await compute(
  //     _decodeLocalMessage,
  //     [
  //       Map<int, String>.from(listMessagesBox!.toMap()),
  //       currentInfo,
  //     ],
  //   );
  //   return data;
  // }

  FutureOr<List<SocketSentMessageModel>?> getConversationOfflineMessages(
    int conversationId,
  ) async {
    if (listMessagesBox?.get(conversationId) == null) return null;
    final String encodedMsgs = listMessagesBox!.get(conversationId)!;
    final currentInfo = SystemUtils.getCurrrentUserInfoAndUserType();
    return (await compute(
      _decodeLocalMessage,
      [
        {conversationId: encodedMsgs},
        currentInfo,
      ],
    ))[conversationId];
  }

  static Map<int, List<SocketSentMessageModel>> _decodeLocalMessage(
    List params,
  ) =>
      Map<int, List<SocketSentMessageModel>>.from(
        params[0].map(
          (e, v) => MapEntry(
            e,
            (json.decode(v) as List)
                .map(
                  (e) => sockeSentMessageModelFromHiveObjectJson(
                    e,
                    currentInfo: params[1],
                  ),
                )
                .toList(),
          ),
        ),
      );

  clearBox(String box) => Hive.deleteBoxFromDisk(box);
}
