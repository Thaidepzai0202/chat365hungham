import 'package:app_chat365_pc/core/error_handling/exceptions.dart';

enum ChatFileType { image, file , CV,video}

extension ChatFileTypeExt on ChatFileType {
  String get name {
    switch (this) {
      case ChatFileType.CV:
        return 'sendCV';
      case ChatFileType.image:
        return 'sendPhoto';
      case ChatFileType.video:
        return 'sendVideo';
      case ChatFileType.file:
        return 'sendFile';
    }
  }

  bool get isFile => this == ChatFileType.image || this == ChatFileType.file;

  bool get isImage => this == ChatFileType.image;

  bool get isCV => this== ChatFileType.CV;

  bool get isVideo => this == ChatFileType.video;

  static ChatFileType valueOf(String name) {
    try {
      return ChatFileType.values.firstWhere((e) => e.name == name);
    } catch (e) {
      throw DataNotFoundException(
          "ChatFileType.name == $name", 'ChatFileType.valueOf');
    }
  }
}
