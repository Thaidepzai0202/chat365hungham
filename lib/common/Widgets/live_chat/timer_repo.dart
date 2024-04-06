import 'dart:async';
import 'dart:isolate';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';

/// Chứa các bộ đếm thời gian tin nhắn livechat,
/// bao gồm bộ đếm cho từng tin nhắn (khi NTD đăng nhập timviec365),
/// và bộ đếm theo từng CTC (khi NTD nhắn tin).
class TimerRepo {
  static const int liveChatCountdownTime = 30;

  @Deprecated(
      "Dùng 'timerRepo' ở main.dart nhé. Nếu không nó sẽ bị sinh 2 lần đấy")
  TimerRepo() {
    // logger.log(
    //     "Sinh TimerRepo ở Isolate: ${Isolate.current.debugName}:\n ${StackTrace.current}",
    //     name: "TimerRepo",
    //     maxLength: 10000);
  }

  /// Dùng cho trường hợp NTD đăng nhập timviec365.
  /// Mapping giữa livechat messageId và tin nhắn.
  /// (nhưng chưa thấy dùng để làm gì cả :) )
  // final Map<String, SocketSentMessageModel> _messagesMap = {};

  /// Dùng cho trường hợp NTD đăng nhập timviec365.
  /// Mapping giữa livechat messageId và LivechatTimer tương ứng cho tin nhắn đó.
  final Map<String, LivechatTimer> _livechatMessageTimer = {};

  /// Bắn ra tin nhắn livechat đã hết hạn mà không được bắt
  Stream<SocketSentMessageModel> get livechatMessageExpired =>
      _livechatMessageExpired.stream;
  late final StreamController<SocketSentMessageModel> _livechatMessageExpired =
      StreamController<SocketSentMessageModel>.broadcast();

  /// Bắn ra ID cuộc trò chuyện đã hết hạn mà chuyên viên không trả lời
  Stream<int> get livechatConversationExpired =>
      _livechatConversationExpired.stream;
  late final StreamController<int> _livechatConversationExpired =
      StreamController<int>.broadcast();

  /// Mapping giữa conversationId và [LivechatTimer] tương ứng.
  /// Dùng để bấm giờ cuộc trò chuyện giữa NTD và chuyên viên.
  ///
  /// Mỗi CTC sẽ có một Timer tương ứng với tin nhắn gần nhất của NTD.
  /// Khi chuyên viên đã trả lời tin nhắn gần nhất đó, thì timer sẽ bị tiêu diệt.
  /// Một cái mới sẽ được tạo lại khi NTD nhắn tin tiếp.
  final Map<int, LivechatTimer> _livechatConversationTimer = {};

  /// Bắt đầu một bộ đếm tin nhắn cho [msg]. Nếu tin nhắn tồn tại rồi thì sẽ đếm lại.
  /// Trả về timer tin nhắn tương ứng của [msg]
  LivechatTimer startLivechatMessageTimer(SocketSentMessageModel msg) {
    // if (!_livechatMessageTimer.containsKey(msg.messageId)) {
    //   logger.log("Không tồn tại Timer ${msg.messageId}", name: "TimerRepo");
    // } else {
    //   _livechatMessageTimer[msg.messageId]!.stop();
    // }

    /// Dừng bộ đếm tin nhắn của tin nhắn trùng id với cái mới này
    _livechatMessageTimer[msg.messageId]?.stop();

    logger.log("Start timer ${msg.messageId}", name: "$runtimeType");
    _livechatMessageTimer[msg.messageId] = LivechatTimer(
        totalTime: Duration(seconds: liveChatCountdownTime),
        interval: Duration(milliseconds: 100));

    // _messagesMap[msg.messageId] = msg;

    /// Bắn event tin nhắn hết hạn khi Timer kết thúc
    _livechatMessageTimer[msg.messageId]!.finished.listen((event) {
      _livechatMessageExpired.add(msg);
    });

    return _livechatMessageTimer[msg.messageId]!;
  }

  /// TL 20/2/2024
  /// Dùng khi đã bắt xong tin nhắn livechat.
  /// Tiêu diệt timer của tin nhắn [msgId],
  /// và clean up một số trạng thái cục bộ của TimerRepo
  void stopLivechatMessageTimer(String messageId) {
    logger.log("Stop timer  $messageId", name: "$runtimeType");
    _livechatMessageTimer[messageId]!.stop();
    _livechatMessageTimer.remove(messageId);
    // _messagesMap.remove(messageId);
  }

  /// TL 21/2/2024:
  ///
  /// Trả về [LivechatTimer] bấm giờ tin nhắn livechat khi
  /// nhà tuyển dụng đăng nhập timviec365 (ít nhất là tôi dùng nó như thế).
  ///
  /// NOTE: Chỉ dùng để nghe event (các stream) thôi.
  /// Nếu muốn cancel nó thì gọi [stopLivechatMessageTimer()] nhé.
  LivechatTimer? getLivechatMessageTimer(String msgId) =>
      _livechatMessageTimer[msgId];

  /// Bắt đầu một bộ đếm tin nhắn cho [msg]. Nếu tin nhắn tồn tại rồi thì sẽ đếm lại.
  /// Trả về timer tin nhắn tương ứng của [msg]
  LivechatTimer startLivechatConversationTimer(int conversationId) {
    /// Dừng bộ đếm tin nhắn của tin nhắn trùng id với cái mới này
    _livechatMessageTimer[conversationId]?.stop();

    logger.log("Start timer ${conversationId}", name: "$runtimeType");
    _livechatConversationTimer[conversationId] = LivechatTimer(
        totalTime: Duration(seconds: liveChatCountdownTime),
        interval: Duration(milliseconds: 100));

    // _messagesMap[msg.messageId] = msg;

    /// Bắn event tin nhắn hết hạn khi Timer kết thúc
    _livechatConversationTimer[conversationId]!.finished.listen((event) {
      _livechatConversationExpired.add(conversationId);
    });

    return _livechatMessageTimer[conversationId]!;
  }

  /// TL 21/2/2024
  /// Dùng khi đã bắt xong tin nhắn livechat.
  /// Tiêu diệt timer của tin nhắn [msgId],
  /// và clean up một số trạng thái cục bộ của TimerRepo
  void stopLivechatConversationTimer(int conversationId) {
    logger.log("Stop timer  $conversationId", name: "$runtimeType");
    if (_livechatConversationTimer[conversationId] != null) {
      _livechatConversationTimer[conversationId]!.stop();
      _livechatConversationTimer.remove(conversationId);
    }
  }

  /// TL 21/2/2024:
  ///
  /// Trả về [LivechatTimer] bấm giờ cuộc trò chuyện livechat khi
  /// nhà tuyển dụng đăng nhập timviec365 (ít nhất là tôi dùng nó như thế).
  ///
  /// NOTE: Chỉ dùng để nghe event (các stream) thôi.
  /// Nếu muốn cancel nó thì gọi [stopLivechatConversationTimer()] nhé.
  LivechatTimer? getLivechatConversationTimer(int conversationId) =>
      _livechatConversationTimer[conversationId];

  ///// VVVVVVVVVVVVV Không phải code Lâm VVVVVV

  // List<SocketSentMessageModel> listLiveChatMessages = [];
  // ValueNotifier<bool> shouShowConversationCountDown = ValueNotifier(true);
  // Map<String, SocketSentMessageModel> messageModels = {};
  // Map<String, Stream> timerStreams = {};
  // Map<int, SocketSentMessageModel> messConversationModels = {};
  // Map<int, Stream> timerStreamsConversation = {};
  // Timer? timer;
  // late StreamController<int> timerController;
  // late int count;
  // SocketSentMessageModel? getMessageModel(String msgId) {
  //   return messageModels[msgId];
  // }

  // SocketSentMessageModel? getMessageModelConversation(int conId) {
  //   return messConversationModels[conId];
  // }

  // // void addMessageModel(SocketSentMessageModel model) {
  // //   if (messageModels.containsKey(model.messageId)) return;
  // //   messageModels.addAll({model.messageId: model});
  // // }
  // void addConversationModel(SocketSentMessageModel model) {
  //   if (messConversationModels.containsKey(model.conversationId)) {
  //     messConversationModels.remove(model.conversationId);
  //   }
  //   messConversationModels.addAll({model.conversationId: model});
  // }

  // late final StreamController<String> livechatExpired =
  //     StreamController<String>.broadcast();
  // Stream<String> get livechatExpiredStream => livechatExpired.stream;

  // Stream? getTimerStream(String msgId) {
  //   return timerStreams[msgId];
  // }

  // Stream? getTimerStreamConversation(int conId) {
  //   return timerStreamsConversation[conId];
  // }

  // // check theo messID
  // Stream<int>? startCountdown(String msgId, {countDown = 30}) {
  //   if (timerStreams.containsKey(msgId)) return null;
  //   timerController = StreamController.broadcast();
  //   timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     countDown--;
  //     timerController.add(countDown);
  //     if (countDown == 0) {
  //       timer.cancel();
  //       timerController.close();
  //     }
  //   });
  //   timerStreams.addAll({msgId: timerController.stream});
  //   return timerController.stream;
  // }

  // // check theo conversation ID
  // Stream<int>? startCountdownConversation(int conId) {
  //   shouShowConversationCountDown.value = true;
  //   count = 30;
  //   timerController = StreamController.broadcast();
  //   timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     count--;
  //     timerController.add(count);
  //     if (count == 0) {
  //       timer.cancel();
  //       timerController.close();
  //     }
  //   });
  //   timerStreamsConversation.addAll({conId: timerController.stream});
  //   return timerController.stream;
  // }

  // void dispose() {
  //   timer?.cancel();
  //   timerController.close();
  // }
}

/// TL 21/2/2024:
///
/// Đây là Timer có thêm chức năng bắn event mỗi giây để build UI cho tiện.
/// Thực ra cũng có thể extends Timer đấy, nhưng không hiểu sao lúc ấy không nghĩ ra -.-
class LivechatTimer {
  /// Mỗi một khoảng thời gian [interval] trôi qua, tick được bắn một lần với argument là thời gian còn lại
  Stream<Duration> get tick => _tickEvent.stream;
  final StreamController<Duration> _tickEvent = StreamController.broadcast();

  /// Được bắn khi timer chạy xong. Argument là tổng thời gian đã chạy (tick * interval)
  Stream<Duration> get finished => _finishedEvent.stream;
  final StreamController<Duration> _finishedEvent =
      StreamController.broadcast();

  late final Timer _timer;

  late final Duration totalTime;
  late final Duration interval;
  Duration get timeLeft => totalTime - interval * _timer.tick;

  /// Dừng bộ đếm thời gian.
  /// Nếu đồng chí muốn dừng bộ đếm cho một tin nhắn livechat,
  /// thì dùng [TimerRepo.stopLivechatMessageTimer()] hoặc [TimerRepo.stopLivechatConversationTimer()] nhé.
  void stop() {
    _timer.cancel();
  }

  /// Tạo một Timer chạy trong [totalTime] giây, mỗi [interval] giây lại
  /// bắn event [tick]. Ở lần bắn event cuối cùng, sẽ bắn thêm cả [finished].
  LivechatTimer(
      {this.totalTime = const Duration(seconds: 30),
      this.interval = const Duration(seconds: 1)}) {
    // logger.log("Sinh Timer ở:\n ${StackTrace.current}",
    //     name: "Timer", maxLength: 10000);

    _timer = Timer.periodic(interval, (timer) {
      _tickEvent.add(timeLeft);

      if (timeLeft.isNegative) {
        timer.cancel();
        _finishedEvent.add(interval * timer.tick);
      }
    });
  }
}
