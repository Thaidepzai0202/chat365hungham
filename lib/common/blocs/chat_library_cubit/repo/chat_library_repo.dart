import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';

/// TL 21/12/2023:
/// Singleton. Dùng cho ChatLibraryCubit.
/// Thêm hay không vào MultiRepositoryProvider ở MyApp thì tùy
/// Nhưng mình nghĩ là không nên
///
/// TL 13/1/2024:
/// Note: Hồi đầu làm Library Cubit thì chưa hiểu về thiết kế Repo nên chưa cache nó luôn ở đây
/// TODO: Cache URL các media mà mình đã tải về.
/// Mô tả luồng (chưa nghĩ xong):
/// 1. Vào app, HiveService init cache repo này
/// 2. Khi mất mạng, các cờ đồng bộ sẽ bị tiêu diệt
/// 3. Khi gọi getLibrary():
/// 3.1 Nếu có mạng và chưa đồng bộ
/// 3.1.T Gọi API cập nhật đến khi đủ thì thôi
/// 3.1.F Nếu không có mạng:
///
class ChatLibraryRepo {
  factory ChatLibraryRepo() => _instance ??= ChatLibraryRepo._();

  ChatLibraryRepo._();

  /// @conversationId: id cuộc trò chuyện
  /// @listMess: số cái đã lấy ra
  /// @countMessage: số cái muốn lấy
  /// @type: 0: tất cả ảnh, link, file, 1: ảnh, 2: file, 3: link
  /// @userId: [OPTIONAL]: Lọc tin nhắn theo id người gửi
  Future<RequestResponse> getLibrary({
    required int conversationId,
    required int listMess,
    required int countMessage,
    required int type,
    int? userId,
  }) =>
      ApiClient().fetch(
        ApiPath.chatLibrary,
        data: {
          'conversationId': conversationId,
          'listMess': listMess,
          'countMessage': countMessage,
          'TYPE': type,
          if (userId != null) 'userId': userId,
          // TL Note 21/12/2023: Nguyễn Công Tiến bảo bỏ
          //'messageDisplay': messageDisplay,
        },
      );

  static ChatLibraryRepo? _instance;
}
