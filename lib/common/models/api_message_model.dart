import 'dart:convert';

import 'package:app_chat365_pc/common/models/api_contact.dart';
import 'package:app_chat365_pc/common/models/auto_delete_message_time_model.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/generator_service.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/num_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'api_message_model.g.dart';

/// Model gửi message lên socket
class ApiMessageModel extends Equatable {
  final String messageId;
  final int conversationId;
  final int senderId;
  final MessageType type;
  final String? message;
  final int? emotion;
  final ApiReplyMessageModel? replyMessage;
  final List<ApiFileModel>? files;
  final IUserInfo? contact;
  final DateTime? createdAt;
  final InfoLink? infoLink;
  final InfoSupport? infoSupport;
  final LiveChat? liveChat;
  final AutoDeleteMessageTimeModel autoDeleteMessageTimeModel;
  final int? isSecretGroup;
  final int? deleteTime;
  final int? deleteType;

  ApiMessageModel({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    this.type = MessageType.text,
    this.message,
    this.emotion,
    this.replyMessage,
    this.files,
    this.contact,
    this.createdAt,
    this.infoLink,
    this.infoSupport,
    this.liveChat,
    this.isSecretGroup,
    this.deleteTime,
    this.deleteType,
    AutoDeleteMessageTimeModel? initAutoDeleteMessageTimeModel,
  }) : autoDeleteMessageTimeModel = initAutoDeleteMessageTimeModel ??
            AutoDeleteMessageTimeModel.defaultModel;

  ApiMessageModel copyWith({
    String? messageId,
    MessageType? type,
    String? message,
    int? emotion,
    ApiReplyMessageModel? replyMessage,
    List<ApiFileModel>? files,
    IUserInfo? contact,
    int? conversationId,
    int? isSecretGroup,
    int? deleteTime,
    int? deleteType,
  }) =>
      ApiMessageModel(
        messageId: messageId ?? GeneratorService.generateMessageId(senderId),
        conversationId: conversationId ?? this.conversationId,
        senderId: senderId,
        type: type ?? this.type,
        message: message ?? this.message,
        emotion: emotion,
        replyMessage: replyMessage ?? this.replyMessage,
        files: files ?? this.files,
        contact: contact ?? this.contact,
        createdAt: createdAt,
        infoLink: infoLink,
        initAutoDeleteMessageTimeModel: autoDeleteMessageTimeModel,
        infoSupport: infoSupport,
        liveChat: liveChat,
        isSecretGroup: this.isSecretGroup,
        deleteTime: deleteTime,
        deleteType: deleteType,
      );

  List<ApiMessageModel> copyWithSeperatedFiles() => (files ?? [])
      .map(
        (e) => ApiMessageModel(
          messageId: messageId,
          conversationId: conversationId,
          senderId: senderId,
          files: [e],
          type: type,
          initAutoDeleteMessageTimeModel: autoDeleteMessageTimeModel,
        ),
      )
      .toList();

  ApiMessageModel copyWithNewMessage({
    required MessageType type,
    String? message,
    int? emotion,
    ApiReplyMessageModel? replyMessage,
    List<ApiFileModel>? files,
    ApiContact? contact,
  }) =>
      ApiMessageModel(
        messageId: GeneratorService.generateMessageId(senderId),
        conversationId: conversationId,
        senderId: senderId,
        type: type,
        message: message,
        emotion: emotion,
        replyMessage: replyMessage,
        files: files,
        contact: contact,
        initAutoDeleteMessageTimeModel: autoDeleteMessageTimeModel,
      );

  Map<String, dynamic> toMapOfDeleteMessage() => {
        'MessageID': messageId,
        'ConversationID': conversationId.toString(),
        'SenderID': senderId.toString(),
        'MessageType': null,
        'Message': null,
        'Emotion': null,
        'Quote': null,
        'File': null,
        'Profile': null,
      };

  Map<String, dynamic> toMapOfEditedMessage() => {
        'ConversationID': conversationId,
        'MessageID': messageId,
        'Message': message,
      };

  SocketSentMessageModel toServerMessageModel() => SocketSentMessageModel(
        conversationId: conversationId,
        messageId: messageId,
        senderId: senderId,
        type: type,
        message: message,
        // emotion: emotion,
        relyMessage: replyMessage,
        createAt: DateTime.now().toLocal(),
        infoLink: null,
        autoDeleteMessageTimeModel: autoDeleteMessageTimeModel,
        isCheck: false,
      );

  @override
  List<Object?> get props => [messageId];

  Map<String, dynamic> toMap() => {
        'MessageID': messageId,
        'ConversationID': conversationId.toString(),
        'SenderID': senderId.toString(),
        'MessageType': type.name,
        'Message': contact != null ? contact!.id : message,
        'Emotion': (emotion ?? 0).toString(),
        // 'Quote': replyMessage?.toMap().toString(),
        'Quote': replyMessage?.toJsonString(),
        'File': files == null
            ? ''
            : files!.map((e) => e.toJsonString()).toList().toString(),
        'Profile': contact == null ? null : contact!.toJsonString(),
        'InfoSupport': infoSupport?.toMap() == null
            ? ''
            : json.encode(infoSupport?.toMap()),
        'LiveChat':
            liveChat?.toMap() == null ? '' : json.encode(liveChat?.toMap()),
        'MessageInforSupport': infoSupport?.message ?? '',
        'isSecret': (isSecretGroup ?? 0).toString(),
        'DeleteTime': (deleteTime ?? 0),
        'DeleteType': (deleteType ?? 0),
      }..addAll(autoDeleteMessageTimeModel.toMapOfSocket());

// factory ApiMessageModel.fromMap(Map<String, dynamic> map) {
//   return ApiMessageModel(
//     messageId: map['messageId'] as String,
//     conversationId: map['conversationId'] as int,
//     senderId: map['senderId'] as int,
//     type: map['type'] as MessageType,
//     message: map['message'] as String,
//     emotion: map['emotion'] as int,
//     replyMessage: map['replyMessage'] as ApiReplyMessageModel,
//     files: map['files'] as List<ApiFileModel>,
//     contact: map['contact'] as IUserInfo,
//     createdAt: map['createdAt'] as DateTime,
//     infoLink: map['infoLink'] as InfoLink,
//     infoSupport: map['infoSupport'] ==null?null: InfoSupport.fromMap(map['InfoSupport']),
//     liveChat: map['LiveChat']==null?null:LiveChat.fromMap(map['LiveChat']),
//     isSecretGroup: int.parse(map['isSecretGroup']??'0'),
//   );
// }
}

@HiveType(typeId: HiveTypeId.apiFileModelHiveTypeId)
class ApiFileModel extends Equatable {
  @HiveField(0)

  /// "" nếu không có
  final String fileName;
  @HiveField(1)

  /// "" nếu không có
  final String resolvedFileName;
  @HiveField(2)

  /// `MessageType.unknown` nếu null
  final MessageType fileType;
  @HiveField(3)

  /// TL 19/12/2023 note: Kích cỡ theo Byte.
  ///
  /// Dùng NumExt.fizeSizeString() để dịch thành B KB MB cho tiện.
  ///
  /// = `-1` nếu rỗng
  final int fileSize;
  @HiveField(4)
  final String displayFileSize;
  @HiveField(5)
  final String? imageSource;
  @HiveField(6)

  /// -1 nếu rỗng
  final num width;
  @HiveField(7)

  /// -1 nếu rỗng
  final num height;

  /// Check file đã upload trên server chưa,
  /// - trường hợp chuyển tiếp file, giá trị [true]
  /// - chọn file từ local, giá trị bằng [false]
  @HiveField(8)
  final bool uploaded;

  @HiveField(9)
  final String? filePath;

  String get originFileName => resolvedFileName.originFileNameFromServerUri;

  const ApiFileModel._({
    required this.fileName,
    required this.resolvedFileName,
    required this.fileType,
    required this.fileSize,
    required this.displayFileSize,
    this.imageSource,
    this.width = 0,
    this.height = 0,
    this.filePath,
    this.uploaded = false,
  });

  factory ApiFileModel({
    required String fileName,
    String? resolvedFileName,
    required MessageType fileType,
    required int fileSize,
    String? displayFileSize,
    String? imageSource,
    num width = 0,
    num height = 0,
    String? filePath,
    bool uploaded = false,
  }) {
    var fName = fileName.replaceAll(RegExp(r'^(\d+-)+'), '');
    var resolvFileName =
        resolvedFileName ?? GeneratorService.generateFileName(fileName);
    var displayFsize = displayFileSize ?? fileSize.fizeSizeString();
    return ApiFileModel._(
      fileName: fName,
      fileType: fileType,
      fileSize: fileSize,
      resolvedFileName: resolvFileName,
      displayFileSize: displayFsize,
      imageSource: imageSource,
      width: width,
      height: height,
      filePath: filePath,
      uploaded: uploaded,
    );
  }

  String get fullFilePath {
    if (fileType.isImage) {
      return ApiPath.imageDomain + resolvedFileName;
    }
    if (fileType.isFile) {
      //bỏ toàn bộ khoảng trắng ở trong chuỗi resolvedFileName
      return ApiPath.fileDomain +
          resolvedFileName.replaceAll(RegExp('[ +!@#%^&*]'), '');
    }
    logger.logError('Unimplement fullFilePath $fileType');
    return '';
  }

  String get downloadPath => ApiPath.downloadDomain + resolvedFileName;

  bool get isVideo {
    String ext = fileName.split('.').last.toLowerCase();
    return AppConst.supportVideoTypes.contains(ext);
  }

  // ApiFileModel copyWith({
  //   String fileName,
  //   int fileSize,
  // }) =>
  //     ApiFileModel(
  //       conversationId: conversationId,
  //       senderId: senderId,
  //       type: type,
  //       message: message,
  //       emotion: emotion,
  //       replyMessage: replyMessage,
  //       fileName: fileName,
  //       fileSize: fileSize,
  //     );

  factory ApiFileModel.fromJsonCopy(Map<String, dynamic> json) {
    return ApiFileModel(
      resolvedFileName: json['resolvedFileName'],
      fileName: json['fileName'],
      fileType: MessageType.image,
      fileSize: json['fileSize'],
      imageSource: json['imageSource'],
      displayFileSize: json['displayFileSize'],
      width: json['width'],
      height: json['height'],
      uploaded: true,
      filePath: json['filePath'],
    );
  }
  factory ApiFileModel.fromMapOfSocket(Map<String, dynamic> json,
      {bool uploaded = false}) {
    return ApiFileModel(
      fileName: json['FullName'],
      resolvedFileName: json['FullName'].replaceAll(RegExp('[ +!@#%^&*]'), ''),
      fileType: MessageTypeExt.valueOf(json['TypeFile']),
      displayFileSize: json['FileSizeInByte'],
      fileSize: json['SizeFile'],
      imageSource: json['ImageSource'],
      width: json['Width'] is int
          ? int.parse(json['Width'].toString())
          : json['Width'],
      height: json['Height'] is int
          ? int.parse(json['Height'].toString())
          : json['Height'],
      filePath: json['FilePath'],
      uploaded: uploaded,
    );
  }

  factory ApiFileModel.fromQuickMessage(
    Map<String, dynamic> map,
  ) =>
      ApiFileModel(
          fileName: map['FullName'],
          fileType: MessageType.image,
          fileSize: map['SizeFile'],
          width: map['Width'],
          height: map['Height'],
          displayFileSize: map['FileSizeInByte'],
          filePath: map['pathImage']);

  Map<String, dynamic> toJsonCopy() {
    return {
      'resolvedFileName': resolvedFileName,
      'fileName': fileName,
      'fileSize': fileSize,
      'imageSource': imageSource,
      'displayFileSize': displayFileSize,
      'width': width,
      'height': height,
      'filePath': filePath,
    };
  }

  /// TL 13/1/2024: Cái này sẽ dùng cho lưu json local
  Map<String, dynamic> toMap() => {
        'FullName': resolvedFileName.replaceAll(RegExp('[ +!@#%^&*]'), ''),
        'NameDisplay': fileName,
        'TypeFile': fileType.databaseName,
        'SizeFile': fileSize,
        'ImageSource': imageSource,
        'FileSizeInByte': displayFileSize,
        'Width': width,
        'Height': height,
        "uploaded": uploaded,
      };

  /// TL 13/1/2024: Cái này sẽ dùng cho lưu json local
  /// Dùng để parse một cái ApiFileModel.toMap()
  factory ApiFileModel.fromMap(Map<String, dynamic> json) {
    return ApiFileModel._(
      fileName: json["NameDisplay"] ?? "",
      resolvedFileName: json["FullName"] ?? "",
      fileType:
          MessageTypeExt.valueOf(json["TypeFile"] ?? MessageType.unknown.name),
      fileSize: json["SizeFile"] ?? -1,
      displayFileSize: json["FileSizeInByte"] ?? "",
      imageSource: json["ImageSource"],
      width: json["Width"] ?? -1,
      height: json["Height"] ?? -1,
      uploaded: json["uploaded"] ?? false,
    );
  }

  String toJsonString() =>
      '''{"FullName":"$resolvedFileName","NameDisplay":"$fileName","TypeFile":"${fileType.databaseName}","SizeFile":$fileSize,"ImageSource":$imageSource,"FileSizeInByte":"${fileSize.fizeSizeString()}","Width":$width,"Height":$height,"isDownnLoad":"False","FilePath":"$filePath"}''';

  @override
  List<Object?> get props => [resolvedFileName];
}

@HiveType(typeId: HiveTypeId.apiReplyMessageModelHiveTypeId)
class ApiReplyMessageModel {
  @HiveField(0)
  final String messageId;
  @HiveField(1)
  final int senderId;
  @HiveField(2)
  final String? senderName;
  @HiveField(3)
  final MessageType? type;
  @HiveField(4)
  final String? message;
  @HiveField(5)
  final DateTime createAt;

  ApiReplyMessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    this.type,
    this.message,
    required this.createAt,
  });

  factory ApiReplyMessageModel.fromMap(Map<String, dynamic> map) {
    MessageType _type = MessageTypeExt.valueOf(
        map['messageType'] ?? map['MessageType'] ?? 'text');
    String msg = _type.isImage
        ? 'Ảnh'
        : _type.isCV
            ? 'CV'
            : map['message'] ?? map['Message'] ?? '';

    return ApiReplyMessageModel(
      messageId: map['MessageID'] ?? "",
      senderId: map['senderID'] ?? int.tryParse(map['SenderID'] ?? "") ?? -1,
      senderName: map['senderName'] ?? map['SenderName'] ?? "",
      type: _type,
      message: msg,
      createAt: DateTime.parse(map['createAt'] ?? map['CreateAt']),
    );
  }

  factory ApiReplyMessageModel.fromMapOfSocket(Map<String, dynamic> map) {
    MessageType _type = MessageTypeExt.valueOf(map['MessageType'] ?? 'text');
    String msg = _type.isImage
        ? 'Ảnh'
        : _type.isCV
            ? 'CV'
            : map['message'] ?? map['Message'] ?? '';
    return ApiReplyMessageModel(
      messageId: map['MessageID'],
      senderId: map['senderID'] ?? map['SenderID'],
      senderName: map['senderName'] ?? map['SenderName'],
      type: _type,
      message: msg,
      createAt:
          DateTime.parse((map['CreateAt'].toString()).toUpperCase()).toLocal(),
    );
  }

  Map<String, dynamic> toMap() => {
        'MessageID': messageId,
        'SenderID': senderId.toString(),
        'SenderName': senderName,
        'MessageType': type!.databaseName,
        'Message': message,
        'CreateAt': createAt.toIso8601String(),
      };

  String toJsonString() =>
      '''{"MessageID": "$messageId","SenderID": "${senderId.toString()}","SenderName": "$senderName","MessageType": "${(type ?? MessageType.text).databaseName}","Message": ${json.encode(message)},"CreateAt": "${createAt.toIso8601String()}"}''';
}
