class IconModel {
  final int id;
  final String icon;
  final List<String> stickerList;
  final int show;

  IconModel({
    required this.id,
    required this.icon,
    required this.stickerList,
    required this.show,
  });
  factory IconModel.fromJson(Map<String, dynamic> json) => IconModel(
    id: json["id"]??0,
    icon: json["icon"]??'',
    stickerList: json["stickerList"] == [] || json["stickerList"] == null ? [] : List<String>.from(json["stickerList"].map((x) => x)),
    show: json["show"]??0,
  );

}
