import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat_conversations/models/ads_model.dart';
import 'package:app_chat365_pc/utils/data/extensions/object_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class AdsMessage extends StatelessWidget {
  final AdsMainOption main_ad;
  final List<AdsModelMainAdOption> options;

  const AdsMessage({Key? key, required this.main_ad, this.options = const []})
      : super(key: key);

  AdsMessage.fromModel(AdsModelMainAd model)
      : main_ad = AdsMainOption.fromModel(model),
        options = model.options,
        super();

  @override
  Widget build(BuildContext context) {
    Widget mainAd = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        main_ad.banner,
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 6, 12),
          child: Text(main_ad.title,
              softWrap: true,
              style: TextStyle(
                  color: AppColors.mineShaft,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          child: Text(main_ad.description,
              softWrap: true,
              style: TextStyle(
                  color: AppColors.grey666,
                  fontSize: 13,
                  fontWeight: FontWeight.w400)),
        ),
      ],
    );
    if (main_ad.url != null)
      mainAd = InkWell(
        onTap: () async {
          if (main_ad.url != null) {
            try {
              if (!await launchUrl(Uri.parse(main_ad.url!)))
                print("Can't launch URL ${main_ad.url}");
            } catch (e) {
              print("Error launching URL ${main_ad.url}: ${e.toErrorString()}");
            }
          }
        },
        child: mainAd,
      );

    return Container(
      color: AppColors.lightGray,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainAd,
          ...List.from(options.map((e) => Column(
                children: [
                  Divider(
                    height: 1,
                    color: AppColors.grayACACAC,
                  ),
                  TextButton(
                      onPressed: () async {
                        if (!await launchUrl(Uri.parse(e.redirect)))
                          print("Can't launch URL ${e.redirect}");
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Text(
                            e.title.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppColors.black47,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          )),
                          SizedBox(
                            width: 16.67,
                            height: 13.33,
                            child: SvgPicture.asset(
                              Images.add,
                            ),
                          ),
                        ],
                      )),
                ],
              )))
        ],
      ),
    );
  }
}

// Main option of the ad. Layout on figma
// Big image banner on top: ["ĐĂNG TIN TUYỂN DỤNG"]
// A bold title under banner: "VIỆC LÀM HOT THÁNG 10 ĐANG CHỜ BẠN"
// Some small descriptions below: "Chào bạn, nếu bạn đang..."
// Finally, when user presses on it, TODO: WHAT WILL HAPPEN?
// 1. Send a text to the advertisor chat
// 2. Open browser link [I'm assuming this]
class AdsMainOption {
  final Image banner;
  final String title;
  final String description;
  final String? url;

  AdsMainOption(
      {required this.banner,
      required this.title,
      required this.description,
      this.url = null});

  AdsMainOption.fromModel(AdsModelMainAd model)
      : banner = Image.network(
          model.image,
          errorBuilder: ((context, error, stackTrace) =>
              const SizedBox.shrink()),
        ),
        title = model.title,
        description = model.description,
        url = model.redirect;
}
