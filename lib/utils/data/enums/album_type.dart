import 'package:equatable/equatable.dart';

enum AlbumType {
  recent,
  pictures,
  sharedFolder,
  unknown,
}

extension AlbumTypeExt on AlbumType{
  String get name {
    switch (this) {
      case AlbumType.recent:
        return "Gần đây";
      case AlbumType.pictures:
        return "Ảnh";
      case AlbumType.sharedFolder:
        return "Được chia sẻ";
      default:
        return "Khác";
    }
  }
}

class AssetAlbum extends Equatable {
  final String id;
  final AlbumType type;

  const AssetAlbum({
    required this.id,
    required this.type,
  });

  @override
  List<Object> get props => [id, type];
}