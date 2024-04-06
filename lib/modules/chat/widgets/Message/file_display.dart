import 'package:app_chat365_pc/common/Widgets/ellipsized_text.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:app_chat365_pc/common/blocs/downloader/model/downloader_model.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/widgets/painter/percent_indicator.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_service.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/permission_extension.dart';
import 'package:app_chat365_pc/utils/helpers/file_utils.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:uuid/uuid.dart';

class FileDisplay extends StatefulWidget {
  FileDisplay({
    Key? key,
    required this.file,
    required this.messageId,
  }) : super(key: key);
  final ApiFileModel file;
  final String messageId;

  @override
  State<FileDisplay> createState() => _FileDisplayState();
}

class _FileDisplayState extends State<FileDisplay> {

  final ValueNotifier<DownloadTask?> taskNotifier = ValueNotifier(null);
  ValueNotifier<double>? uploadProgress;
  late final ChatBloc _chatBloc;

  @override
  void initState() {
    _chatBloc = context.read<ChatBloc>();
    uploadProgress = _chatBloc.fileProgressListener[widget.messageId];
    ApiFileModel? currentFile = _chatBloc.cachedMessageImageFile[widget.messageId]?.firstOrNull;
    if (uploadProgress != null&&currentFile != null) {
      downloaderRepo.addTask(DownloaderModel(
        widget.messageId,
        fileName: currentFile.fileName,
        saveDir: currentFile.filePath,
        taskId: const Uuid().v4(),
        status: true,
      ));
    }
    super.initState();
  }

  _downloadFile(BuildContext context) async {
    try {
      var savePath = await SystemUtils.prepareSaveDir();
      if (savePath == null) {
        return AppDialogs.toast('Tạo đường dẫn download thất bại');
      }
      var task = await SystemUtils.downloadFile(
        widget.file.downloadPath,
        savePath,
        fileName: FileUtils.getUniqueFile(savePath, widget.file.fileName),
        messageId: widget.messageId,
      );

      if (task != null) {
        taskNotifier.value = task;
        task.progress.addListener(() {
          print("progress: ${task.progress.value}");
        });
        task.status.addListener(() {
          print("status: ${task.status.value}");
        });
      } else {
        AppDialogs.toast('Tạo task download thất bại\nVui lòng thử lại');
      }
    } catch (e, s) {
      logger.logError(e, s);
      BotToast.showText(text: 'Lỗi khi tải file\n$e');
    }
  }

  _openFile(
    BuildContext context,
  ) async {
    DownloaderModel? model = downloaderRepo.tasks[widget.messageId];
    if (model == null) {
      AppDialogs.toast("File không tồn tại");
      return;
    }
    print('\x1b[35mOpen File ${model.fileName}\x1b[m');
    var openRes = await OpenFilex.open(model.saveDir);
    logger.log(openRes.message);
    var message = openRes.message;
    switch (openRes.type) {
      case ResultType.error:
        AppDialogs.toast(message);
        break;
      case ResultType.fileNotFound:
        AppDialogs.toast(message);
        HiveService().downloadBox?.delete(model.messageId);
        downloaderRepo.updateTaskStatus(model.messageId, false);
        break;
      case ResultType.noAppToOpen:
        AppDialogs.toast(message);
        break;
      case ResultType.permissionDenied:
        AppDialogs.toast(message);
        break;
      default:
    }
    
  }

  buildTooltipButton(
    {
      required String tooltip,
      required IconData icon,
      void Function()? onTap}) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        color: context.theme.text2Color,
        iconSize: 18,
        padding: const EdgeInsets.all(0),
        visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
      ),
    );
  }

  Widget buildDownloadButton() {
    if (uploadProgress != null) {
      return ValueListenableBuilder(
        valueListenable: uploadProgress!,
        builder: (_, __, ___) {
          double progress = uploadProgress?.value ?? 0;
          if (progress < 1.0) {
            return Text("${(progress * 100).floor()}%");
          } else {
            return buildTooltipButton(tooltip: "Mở", icon: Icons.file_open, onTap: () {_openFile(context);});
          }
        }
      );
    }
    return Builder(
      builder: (context) {
        DownloaderModel? model = downloaderRepo.tasks[widget.messageId];
        if (model != null&&model.status == true) {
        return buildTooltipButton(tooltip: "Mở", icon: Icons.file_open, onTap: () {_openFile(context);});
        } else {
          return ValueListenableBuilder(
            valueListenable: taskNotifier,
            builder: (_, __, ___) {
              if (taskNotifier.value == null) {
                return buildTooltipButton(tooltip: "Tải xuông", icon: Icons.download, onTap: () {_downloadFile(context);});
              } else {
                var statusNotifier = taskNotifier.value!.status;
                var progressNotifier = taskNotifier.value!.progress;
                return ValueListenableBuilder(
                  valueListenable: statusNotifier,
                  builder: (_, __, ___) {
                    DownloadStatus status = statusNotifier.value;
                    if (status == DownloadStatus.downloading) {
                      return ValueListenableBuilder(
                        valueListenable: progressNotifier,
                        builder: (_, __, ___) {
                          return Text("${(progressNotifier.value * 100).floor()}%");
                        }
                      );
                    } else if (status == DownloadStatus.completed) {
                      if (model != null) {
                        downloaderRepo.updateTaskStatus(model.messageId, true);
                      }
                      return buildTooltipButton(tooltip: "Mở", icon: Icons.file_open, onTap: () {_openFile(context);});
                    } else {
                      return buildTooltipButton(tooltip: "Tải xuông", icon: Icons.download, onTap: () {_downloadFile(context);});
                    }
                  }
                );
              }
            }
          );
        }
      }
    );
  }
    
  String getFileIcon(String fileExtension) {
    switch (fileExtension) {
      case ".doc": return Images.icon_atch_word;
      case ".docx": return Images.icon_atch_word;
      case ".txt": return Images.icon_atch_txt;
      case ".rtf": return Images.icon_atch_rtf;
      case ".xls": return Images.icon_atch_excel;
      case ".xlsx": return Images.icon_atch_excel;
      case ".zip": return Images.icon_atch_zip;
      case ".pdf": return Images.icon_atch_pdf;
      default: return Images.icon_atch_generic;
    }
  }

  Widget buildUploadProgressIndicator() {
    if (uploadProgress == null||uploadProgress?.value == 1.0) return const SizedBox.shrink();
    return ValueListenableBuilder(
      valueListenable: uploadProgress!,
      builder: (_, __, ___) {
        return LinearPercentIndicator(
          padding: EdgeInsets.zero,
          barRadius: const Radius.circular(10),
          backgroundColor: const Color.fromARGB(52, 244, 244, 244),
          progressColor: context.theme.colorPirimaryNoDarkLight,
          percent: uploadProgress?.value??0,
        );
      }
    );
  }

  Widget buildDownloadProgressIndicator(DownloaderModel? model) {
    if (taskNotifier.value == null) return const SizedBox.shrink();
    if (model != null&&model.status) return const SizedBox.shrink();
    return ValueListenableBuilder(
      valueListenable: taskNotifier.value!.status,
      builder: (_, __, ___) {
        DownloadStatus status = taskNotifier.value!.status.value;
        if (status == DownloadStatus.downloading) {
          return ValueListenableBuilder(
            valueListenable: taskNotifier.value!.progress,
            builder: (_, __, ___) {
              double progress = taskNotifier.value!.progress.value;
              return LinearPercentIndicator(
                padding: EdgeInsets.zero,
                barRadius: const Radius.circular(10),
                backgroundColor: const Color.fromARGB(52, 244, 244, 244),
                progressColor: context.theme.colorPirimaryNoDarkLight,
                percent: progress,
              );
            }
          );
        }
        return const SizedBox.shrink();
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    String fileExtension = p.extension(widget.file.fileName).toLowerCase();
    DownloaderModel? model = downloaderRepo.tasks[widget.messageId];

    return ValueListenableBuilder(
      valueListenable: taskNotifier,
      builder: (_, __, ___) {
        return Container(
          width: 350,
          color: context.theme.messageFileBoxColor,
          padding: const EdgeInsets.all(12),
          // đây là phần hiển thị file
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      getFileIcon(fileExtension),
                      width: 50,
                    ),
                    SizedBoxExt.w10,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EllipsizedText(
                            widget.file.fileName.replaceAll(fileExtension, ""),
                            // maxLines: 3,
                            style: AppTextStyles.regularW500(
                              context,
                              size: 16,
                              lineHeight: 21,
                              color: context.theme.text2Color
                            ),
                            ellipsis: Ellipsis.end,
                          ),
                          SizedBoxExt.h10,
                          buildDownloadProgressIndicator(model),
                          buildUploadProgressIndicator()
                        ],
                      ),
                    ),
                    SizedBoxExt.w10,
                    buildDownloadButton()
                  ],
                ),
              ),
              SizedBoxExt.h10,
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Text("${widget.file.displayFileSize} - ${fileExtension.substring(1).toUpperCase()}",style: TextStyle(color: context.theme.text2Color),),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}