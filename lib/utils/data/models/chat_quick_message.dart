import 'dart:io';

import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:equatable/equatable.dart';

class QuickMessageModel extends Equatable {
  String? Id;
  final int userId;
  final String title;
  final String message;
  File? image;
  final int? isImage;
  final ApiFileModel? infoImage;
  File? placeHolder;

  QuickMessageModel(
      {this.Id,
      required this.userId,
      required this.title,
      required this.message,
      this.image,
      this.isImage,
      this.infoImage,
      this.placeHolder});

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'message': message,
        'image': image,
        'isImage': isImage,
        'infoImage': infoImage
      };

  factory QuickMessageModel.fromMap(Map<String, dynamic> map) =>
      QuickMessageModel(
        infoImage: map['infoImage'] == null || map['infoImage'] == ''
            ? null
            : ApiFileModel.fromQuickMessage(map['infoImage']),
        Id: map['_id'],
        userId: map['userId'],
        title: map['title'],
        message: map['message'],
        image: File(map['image']),
      );

  @override
  List<Object?> get props => [Id];
}
