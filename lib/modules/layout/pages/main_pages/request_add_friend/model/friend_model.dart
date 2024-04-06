import 'package:app_chat365_pc/utils/data/enums/friend_status.dart';
import 'package:equatable/equatable.dart';

class FriendModel extends Equatable {
  final int userId;
  final int contactId;
  final FriendStatus status;
  final int? type365;

  FriendModel({
    required this.userId,
    required this.contactId,
    required this.status,
    this.type365,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
    userId: json['userId'],
    contactId: json['contactId'],
    status: FriendStatusExt.fromValue(json['status']),
    type365: json['type365'],
  );

  FriendModel changeStatus(FriendStatus newStatus) => FriendModel(
    userId: userId,
    contactId: contactId,
    status: newStatus,
    type365: type365,
  );

  @override
  List<Object?> get props => [
    contactId,
    status,
  ];
}
