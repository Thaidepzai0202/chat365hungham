class ListMemberApproval {
  final List<MemberApproval> add;
  final List<MemberApproval> delete;
  ListMemberApproval({
    required this.add,
    required this.delete,
  });
  factory ListMemberApproval.fromJson(Map<String, dynamic> json) {
    return ListMemberApproval(
      add: List<MemberApproval>.from(
          (json['add'] as List).map((e) => MemberApproval.fromJson(e))),
      delete: List<MemberApproval>.from(
          (json['delete'] as List).map((e) => MemberApproval.fromJson(e))),
    );
  }
}

class MemberApproval {
  final int conversationId;
  final int userId;
  final dynamic avatarUser;
  final String userName;
  final String userNameSuggest;
  late String request;
  String? reasonForDelete;
  MemberApproval({
    required this.conversationId,
    required this.userId,
    required this.avatarUser,
    required this.userName,
    required this.userNameSuggest,
    required this.request,
    this.reasonForDelete,
  });

  factory MemberApproval.fromJson(Map<String, dynamic> json) {
    return MemberApproval(
      conversationId: json['_id'],
      userId: json['userId'],
      avatarUser: json['avatarUser'],
      userName: json['userName'],
      userNameSuggest: json['userNameSuggest'],
      request: json['request'],
      reasonForDelete: json['reasonForDelete'],
    );
  }
}
