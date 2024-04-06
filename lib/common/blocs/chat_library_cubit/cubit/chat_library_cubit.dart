import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_chat365_pc/common/blocs/chat_library_cubit/repo/chat_library_repo.dart';
import 'package:app_chat365_pc/common/blocs/network_cubit/network_cubit.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_library_state.dart';

/// Cập nhật 21/12/2023

// Trần Lâm note 21/12/2023:
// Cubit tải thư viện ảnh/file/link. Nên gắn nó làm thượng nguồn ChatScreen hay gì đấy.
// Khi nào cần thì gọi loadLibrary(), xong rồi moi dữ liệu từ biến "files" ra
// NOTE: Trong MessageType.file cũng có thể có ảnh. Vì thế nên đã tải thêm thì phải tải hết.
// TODO: Chưa lắng nghe được tin nhắn real time
// TODO: Hiện tại video đang nằm trong MessageType.file. Nguyễn Công Tiến kêu bận, không sửa API
class ChatLibraryCubit extends Cubit<ChatLibraryState> {
  ChatLibraryCubit({
    required this.conversationId,
  }) : super(ChatLibraryStateLoadSuccess()) {
    _networkSubscription = navigatorKey.currentContext!
        .read<NetworkCubit>()
        .stream
        .listen(_onNetworkStateChanged);
  }

  /// Phải làm hẳn các biến *Count này vì có thể một tin nhắn file chứa nhiều file (ảnh, video,...)
  /// Số file đã lấy của CTC chung
  ///int conversationFetchedFileCount = 0;

  /// Số file đã lấy của từng người. Key-Value: id - số file đã lấy
  ///Map<int, int> perPersonFetchedFileCount = {};

  _onNetworkStateChanged(NetworkState networkState) {
    if (state is ChatLibraryLoadConversationDetailError &&
        networkState.hasInternet) {
      _gatherAllMediasAvailable();
    } else if (state is ChatLibraryStateError &&
        (state as ChatLibraryStateError).error.isNetworkException) {}
  }

  _gatherAllMediasAvailable() async {
    try {
      //loadAllLibrary();
    } on CustomException catch (e) {
      emit(ChatLibraryLoadConversationDetailError(e.error));
    }
  }

  /// NOTE: Vì mù mờ việc trong file có thể có ảnh, video,
  /// do đó sẽ chỉ lấy từng loại một, theo API cung cấp
  ///
  /// @messageType:
  /// 1: Ảnh
  /// 2: File
  /// 3: Link
  /// @userId là người mà mình muốn lọc thư viện theo
  /// @fetchCount: Số file lấy thêm, tính từ lần cuối gọi API lấy
  ///
  /// emit ChatLibraryStateLoadSuccess khi thành công
  /// Lấy kết quả ra từ allFiles tương ứng
  Future<void> loadLibrary(
      {required MessageType messageType, int fetchCount = 10}) async {
    try {
      var fetchFileType = _getTypeId(messageType);
      await ChatLibraryRepo()
          .getLibrary(
        conversationId: conversationId,
        listMess: allFiles[messageType]!.filesFetchedFromAPI,
        countMessage: fetchCount,
        type: _getTypeId(messageType),
      )
          .then((response) {
        if (response.hasError) {
          /// TL 27/2/2024: TẠM BIỆT NHỮNG NGƯỜI Ở LẠI :>
          // Lỗi 200: {"data":null,"error":{"code":200,"message":"Cuộc trò chuyện không có ảnh, file, link nào"}}
          if (response.error!.code == 200) {
            emit(ChatLibraryStateLoadedEverything(messageType: messageType));
            return;
          } else {
            logger.logError("Tải API gặp lỗi: ${response.error!.messages}",
                null, "$runtimeType.loadLibrary");
            emit(ChatLibraryStateError(ExceptionError(response.error!.error)));
            return;
          }
        }

        var listMessages = List<SocketSentMessageModel>.from(
            (json.decode(response.data)['data']['listMessages'] as List).map(
          (e) => SocketSentMessageModel.fromMap(e),
        ));
        //conversationFetchedFileCount += listMessages.length;

        for (var mess in listMessages) {
          //_tryInitializeUserLib(userId: mess.senderId);
          // perPersonFetchedFileCount[mess.senderId] =
          //     perPersonFetchedFileCount[mess.senderId]! + 1;

          Iterable<SocketSentMessageModel> unzippedMessages;

          // Với ảnh và video, có khả năng nó chứa nhiều ảnh/video một lúc
          // Vì thế nên cần phải "giải nén" nó ra
          if (mess.type?.isImage == true || mess.type?.isFile == true) {
            unzippedMessages = mess.files!.map((e) {
              // var fType = mess.type;
              // if ([MessageType.image, MessageType.video].contains(e.fileType)) {
              //   fType = e.fileType;
              // }
              // var newMess = mess.copyWith(files: [e], type: fType);
              var newMess = mess.copyWith(files: [e]);
              return newMess;
            });
          } else {
            unzippedMessages = [mess];
          }

          for (final m in unzippedMessages) {
            allFiles[m.type]!.files.add(m);
            //   perPersonFiles[mess.senderId]![m.type]!.files.add(m);
          }
        }

        allFiles[messageType] = (
          filesFetchedFromAPI:
              allFiles[messageType]!.filesFetchedFromAPI + listMessages.length,
          files: allFiles[messageType]!.files
        );
      });

      emit(ChatLibraryStateLoadSuccess());
    } on CustomException catch (e, s) {
      logger.logError(e, s);
      if (e.error.error == 'Cuộc trò chuyện không có ảnh, file, link nào') {
        emit(ChatLibraryStateLoadedEverything(messageType: messageType));
        return;
      }
      emit(ChatLibraryStateError(e.error));
    }
  }

  /// TODO: Code vẫn ở đây, nhưng xử lí chưa xong
  /// @messageType:
  /// 0: Tất cả 1, 2, 3
  /// 1: Ảnh/Video
  /// 2: File
  /// 3: Link
  /// @userId là người mà mình muốn lọc thư viện theo
  ///
  /// emit ChatLibraryStateLoadSuccess khi thành công
  /// Lấy kết quả ra từ allFiles tương ứng
  // Future<void> loadLibraryFilteredByUser(
  //     {required int userId, MessageType? messageType}) async {
  //   _tryInitializeUserLib(userId: userId);

  //   try {
  //     var res = await ChatLibraryRepo().getLibrary(
  //       conversationId: conversationId,
  //       listMess: perPersonFetchedFileCount[userId]!,
  //       countMessage: filesPerFetch,
  //       type: _getTypeId(messageType),
  //       userId: userId,
  //     );

  //     await res.onCallBack((_) {
  //       var listMessages = List<SocketSentMessageModel>.from(
  //           (json.decode(res.data)['data']['listMessages'] as List).map(
  //         (e) => SocketSentMessageModel.fromMap(e),
  //       ));
  //       perPersonFetchedFileCount[userId] =
  //           perPersonFetchedFileCount[userId]! + listMessages.length;

  //       for (var mess in listMessages) {
  //         Iterable<SocketSentMessageModel> unzippedMessages;

  //         // Với ảnh và video, có khả năng nó chứa nhiều ảnh/video một lúc
  //         // Vì thế nên cần phải "giải nén" nó ra
  //         if (mess.type?.isImage == true || mess.type?.isFile == true) {
  //           unzippedMessages = mess.files!.map((e) {
  //             var fType = mess.type;
  //             if ([MessageType.image, MessageType.video].contains(e.fileType)) {
  //               fType = e.fileType;
  //             }
  //             var newMess = mess.copyWith(files: [e], type: fType);
  //             return newMess;
  //           });
  //         } else {
  //           unzippedMessages = [mess];
  //         }

  //         for (final m in unzippedMessages) {
  //           allFiles[m.type]!.add(m);
  //         }
  //       }
  //     });

  //     emit(ChatLibraryStateLoadSuccess());
  //   } on CustomException catch (e, s) {
  //     logger.logError(e, s);
  //     if (e.error.error == 'Cuộc trò chuyện không có ảnh, file, link nào') {
  //       emit(ChatLibraryStateLoadSuccess());
  //       return;
  //     }
  //     emit(ChatLibraryStateError(e.error));
  //   }
  // }

  /// Trả id kiểu tin nhắn tương ứng để gọi repo
  /// Tất cả Ảnh, File, Link: 0
  /// Ảnh: 1
  /// File: 2
  /// Link: 3
  int _getTypeId(MessageType? messageType) {
    switch (messageType) {
      case MessageType.image:
        return 1;
      case MessageType.file:
        return 2;
      case MessageType.link:
        return 3;
      default:
        return 2;
      // Tất cả mọi loại, kể cả messageType là CV hay notification hay gì đi nữa
      //return 0;
    }
  }

  final int conversationId;
  late final StreamSubscription<NetworkState> _networkSubscription;

  /// TL Note: Tất cả mọi files trong CTC này
  /// Đây là map: Kiểu file: (số file đã lấy từ API, Các message chứa file)
  Map<MessageType,
          ({int filesFetchedFromAPI, Set<SocketSentMessageModel> files})>
      allFiles = {
    MessageType.image: (filesFetchedFromAPI: 0, files: {}),
    // Có lẽ để sau
    //MessageType.video: {},
    MessageType.file: (filesFetchedFromAPI: 0, files: {}),
    MessageType.link: (filesFetchedFromAPI: 0, files: {}),
  };

  /// TL Note: Files được lọc theo từng người trong CTC
  /// Đây là map:
  /// userId: Kiểu file: (số file đã lấy từ API, Các message chứa file)
  // Map<
  //         int,
  //         Map<MessageType,
  //             ({int filesFetchedFromAPI, Set<SocketSentMessageModel> files})>>
  //     perPersonFiles = {};

  // TODO: Hiện cả file và video. Hiện tại mới chỉ có ảnh
  /// Dùng để hiển thị những file gần nhất cho CTC nhóm. Lấy 4 videos, ảnh gần nhất
  List<SocketSentMessageModel> getMostRecentFiles({required int amount}) {
    var imagesSortedByTime = allFiles[MessageType.image]!.files.toList();
    imagesSortedByTime.sort(((a, b) => a.createAt.compareTo(b.createAt)));
    return imagesSortedByTime.slice(
        start: max(0, imagesSortedByTime.length - amount));
  }

  @override
  Future<void> close() {
    _networkSubscription.cancel();
    return super.close();
  }

  /// Khởi tạo danh sách tin nhắn của người dùng này
  /// khi chúng ta chưa tải về file nào của họ
  // void _tryInitializeUserLib({required int userId}) {
  //   if (!perPersonFiles.containsKey(userId)) {
  //     //perPersonFetchedFileCount[userId] = 0;
  //     perPersonFiles[userId] = {
  //       MessageType.image: (filesFetchedFromAPI: 0, files: {}),
  //       //MessageType.video: {},
  //       MessageType.file: (filesFetchedFromAPI: 0, files: {}),
  //       MessageType.link: (filesFetchedFromAPI: 0, files: {}),
  //     };
  //   }
  // }
}
