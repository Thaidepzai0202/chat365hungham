class StickerModel {
  late final int id;
  late final String icon;
  late final List stickerList;
  late final int show;
  StickerModel({
    required this.id,
    required this.icon,
    required this.stickerList,
    required this.show,
  });

  factory StickerModel.fromJson(Map<String, dynamic> json) {
    return StickerModel(
      id: json['id'] as int,
      icon: json['icon'] as String,
      stickerList: json['stickerList'] as List,
      show: json['show'] as int,
    );
  }
  @override
  String toString() {
    return 'id:$id,icon:$icon,stickerList:$stickerList,show: $show, ';
  }
}
