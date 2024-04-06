import 'dart:io';

import 'package:app_chat365_pc/core/constants/app_constants.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  static bool _isFileSizeGreaterThanMb(File file, double megabyte) =>
      file.sizeInMb > megabyte;

  static bool isImageFileSizeGreaterThanMb(
    File file, [
    double megabyte = AppConst.maxImageSizeInMb,
  ]) =>
      _isFileSizeGreaterThanMb(file, megabyte);

  static bool isImageFileSizeSmallerOrEqualThanMb(
    File file, [
    double megabyte = AppConst.maxImageSizeInMb,
  ]) =>
      _isFileSizeGreaterThanMb(file, megabyte) == false;

  static bool isFileSizeGreaterThanMb(
    File file, [
    double megabyte = AppConst.maxFileSizeInMb,
  ]) =>
      _isFileSizeGreaterThanMb(file, megabyte);

  static String getFileExtensionFromFileName(String filename) =>
      filename.substring(filename.lastIndexOf('.'));

  static String getFileExtensionFromFile(File file) => file.ext;

  static String getUniqueFile(String folderName, final String? fileName) {
    int num = 1;

    String destFileName =
        fileName ?? '${DateTime.now().millisecondsSinceEpoch}';

    String ext = path.extension(destFileName);
    String baseName = path.basenameWithoutExtension(destFileName);

    File file = File(folderName + path.separator + destFileName);
    while (file.existsSync()) {
      try {
        var gex = RegExp(r'\(\d+\)');
        // print(gex.hasMatch(baseName));
        var match = gex.allMatches(baseName).last;
        String matchValue = gex.allMatches(baseName).last[0].toString();
        int matchReplace =
            int.parse(matchValue.substring(1, matchValue.length - 1)) + 1;
        baseName =
            baseName.replaceRange(match.start, match.end, '($matchReplace)');
        destFileName = '$baseName$ext';
      } catch (e) {
        destFileName = '$baseName (${num++})$ext';
      }
      file = File(folderName + path.separator + destFileName);
    }
    print('$destFileName - ${file.existsSync()}');
    return destFileName;
  }

  /*
  static File renameFileFollowApiFormat(File file, [String? fileName]) {
    return file.renameSync(
        "${file.pathOnly}${TimeUtils.currentTicks}-${fileName ?? file.name}");
  }
  */
}

extension FileExt on File {
  String get name => absolute.path.split(Platform.pathSeparator).last;

  String get nameOnly {
    final nameWithExt = name;

    return nameWithExt.substring(0, nameWithExt.lastIndexOf('.'));
  }

  /// file extension
  String get ext => FileUtils.getFileExtensionFromFileName(name);

  String get pathOnly =>
      absolute.path.substring(0, absolute.path.lastIndexOf('/') + 1);

  int get lengthInBytes => readAsBytesSync().lengthInBytes;

  /// size in megabyte
  double get sizeInMb => lengthInBytes / 1024 / 1024;

  // File addCurrentTicksToFileName(String suffixNameWithoutExt) {
  //   // we do not need package `path_provider` 'cause `image_picker` read file to cache
  //   final String filename =
  //       TimeUtils.currentTicks.toString() + suffixNameWithoutExt + ext;

  //   return copySync("$pathOnly$filename");
  // }
}
