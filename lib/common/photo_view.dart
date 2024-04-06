import 'dart:io';

import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/api_livechat_message_model.dart';
import 'package:app_chat365_pc/common/widget_slider.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat/widgets/my_entry.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/helpers/system_utils.dart';

class ImageMessageSliderScreen extends StatelessWidget {
  const ImageMessageSliderScreen({
    Key? key,
    required this.images,
    required this.initIndex,
  }) : super(key: key);

  final List<SocketSentMessageModel> images;
  final int initIndex;

  static const String initIndexArg = 'initIndexArg';
  static const String imagesArg = 'imagesArg';

  @override
  Widget build(BuildContext context) {
    final GlobalKey<WidgetSliderState> _sliderKey =
        GlobalKey<WidgetSliderState>();
    return Scaffold(
      backgroundColor: AppColors.mineShaft,
      appBar: AppBar(
        backgroundColor: AppColors.mineShaft,
        leading: const BackButton(
          color: AppColors.white,
        ),
        elevation: 0,
        actions: [
          IconButton(
            /// TL 13/1/2024: Sửa lại phần tải ảnh để:
            /// - Lưu bằng cách copy từ cache qua
            /// - Không cần thông qua trình duyệt (mong là được. Chưa test)
            onPressed: () async {
              var imageFile = images[_sliderKey.currentState!.tabIndex];
              var file = imageFile.files!.first;

              /// TL 13/1/2024: Nhớ là anh Việt Hùng từng bảo Mac phải tải qua trình
              /// duyệt gì gì đấy. Vì thế nên vẫn giữ lại chức năng tải qua trình duyệt
              /// làm chốt chặn cuối cùng
              bool stillNeedToDownloadViaBrowser = true;

              await DefaultCacheManager()
                  .getFileFromCache(file.downloadPath)
                  .then((fileInfo) async {
                if (fileInfo != null) {
                  var fileName = fileInfo.originalUrl.split("/").last;

                  /// TL 13/1/2024: Thật may mắn là package hỗ trợ thư mục Downloads
                  /// ở tất cả mọi nền tảng trừ Android. Không cần Android vì mình build PC :>
                  await getDownloadsDirectory().then((directory) async {
                    var file = File("${directory!.absolute.path}/$fileName");
                    BotToast.showText(text: "Đang tải ảnh");
                    // Trường hợp đơn giản: File không tồn tại. Lưu luôn
                    if (!await file.exists()) {
                      fileInfo.file.setLastModifiedSync(DateTime.now());
                      await fileInfo.file.copy("${file.absolute.path}");
                    }
                    // Trường hợp phức tạp: Có file trùng tên đã tồn tại.
                    // Cần phải tìm đường dẫn chưa dùng cho nó
                    else {
                      for (int i = 1; true; ++i) {
                        file =
                            File("${directory.absolute.path}/$fileName ($i)");
                        if (!await file.exists()) {
                          fileInfo.file.setLastModifiedSync(DateTime.now());
                          await fileInfo.file.copy("${file.absolute.path}");
                          break;
                        }
                      }
                    }
                    BotToast.showText(text: "Tải ảnh thành công");
                    stillNeedToDownloadViaBrowser = false;
                  });
                }
              }).catchError((err) {
                BotToast.showText(text: "Tải ảnh thất bại: ${err.toString()}");
              });

              // TL 13/1/2024: Tải ảnh qua trình duyệt
              // Nếu trên MacOS tải được nhờ copy cache rồi, thì xóa đoạn code này đi nhé
              if (stillNeedToDownloadViaBrowser) {
                final Uri url = Uri.parse(file.downloadPath);
                launchUrl(url).then((value) {
                  BotToast.showText(text: "Tải ảnh thành công");
                }).catchError((err) {
                  BotToast.showText(text: "Tải ảnh thất bại");
                });
              }
            },
            icon: SvgPicture.asset(Images.ic_download),
          ),
          // PopupMenuButton(
          //   child: const Icon(
          //     Icons.more_vert,
          //     color: AppColors.white,
          //   ),
          //   itemBuilder: (_) {
          //     return [
          //       // MyEntry(
          //       //   child: Text('Tải xuống'),
          //       //   onTap: () async {
          //       //     var imageFile = images[_sliderKey.currentState!.tabIndex];
          //       //     var file = imageFile.files!.first;
          //       //     var savePath = await SystemUtils.prepareSaveDir();
          //       //     if (savePath == null)
          //       //       return AppDialogs.toast(
          //       //         'Tạo đường dẫn tải file thất bại',
          //       //       );
          //       //     SystemUtils.permissionCallback(
          //       //       PermissionExt.downloadPermission,
          //       //       () => SystemUtils.downloadFile(
          //       //         file.downloadPath,
          //       //         savePath,
          //       //         fileName: file.fileName,
          //       //       ),
          //       //     );
          //       //   },
          //       // ),
          //       // MyEntry(
          //       //   child: Text('Chuyển tiếp'),
          //       //   onTap: () {
          //       //     var file = images[_sliderKey.currentState!.tabIndex];
          //       //     AppRouterHelper.toForwardMessagePage(
          //       //       context,
          //       //       message: file,
          //       //       senderInfo: context.userInfo(),
          //       //     );
          //       //   },
          //       // ),
          //       // MyEntry(
          //       //   child: Text('Chỉnh sửa ảnh'),
          //       //   onTap: () async {
          //       //     var file = images[_sliderKey.currentState!.tabIndex];
          //       //     Navigator.of(context).push(MaterialPageRoute(
          //       //       builder: (context) => ImageEditor(
          //       //         image: file,
          //       //       ),
          //       //     ));
          //       //   },
          //       // ),
          //     ];
          //   },
          // ),
          const SizedBox(width: 15),
        ],
      ),
      body: WidgetSlider(
        key: _sliderKey,
        initIndex: initIndex,
        tabBarImages: images
            .map((e) => CachedNetworkImage(
                  imageUrl: e.files!.first.fullFilePath,
                  errorWidget: (_, __, ___) => const Placeholder(),
                  height: 60,
                  width: 60,
                  memCacheHeight: 60,
                  memCacheWidth: 60,
                ))
            .toList(),
        images: images
            .map(
              (e) => PhotoView(
                imageProvider: CachedNetworkImageProvider(
                    e.type == MessageType.sendCV&&e.linkPng != null? e.linkPng??"" : e.files!.first.fullFilePath, errorListener: (obj) {
                  logger.logError(
                      "Ảnh ImageMessageSliderScreen gặp lỗi: ${obj.toString()}",
                      null,
                      "$runtimeType");
                }),
                errorBuilder: (_, __, ___) => const Placeholder(),
                scaleStateChangedCallback: (value) {
                  if (value == PhotoViewScaleState.zoomedIn &&
                      _sliderKey.currentState!.isScrollable) {
                    _sliderKey.currentState!.changePhysics(
                      const NeverScrollableScrollPhysics(),
                    );
                  } else if (value == PhotoViewScaleState.zoomedOut) {
                    AppRouter.back(context);
                  } else if (!_sliderKey.currentState!.isScrollable) {
                    _sliderKey.currentState!.changePhysics(
                      const AlwaysScrollableScrollPhysics(),
                    );
                  }
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
