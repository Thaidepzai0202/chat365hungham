import 'package:app_chat365_pc/common/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/photo_view.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat/widgets/my_entry.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/permission_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class CvDisplay extends StatelessWidget {
  const CvDisplay(
      {Key? key, required this.isSentByCurrentUser, required this.msgModel})
      : super(key: key);

  final bool isSentByCurrentUser;
  final SocketSentMessageModel msgModel;

  _launchURL(String link) async {
    final Uri url = Uri.parse('${link}');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          isSentByCurrentUser ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 300,
            child: InkWell(
              onTap: () {
                 AppRouter.toPage(
                  context,
                  AppPages.imageSlide,
                  arguments: {
                    ImageMessageSliderScreen.imagesArg: [msgModel],
                    ImageMessageSliderScreen.initIndexArg: 0,
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: context.theme.messageBoxColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    )),
                width: 240,
                height: 300,
                // width: 120,
                // height: 150,
                child: CachedNetworkImage(
                  imageUrl: msgModel.linkPng ?? '',
                  placeholder: (_, __) => const ShimmerLoading(),
                  errorWidget: (_, __, ___) => Container(),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          InkWell(
            onTap: () async {
              if (msgModel.files != null) {
               _launchURL(msgModel.files![1].downloadPath);
              } else {
                AppDialogs.toast('Tạo đường dẫn download thất bại');
              }
            },
            child: Container(
              width: 240,
              height: 40,
              // padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: context.theme.messageBoxColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TẢI PDF',
                    style: AppTextStyles.regularW400(context,
                        size: 14, color: AppColors.primary),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset(
                    Images.ic_download_linear,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CvView extends StatelessWidget {
  const CvView({Key? key, required this.msg}) : super(key: key);

  final SocketSentMessageModel msg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mineShaft,
      appBar: AppBar(
        backgroundColor: AppColors.mineShaft,
        leading: const BackButton(
          color: AppColors.white,
        ),
        actions: [
          PopupMenuButton(
            icon: SvgPicture.asset(Images.ic_download),
            itemBuilder: (_) {
              return [
                MyEntry(
                  child: const Text('Tải xuống PNG'),
                  onTap: () async {
                    // await SystemUtils.permissionCallback(
                    //     PermissionExt.downloadPermission, () async {
                    //   await SystemUtils.downloadImage(
                    //       [msg.files![0].downloadPath]);
                    // });
                  },
                ),
                MyEntry(
                  child: const Text('Tải xuống PDF'),
                  onTap: () async {
                    final ValueNotifier<String?> taskIdNotifier = ValueNotifier(
                        downloaderRepo.tasks[msg.messageId]?.taskId);
                    try {
                      print("_downloadFunction");
                      var savePath =
                          await SystemUtils.prepareSaveDir(isImage: false);
                      if (savePath == null) {
                        BotToast.showText(
                            text: 'Tạo đường dẫn download thất bại');

                        // return AppDialogs.toast(
                        //     'Tạo đường dẫn download thất bại');
                      }
                      // await SystemUtils.permissionCallback(
                      //     PermissionExt.downloadPermission,
                      //         () async => await SystemUtils.downloadFile(
                      //       msg.files![1].downloadPath,
                      //       savePath,
                      //       fileName: msg.files![1].fileName,
                      //       messageId: msg.messageId,
                      //     ));
                    } catch (e, s) {
                      logger.logError(e, s);
                      BotToast.showText(text: 'Lỗi khi tải file\n$e');

                      // AppDialogs.toast(
                      //   'Lỗi khi tải file\n$e',
                      //   toast: Toast.LENGTH_SHORT,
                      // );
                    }
                  },
                ),
              ];
            },
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          width: AppDimens.width,
          height: AppDimens.height,
          child: PhotoView(
            backgroundDecoration:
                const BoxDecoration(color: Colors.transparent),
            imageProvider: CachedNetworkImageProvider(msg.linkPng ?? '',
                errorListener: (obj) {
              logger.log("CvView không có linkPng.", name: "$runtimeType");
            }),
            minScale: 0.5,
            maxScale: 1.3,
          ),
        ),
      ),
    );
  }
}
