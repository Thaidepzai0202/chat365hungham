
class User365Model {
  final String epId;
  final String? epEmail;
  final String epName;
  final String epPhone;
  final String epImage;
  final String epAddress;
  final String? epEducation;
  final String? epExp;
  final int? epBirthDay;
  final String epMarried;
  final String epGender;
  final String roleId;
  final String positionId;
  final EpStatus epStatus;
  final DateTime? updateTime;
  final String allowUpdateFace;
  final String realComId;
  final String comId;
  final ComName comName;
  final ComLogo comLogo;
  final String? depId;
  final String? depName;
  final DateTime createTime;
  final String? groupId;
  final String? shiftId;

  User365Model({
    required this.epId,
    required this.epEmail,
    required this.epName,
    required this.epPhone,
    required this.epImage,
    required this.epAddress,
    required this.epEducation,
    required this.epExp,
    required this.epBirthDay,
    required this.epMarried,
    required this.epGender,
    required this.roleId,
    required this.positionId,
    required this.epStatus,
    required this.updateTime,
    required this.allowUpdateFace,
    required this.realComId,
    required this.comId,
    required this.comName,
    required this.comLogo,
    required this.depId,
    required this.depName,
    required this.createTime,
    required this.groupId,
    required this.shiftId,
  });


  factory User365Model.fromJson(Map<String, dynamic> json) => User365Model(
    epId: json["ep_id"],
    epEmail: json["ep_email"],
    epName: json["ep_name"],
    epPhone: json["ep_phone"],
    epImage: json["ep_image"],
    epAddress: json["ep_address"],
    epEducation: json["ep_education"],
    epExp: json["ep_exp"],
    epBirthDay: json["ep_birth_day"],
    epMarried: json["ep_married"],
    epGender: json["ep_gender"],
    roleId: json["role_id"],
    positionId: json["position_id"],
    epStatus: epStatusValues.map[json["ep_status"]]!,
    updateTime: json["update_time"] == null ? null : DateTime.parse(json["update_time"]),
    allowUpdateFace: json["allow_update_face"],
    realComId: json["real_com_id"],
    comId: json["com_id"],
    comName: comNameValues.map[json["com_name"]]!,
    comLogo: comLogoValues.map[json["com_logo"]]!,
    depId: json["dep_id"],
    depName: json["dep_name"],
    createTime: DateTime.parse(json["create_time"]),
    groupId: json["group_id"],
    shiftId: json["shift_id"],
  );

}

enum ComLogo {
  THE_20230825_APP1692935633_GIRL_PNG
}

final comLogoValues = EnumValues({
  "2023/08/25/app1692935633_girl.png": ComLogo.THE_20230825_APP1692935633_GIRL_PNG
});

enum ComName {
  CNG_TY_C_PHN_THANH_TON_HNG_H
}

final comNameValues = EnumValues({
  "Công ty Cổ phần Thanh toán Hưng Hà": ComName.CNG_TY_C_PHN_THANH_TON_HNG_H
});

enum EpStatus {
  ACTIVE
}

final epStatusValues = EnumValues({
  "Active": EpStatus.ACTIVE
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
