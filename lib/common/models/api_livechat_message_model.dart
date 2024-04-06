import 'dart:convert';

import 'package:app_chat365_pc/common/models/api_contact.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/models/auto_delete_message_time_model.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/generator_service.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:equatable/equatable.dart';

//part 'api_livechat_message_model.g.dart';

/// Model live chat message
class ApiLivechatMessageModel extends Equatable {
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

  ApiLivechatMessageModel({
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
    AutoDeleteMessageTimeModel? initAutoDeleteMessageTimeModel,
  }) : autoDeleteMessageTimeModel = initAutoDeleteMessageTimeModel ??
            AutoDeleteMessageTimeModel.defaultModel;

  ApiLivechatMessageModel copyWith({
    String? messageId,
    MessageType? type,
    String? message,
    int? emotion,
    ApiReplyMessageModel? replyMessage,
    List<ApiFileModel>? files,
    IUserInfo? contact,
    int? conversationId,
  }) =>
      ApiLivechatMessageModel(
        messageId: messageId ?? GeneratorService.generateMessageId(senderId),
        conversationId: conversationId ?? this.conversationId,
        senderId: this.senderId,
        type: type ?? this.type,
        message: message,
        emotion: emotion,
        replyMessage: replyMessage ?? this.replyMessage,
        files: files ?? this.files,
        contact: contact ?? this.contact,
        createdAt: this.createdAt,
        infoLink: this.infoLink,
        initAutoDeleteMessageTimeModel: autoDeleteMessageTimeModel,
        infoSupport: this.infoSupport,
        liveChat: this.liveChat,
      );

  List<ApiLivechatMessageModel> copyWithSeperatedFiles() => (files ?? [])
      .map(
        (e) => ApiLivechatMessageModel(
          messageId: messageId,
          conversationId: conversationId,
          senderId: senderId,
          files: [e],
          type: type,
          initAutoDeleteMessageTimeModel: autoDeleteMessageTimeModel,
        ),
      )
      .toList();

  ApiLivechatMessageModel copyWithNewMessage({
    required MessageType type,
    String? message,
    int? emotion,
    ApiReplyMessageModel? replyMessage,
    List<ApiFileModel>? files,
    ApiContact? contact,
  }) =>
      ApiLivechatMessageModel(
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
      }..addAll(autoDeleteMessageTimeModel.toMapOfSocket());

  @override
  List<Object?> get props => [messageId];
}

/// TL 8/1/2024: 
/// VVVVVVVVVVVVVVV CODE TRÙNG VỚI BÊN api_message_model.dart VVVVVVVVVVVVVV 
 
// @HiveType(typeId: HiveTypeId.apiFileModelHiveTypeId)
// class ApiFileModel extends Equatable {
//   @HiveField(0)
//   final String _fileName;
//   @HiveField(1)
//   final String resolvedFileName;
//   @HiveField(2)
//   final MessageType fileType;
//   @HiveField(3)
//   final int fileSize;
//   @HiveField(4)
//   final String displayFileSize;
//   @HiveField(5)
//   final String? imageSource;
//   @HiveField(6)
//   final num width;
//   @HiveField(7)
//   final num height;

//   /// Check file đã upload trên server chưa,
//   /// - trường hợp chuyển tiếp file, giá trị [true]
//   /// - chọn file từ local, giá trị bằng [false]
//   @HiveField(8)
//   final bool uploaded;

//   @HiveField(9)
//   final String? filePath;

//   late final String originFileName;

//   ApiFileModel({
//     required String fileName,
//     String? resolvedFileName,
//     required this.fileType,
//     required this.fileSize,
//     String? displayFileSize,
//     this.imageSource,
//     this.width = 0,
//     this.height = 0,
//     this.filePath,
//     this.uploaded = false,
//   })  : _fileName = fileName.replaceAll(RegExp(r'^(\d+-)+'), ''),
//         resolvedFileName =
//             resolvedFileName ?? GeneratorService.generateFileName(fileName),
//         displayFileSize = displayFileSize ?? fileSize.fizeSizeString() {
//     originFileName = this.resolvedFileName.originFileNameFromServerUri;
//   }

//   String get fileName => _fileName;

//   String get fullFilePath {
//     if (fileType.isImage) {
//       return ApiPath.imageDomain + resolvedFileName;
//     }
//     if (fileType.isFile) {
//       //bỏ toàn bộ khoảng trắng ở trong chuỗi resolvedFileName
//       return ApiPath.fileDomain +
//           resolvedFileName.replaceAll(RegExp('[ +!@#%^&*]'), '');
//     }
//     logger.logError('Unimplement fullFilePath $fileType');
//     return '';
//   }

//   String get downloadPath => ApiPath.downloadDomain + resolvedFileName;

//   // ApiFileModel copyWith({
//   //   String fileName,
//   //   int fileSize,
//   // }) =>
//   //     ApiFileModel(
//   //       conversationId: conversationId,
//   //       senderId: senderId,
//   //       type: type,
//   //       message: message,
//   //       emotion: emotion,
//   //       replyMessage: replyMessage,
//   //       fileName: fileName,
//   //       fileSize: fileSize,
//   //     );

//   Map<String, dynamic> toMap() => {
//         'FullName': resolvedFileName.replaceAll(RegExp('[ +!@#%^&*]'), ''),
//         'NameDisplay': fileName,
//         'TypeFile': fileType.databaseName,
//         'SizeFile': fileSize,
//         'ImageSource': imageSource,
//         'FileSizeInByte': displayFileSize,
//         'Width': width,
//         'Height': height,
//       };

//   String toJsonString() =>
//       '''{"FullName":"$resolvedFileName","NameDisplay":"$fileName","TypeFile":"${fileType.databaseName}","SizeFile":$fileSize,"ImageSource":$imageSource,"FileSizeInByte":"${fileSize.fizeSizeString()}","Width":$width,"Height":$height,"isDownnLoad":"False"}''';

//   @override
//   List<Object?> get props => [resolvedFileName];
// }

// @HiveType(typeId: HiveTypeId.apiReplyMessageModelHiveTypeId)
// class ApiReplyMessageModel {
//   @HiveField(0)
//   final String messageId;
//   @HiveField(1)
//   final int senderId;
//   @HiveField(2)
//   final String? senderName;
//   @HiveField(3)
//   final MessageType? type;
//   @HiveField(4)
//   final String? message;
//   @HiveField(5)
//   final DateTime createAt;

//   ApiReplyMessageModel({
//     required this.messageId,
//     required this.senderId,
//     required this.senderName,
//     this.type,
//     this.message,
//     required this.createAt,
//   });

//   factory ApiReplyMessageModel.fromMap(Map<String, dynamic> map) =>
//       ApiReplyMessageModel(
//         messageId: map['messageID'],
//         senderId: map['senderID'],
//         senderName: map['senderName'],
//         type: MessageTypeExt.valueOf(map['messageType']),
//         message: map['message'],
//         createAt: DateTime.parse(map['createAt']).toLocal(),
//       );

//   factory ApiReplyMessageModel.fromMapOfSocket(Map<String, dynamic> map) =>
//       ApiReplyMessageModel(
//         messageId: map['MessageID'],
//         senderId: map['SenderID'],
//         senderName: map['senderName'],
//         type: MessageTypeExt.valueOf(map['MessageType']),
//         message: map['Message'],
//         createAt: DateTime.parse((map['CreateAt'].toString()).toUpperCase())
//             .toLocal(),
//       );

//   Map<String, dynamic> toMap() => {
//         'MessageID': messageId,
//         'SenderID': senderId.toString(),
//         'SenderName': senderName,
//         'MessageType': type!.databaseName,
//         'Message': message,
//         'CreateAt': createAt.toString(),
//       };

//   String toJsonString() =>
//       '''{"MessageID": "$messageId","SenderID": "${senderId.toString()}","SenderName": "$senderName","MessageType": "${(type ?? MessageType.text).databaseName}","Message": ${json.encode(message)},"CreateAt": "${createAt.toString()}"}''';
// }
