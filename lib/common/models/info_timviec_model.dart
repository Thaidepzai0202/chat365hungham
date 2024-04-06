import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/rx_class.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class InfoTimviec365Model extends Equatable {
  final String? id;
  final String? email;
  final String? passMD5;
  final UserType? userType;
  final int? cityId;
  final String? cityName;
  final List? listJob;
  final String? name;
  final String? phone;
  RxInt? point;
  double? percents;
  ValueNotifier<String>? token;
   InfoTimviec365Model({
     this.id,
     this.email,
     this.passMD5,
     this.userType,
     this.cityId,
    this.cityName,
    this.listJob =  const [],
    this.name, this.phone,
     this.point,
     this.token,
     this.percents
  });

  factory InfoTimviec365Model.fromMap(Map<String, dynamic> map) {
    return InfoTimviec365Model(
      id: map['id_timviec'] == 0 || map['id_timviec'] == null ?'-1': map['id_timviec'].toString(),
      email: map['email'],
      passMD5: map['password']??'',
      userType: UserType.fromId(map['type']??0),
      cityId: map['city_id'],
      cityName: map['CityName']??'',
      listJob: !(map['list_new'] ==null?[]:map['list_new'] as List).isBlank ?map['list_new'].map((e)=> e).toList() : [],
      name: map['name']??'',
      phone: map['phone']??'',
      point: RxInt(map['point']),
      token: ValueNotifier(map['token']??''),
      percents: map['percents'].runtimeType ==int?(map['percents'] as int).toDouble(): map['percents']??0
    );
  }
  factory InfoTimviec365Model.blankData(){
    return InfoTimviec365Model(
      cityId: null,
      cityName: '',
      email: null,
      id: '',
      listJob: [],
      passMD5: '',
      userType: UserType.unAuth,
      name: '',
      phone: '',
      point: RxInt(0),
      token: ValueNotifier(''),
      percents: 0
    );
  }

  InfoTimviec365Model copyWith({
    String? id,
    String? email,
    String? passMD5,
    UserType? userType,
    int? cityId,
    String? cityName,
    List<Map<String, dynamic>>? listJob,
    final String? name,
    final String? phone,
  RxInt? point,
    double? percents,
    ValueNotifier<String>? token
  }) {
    return InfoTimviec365Model(
      id: id ?? this.id,
      email: email ?? this.email,
      passMD5: passMD5 ?? this.passMD5,
      userType: userType ?? this.userType,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      listJob: listJob ?? this.listJob,
      name: name??this.name,
      phone: phone??this.phone,
      point: point??this.point,
      token: token??this.token,
      percents: percents??this.percents??0
    );
  }

  @override
  List<Object> get props => [];
}
