import 'dart:async';
import 'dart:collection';
import 'dart:developer' show log;
import 'dart:io';
import 'dart:ui';

import 'package:app_chat365_pc/common/blocs/auth_bloc/auth_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:app_chat365_pc/common/blocs/downloader/model/downloader_model.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/data/services/generator_service.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_status.dart';
import 'package:app_chat365_pc/utils/data/enums/download_status.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/file_utils.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sp_util/sp_util.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class SystemUtils {
  static Future<void> _launchUrl(String url) async {
    // if (await canLaunchUrl(Uri.parse(url)))
    //   await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  static Future<void> openUrlInBrowser(String url) {
    logger.log(url);
    return _launchUrl(url);
  }

  // download Image
  // static downloadImage(List<String> urls, {bool isImage = true}) async {
  //   var _port = IsolateNameServer.lookupPortByName('image_send_port');
  //   _port != null
  //       ? _port.send([urls, isImage])
  //       : AppDialogs.toast('Có lỗi xảy ra!');
  //   return;
  // }

  /*
  static Future<void> openUri({
    required AppStoreUri appStoreUri,
    String? url,
  }) async {
    if (Platform.isAndroid && appStoreUri.androidId != null) {
      if (await canLaunch(appStoreUri.nativeAndroid!))
        await launch(appStoreUri.nativeAndroid!);
      else
        openUrlInBrowser(appStoreUri.androidWeb!);
    } else if (Platform.isIOS && appStoreUri.iosId != null) {
      if (await canLaunch(appStoreUri.nativeIos!))
        await launch(appStoreUri.nativeIos!);
      else
        openUrlInBrowser(appStoreUri.iosWeb!);
    } else if (url != null) await SystemUtils.openUrlInBrowser(url);
  }

  static Future<void> openFile(FutureOr<String> filePath) async {
    final OpenResult result = await OpenFile.open(await filePath);

    switch (result.type) {
      case ResultType.noAppToOpen:
        // throw UnsupportedError('Không có ứng dụng khả dụng để mở file này!');
        throw 'Không có ứng dụng khả dụng để mở file này!';
      case ResultType.fileNotFound:
        // throw FileSystemException(
        //     'Đã có lỗi xảy ra, không tìm thấy file được yêu cầu!');
        // throw 'Đã có lỗi xảy ra, không tìm thấy file được yêu cầu!';
        // throw 'Không tìm thấy file!';
        throw FileNotFound();
      case ResultType.permissionDenied:
        throw PermissionDenied('Vui lòng cấp quyền truy cập!');
      default:
        break;
    }
  }

  static Future<void> launchPhoneUrlScheme(String url) => _launchUrl(url);
  */

  static Future<Uint8List?> getCachedImageAsByte(String url) async {
    var cached = await DefaultCacheManager().getFileFromCache(url);
    if (cached == null) return null;

    return await cached.file.readAsBytes();
  }

  static Future<String> getAppDirectory() async {
    if (Platform.isAndroid)
      return (await getExternalStorageDirectory() ??
              await getApplicationSupportDirectory())
          .path;
    else
      return (await getApplicationSupportDirectory()).path;
  }

  static Future<String> getDeviceTemporaryDirectory() async {
    return (await getTemporaryDirectory()).path;
  }

  static Future<String> getPathToDownloadFolder() async =>
      await getAppDirectory();

  static Future<String> getPathToDownloadedCvFolder(String folder) async =>
      await getPathToDownloadFolder() + "/downloaded_cv/$folder";

  static Future<String> getChatFilePath(String fileName) async =>
      await getPathToDownloadFolder() + "/chat/$fileName";

  static debugLog(String source, String message) {
    if (kDebugMode) log(message, name: source);
  }

  static Future<File> ImageToFile(String image) async {
    var savePath = await _getSavePath(image);
    print(savePath);

    await Dio().download(image, savePath, onReceiveProgress: (count, total) {
      var progress = count * 100 / total;
      logger.log(progress.toString());
    });

    return File(savePath);
  }

  static Future<String> _getSavePath(String image) async {
    var saveDir = await getTemporaryDirectory();
    var fileName = image.split('/').last;
    return '${saveDir.path}/$fileName';
  }
  // static copyImageToClipboard(String image) async {
  //   var save = (await getTemporaryDirectory()).absolute.path;
  //   var savePath = save + '/' + image.split('/').last;
  //   print(savePath);
  //   var file = await Dio().download(Uri.parse(image).toString(), savePath,
  //       onReceiveProgress: ((count, total) =>
  //           logger.log((count * 100 / total).toString())));
  //
  //  // print(file);
  //   final paths = [savePath];
  //   await Pasteboard.writeFiles(paths);
  //
  //   final imageBytes = await Pasteboard.image;
  //   print(imageBytes?.length);
  //
  //   BotToast.showText(text:
  //     'Sao chép thành công',
  //     toast: Toast.LENGTH_SHORT,
  //   );
  // }

  static copyToClipboard(String text) async {
    await Clipboard.setData(
      ClipboardData(
        text: text,
      ),
    );
    BotToast.showText(
      text: 'Sao chép thành công',
    );
  }

  // requests storage permission
  // static Future<bool> _requestWritePermission() async {
  //   var isGranted = PermissionExt.downloadPermission.request().isGranted;
  //   if (!(await isGranted)) {
  //     var res = await PermissionExt.downloadPermission.request();
  //     return res.isGranted;
  //   } else
  //     return true;
  //   // return await Permission.manageExternalStorage.request().isGranted;
  // }

  // static Future<ExceptionError?> saveImage(
  //   ApiFileModel file, {
  //   VoidCallback? onDownloadingFile,
  //   VoidCallback? onDownloadFileError,
  //   VoidCallback? onDownloadFileSuccess,
  //   VoidCallback? onSavingFile,
  //   VoidCallback? onSaveFileError,
  //   ValueChanged<String>? onSaveFileSuccess,
  // }) async {
  //   // requests permission for downloading the file
  //   bool hasPermission = await _requestWritePermission();
  //   if (!hasPermission) return ExceptionError.notAllowWriteFile();

  //   var response = await ApiClient().downloadImage(
  //     file.fullFilePath,
  //   );

  //   if (response.isNotEmpty) {
  //     onDownloadFileSuccess?.call();
  //     final result = await ImageGallerySaver.saveImage(
  //       Uint8List.fromList(response),
  //       quality: 60,
  //       name: file.fileName,
  //     );

  //     logger.log(Map<String, dynamic>.from(result));

  //     if (result['errorMessage'] == null) {
  //       try {
  //         var filePath = (result['filePath'] as String)
  //             .replaceAll(RegExp(r'\w+\:\/\/'), '');
  //         onSaveFileSuccess?.call(filePath);
  //         return null;
  //       } catch (e, s) {
  //         logger.logError(e, s);
  //         ExceptionError.openFileError();
  //       }
  //     }
  //   }
  //   return ExceptionError.downloadFileError();
  // }

  static Iterable<T> searchFunction<T>(
    String text,
    Iterable<T> list, {
    bool toEng = true,
    String Function(T value)? delegate,
  }) {
    String Function(T value) _delegate = delegate ?? (T e) => e.toString();

    if (text.isNotEmpty) {
      Iterable<String> searchList;

      if (toEng) {
        text = text.toEngAlphabetString();
        searchList = list.map((e) => _delegate(e).toEngAlphabetString());
      } else
        searchList = list.map((e) => _delegate(e));

      List<String> spl = text.split(RegExp(r'[ _]'));
      // var reg = RegExp(
      //     '(?:^|(?<= ))(${spl.map((e) => '\\w*$e\\w*').join('|')})(?:(?= )|\$)');
      var reg = RegExp('(${spl.join('|')})');

      var map = Map.fromIterables(
          list,
          searchList.map(
            (e) => reg.allMatches(e).toList(),
          ));

      map.removeWhere((k, v) => v.isEmpty);

      var sortedKeys = map.keys.toList(growable: false)
        ..sort((k1, k2) => map[k1]!.length.compareTo(map[k2]!.length));

      LinkedHashMap sortedMap = LinkedHashMap.fromIterable(sortedKeys,
          key: (k) => k, value: (k) => map[k]);

      return sortedMap.keys.cast();
    }

    return list;
  }

  static Iterable<T> searchFunctionQuickMessage<T>(
    String text,
    Iterable<T> list, {
    String Function(T value)? delegate,
  }) {
    String Function(T value) _delegate = delegate ?? (T e) => e.toString();

    if (text.isNotEmpty) {
      Iterable<String> searchList;

      text = text.toEngAlphabetString();
      searchList = list.map((e) => _delegate(e).toEngAlphabetString());

      List<String> spl = text.split(RegExp(r'[ _]'));
      // var reg = RegExp(
      //     '(?:^|(?<= ))(${spl.map((e) => '\\w*$e\\w*').join('|')})(?:(?= )|\$)');
      var reg = RegExp('(${spl.join('|')})');

      var map = Map.fromIterables(
          list,
          searchList.map(
            (e) => reg.allMatches(e).toList(),
          ));

      map.removeWhere((k, v) => v.isEmpty);

      var sortedKeys = map.keys.toList(growable: false)
        ..sort((k1, k2) => map[k1]!.length.compareTo(map[k2]!.length));

      LinkedHashMap sortedMap = LinkedHashMap.fromIterable(sortedKeys,
          key: (k) => k, value: (k) => map[k]);

      return sortedMap.keys.cast();
    }

    return list;
  }

  /// Truyền vào [text] và danh sách các [File], [Image], [Contact], [InfoLink] đính kèm nếu infoLinkMessageType == [MessageType.document] cần gửi,
  ///
  /// Trả về danh sách các [ApiMessageModel] gồm:
  /// - 1 model gửi [text] (+ [ApiRelyMessageModel] nếu có)
  /// - 1+ model gửi các [File]
  /// - 1 model gửi các [Image]
  /// - 1 model gửi [Contact]
  /// - 1 model gửi message kèm [InfoLink]
  ///
  /// Các type không phải text cần 1 đơn vị để không bị trùng messageId vs text khi truyền file cùng
  /// text
  /// - 1: ứng với Ảnh
  /// - 2: ứng với Link
  /// - 3: ứng với Contact
  /// - 4: ứng với File
  static List<ApiMessageModel> getListApiMessageModels({
    required IUserInfo senderInfo,
    required int conversationId,
    String? text,
    List<File> files = const [],
    InfoLink? infoLink,
    MessageType? infoLinkMessageType,

    /// Các file đã upload lên server
    List<ApiFileModel> uploadedFiles = const [],
    ApiReplyMessageModel? replyModel,
    IUserInfo? contact,
    String? messageId,

    /// [createdAt] Thời gian tạo tin nhắn
    /// - Ví dụ chỉnh sửa tin nhắn: createdAt là thời gian tạo của tin nhắn gốc
    DateTime? createdAt,
  }) {
    ApiMessageModel? textMsg;
    ApiMessageModel? imageMsg;
    ApiMessageModel? videoMsg;
    ApiMessageModel? voiceMsg;
    ApiMessageModel? mapMsg;
    List<ApiMessageModel>? fileMsg;
    ApiMessageModel? contactMsg;
    ApiMessageModel? linkMsg;
    ApiMessageModel? documentMsg;

    messageId ??= GeneratorService.generateMessageId(senderInfo.id);

    final senderId = senderInfo.id;

    logger.log(text, name: 'kkkkkkkkkkkkkkkkkkkkkkk132');

    /// Text
    if (infoLinkMessageType == null ||
        infoLinkMessageType == MessageType.text && !text.isBlank ||
        replyModel != null) {
      logger.log('+_+_+_+_+_ $text _+_+_+_+_');
      textMsg = ApiMessageModel(
        createdAt: createdAt ?? DateTime.now(),
        messageId: messageId,
        conversationId: conversationId,
        senderId: senderId,
        type: MessageType.text,
        message: text,
        replyMessage: replyModel,
      );
    }

    /// File
    if (files.isNotEmpty || uploadedFiles.isNotEmpty) {
      final List<ApiFileModel> pickedFiles = [
        ...uploadedFiles,
        ...List<ApiFileModel>.from(
          files.map(
            (e) => ApiFileModel(
              fileName: e.name,
              fileType:
                  MessageTypeExt.fromFileExtension(e.path.split('.').last),
              fileSize: e.lengthSync(),
              filePath: e.path,
            ),
          ),
        )
      ];

      final List<ApiFileModel> apiImages =
          pickedFiles.where((e) => e.fileType == MessageType.image).toList();

      if (apiImages.isNotEmpty)
        imageMsg = ApiMessageModel(
          createdAt: createdAt,
          messageId: GeneratorService.addToMessageId(messageId, 1),
          conversationId: conversationId,
          senderId: senderId,
          files: apiImages,
          type: MessageType.image,
        );

      List<ApiFileModel> voiceFile =
          pickedFiles.where((e) => e.fileType == MessageType.voice).toList();
      if (voiceFile.isNotEmpty)
        voiceMsg = ApiMessageModel(
          createdAt: createdAt,
          messageId: GeneratorService.addToMessageId(messageId, 2),
          conversationId: conversationId,
          senderId: senderId,
          files: voiceFile,
          type: MessageType.voice,
          message: '',
        );
      // final List<ApiFileModel> apiVideos = pickedFiles.where((e) => e.fileType == MessageType.video).toList();
      //
      // if (apiVideos.isNotEmpty) {
      //   var ticks = messageId.tickFromMessageId + 4;
      //   fileMsg = apiVideos
      //       .asMap()
      //       .keys
      //       .map((index) => ApiMessageModel(
      //             createdAt: createdAt,
      //             messageId: GeneratorService.generateMessageId(
      //               senderId,
      //               ticks + index,
      //             ),
      //             conversationId: conversationId,
      //             senderId: senderId,
      //             files: [apiVideos[index]],
      //             type: MessageType.video,
      //           ))
      //       .toList();
      // }

      List<ApiFileModel> apiFiles = pickedFiles
          .where((e) =>
              e.fileType == MessageType.file || e.fileType == MessageType.video)
          .toList();

      if (apiFiles.isNotEmpty) {
        var ticks = messageId.tickFromMessageId + 4;
        fileMsg = apiFiles
            .asMap()
            .keys
            .map((index) => ApiMessageModel(
                  createdAt: createdAt,
                  messageId: GeneratorService.generateMessageId(
                    senderId,
                    ticks + index,
                  ),
                  conversationId: conversationId,
                  senderId: senderId,
                  files: [apiFiles[index]],
                  type: MessageType.file,
                ))
            .toList();
      }
    }

    /// Tin nhắn có InfoLink đính kèm
    if (infoLink != null) {
      if (infoLinkMessageType == MessageType.document)
        documentMsg = ApiMessageModel(
          conversationId: conversationId,
          messageId: GeneratorService.addToMessageId(messageId, 2),
          senderId: senderId,
          type: infoLinkMessageType!,
          message: text,
          infoLink: infoLink,
        );

      /// Link
      else
        linkMsg = ApiMessageModel(
          createdAt: createdAt,
          messageId: GeneratorService.addToMessageId(messageId, 2),
          conversationId: conversationId,
          senderId: senderId,
          type: infoLinkMessageType ?? MessageType.link,
          message: infoLink.link ?? infoLink.linkHome,
          infoLink: infoLink,
        );
    } else if (infoLink == null && infoLinkMessageType == MessageType.link) {
      /// Link
      linkMsg = ApiMessageModel(
        createdAt: createdAt,
        messageId: GeneratorService.addToMessageId(messageId, 2),
        conversationId: conversationId,
        senderId: senderId,
        type: MessageType.link,
        message: text,
        infoLink: infoLink,
      );
    }

    /// Contact
    if (contact != null)
      contactMsg = ApiMessageModel(
        createdAt: createdAt,
        messageId: GeneratorService.addToMessageId(messageId, 3),
        conversationId: conversationId,
        senderId: senderId,
        type: MessageType.contact,
        contact: contact,
      );

    if (infoLinkMessageType == MessageType.map) {
      textMsg = ApiMessageModel(
        createdAt: createdAt,
        messageId: messageId,
        conversationId: conversationId,
        senderId: senderId,
        type: MessageType.map,
        message: text,
        replyMessage: replyModel,
      );
    }

    logger.log(textMsg?.toMap(), name: 'hhhhhhhhhhhhhhhhhhhhhhh');
    List<ApiMessageModel> messages = ([
      textMsg,
      imageMsg,
      if (fileMsg != null) ...fileMsg,
      contactMsg,
      linkMsg,
      documentMsg,
      mapMsg,
      voiceMsg,
    ]..removeWhere((e) => e == null))
        .cast();

    return messages;
  }

  static Future<String?> _findLocalPath({bool isImage = false}) async {
    String? externalStorageDirPath;
    // if (Platform.isAndroid) {
    //   try {
    //     if (isImage)
    //       externalStorageDirPath = await AndroidPathProvider.picturesPath;
    //     else
    //       externalStorageDirPath = await AndroidPathProvider.downloadsPath;
    //   } catch (e) {
    //     print('Có lỗi rồi nè.....');
    //     final directory = await getApplicationDocumentsDirectory();
    //     externalStorageDirPath = directory.path;
    //   }
    // } else if (Platform.isIOS) {
    //   // if(isImage) {
    //   //   externalStorageDirPath = (await getLibraryDirectory()).absolute.path;
    //   //   print('saveDir ne: $externalStorageDirPath');
    //   // } else
    //   externalStorageDirPath =
    //       (await getApplicationDocumentsDirectory()).absolute.path;
    // }
    return externalStorageDirPath;
  }

  static Future<String?> prepareSaveDir({bool isImage = false}) async {
    try {
      final savedDir = await getDownloadsDirectory();
      return savedDir?.path;
    } catch (e, s) {
      logger.logError(e, s, 'PrepareSaveDirErro');
    }
    return null;
  }

  static Future<bool> checkFileExist(String fileName) async {
    var saveDir = await prepareSaveDir();
    if (saveDir == null) return false;
    File file = File('$saveDir/$fileName');
    return file.existsSync();
  }

  static Future<DownloadTask?> _enqueueDownloader(
    String filePath,
    String savePath, {
    String? fileName,
  }) async {
    return await downloadManager.addDownload(filePath, p.join(savePath, fileName));
  }

  static Future<DownloadTask?> downloadFile(
    String filePath,
    String savePath, {
    String? fileName,
    String? messageId,
  }) async {
    Completer<DownloadTask?> c = Completer();
    bool check = await checkFileExist(fileName!);
    if(check){
      await AppDialogs.showFileExistDialog(navigatorKey.currentContext!, () async {
        AppRouter.back(navigatorKey.currentContext!);
        c.complete(await _downloadFile(filePath, savePath,
          fileName: FileUtils.getUniqueFile(savePath, fileName),
          messageId: messageId));
      });
    } else {
      c.complete(await _downloadFile(filePath, savePath,
        fileName: FileUtils.getUniqueFile(savePath, fileName),
        messageId: messageId));
    }
    return c.future;
  }

  static Future<DownloadTask?> _downloadFile(
    String filePath,
    String savePath, {
    String? fileName,
    String? messageId,
  }) async {
    var downloadTask = await _enqueueDownloader(
      filePath,
      savePath,
      fileName: fileName,
    );

    var taskId = const Uuid().v4();

    if (downloadTask != null) {
      try {
        downloaderRepo.addTask(DownloaderModel(
          messageId!,
          fileName: fileName!,
          saveDir: p.join(savePath, fileName),
          status: false,
          progress: 0,
          task: downloadTask,
          taskId: taskId
        ));
        logger.log('a');
      } catch (e) {
        logger.log('Đã có lỗi xảy ra khi tải file $e'.addColor(StrColor.red));
      }
    }

    return downloadTask;
  }

  // static downloadImage(List<String> urls, {bool isImage = true}) async {
  //   var _port = IsolateNameServer.lookupPortByName('image_send_port');
  //   _port != null
  //       ? _port.send([urls, isImage])
  //       : BotToast.showText(text:'Có lỗi xảy ra!');
  //   return;
  // }

  // _downloadImage() async {}

  // static Future<String?> launchUrlInAppWebView(String path) async {
  //   var uri = GeneratorService.generatePreviewLink(path);
  //   // : path;

  //   logger.log(uri, name: 'PreviewUri');

  //   bool openRes;

  //   try {
  //     openRes = await launchUrl(
  //       Uri.parse(uri),
  //       // mode: LaunchMode.platformDefault,
  //       webViewConfiguration: WebViewConfiguration(),
  //     );
  //   } catch (e) {
  //     openRes = false;
  //   }
  //   if (!openRes) return 'Xem trước file thất bại';

  //   logger.log(openRes, name: 'FilePreview');

  //   return null;
  // }

  // @pragma('vm:entry-point')
  // static void downloadCallback(
  //   String id,
  //   int status,
  //   int progress,
  // ) =>
  //     IsolateNameServer.lookupPortByName('downloader_send_port')
  //         ?.send([id, status, progress]);

  // //
  // // @pragma('vm:entry-point')
  // // static void imageDownloadCallback(
  // //   List<String> url,
  // //   int progress,
  // // ) =>
  // //     IsolateNameServer.lookupPortByName('image_download_send_port')
  // //         ?.send([url, progress]);

  /// [onRequest] cần bao gồm cả [callBack] trong đó vì trong này không gọi lại [callBack] khi
  /// chưa có [permission]
  ///
  /// [onPermissionDisabled]:
  /// - gọi khi không thể request permission:
  /// - mặc đinh gọi đến [openAppSettings()]
  static Future<void> permissionCallback(
    Permission permission,
    VoidCallback callback, {
    Future Function()? onRequest,
    Function()? onPermissionDisabled,
    ValueChanged<bool>? onPermissionStatusGrandted,
  }) async {
    try {
      log('status ${await permission.request()}');
      final Function() onDisabled = onPermissionDisabled ?? openAppSettings;
      if (await permission.isPermanentlyDenied ||
          await permission.isRestricted) {
        onPermissionDisabled?.call() ?? openAppSettings();
        onPermissionStatusGrandted?.call(false);
      } else if (await permission.isDenied) {
        if (onRequest != null) {
          await onRequest();
          onPermissionStatusGrandted?.call(false);
        } else {
          var status = await permission.request();
          if (status.isGranted) {
            callback();
            onPermissionStatusGrandted?.call(true);
          } else if (status == PermissionStatus.permanentlyDenied) {
            onDisabled();
            onPermissionStatusGrandted?.call(false);
          }
        }
      } else {
        logger.log("permissionCallback already: $permission");
        callback();
        onPermissionStatusGrandted?.call(true);
      }
    } catch (e) {
      logger.log("permissionCallback err: $e");
    }
  }

  // static Future<void> permissionFutureCallback(
  //   Permission permission,
  //   Future Function() callback, {
  //   Future Function()? onRequest,
  //   Function()? onPermissionDisabled,
  //   ValueChanged<bool>? onPermissionStatusGrandted,
  // }) async {
  //   try {
  //     log('status ${await permission.request()}');
  //     final Function() onDisabled = onPermissionDisabled ?? openAppSettings;
  //     if (await permission.isPermanentlyDenied ||
  //         await permission.isRestricted) {
  //       onPermissionDisabled?.call() ?? openAppSettings();
  //       onPermissionStatusGrandted?.call(false);
  //     } else if (await permission.isDenied) {
  //       if (onRequest != null) {
  //         await onRequest();
  //         onPermissionStatusGrandted?.call(false);
  //       } else {
  //         var status = await permission.request();
  //         if (status.isGranted) {
  //           await callback();
  //           onPermissionStatusGrandted?.call(true);
  //         } else if (status == PermissionStatus.permanentlyDenied) {
  //           onDisabled();
  //           onPermissionStatusGrandted?.call(false);
  //         }
  //       }
  //     } else {
  //       print("permissionCallback already: ${permission}");
  //       await callback();
  //       onPermissionStatusGrandted?.call(true);
  //     }
  //   } catch (e) {
  //     print("permissionCallback err: ${e}");
  //   }
  // }

  static sendSms(
    String phoneNumber, {
    required String message,
  }) async {
    var symbol = Platform.isAndroid ? '?' : '&';

    /// https://github.com/flutter/flutter/issues/51352
    // var androidExternalSymbol =
    // DeviceInfoService().isIosOrLowerAndroid11 ? '' : '//';

    // if (Platform.isIOS) {
    // var res = await launchUrlString(
    //   'sms:$androidExternalSymbol$phoneNumber${symbol}body=${Uri.encodeFull(message)}',
    // );
    // if (true) BotToast.showText(text: 'Không thể gửi tin nhắn !');
    // } else
    //   _sendSmsAndroid(phoneNumber, message);
  }

  // static String? encodeQueryParameters(Map<String, String> params) {
  //   return params.entries
  //       .map((e) =>
  //           '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
  //       .join('&');
  // }

  // static _sendSmsAndroid(String phoneNumber, String message) async {
  //   Uri smsUri = Uri(
  //     scheme: 'sms',
  //     path: '$phoneNumber',
  //     query: encodeQueryParameters(<String, String>{'body': message}),
  //   );

  //   try {
  //     if (await canLaunchUrlString(smsUri.toString())) {
  //       await launchUrlString(smsUri.toString());
  //     }
  //   } catch (e) {
  //     BotToast.showText(text:'Không thể gửi tin nhắn !');
  //   }
  // }

  static logout(BuildContext context) async {
    print('ccccccccccccccccc${SpUtil.getString(LocalStorageKey.userInfo)}');

    var id = context.userInfo().id;
    context.read<ChatRepo>().logout(id);
    context.read<ChatConversationBloc>().clear();

    // TL 4/1/2024: emit event đăng xuất để xóa cache
    AuthRepo().addStatus(AuthStatus.unauthenticated);
    // ignore: invalid_use_of_visible_for_testing_member
    context.read<ChatBloc>().emit(ChatStateGettingConversationId());
    await Future.delayed(const Duration(milliseconds: 300));
    var authBloc = context.read<AuthBloc>();
    authBloc.add(AuthLogoutRequest());
  }

  // static void updateListMessageUnreadWithBadge(List<dynamic> data) {
  //   //update
  //   SpUtil.putString(
  //       AppConst.LIST_MESSAGE_UNREAD, data.map((e) => e.id).toList().join(','));
  //   FlutterAppBadger.updateBadgeCount(data.length);
  // }

  static bool checkRoomIsUnReadByUser(String roomID) {
    // LIST_MESSAGE_UNREAD chứa danh sách những message chưa đọc kèm room_id
    List listRoomIDUnRead =
        SpUtil.getString(LocalStorageKey.unreadConversations, defValue: "")!
            .split(',');
    return listRoomIDUnRead.contains(roomID);
  }

  static Future<void> increaseListMessageUnreadWithBadge() async {
    // tang so luong thong bao tren app icon
    List listRoomIDUnRead =
        SpUtil.getString(LocalStorageKey.unreadConversations, defValue: "")!
            .split(',');
    // FlutterAppBadger.updateBadgeCount(listRoomIDUnRead.length + 1);
  }

  // static void decreaseListMessageUnreadWithBadge() {
  //   // giam so luong thong bao tren app icon
  //   List listRoomIDUnRead =
  //       SpUtil.getString(LocalStorageKey.unreadConversations, defValue: "")!
  //           .split(',');
  //   FlutterAppBadger.updateBadgeCount(
  //       listRoomIDUnRead.length > 0 ? listRoomIDUnRead.length - 1 : 0);
  // }

  //getInfo devices
  static Future<String?> getIDDevice() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();

    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      // print(jsonEncode(build.toMap()));
      // deviceName = "${build.brand}: ${build.model}";
      // deviceVersion = build.version.toString();
      return build.androidId; //UUID for Android
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      // deviceName = "${data.model}: ${data.name}";
      // deviceVersion = data.systemVersion;
      return data.identifierForVendor; //UUID for iOS
    }
    return null;
  }

  static CurrentUserInfoModel getCurrrentUserInfoAndUserType() {
    IUserInfo? currentUserInfo;
    UserType? currentUserType;

    try {
      final BuildContext context = navigatorKey.currentContext!;
      currentUserInfo = context.userInfo();
      currentUserType = context.userType();
    } catch (e) {
      currentUserInfo = userInfo;
      currentUserType = userType;
    }

    return CurrentUserInfoModel(
      userInfo: currentUserInfo,
      userType: currentUserType,
    );
  }
}

class CurrentUserInfoModel {
  final IUserInfo? userInfo;
  final UserType? userType;

  CurrentUserInfoModel({
    this.userInfo,
    this.userType,
  });
}
