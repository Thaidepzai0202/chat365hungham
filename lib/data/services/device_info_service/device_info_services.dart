import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  static DeviceInfoService? _instance;

  factory DeviceInfoService() => _instance ??= DeviceInfoService._();

  DeviceInfoService._() {}

  late final BaseDeviceInfo baseDeviceInfo;

  String? macosSystemVersion;

  init() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isMacOS) {
      baseDeviceInfo = await deviceInfo.macOsInfo;
      // logger.log(baseDeviceInfo.toMap(), name: 'baseDeviceInfo');
    } else if (Platform.isWindows) {
      baseDeviceInfo = await deviceInfo.windowsInfo;

      // logger.log(baseDeviceInfo.toMap(), name: 'baseDeviceInfo');
    } else
      baseDeviceInfo = await deviceInfo.deviceInfo;
  }
}
