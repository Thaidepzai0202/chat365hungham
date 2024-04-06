class ModelSticker {
    int id;
    String icon;
    List<String> stickerList;
    int show;

    ModelSticker({
        required this.id,
        required this.icon,
        required this.stickerList,
        required this.show,
    });

    factory ModelSticker.fromJson(Map<String, dynamic> json) => ModelSticker(
        id: json["id"] ?? 0,
        icon: json["icon"] ?? '',
        stickerList: List<String>.from(json["stickerList"].map((x) => x)) ??[],
        show: json["show"] ?? 1,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "icon": icon,
        "stickerList": List<dynamic>.from(stickerList.map((x) => x)),
        "show": show,
    };
}