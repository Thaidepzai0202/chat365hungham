import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/core/constants/status_code.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part "user_type.g.dart";

/// 1: 'Công ty', 2: 'Nhân viên', 0: 'Khách hàng cá nhân', -1: 'Không xác định'

@HiveType(typeId: HiveTypeId.userTypeHiveTypeId)
class UserType extends Equatable {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String type;

  const UserType(this.id, this.type);

  /// Người dùng chưa đăng nhập
  static const unAuth = UserType(-1, 'Không xác định');

  static const customer = UserType(0, 'Khách hàng cá nhân');

  static const company = UserType(1, 'Công ty');

  static const staff = UserType(2, 'Nhân viên');

  static const authTypes = [customer, company, staff];

  /// Dùng khi xác thực OTP, vì trên QLC 1:nhân viên, 2:công ty
  int get reverseID=>id==1?2:1;

  @override
  String toString() => type;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
      };

  factory UserType.fromJson(Map<String, dynamic> json) => UserType(
        json['id'],
        json['type'],
      );

  static UserType fromId(int id) =>
      authTypes.singleWhere((element) => element.id == id);

  @override
  List<Object?> get props => [id];

  static Map<int, UserType> authUserTypeFromStatusCode = {
    StatusCode.wrongCustomerAuthStatusCode: UserType.customer,
    StatusCode.wrongStaffAuthStatusCode: UserType.staff,
    StatusCode.wrongCompanyAuthStatusCode: UserType.company,
  };

  String get authName {
    if (this == UserType.company) return StringConst.company;
    if (this == UserType.staff) return StringConst.employee;
    if (this == UserType.customer) return StringConst.personal;
    return '';
  }
}
