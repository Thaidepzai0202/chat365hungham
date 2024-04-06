import 'dart:io';

import 'package:app_chat365_pc/data/services/device_info_service/device_info_services.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:permission_handler/permission_handler.dart';
extension PermissionExt on Permission {
  String get name {
    var str = this.toString();
    if (this == Permission.camera)
      str = 'Máy ảnh';
    else if (this == Permission.mediaLibrary ||
        this == Permission.accessMediaLocation)
      str = 'Thư viện';
    else if (this == Permission.manageExternalStorage)
      str = 'Bộ nhớ ngoài';
    else if (this == Permission.contacts) str = 'Danh bạ';
    return str;
  }

  AppPages get page {
    // if (this == Permission.contacts) return AppPages.Contact_Permission;

    throw Exception('Không tìm thấy PermissionPage ứng với $this permission');
  }

  static Permission get photoPermission =>
      Platform.isIOS ? Permission.photos : Permission.accessMediaLocation;
  static Permission get libraryPermission =>
      Platform.isIOS ? Permission.mediaLibrary : Permission.accessMediaLocation;

  // static openLibraryPermissionSetting() => AppSettings.openAppSettings();

  // static Permission get downloadPermission {
  //   var version = Platform.isIOS
  //       ? DeviceInfoService().macosSystemVersion
  //       : DeviceInfoService().androidSdkInt!;
  //   // : version >= 29
  //   //     ? PermissionExt.downloadPermission
  //   //     : PermissionExt.downloadPermission;
  //   if (Platform.isIOS) {
  //     logger.log(
  //       'iosSystemVersion: $version',
  //       name: 'DownloadPermission',
  //     );
  //     return Permission.mediaLibrary;
  //   } else {
  //     logger.log(
  //       'androidSdkInt: $version',
  //       name: 'DownloadPermission',
  //     );
  //     // int androidVersion = DeviceInfoService().androidSdkInt!;
  //     // return androidVersion >= 33 ? Permission.photos : Permission.storage;
  //   }
  // }

  // static Permission get downloadImagePermission {
    // var version = Platform.isIOS
        // ? DeviceInfoService().macosSystemVersion
        // : DeviceInfoService().androidSdkInt!;
    // var permission = Platform.isIOS
    //     ? Permission.photosAddOnly
    //     : PermissionExt.downloadPermission;
    // : version >= 29
    //     ? PermissionExt.downloadPermission
    //     : PermissionExt.downloadPermission;
    // if (Platform.isIOS) {
      // logger.log(
      //   'iosSystemVersion: $version: $permission',
      //   name: 'DownloadImagePermission',
      // );
    // } else {
    //   logger.log(
    //     'androidSdkInt: $version: $permission',
    //     name: 'DownloadImagePermission',
    //   );
    // }
    // return permission;
  // }

  // static Permission get openFilePermission => PermissionExt.downloadPermission;

  /// isPermanentlyDenied,
  ///
  /// isRestricted,
  ///
  /// isDenied,
  ///
  /// isGranted,
  ///
  /// isLimited,
  ///
  Future<List<bool>> get statuses => Future.wait([
    isPermanentlyDenied,
    isRestricted,
    isDenied,
    isGranted,
    isLimited,
  ]);

  Future<bool> get isAccepted async => await isGranted || await isLimited;

  Future<bool> get isDisabled async =>
      await isPermanentlyDenied || await isRestricted || await isDenied;
}

extension PermissionStatusExt on PermissionStatus {
  bool get isAccepted => isGranted || isLimited;

  bool get isDisabled => isPermanentlyDenied || isRestricted || isDenied;
}
