class PrivacyModel {
  late SearchSource searchSource;
  int? seenMessage;
  int? statusOnline;
  String? id;
  int? userId;
  int? active;
  int? showDateOfBirth;
  int? chat;
  int? call;
  String? post;
  late List<dynamic> blockMessage;
  late List<dynamic> blockPost;
  late List<dynamic> hidePost;

  PrivacyModel({
    required this.searchSource,
    this.seenMessage,
    this.statusOnline,
    this.id,
    this.userId,
    this.active,
    this.showDateOfBirth,
    this.chat,
    this.call,
    this.post,
    required this.blockMessage,
    required this.blockPost,
    required this.hidePost,
  });

  PrivacyModel.fromJson(Map<String, dynamic> json) {
    searchSource = SearchSource.fromMap(json['searchSource'] ?? {});
    seenMessage = json['seenMessage'];
    statusOnline = json['statusOnline'];
    id = json['_id'];
    userId = json['userId'];
    active = json['active'];
    showDateOfBirth = json['showDateOfBirth'];
    chat = json['chat'];
    call = json['call'];
    post = json['post'];
    blockMessage = json['blockMessage'] ?? [];
    blockPost = json['blockPost'] ?? [];
    hidePost = json['hidePost'] ?? [];
  }
}

class SearchSource {
  SearchSource({
    this.searchByPhone,
    this.qrCode,
    this.generalGroup,
    this.businessCard,
    this.suggest,
  });

  final int? searchByPhone;

  final int? qrCode;

  final int? generalGroup;

  final int? businessCard;

  final int? suggest;

  factory SearchSource.fromMap(Map<String, dynamic> map) => SearchSource(
        searchByPhone: map['searchByPhone'] ?? 1,
        qrCode: map['qrCode'] ?? 1,
        generalGroup: map['generalGroup'] ?? 1,
        businessCard: map['businessCard'] ?? 1,
        suggest: map['suggest'] ?? 1,
      );
}
