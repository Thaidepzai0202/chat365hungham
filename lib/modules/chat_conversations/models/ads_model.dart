/// Model để from-to Json cho API quảng cáo dễ hơn
import 'dart:convert';

AdsModel adsModelFromJson(String str) => AdsModel.fromJson(json.decode(str));

String adsModelToJson(AdsModel data) => json.encode(data.toJson());

class AdsModel {
  /// Name
  final String advertiser;

  /// Avatar URL
  final String avatar;
  final AdsModelMainAd main_ads;
  final List<AdsModelButton> buttons;

  factory AdsModel.fromJson(Map<String, dynamic> json) => AdsModel(
        advertiser: json["advertiser"] ?? "",
        avatar: json["avatar"] ?? "",
        main_ads: AdsModelMainAd.fromJson(json["main_ads"]),
        buttons: List.from(
          (json["buttons"] as List<dynamic>)
              .map((e) => AdsModelButton.fromJson(e)),
        ),
      );

  AdsModel(
      {required this.advertiser,
      required this.avatar,
      required this.main_ads,
      required this.buttons});

  Map<String, dynamic> toJson() => {
        "advertiser": advertiser,
        "avatar": avatar,
        "main_ads": main_ads,
        "buttons": buttons,
      };
}

class AdsModelMainAd {
  final String image;
  final String title;
  final String description;
  final String redirect;
  final List<AdsModelMainAdOption> options;

  AdsModelMainAd(
      {required this.image,
      required this.title,
      required this.description,
      required this.redirect,
      required this.options});

  factory AdsModelMainAd.fromJson(Map<String, dynamic> json) => AdsModelMainAd(
        image: json["image"],
        title: json["title"],
        description: json["description"],
        redirect: json["redirect"],
        options: List.from(
          (json["options"] ?? []).map((e) => AdsModelMainAdOption.fromJson(e)),
        ),
      );
}

class AdsModelMainAdOption {
  final String title;
  final String redirect;

  AdsModelMainAdOption({required this.title, required this.redirect});

  factory AdsModelMainAdOption.fromJson(Map<String, dynamic> json) =>
      AdsModelMainAdOption(
        title: json["title"],
        redirect: json["redirect"],
      );
}

class AdsModelButton {
  final String icon;
  final String description;
  final String redirect;

  AdsModelButton(
      {required this.icon, required this.description, required this.redirect});

  factory AdsModelButton.fromJson(Map<String, dynamic> json) => AdsModelButton(
        icon: json["icon"],
        description: json["description"],
        redirect: json["redirect"],
      );
}
