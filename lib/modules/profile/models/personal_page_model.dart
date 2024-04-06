class ModelPersonalPage {
  final String id;
  final int userId;
  final String userName;
  final String avatarUser;
  final DateTime? createAt;
  final String contentPost;
  final List<Imagee> imageList;
  final List<Video> videoList;
  final String emotionName;
  final String emotionAvatar;
  String listTag;
  final String? link;
  String raw;
  List<dynamic> tagName;
  List<dynamic> tagAvatar;
  final List<String> imageListId;
  final List<String> videoListId;
  List<Commentt> commenttList;
  final List<BackGroundPersonal> backGround;
  final String? emotion;
  late final int? totalEmotion;
  final int? totalComment;
  String? albumName;
  final String? contentAlbum;
  final int? totalImage;
  final int? totalVideo;
  final String? IdAlbum;
  ModelPersonalPage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.avatarUser,
    this.createAt,
    required this.contentPost,
    this.imageList = const [],
    this.videoList = const [],
    required this.emotionName,
    required this.emotionAvatar,
    required this.listTag,
    required this.raw,
    this.imageListId = const [],
    this.videoListId = const [],
    this.link,
    this.backGround = const [],
    this.tagName = const [],
    this.tagAvatar = const [],
    this.commenttList = const [],
    this.emotion,
    this.totalEmotion,
    this.totalComment,
    this.albumName,
    this.contentAlbum,
    this.totalImage,
    this.totalVideo,
    this.IdAlbum,
  });
  factory ModelPersonalPage.fromJson(Map<String, dynamic> json) {
    return ModelPersonalPage(
      id: json['_id'],
      userId: json['userId'],
      userName: json['userName']??'',
      avatarUser: json['avatarUser']??'',
      createAt: DateTime.tryParse(json['createAt']),
      contentPost: json['contentPost'] ?? '',
      imageList:
          json['imageList'].map<Imagee>((e) => Imagee.fromJson(e)).toList(),
      videoList:
          json['videoList'].map<Video>((e) => Video.fromJson(e)).toList(),
      emotionName: json['emotionName'] ?? '',
      emotionAvatar: json['emotionAvatar'] ?? '',
      listTag: json['listTag'] ?? '',
      tagName: json['tagName'],
      tagAvatar: json['tagAvatar'],
      // imageListId: json['imageListId'],
      // videoListId: json['videoListId'],
      link: json['link'] ?? '',
      commenttList: json['commentList']
          .map<Commentt>((e) => Commentt.fromJson(e))
          .toList(),
      emotion: json['emotion'] ?? '',
      raw: json['raw'],
      totalEmotion: json['totalEmotion'] ?? 0,
      totalComment: json['totalCommnet'] ?? 0,
      albumName: json['albumName'] ?? '',
      contentAlbum: json['contentAlbum'] ?? '',
      totalImage: json['totalImage'] ?? 0,
      totalVideo: json['totalVideo'] ?? 0,
      backGround: json['backgroundImage']
          .map<BackGroundPersonal>((e) => BackGroundPersonal.fromJson(e))
          .toList(),
      IdAlbum: json['IdAlbum'] ?? '',
    );
  }
}

class TagFriendPersonal {
  final String tagId;
  final String tagName;
  final dynamic tagAvatar;
  TagFriendPersonal({
    required this.tagId,
    required this.tagName,
    required this.tagAvatar,
  });
}

class Imagee {
  final String pathFile;
  final int sizeFile;
  String imageEmotion;
  String imageLikeName;
  String imageLikeAvatar;
  int totalComment;
  final String id;
  final String postId;
  final String contentPost;
  Imagee({
    required this.id,
    required this.imageEmotion,
    required this.imageLikeAvatar,
    required this.imageLikeName,
    required this.pathFile,
    required this.sizeFile,
    required this.totalComment,
    required this.postId,
    required this.contentPost,
  });

  factory Imagee.fromJson(Map<String, dynamic> json) {
    return Imagee(
      id: json['_id'] ?? '',
      imageEmotion: json['imageEmotion'] ?? '',
      imageLikeAvatar: json['imageLikeAvatar'] ?? '',
      imageLikeName: json['imageLikeName'] ?? '',
      pathFile: json['pathFile'] ?? '',
      sizeFile: json['sizeFile'] ?? 0,
      totalComment: json['totalComment'] ?? 0,
      postId: json['postId'] ?? '',
      contentPost: json['contentPost'] ?? '',
    );
  }
}

class Video {
  final String pathFile;
  final int sizeFile;
  final String thumbnailName;
  String videoEmotion;
  String videoLikeName;
  String videoLikeAvatar;
  final String id;
  int totalComment;
  final String postId;
  final String contentPost;
  Video({
    required this.id,
    required this.pathFile,
    required this.sizeFile,
    required this.thumbnailName,
    required this.videoEmotion,
    required this.videoLikeAvatar,
    required this.videoLikeName,
    required this.totalComment,
    required this.postId,
    required this.contentPost,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['_id'] ?? '',
      pathFile: json['pathFile'] ?? '',
      sizeFile: json['sizeFile'] ?? 0,
      thumbnailName: json['thumbnailName'] ?? '',
      videoEmotion: json['videoEmotion'] ?? '',
      videoLikeAvatar: json['videoLikeAvatar'] ?? '',
      videoLikeName: json['videoLikeName'] ?? '',
      totalComment: json['totalComment'] ?? 0,
      postId: json['postId'] ?? '',
      contentPost: json['contentPost'] ?? '',
    );
  }
}

class Commentt {
  String content;
  int commentatorId;
  DateTime? createAt;
  String commentName;
  String commentAvatar;
  String commentEmotion;
  String commentLikeAvatar;
  String commentLikeName;
  String? image;
  String id;
  Commentt({
    required this.commentAvatar,
    required this.commentEmotion,
    required this.commentLikeAvatar,
    required this.commentLikeName,
    required this.commentName,
    required this.commentatorId,
    required this.content,
    this.createAt,
    required this.id,
    this.image,
  });

  factory Commentt.fromJson(Map<String, dynamic> json) {
    return Commentt(
      commentAvatar: json['commentAvatar'] ?? '',
      commentEmotion: json['commentEmotion'] ?? '',
      commentLikeAvatar: json['commentLikeAvatar'] ?? '',
      commentLikeName: json['commentLikeName'] ?? '',
      commentName: json['commentName'] ?? '',
      commentatorId: json['commentatorId'] ?? 0,
      content: json['content'] ?? '',
      createAt: DateTime.tryParse(json['createAt']),
      id: json['_id'] ?? '',
      image: (json['image'] != null) ? json['image'] : '',
    );
  }
}

class ModelCountFile {
  final int totalImage;
  final int totalVideo;
  final String linkbackgroundImg;
  String description;
  ModelCountFile({
    required this.totalImage,
    required this.totalVideo,
    required this.linkbackgroundImg,
    required this.description,
  });

  factory ModelCountFile.fromJson(Map<String, dynamic> json) {
    return ModelCountFile(
      totalImage: json['totalImage'] ?? 0,
      totalVideo: json['totalVideo'] ?? 0,
      linkbackgroundImg: json['linkbackgroundImg'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class ModelAllIdPersonal {
  final String id;
  final List<String> imageListId;
  final List<String> videoListId;
  ModelAllIdPersonal({
    required this.id,
    this.imageListId = const [],
    this.videoListId = const [],
  });
//json['videoList'].map<Video>((e) => Video.fromJson(e)).toList(),
  factory ModelAllIdPersonal.fromJson(Map<String, dynamic> json) {
    return ModelAllIdPersonal(
      id: json['_id'] ?? '',
      imageListId: json['imageListId'],
      videoListId: json['videoListId'],
    );
  }
}

class ModelImageOfDay {
  final String createAt;
  final List<ImageeInfo> imageInfo;
  ModelImageOfDay({
    required this.createAt,
    this.imageInfo = const [],
  });

  factory ModelImageOfDay.from(Map<String, dynamic> json) {
    return ModelImageOfDay(
      createAt: json['createAt'],
      imageInfo: json['imageInfo']
          .map<ImageeInfo>((e) => ImageeInfo.fromJson(e))
          .toList(),
    );
  }
}

class ImageeInfo {
  final String idImage;
  final String idVideo;
  final String postId;
  final String pathFile;
  final String contentPost;
  final String thumbnailName;
  int totalCommentImage;
  int totalEmotionImage;
  int totalCommentVideo;
  int totalEmotionVideo;
  String imageEmotion;
  List<EmotionImagee> emotion;
  ImageeInfo({
    required this.idImage,
    required this.idVideo,
    required this.postId,
    required this.pathFile,
    required this.contentPost,
    required this.totalCommentImage,
    required this.totalEmotionImage,
    required this.imageEmotion,
    required this.thumbnailName,
    required this.totalCommentVideo,
    required this.totalEmotionVideo,
    this.emotion = const [],
  });

  factory ImageeInfo.fromJson(Map<String, dynamic> json) {
    return ImageeInfo(
        idVideo: json['idVideo'] ?? '',
        idImage: json['idImage'] ?? '',
        postId: json['postId'] ?? '',
        pathFile: json['pathFile'] ?? '',
        contentPost: json['contentPost'] ?? '',
        totalCommentImage: json['totalCommentImage'] ?? 0,
        totalEmotionImage: json['totalEmotionImage'] ?? 0,
        imageEmotion: json['imageEmotion'] ?? '',
        thumbnailName: json['thumbnailName'] ?? '',
        emotion: json['emotion']
            .map<EmotionImagee>((e) => EmotionImagee.fromJson(e))
            .toList(),
        totalCommentVideo: json['totalCommentVideo'] ?? 0,
        totalEmotionVideo: json['totalEmotionVideo'] ?? 0);
  }
}

class EmotionImagee {
  final int id;
  final String userName;
  final String avatarUser;
  EmotionImagee({
    required this.id,
    required this.avatarUser,
    required this.userName,
  });

  factory EmotionImagee.fromJson(Map<String, dynamic> json) {
    return EmotionImagee(
      id: json['_id'] ?? 0,
      avatarUser: json['avatarUser'] ?? '',
      userName: json['userName'] ?? '',
    );
  }
}

class BackGroundPersonal {
  final String id;
  final String pathFile;
  final int sizeFile;
  BackGroundPersonal({
    required this.id,
    required this.pathFile,
    required this.sizeFile,
  });

  factory BackGroundPersonal.fromJson(Map<String, dynamic> json) {
    return BackGroundPersonal(
      id: json['_id'] ?? '',
      pathFile: json['pathFile'] ?? '',
      sizeFile: json['sizeFile'] ?? 0,
    );
  }
}
