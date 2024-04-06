import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:hive/hive.dart';
part 'conversation_item_model.g.dart';

@HiveType(typeId: HiveTypeId.conversationItemHiveZalo)
class ConversationItemZaloModel{
  @HiveField(0)
  String name;
  @HiveField(1)
  String ava;
  @HiveField(2)
  bool checkPined;
  @HiveField(3)
  bool unread;
  @HiveField(4)
  String lastMess;
  @HiveField(5)
  String timeMess;
  @HiveField(6)
  dynamic numUnread;
  @HiveField(7)
  int tagLabel;

  ConversationItemZaloModel({
    required this.name,
    required this.ava,
    required this.checkPined,
    required this.unread,
    required this.lastMess,
    required this.timeMess,
    required this.numUnread,
    required this.tagLabel
  });

  factory ConversationItemZaloModel.fromJson(Map<String, dynamic> map) {
    return ConversationItemZaloModel(
      name: map['name'] ?? '',
      ava: map['ava'] ?? '',
      checkPined: map['check_pined'] ?? false,
      unread: map['unread'] ?? true,
      lastMess: map['last_mess'] ?? '',
      timeMess: map['time_mess'] ?? '',
      numUnread: map['num_unread'] ?? [],
      tagLabel: map['tag_label'] ?? -1,      
    );
  }
}
