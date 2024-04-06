// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/photo_view.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_dimens.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ImageDisplay extends StatelessWidget {
  const ImageDisplay({
    Key? key,
    required this.file,
    required this.messageModel,
    this.remain = 0,
    this.fit,
    this.placeholder,
    this.cachedSize,
  }) : super(key: key);

  final ApiFileModel file;
  final BoxFit? fit;
  final File? placeholder;
  final SocketSentMessageModel messageModel;
  final int remain;
  final int? cachedSize;

  Widget clipRRect(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: deletedFileImage(context),
      );

  @override
  Widget build(BuildContext context) {
    var fileImagePlaceholder;
    if (placeholder != null) {
      fileImagePlaceholder = placeholder!.path.contains('https')
          ? CachedNetworkImage(
              imageUrl: placeholder!.path,
              errorWidget: ((context, url, error) => clipRRect(context)),
              progressIndicatorBuilder: (context, _, __) =>
                  const ShimmerLoading(dimension: double.infinity),
            )
          : Image.file(
              placeholder!,
              fit: fit,
              width: double.infinity,
            );
    } else {
      fileImagePlaceholder = CachedNetworkImage(
        // TL 13/1/2024: Cache download path, chứ sao lại dùng cái mess.timviec.365 nay :)
        imageUrl: file
            .fullFilePath, // 'https://mess.timviec365.vn/uploads/' + file.resolvedFileName,
        fit: fit,
        width: double.infinity,
        errorWidget: ((context, url, error) => clipRRect(context)),
        progressIndicatorBuilder: (context, _, __) =>
            const ShimmerLoading(dimension: double.infinity),
      );
    }
    // đây là phần hiển thị ảnh
    var cachedNetworkImage = CachedNetworkImage(
      imageUrl: file.fullFilePath,
      // memCacheWidth: cachedSize,
      memCacheHeight: cachedSize,
      fit: fit,
      progressIndicatorBuilder: (context, _, __) =>
          fileImagePlaceholder ??
          const ShimmerLoading(dimension: double.infinity),
      errorWidget: (context, uri, error) {
        logger.log(
          Uri.parse(uri),
          name: 'ErrorMessageImage',
          color: StrColor.red,
        );
        return fileImagePlaceholder ?? clipRRect(context);
      },
    );
    return InkWell(
      onTap: () async{
        await context.read<ChatDetailBloc>().fetchListMessages();
        var imageFiles = context.read<ChatDetailBloc>().listImageFiles.toSet().toList();
        var initIndex = imageFiles.indexWhere(
          (e) =>
              e.messageId == messageModel.messageId &&
              e.files!.first.originFileName ==
                  messageModel.files!.first.originFileName,
        );
        print('__________${imageFiles.length}');
        AppRouter.toPage(
          context,
          AppPages.imageSlide,
          arguments: {
            ImageMessageSliderScreen.imagesArg: imageFiles,
            ImageMessageSliderScreen.initIndexArg: initIndex,
          },
        );
      },
      child: remain == 0
          ? cachedNetworkImage
          : Stack(
              children: [
                cachedNetworkImage,
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: AppColors.black.withOpacity(0.5),
                  alignment: Alignment.center,
                  child: Text(
                    '$remain +',
                    style: AppTextStyles.regularW500(
                      context,
                      size: 30,
                      color: AppColors.white,
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget deletedFileImage(BuildContext context) {
    return Container(
      width: AppDimens.width * 0.68,
      height: AppDimens.width * 0.38,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: AppColors.dustyGray.withOpacity(0.5)),
      child: const ShimmerLoading()
    );
  }
}
