import 'package:intl/intl.dart';

class ProfileModelDiary {
  final String id;
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
  final String? emotion;
  List<CommentList> commentList;
  final int? totalEmotion;
  final List<ListUserEmotion>? listUserEmotion;
  final String? display_createAt;
  final String? titleLink;
  final String? display_raw;
  final String? nameAlbum;
  final int captionDai;
  final int XemBL;
  final String? textComment;

  ProfileModelDiary({
    required this.id,
    required this.userNameSender,
    required this.avatarUserSender,
    this.commentList = const [],
    required this.content,
    required this.conversationId,
    this.createAt,
    this.emotion,
    this.link,
    this.listTag = const [],
    required this.raw,
    this.totalEmotion,
    required this.type,
    required this.userSender,
    this.fileList = const [],
    this.listUserEmotion = const [],
    this.display_createAt,
    this.titleLink,
    this.display_raw,
    required this.captionDai,
    required this.XemBL,
    this.textComment,
    this.nameAlbum,
  });

  factory ProfileModelDiary.fromJson(Map<String, dynamic> json) {
    return ProfileModelDiary(
      id: json['_id'],
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
      listUserEmotion: (json['listUserEmotion'] != null)
          ? json['listUserEmotion']
              .map<ListUserEmotion>((e) => ListUserEmotion.fromJson(e))
              .toList()
          : null,
      display_createAt: null,
      display_raw: null,
      titleLink: null,
      captionDai: 0,
      XemBL: 0,
      nameAlbum: null,
      textComment: null,
    );
  }

  Map<String, dynamic> toMap() => {
        '_id': id,
        'userSender': userSender,
        'userNameSender': userNameSender,
        'fileList': fileList.map((e) => e.toMap()).toList(),
        'emotion': emotion,
        'listUserEmotion': listUserEmotion?.map((e) => e.toMap()).toList(),
        'commentList': commentList.map((e) => e.toMap()).toList(),
        'totalEmotion': totalEmotion,
        'avatarUserSender': avatarUserSender,
        'conversationId': conversationId,
        'createAt': createAt?.toIso8601String().replaceFirst(' ', 'T') ??
            null.toString(),
        'display_createAt':
            '${DateFormat('dd').format(createAt!)} tháng ${DateFormat('MM').format(createAt!)} năm ${DateFormat('yyyy').format(createAt!)} ${DateFormat('HH:mm:ss').format(createAt!)}',
        'content': content,
        'type': type,
        'link': link,
        'titleLink': titleLink,
        'raw': raw,
        'display_raw': raw,
        'nameAlbum': nameAlbum,
        'listTag': listTag.map((e) => e.toMap()).toList(),
        'captionDai': captionDai,
        'XemBL': XemBL,
        'textComment': textComment,
      };
}

class FileList {
  final String id;
  final String pathFile;
  final int sizeFile;
  FileList({
    required this.id,
    required this.pathFile,
    required this.sizeFile,
  });

  factory FileList.fromJson(Map<String, dynamic> json) {
    return FileList(
        id: json['_id'],
        pathFile: json['pathFile'],
        sizeFile: json['sizeFile']);
  }

  Map<String, dynamic> toMap() => {
        '_id': id,
        'pathFile': pathFile,
        'sizeFile': sizeFile,
      };
}

class ListUserEmotion {
  final int id;
  final String userName;
  final String avatarUser;
  ListUserEmotion(
      {required this.id, required this.avatarUser, required this.userName});

  factory ListUserEmotion.fromJson(Map<String, dynamic> json) {
    return ListUserEmotion(
        id: json['_id'],
        avatarUser: json['avatarUser'],
        userName: json['userName']);
  }
  Map<String, dynamic> toMap() => {
        '_id': id,
        'avatarUser': avatarUser,
        'userName': userName,
      };
}

class ListTag {
  final int id;
  final String userName;
  final String avatarUser;
  ListTag({required this.id, required this.userName, required this.avatarUser});
  factory ListTag.fromJson(Map<String, dynamic> json) {
    return ListTag(
        id: json['_id'],
        userName: json['userName'],
        avatarUser: json['avatarUser']);
  }
  Map<String, dynamic> toMap() =>
      {'_id': id, 'userName': userName, 'avatarUser': avatarUser};
}

class CommentList {
  final String id;
  final String content;
  final int commentatorId;
  final DateTime? createAt;
  final String commentName;
  final String commentAvatar;
  final String commentEmotion;
  // final String commentLikeAvatar;
  // final String commentLikeName;
  CommentList({
    required this.id,
    required this.content,
    required this.commentAvatar,
    required this.commentEmotion,
    // required this.commentLikeAvatar,
    // required this.commentLikeName,
    required this.commentName,
    required this.commentatorId,
    this.createAt,
  });

  factory CommentList.fromJson(Map<String, dynamic> json) {
    return CommentList(
        id: json['_id'],
        content: json['content'],
        commentAvatar: json['commentAvatar'],
        commentEmotion: json['commentEmotion'],
        // commentLikeAvatar: json['commentLikeAvatar'],
        // commentLikeName: json['commentLikeName'],
        commentName: json['commentName'],
        commentatorId: json['commentatorId'],
        createAt: DateTime.tryParse(json['createAt']));
  }
  Map<String, dynamic> toMap() => {
        '_id': id,
        'content': content,
        'commentAvatar': commentAvatar,
        'commentEmotion': commentEmotion,
        // 'commentLikeAvatar': commentLikeAvatar,
        // 'commentLikeName': commentLikeName,
        'commentName': commentName,
        'commentatorId': commentatorId,
        'createAt': createAt?.toIso8601String().replaceFirst(' ', 'T') ??
            null.toString(),
      };
}
