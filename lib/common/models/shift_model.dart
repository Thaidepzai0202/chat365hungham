class ShiftModel {
  final String id;
  final int shiftId;
  final int comId;
  final String shiftName;
  final String startTime;
  final String? startTimeLatest;
  final String endTime;
  final String? endTimeEarliest;
  final int overNight;
  final int shiftType;
  final dynamic numToCalculate;
  final int numToMoney;
  final int moneyPerhour;
  final int isOvertime;
  final int status;
  final List<RelaxTime>? relaxTime;
  final int? flex;
  final DateTime createTime;

  ShiftModel({
    required this.id,
    required this.shiftId,
    required this.comId,
    required this.shiftName,
    required this.startTime,
    required this.startTimeLatest,
    required this.endTime,
    required this.endTimeEarliest,
    required this.overNight,
    required this.shiftType,
    required this.numToCalculate,
    required this.numToMoney,
    required this.moneyPerhour,
    required this.isOvertime,
    required this.status,
    this.relaxTime,
    this.flex,
    required this.createTime,
  });


  factory ShiftModel.fromJson(Map<String, dynamic> json) => ShiftModel(
    id: json["_id"] ?? '',
    shiftId: json["shift_id"],
    comId: json["com_id"],
    shiftName: json["shift_name"] ?? '',
    startTime: json["start_time"] ?? '',
    startTimeLatest: json["start_time_latest"] ?? '',
    endTime: json["end_time"] ?? '',
    endTimeEarliest: json["end_time_earliest"] ?? '',
    overNight: json["over_night"] ?? 0,
    shiftType: json["shift_type"] ?? 0,
    numToCalculate: json["num_to_calculate"] ?? '',
    numToMoney: json["num_to_money"] ?? 0,
    moneyPerhour: json["money_per_hour"] ?? 0,
    isOvertime: json["is_overtime"] ?? 0,
    status: json["status"] ?? 0,
    relaxTime: json["relaxTime"] == null ? [] : List<RelaxTime>.from(json["relaxTime"]!.map((x) => RelaxTime.fromJson(x))),
    flex: json["flex"] ?? 0,
    createTime: DateTime.parse(json["create_time"]),
  );


}

class NumToCalculateClass {
  final String numberDecimal;

  NumToCalculateClass({
    required this.numberDecimal,
  });

  factory NumToCalculateClass.fromJson(Map<String, dynamic> json) => NumToCalculateClass(
    numberDecimal: json["\u0024numberDecimal"],
  );

  Map<String, dynamic> toJson() => {
    "\u0024numberDecimal": numberDecimal,
  };
}

class RelaxTime {
  final dynamic startTimeRelax;
  final dynamic endTimeRelax;
  final String id;

  RelaxTime({
    required this.startTimeRelax,
    required this.endTimeRelax,
    required this.id,
  });

  factory RelaxTime.fromJson(Map<String, dynamic> json) => RelaxTime(
    startTimeRelax: json["start_time_relax"],
    endTimeRelax: json["end_time_relax"],
    id: json["_id"],
  );

}
