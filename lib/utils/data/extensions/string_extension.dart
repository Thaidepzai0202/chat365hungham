import 'dart:convert';

import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';

extension NullableStringExt on String? {
  String addColor(StrColor color) {
    String str;
    switch (color) {
      case StrColor.black: //   \x1B[30m
        str = '\x1B[30m';
        break;
      case StrColor.red: //     \x1B[31m
        str = '\x1B[31m';
        break;
      case StrColor.green: //   \x1B[32m
        str = '\x1B[32m';
        break;
      case StrColor.yellow: //  \x1B[33m
        str = '\x1B[33m';
        break;
      case StrColor.blue: //    \x1B[34m
        str = '\x1B[34m';
        break;
      case StrColor.magenta: // \x1B[35m
        str = '\x1B[35m';
        break;
      case StrColor.cyan: //    \x1B[36m
        str = '\x1B[36m';
        break;
      case StrColor.white: //   \x1B[37m
        str = '\x1B[37m';
        break;
      case StrColor.reset: //   \x1B[0m
        str = '\x1B[0m';
        break;
      case StrColor.darkRed:
        str = '\x1B[38;5;166m';
        break;
      default:
        str = '';
    }
    return '$str$this\x1B[m';
  }

  bool get isBlank => this == null || this!.trim().isEmpty;

  String valueIfNull(String value) => isBlank ? value : this!;

  String? cut(int maxLength) => isBlank
      ? this
      : this!.length < maxLength
          ? this!.substring(0, this!.length)
          : (this!.substring(0, maxLength) + '...');
}

extension StringExt on String {
  String toTitleCase() {
    if (isNotEmpty) {
      return this[0].toUpperCase() + substring(1);
    } else {
      return this;
    }
  }

  bool get isNotImageUrl {
    final int invertLastIndex = length - lastIndexOf('.');

    // ext của ảnh thường có length == 3
    // thêm dấu . thì == 4
    return invertLastIndex == -1 || invertLastIndex > 5;
  }

  bool get isImageUrl => !isNotImageUrl;

  String toEngAlphabetString() {
    var str = this;
    str = str.toLowerCase();
    str = str.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), "a");
    str = str.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), "e");
    str = str.replaceAll(RegExp(r'[ìíịỉĩ]'), "i");
    str = str.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), "o");
    str = str.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), "u");
    str = str.replaceAll(RegExp(r'[ỳýỵỷỹ]'), "y");
    str = str.replaceAll(RegExp(r'[đ]'), "d");
    // Some system encode vietnamese combining accent as individual utf-8 characters
    // str = str.replace(/\u0300\u0301|\u0303|\u0309|\u0323, ""); // Huyền sắc hỏi ngã nặng
    // str = str.replace(/\u02C6|\u0306|\u031B, ""); // Â, Ê, Ă, Ơ, Ư
    return str;
  }

  /// Lấy ra danh sách các số từ chuỗi
  List<int> getListIntFromThis() =>
      (split(RegExp(r'\s[^\d]+\s?')).map((e) => int.tryParse(e)).toList()
            ..removeWhere((e) => e == null))
          .cast();

  static final pinRegex = RegExp(r'^(\d+) pinned a message\:?.*');

  static final unPinRegex = RegExp(r'^(\d+) unpinned a message\:?.*');

  static final disableAutoDeleteMessageRegex =
      RegExp(r'^(\d+) set delete time is off');

  static final setAutoDeleteMessageRegex =
      RegExp(r'^(\d+) set delete time is (\d+) (\w+)');

  /// Parse từ message từ api thành thông báo hiển thị
  static String getDisplayMessageFromApiMessage(
    String apiMessage,
    List<String> users,
  ) {
    var _message = 'Không thể hiển thị thông báo';

    String msg = apiMessage.split('  ').join(' ');

    try {
      /// set auto delete message
      if (setAutoDeleteMessageRegex.hasMatch(msg)) {
        String _msg = msg.replaceAll(
            setAutoDeleteMessageRegex.allMatches(msg).first.group(1).toString(),
            users[0]);
        _message = _msg
            .replaceAll('set delete time is', 'đã đặt thời gian tự xóa là')
            .replaceAll('second', 'giây')
            .replaceAll('minute', 'phút')
            .replaceAll('day', 'ngày')
            .replaceAll('hour', 'giờ');
      }

      /// required

      bool isJsonString(String jsonString) {
        try {
          jsonDecode(jsonString);
          return true;
        } catch (e) {
          return false;
        }
      }

      if (isJsonString(apiMessage)) {
        Map<String, dynamic> jsonMap = jsonDecode(apiMessage);
        String message = jsonMap['message'];
        // print('meomeo: $message');
        _message = message;
      }

      /// disable auto delete message
      else if (disableAutoDeleteMessageRegex
          .hasMatch(apiMessage.split(RegExp(r'( )+')).join(' '))) {
        _message = changeLanguage.value == 'vi'
            ? '${users[0]} đã tắt tin nhắn tự xóa'
            : '${users[0]} turn off auto-deleta messagees';
      }

      /// add friend
      else if (apiMessage.contains('add friend'))
        _message = changeLanguage.value == 'vi'
            ? '${users[0]} đã gửi lời mời kết bạn đến ${users[1]}'
            : '${users[0]} sent a friend request to ${users[1]}';

      /// accept friend
      else if (apiMessage.contains('accept request'))
        _message = changeLanguage.value == 'vi'
            ? '${users[0]} đã chấp nhận lời mời kết bạn từ ${users[1]}'
            : '${users[0]} accept friend request from ${users[1]}';

      /// add
      else if (apiMessage.contains('added') &&
          apiMessage.contains('to this consersation')) {
        var user2;
        users.length == 1 ? user2 = users.single : user2 = users[1];
        _message = changeLanguage.value == 'vi'
            ? '${users[0]} đã thêm $user2 vào cuộc trò chuyện'
            : '${users[0]} added $user2 to this conversation';
      }

      /// delete
      else if (apiMessage.contains('remove') || apiMessage.contains('delete')) {
        _message = changeLanguage.value == 'vi'
            ? '${users[0]} đã xóa ${users[1]} khỏi cuộc trò chuyện'
            : '${users[0]} deleted ${users[1]} into this conversation';
      }

      /// join
      else if (apiMessage.contains('join')) {
        _message = changeLanguage.value == 'vi'
            ? '${users[0]} đã tham gia vào cuộc trò chuyện'
            : '${users[0]} joined in this conversation';
      }

      /// unpinned
      else if (unPinRegex.hasMatch(apiMessage)) {
        _message = changeLanguage.value == 'vi'
            ? '${users[0]} đã gỡ một tin nhắn đã ghim'
            : '${users[0]} removed a pinned message';
      }

      /// edit pinned message
      else if (apiMessage.contains('edited a pin')) {
        var index = apiMessage.indexOf(':');
        _message = changeLanguage.value == 'vi'
            ? '${users[0]} đã sửa tin nhắn đã ghim thành ${apiMessage.substring(index)}'
            : '${users[0]} edited the pinned message to ${apiMessage.substring(index)}';
      }

      /// pinned message
      else if (pinRegex.hasMatch(apiMessage)) {
        var index = apiMessage.indexOf(':');
        _message = changeLanguage.value == 'vi'
            ? '${users[0]} đã ghim một tin nhắn ${apiMessage.substring(index)}'
            : '${users[0]} pinned a message ${apiMessage.substring(index)}';
      }

      /// left conversation
      else if (apiMessage.contains('leaved')) {
        _message = changeLanguage.value == 'vi'
            ? '${users[0]} đã rời khỏi cuộc trò chuyện'
            : '${users[0]} leaved the conversation';
      }

      /// nomal notification
      else if (apiMessage.isNotEmpty) {
        _message = apiMessage;
      }

      ///
      else {
        throw CustomException(
          ExceptionError('Không thể nhận diện thông báo: $apiMessage'),
        );
      }
    } catch (e, s) {
      logger.logError('OriginApiNotification', apiMessage);
      logger.logError(e, s);
    }
    return _message;
  }

  int get tickFromMessageId => int.parse(split('_')[0]);

  String get originFileNameFromServerUri =>
      split('/').last.replaceAll(RegExp(r'^(\d+)-'), '');

  bool found(String keyWord) {
    if (toEngAlphabetString().contains(keyWord.toEngAlphabetString()))
      return true;
    String textOnly =
        this.toEngAlphabetString().replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');
    try {
      List<String> splitText = (textOnly.split(RegExp(r'( )+'))
            ..removeWhere((element) => element.isBlank))
          .map<String>((e) => e.substring(0, 1))
          .toList();
      if (textOnly.replaceAll(' ', '').contains(keyWord.toEngAlphabetString()))
        return true;
      if (splitText
          .join()
          .toEngAlphabetString()
          .contains(keyWord.toEngAlphabetString())) return true;
      return false;
    } catch (e) {
      logger.log(
          '$this --- ${jsonEncode(textOnly.split(RegExp(r'( )+')))} --- $e');
      return false;
    }
  }
}

enum StrColor {
  black, //   \x1B[30m
  red, //     \x1B[31m
  green, //   \x1B[32m
  yellow, //  \x1B[33m
  blue, //    \x1B[34m
  magenta, // \x1B[35m
  cyan, //    \x1B[36m
  white, //   \x1B[37m
  reset, //   \x1B[0m
  darkRed,
  emitSocket,
  onSocket,
}
