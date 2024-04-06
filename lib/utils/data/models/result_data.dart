import 'dart:convert';

import 'package:app_chat365_pc/utils/data/models/chat_quick_message.dart';

ResultDataIdString resultDataIdStringFromJson(String str) =>
    ResultDataIdString.fromJson(json.decode(str));

String ResultDataIdStringToJson(ResultDataIdString data) =>
    json.encode(data.toJson());

class ResultDataIdString {
  ResultDataIdString({
    required this.data,
    required this.error,
  });

  final Data data;
  final Error error;

  factory ResultDataIdString.fromJson(Map<String, dynamic> json) =>
      ResultDataIdString(
        data: Data.fromJson(json["data"] ?? {}),
        error: Error.fromJson(json["error"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "error": error.toJson(),
      };
}

class Data {
  Data({
    required this.result,
    required this.message,
    required this.id,
  });

  final bool result;
  final String message;
  final String id;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        result: json["result"] ?? false,
        message: json["message"] ?? "",
        id: json["id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "message": message,
        "_id": id,
      };
}

class Error {
  Error({
    required this.code,
    required this.message,
  });

  final int? code;
  final String message;

  factory Error.fromJson(Map<String, dynamic> json) => Error(
        code: json["code"] ?? 0,
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
      };
}

ResultDataIdInt resultDataIdIntFromJson(String str) =>
    ResultDataIdInt.fromJson(json.decode(str));

String ResultDataIdIntToJson(ResultDataIdInt data) =>
    json.encode(data.toJson());

class ResultDataIdInt {
  ResultDataIdInt({
    required this.data,
    required this.error,
  });

  final DataIdInt data;
  final Error error;

  factory ResultDataIdInt.fromJson(Map<String, dynamic> json) =>
      ResultDataIdInt(
        data: DataIdInt.fromJson(json["data"] ?? {}),
        error: Error.fromJson(json["error"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "error": error.toJson(),
      };
}

class DataIdInt {
  DataIdInt({
    required this.result,
    required this.message,
    required this.id,
  });

  final bool result;
  final String message;
  final String id;

  factory DataIdInt.fromJson(Map<String, dynamic> json) => DataIdInt(
        result: json["result"] ?? false,
        message: json["message"] ?? "",
        id: json["_id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "message": message,
        "_id": id,
      };
}

ResultDataAddQuickMessage resultDataAddQuickMessageFromJson(String str) =>
    ResultDataAddQuickMessage.fromJson(json.decode(str));

String ResultDataAddQuickMessageToJson(ResultDataIdInt data) =>
    json.encode(data.toJson());

class ResultDataAddQuickMessage {
  ResultDataAddQuickMessage({
    required this.data,
    required this.error,
  });

  final DataAddQuickMessage data;
  final Error error;

  factory ResultDataAddQuickMessage.fromJson(Map<String, dynamic> json) =>
      ResultDataAddQuickMessage(
        data: DataAddQuickMessage.fromJson(json["data"] ?? {}),
        error: Error.fromJson(json["error"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "error": error.toJson(),
      };
}

class DataAddQuickMessage {
  DataAddQuickMessage({
    required this.result,
    required this.message,
    required this.data,
    required this.id,
  });

  final bool result;
  final String message;
  final QuickMessageModel data;
  final String id;

  factory DataAddQuickMessage.fromJson(Map<String, dynamic> json) =>
      DataAddQuickMessage(
        result: json["result"] ?? false,
        message: json["message"] ?? "",
        data: QuickMessageModel.fromMap(json['data']),
        id: json["_id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "message": message,
        "_id": id,
      };
}
