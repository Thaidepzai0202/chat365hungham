import 'dart:async';
import 'dart:convert' show base64, utf8;
import 'dart:ui';

import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/date_time_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class GeneratorService {
  static var context = navigatorKey.currentContext!;
  static String generateMessageId(int userId, [int? tick]) =>
      (tick ?? DateTimeExt.currentServerTicks).toString() + '_$userId';

  static String generateFileName(String fileName) =>
      DateTimeExt.currentServerTicks.toString() + '-$fileName';

  /// Thay đổi tick trong messageId [number] đơn vị, giữ nguyên [senderId]
  static String addToMessageId(String genereatedId, int number) {
    var splitted = genereatedId.split('_');
    var ticks = int.parse(splitted[0]);
    var newTicks = ticks + number;
    var userId = splitted[1];
    return newTicks.toString() + '_$userId';
  }

  static String generateDialogRouteName() =>
      'DIALOG_${DateTime.now().microsecondsSinceEpoch}';

  static String generatePreviewLink(String path) {
    var genLink =
        'https://timviec365.vn/api_app/preview_file.php?url_file=${path}';

    logger.log(genLink, name: 'Generated_Preview_Link', color: StrColor.green);

    return genLink;
  }

  static Future<Uint8List> getBytesFromAsset(String path, int? width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Marker createMarker(
      LatLng position,
      String markerId, {
        Uint8List? icon,
        InfoWindow infoWindow = InfoWindow.noText,
      }) =>
      Marker(
        markerId: MarkerId(markerId),
        icon: icon != null
            ? BitmapDescriptor.fromBytes(icon)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: position,
        infoWindow: infoWindow,
      );

  static generate365Link(
      String link, {
        IUserInfo? currentUserInfo,
        UserType? currentUserType,
      }) {
    UserType? _currentUserType;
    IUserInfo? _currentUserInfo;
    bool isEmployee = link.contains('quanlychung.timviec365.vn') ||
        link.contains('chat365.timviec365.vn') ||
        link.contains('phanmemnhansu.timviec365.vn') ||
        link.contains('vanthu.timviec365.vn') ||
        link.contains('tinhluong.timviec365.vn') ||
        link.contains('kpi.timviec365.vn') ||
        link.contains('phanmemquanlykho.timviec365.vn') ||
        link.contains('phanmemdanhgiananglucnhanvien.timviec365.vn') ||
        link.contains('phanmemgiaoviec.timviec365.vn') ||
        link.contains('phanmemquanlytaisan.timviec365.vn') ||
        link.contains('phanmemsohoatailieu.timviec365.vn') ||
        link.contains('dms.timviec365.vn') ||
        link.contains('cardvisitthongminh.timviec365.vn') ||
        link.contains('chuyenvanbanthanhgiongnoi.timviec365.vn') ||
        link.contains('phanmemquanlygaraoto.timviec365.vn') ||
        link.contains('phanmemquanlykhoxaydung.timviec365.vn') ||
        link.contains('loyalty.timviec365.vn') ||
        link.contains('phanmemquanlytaichinhcongtrinh.timviec365.vn') ||
        link.contains('truyenthongnoibo.timviec365.vn');
    bool isCompany = link.contains('lichbieu.timviec365.vn') ||
        link.contains('phanmemquanlycungung.timviec365.vn') ||
        link.contains('phanmemquanlyvantai.timviec365.vn') ||
        link.contains('chamcong.timviec365.vn') ||
        link.contains('crm.timviec365.vn') ||
        link.contains('phanmemsohoatailieu.timviec365.vn') ||
        link.contains('dms.timviec365.vn') ||
        link.contains('phanmemquanlyquytrinhsanxuat.timviec365.vn');
    try {
      if (currentUserInfo != null && currentUserType != null) {
        _currentUserInfo = currentUserInfo;
        _currentUserType = currentUserType;
      } else {
        // _currentUserInfo = userInfo;
        // _currentUserType = userType;
        // if (_currentUserInfo == null) {
        _currentUserType = context.userType();
        _currentUserInfo = context.userInfo();
        // }
      }
      //link timviec
      if (link.contains('//timviec365.vn')) {
        return generateTimviecLink(link);
      }

      /// Nhân viên
      else if (_currentUserType.id == 2) {
        if (isEmployee) {
          return "https://chamcong.timviec365.vn/thong-bao.html?s=81b016d57ec189daa8e04dd2d59a22c3." +
              _currentUserInfo.id365!.toString() +
              "." +
              _currentUserInfo.password! +
              "&link=" +
              link;
        } else {
          return link;
        }
      }

      /// Công ty
      else if (_currentUserType.id == 1) {
        if (isEmployee || isCompany) {
          return "https://chamcong.timviec365.vn/thong-bao.html?s=f30f0b61e761b8926941f232ea7cccb9." +
              _currentUserInfo.id365!.toString() +
              "." +
              _currentUserInfo.password! +
              "&link=" +
              link;
        } else {
          return link;
        }
      }
    } catch (e, s) {
      logger.logError(e, s);
    }
    return link;
  }

  static generateTimviecLink(String link) {
    try {
      // var data = dataInfo.value;
      // // kiếm đâu ra cái data không có password, type thì công ty lại là khách cá nhân v
      // // gọi api lấy data bên timviec bị null chứ làm sao không có password được
      // var password = AuthRepo().userInfo?.password ?? data?.passMD5;
      // var email = data?.email ?? AuthRepo().userInfo?.email;
      // // lưu ý type nhân viên ở chat cũng truyền 0
      // var userType = AuthRepo().userType.id == 1 ? 1 : 0;
      // print(
      //     '---------data: "email:$email,pass:${password},type: ${data?.userType?.id}"');
      // if (data?.id !='-1') {
      //   return "https://timviec365.vn?token=" +
      //       base64.encode(utf8.encode("{\"email\":\"" +
      //           "$email" +
      //           "\",\"pass\":\"" +
      //           "$password" +
      //           "\",\"type\":\"$userType\",\"link_notify\":\"" +
      //           link +
      //           "\"}"))
      //       + md5.convert(utf8.encode('timviec365.vn')).toString();
      // } else {
      //   return link;
      // }
    } catch (e, s) {
      logger.logError(e, s);
    }
    return link;
  }

  static generateRaonhanhLink(String link) {
    return link;
  }
}
