import 'package:app_chat365_pc/modules/profile/models/profile_models.dart';

class AlbumModelDiary {
  final String id;
  final String nameAlbum;
  final int userSender;
  final String avatarUserSender;
  final String userNameSender;
  final int conversationId;
  final DateTime? createAt;
  final String type;
  final List<ListTag> listTag;
  final String content;
  final String? link;
  final List<FileList> fileList;
  final String raw;
  final String emotion;
  final List<CommentList> commentList;
  final int totalEmotion;
  final List<ListUserEmotion> listUserEmotion;

  AlbumModelDiary({
    required String id,
    required this.nameAlbum,
    required this.userNameSender,
    required this.avatarUserSender,
    this.commentList = const [],
    required this.content,
    required this.conversationId,
    this.createAt,
    required this.emotion,
    this.link,
    this.listTag = const [],
    required this.raw,
    required this.totalEmotion,
    required this.type,
    required this.userSender,
    this.fileList = const [],
    this.listUserEmotion = const [],
  }) : this.id = id;

  factory AlbumModelDiary.fromJson(Map<String, dynamic> json) {
    return AlbumModelDiary(
      id: json['_id'],
      nameAlbum: json['nameAlbum'],
      userNameSender: json['userNameSender'],
      avatarUserSender: json['avatarUserSender'],
      commentList: json['commentList']
          .map<CommentList>((e) => CommentList.fromJson(e))
          .toList(),
      content: json['content'],
      conversationId: json['conversationId'],
      createAt: DateTime.tryParse(json['createAt']),
      emotion: json['emotion'],
      link: json['link'],
      listTag:
          json['listTag'].map<ListTag>((e) => ListTag.fromJson(e)).toList(),
      raw: json['raw'],
      totalEmotion: json['totalEmotion'],
      type: json['type'],
      userSender: json['userSender'],
      fileList:
          json['fileList'].map<FileList>((e) => FileList.fromJson(e)).toList(),
      listUserEmotion: json['listUserEmotion']
          .map<ListUserEmotion>((e) => ListUserEmotion.fromJson(e))
          .toList(),
    );
  }
}
