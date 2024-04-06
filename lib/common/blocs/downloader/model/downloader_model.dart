import 'package:app_chat365_pc/data/services/hive_service/hive_type_id.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/enums/download_status.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:hive_flutter/adapters.dart';
part 'downloader_model.g.dart';

@HiveType(typeId: HiveTypeId.downloaderModelHiveTypeId)
class DownloaderModel {
  @HiveField(0)
  final String messageId;
  @HiveField(1)
  bool status;
  @HiveField(2)
  final String? saveDir;
  @HiveField(3)
  final String? taskId;
  @HiveField(4)
  final String fileName;
  final ValueNotifier<int?> progress = ValueNotifier(0);
  final DownloadTask? task;

  DownloaderModel(
    this.messageId, {
    required this.fileName,
    this.task,
    this.status = false,
    this.saveDir,
    this.taskId,
    int? progress,
  }) {
    if (task != null) {
      task!.progress.addListener(() {
        this.progress.value = (task!.progress.value * 100).floor();
      });
      task!.status.addListener(() {
        status = task?.status.value == DownloadStatus.completed;
        logger.log("$messageId:: $status", name: "DownloaderTasks");
        downloaderRepo.updateTaskStatus(messageId, status);
      });
    }
  }

  copyWith({bool? status}) => DownloaderModel(
        messageId,
        fileName: fileName,
        status: status ?? this.status,
        progress: progress.value,
        saveDir: saveDir,
        taskId: taskId,
      );

  // toJson() => {
  //       'messageId': messageId,
  //       'status': status.value.id,
  //       'saveDir': saveDir.value,
  //       'progress': progress.value,
  //       'taskId': taskId.value,
  //       'fileName': fileName.value,
  //     };

  // factory DownloaderModel.fromJson(Map<String, dynamic> json) =>
  //     DownloaderModel(
  //       json['messageId'],
  //       status: DownloadStatusExt.fromId(json['status']),
  //       saveDir: json['saveDir'],
  //       progress: json['progress'],
  //       taskId: json['taskId'],
  //     );

  @override
  String toString() => 'DownloaderModel(${taskId.toString()})';

  @override
  int get hashCode => messageId.hashCode;
}
