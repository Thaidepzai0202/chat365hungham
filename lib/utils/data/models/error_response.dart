import 'package:app_chat365_pc/core/constants/status_code.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/utils/data/models/exception_error.dart';

class ErrorResponse extends ExceptionError {
  ErrorResponse({
    int? code,
    String? message,
  })  : this.code = code ?? StatusCode.errorUnknownCode,
        this.messages = message ?? StringConst.errorHappenedTryAgain,
        super(message ?? StringConst.errorHappenedTryAgain, code: code);

  final int? code;
  final String? messages;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
        code: int.tryParse(json["code"]?.toString() ?? ''),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": messages,
      };

  @override
  String toString() => '$messages\n[$code]';
}
