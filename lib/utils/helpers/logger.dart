import 'dart:developer' as dev;

import 'package:app_chat365_pc/utils/data/extensions/object_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:flutter/foundation.dart';

class Logger {
  log(Object? logStr, {StrColor? color, String name = 'appLog',int maxLength = 1500}) {
    String? _logStr = logStr.toString().cut(maxLength);
    if (kDebugMode || kProfileMode) {
      if (color != null) {
        dev.log('${(_logStr??'').toColoredString(color)}', name: name);
      } else {
        dev.log(_logStr.toString(), name: name);
      }
    } else {
      _logPrint(_logStr, color: color, name: name);
    }
  }

  String _logTime() {
    var now = DateTime.now();
    var year = now.year;
    var month = now.month;
    var day = now.day;
    var hour = now.hour;
    var minute = now.minute;
    var second = now.second;
    return [day, month, year].join('-') +
        ' ' +
        [hour, minute, second].join(':');
  }

  void _logPrint(
    Object? object, {
    StrColor? color,
    String? name,
  }) async {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    var chunks = pattern.allMatches(object.toString());
    var time = _logTime();
    debugPrint('[$time] '.addColor(StrColor.white));
    for (var e in chunks) {
      var group = e.group(0);
      var logName = (name != null ? '[$name] ' : '').addColor(StrColor.white);
      if (color != null) {
        debugPrint(logName + group.addColor(color));
      } else {
        debugPrint(logName + group.toString());
      }
    }
  }

  logError(Object? error, [Object? stackTrace, String? name]) {
    log(error, color: StrColor.red, name: name ?? 'LogError');
    if (stackTrace != null)
      log(stackTrace, color: StrColor.red, name: name ?? 'LogError');
  }
  logEventLeak(Object? error, {String? name}) {
    log(error, color: StrColor.magenta, name: name ?? 'LogEventLeak');
  }
}

var logger = Logger();
