import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/utils/data/extensions/date_time_extension.dart';
import 'package:hive/hive.dart';

part 'auto_delete_message_time_model.g.dart';

@HiveType(typeId: HiveTypeId.autoDeleteMessageModelHiveTypeId)
class AutoDeleteMessageTimeModel {
  @HiveField(0)
  final int deleteType;
  @HiveField(1)
  final int deleteTime;
  @HiveField(2)
  final DateTime? deleteDate;

  const AutoDeleteMessageTimeModel({
    required this.deleteType,
    required this.deleteTime,
    this.deleteDate,
  });

  bool get isAutoDeleteMessage => deleteTime != 0 || deleteType != 0;

  AutoDeleteMessageType? get autoDeleteType {
    if (!isAutoDeleteMessage) return null;
    if (deleteType == 0) {
      return AutoDeleteMessageType.secrect;
    } else {
      return AutoDeleteMessageType.autoDelete;
    }
  }

  static const defaultModel = AutoDeleteMessageTimeModel(
    deleteTime: 0,
    deleteType: 0,
  );

  factory AutoDeleteMessageTimeModel.fromJson(Map<String, dynamic> json) {
    var tryTimeZoneParse = DateTimeExt.tryTimeZoneParse(
      json['deleteDate'] ?? json['DeleteDate'],
    )?.subtract(const Duration(hours: 7));
    return AutoDeleteMessageTimeModel(
      deleteTime: json['deleteTime'] ?? json['DeleteTime'] ?? 0,
      deleteType: json['deleteType'] ?? json['DeleteType'] ?? 0,
      deleteDate: tryTimeZoneParse,
    );
  }

  Map<String, dynamic> toJson() => {
        'deleteTime': deleteTime,
        'deleteType': deleteType,
        'deleteDate': deleteDate?.toTimezoneFormatString(),
      };

  Map<String, dynamic> toMapOfSocket() => {
        'DeleteTime': deleteTime,
        'DeleteType': deleteType,
        'DeleteDate': deleteDate?.toTimezoneFormatString(),
      };
}

enum AutoDeleteMessageType {
  secrect,
  autoDelete,
}
