import 'package:flutter/material.dart';

class Convert {
  // xoa dau khoi chuoi
  String removeDiacritics(String input) {
    final diacriticCharacters = {
      'a': [
        'á',
        'à',
        'ả',
        'ã',
        'ạ',
        'ă',
        'ắ',
        'ằ',
        'ẳ',
        'ẵ',
        'ặ',
        'â',
        'ấ',
        'ầ',
        'ẩ',
        'ẫ',
        'ậ'
      ],
      'e': ['é', 'è', 'ẻ', 'ẽ', 'ẹ', 'ê', 'ế', 'ề', 'ể', 'ễ', 'ệ'],
      'i': ['í', 'ì', 'ỉ', 'ĩ', 'ị'],
      'o': [
        'ó',
        'ò',
        'ỏ',
        'õ',
        'ọ',
        'ô',
        'ố',
        'ồ',
        'ổ',
        'ỗ',
        'ộ',
        'ơ',
        'ớ',
        'ờ',
        'ở',
        'ỡ',
        'ợ'
      ],
      'u': ['ú', 'ù', 'ủ', 'ũ', 'ụ', 'ư', 'ứ', 'ừ', 'ử', 'ữ', 'ự'],
      'y': ['ý', 'ỳ', 'ỷ', 'ỹ', 'ỵ'],
      'd': ['đ']
    };

    for (var key in diacriticCharacters.keys) {
      for (var char in diacriticCharacters[key]!) {
        input = input.replaceAll(char, key);
      }
    }

    return input;
  }

  // chuyen tu DateTime sang chuoi co dang yyyy-mm-ddThh-mm-ssZ
  String DateTimeToTZString(DateTime? dateTime) {
    // String year = dateTime.year.toString();
    // String month =
    // dateTime.month < 10 ? '0${dateTime.month}' : dateTime.month.toString();
    // String day =
    // dateTime.day < 10 ? '0${dateTime.day}' : dateTime.day.toString();
    // String hour =
    // dateTime.hour < 10 ? '0${dateTime.hour}' : dateTime.hour.toString();
    // String minute = dateTime.minute < 10
    //     ? '0${dateTime.minute}'
    //     : dateTime.minute.toString();
    // String second = dateTime.second < 10
    //     ? '0${dateTime.second}'
    //     : dateTime.second.toString();
    // return '${year}-${month}-${day}T${hour}:${minute}:${second}Z';
    return '${(dateTime == null) ? DateTime.now().toIso8601String() : dateTime.toIso8601String()}';
  }

  // chuyen tu chuoi co dang yyyy-mm-ddThh-mm-ssZ sang DateTime
  DateTime TZStringToDateTime(String? dateTimeString) {
    DateTime dateTime = (dateTimeString == null || dateTimeString.isEmpty)
        ? DateTime.now()
        : DateTime.parse(dateTimeString);
    return dateTime;
  }

  /// chuyen tu DateTime sang chuoi co dang hh:mm SA/CH, dd-mm-yyyy
  String DateTimeToSACHString(DateTime? dateTime) {
    DateTime tsDate = dateTime ?? DateTime.now();
    TimeOfDay timeOfDay = TimeOfDay.fromDateTime(tsDate);
    return (timeOfDay.hour < 10 ? "0" : "") +
        timeOfDay.hourOfPeriod.toString() +
        ":" +
        (timeOfDay.minute < 10 ? "0" : "") +
        timeOfDay.minute.toString() +
        " " +
        ((timeOfDay.hour > 12 && timeOfDay.hour < 24) ? 'CH' : 'SA') +
        ', ' +
        (tsDate.day < 10 ? "0" : "") +
        tsDate.day.toString() +
        "-" +
        (tsDate.month < 10 ? "0" : "") +
        tsDate.month.toString() +
        "-" +
        tsDate.year.toString();
  }

  // chuyen tu DateTime sang chuoi co dang dd-mm-yyyy
  String DateTimeToDayString(DateTime? dateTime) {
    DateTime tsDate = dateTime ?? DateTime.now();
    return (tsDate.day < 10 ? "0" : "") +
        tsDate.day.toString() +
        "-" +
        (tsDate.month < 10 ? "0" : "") +
        tsDate.month.toString() +
        "-" +
        tsDate.year.toString();
  }

  int DateTimeToTimeStamp(DateTime dateTime) =>
      dateTime.millisecondsSinceEpoch ~/ 1000;

  // chuyen tu TimeStamp sang chuoi co dang dd-mm-yyyy, hh:mm:ss
  String TimeStampToFormatString(int? timeInt) {
    String datetime = "";
    int? ts = timeInt;
    DateTime tsDate = (ts == null)
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    datetime = (tsDate.day < 10 ? "0" : "") +
        tsDate.day.toString() +
        "-" +
        (tsDate.month < 10 ? "0" : "") +
        tsDate.month.toString() +
        "-" +
        tsDate.year.toString() +
        ", " +
        (tsDate.hour < 10 ? "0" : "") +
        tsDate.hour.toString() +
        ":" +
        (tsDate.minute < 10 ? "0" : "") +
        tsDate.minute.toString() +
        ":" +
        (tsDate.second < 10 ? "0" : "") +
        tsDate.second.toString();
    return datetime;
  }

  // chuyen int cua TimeStamp thanh DateTime
  DateTime TimeStampToDateTime(int? timeInt) {
    DateTime tsDate = (timeInt == null)
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(timeInt * 1000);
    return tsDate;
  }

  // chuyen TimeOfDay thanh String
  String TimeOfDayToString(TimeOfDay? timeOfDay) {
    return timeOfDay == null
        ? TimeOfDay.fromDateTime(DateTime.now()).toString()
        : timeOfDay.toString();
  }

  /// Return DateTime in form hh:mm
  String toHhMm(DateTime dt) {
    return "${dt.hour < 10 ? "0" : ""}${dt.hour}:${dt.minute < 10 ? "0" : ""}${dt.minute}";
  }

  // chuyen thoi gian dang hh:mm SA/CH, hh:mm, hh:mm:ss, --:-- -- thanh TimeOfDay
  // tam thoi chua can thiet vi chua can lay thoi gian cua ca lam viec
  // luc nao can se hoi lai
  // TimeOfDay TimeStringToTimeOfDay(String timeString) {
  //   RegExp
  // }
}
