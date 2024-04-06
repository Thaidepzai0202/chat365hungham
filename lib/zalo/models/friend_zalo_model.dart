import 'dart:convert';

import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_chat365_pc/utils/data/enums/download_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'friend_zalo_model.g.dart';

@HiveType(typeId: HiveTypeId.friendHiveZalo)
class FriendZalo {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String ava;
  @HiveField(3)
  final int numLabel;
  @HiveField(4)
  final String nameLabel;

  FriendZalo(
      {required this.id,
      required this.name,
      required this.ava,
      required this.numLabel,
      required this.nameLabel});

  factory FriendZalo.fromJson(Map<String, dynamic> map) {
    return FriendZalo(
      name: map['name'] ?? '',
      ava: map['ava'] ?? '',
      numLabel: map['num_label'] ?? 0,
      nameLabel: map['name_label'] ?? '',
      id: map['id'] ?? '',
    );
  }
}
