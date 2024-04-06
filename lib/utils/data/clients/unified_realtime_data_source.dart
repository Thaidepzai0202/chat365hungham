import 'dart:async';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/clients/interceptors/mqtt_client_5.dart';

/// TL 18/2/2024
///
/// Class này dùng để tập hợp tất cả các nguồn data realtime về một mối,
/// tránh để các class (Repo?) cần lấy data từ N nguồn
/// thì phải viết N đoạn code giống nhau.
///
/// Sử dụng UnifiedRealtimeDataSource.events.listen() để lắng nghe event.
///
/// Hiện tại đang sử dụng data realtime từ các nguồn:
/// - Socket (ChatClient)
/// - MQTT
class UnifiedRealtimeDataSource {
  static UnifiedRealtimeDataSource? _instance;

  factory UnifiedRealtimeDataSource() =>
      _instance ??= UnifiedRealtimeDataSource._();

  UnifiedRealtimeDataSource._() {
    MqttClient().stream.listen(emitChatEvent);
    ChatClient().stream.listen(emitChatEvent);
  }

  final StreamController<ChatEvent> _controller = StreamController.broadcast();

  Stream<ChatEvent> get stream => _controller.stream;

  /// Dùng để tự bắn event cho chính mình.
  void emitChatEvent(ChatEvent event) async {
    _controller.add(event);
  }

  // _onNicknameChangedHandler(e) {
  //   _controller.sink.add(
  //     UserInfoEventNicknameChanged(
  //       newNickname: e[1],
  //       conversationId: int.parse(e[0].toString()),
  //     ),
  //   );
  // }
}
