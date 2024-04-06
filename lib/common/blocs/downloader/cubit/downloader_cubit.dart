import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:bloc/bloc.dart';
import 'package:app_chat365_pc/common/blocs/downloader/model/downloader_model.dart';
import 'package:app_chat365_pc/data/services/hive_service/hive_service.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_chat365_pc/common/blocs/downloader/model/downloader_model.dart';

part 'downloader_state.dart';

class DownloaderRepo {
  DownloaderRepo._() {
    try {
      downloadBox = _hiveService.downloadBox;
    } catch (e) {
      downloadBox = null;
    }
    _loadTask();
  }

  static DownloaderRepo? instance;

  factory DownloaderRepo() => instance ??= DownloaderRepo._();

  // DownloaderCubit()._(){}

  final HiveService _hiveService = HiveService();

  /// messageId - downloaderModel
  late final Map<String, DownloaderModel> tasks;

  late final Box<DownloaderModel>? downloadBox;

  _loadTask() {
    var task = downloadBox?.values ?? {};
    tasks = Map.fromIterable(
      task,
      key: (e) => (e as DownloaderModel).messageId,
    );
    tasks.forEach((key, value) {logger.log({"$key: ${value.status}"}, name: "DownloaderTasks");});

  }

  updateTaskStatus(String messageId, bool status) {
    var model = tasks[messageId];
    if (model != null) {
      model.status = status;
      if (downloadBox != null) {
        downloadBox!.put(messageId, model);
      }
    }
  }

  addTask(DownloaderModel model) {
    if (tasks[model.messageId] == null) {
      tasks.addAll({model.messageId: model});
      if (downloadBox != null) {
        downloadBox!.put(model.messageId, model);
      }
    }
  }
}
