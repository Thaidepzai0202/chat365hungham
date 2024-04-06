import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:hive/hive.dart';
part 'user_model_zalo.g.dart';

@HiveType(typeId: HiveTypeId.userInfoHiveZalo)
class UserInfoZalo {
  @HiveField(0)
  String name;
  @HiveField(1)
  String ava;
  @HiveField(2)
  String idZalo;
  @HiveField(3)
  String numPhoneZalo;
  @HiveField(4)
  bool status;

  UserInfoZalo(
      {required this.ava,
      required this.idZalo,
      required this.name,
      required this.numPhoneZalo,
      required this.status});

  factory UserInfoZalo.fromJson(Map<String, dynamic> map) {
    return UserInfoZalo(
      name: map['name'] ?? '',
      ava: map['ava'] ?? '',
      idZalo: map['id_zalo'] ?? '',
      numPhoneZalo: map['num_phone_zalo'] ?? '',
      status: map['status'] == 'true' ? true : false,
    );
  }
}
