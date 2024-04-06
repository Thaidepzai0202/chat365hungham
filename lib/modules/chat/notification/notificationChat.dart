import 'dart:io';

import 'package:app_chat365_pc/common/images.dart';
import 'package:flutter/material.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';
// import 'package:windows_notification_example/templates/alarm_template.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
// import 'package:windows_notification_example/templates/meeting_template.dart';


// Create an instance of Windows Notification with your application name
// application id must be null in packaged mode
final winNotifyPlugin = WindowsNotification(applicationId: "Chat365PC");

Future<String> getImageBytes(String url) async {
  final supportDir = await getApplicationSupportDirectory();
  final cl = http.Client();
  final resp = await cl.get(Uri.parse(url));
  final bytes = resp.bodyBytes;
  final imageFile =
      File("${supportDir.path}/${DateTime.now().millisecond}.png");
  await imageFile.create();
  await imageFile.writeAsBytes(bytes);
  return imageFile.path;
}

void showWithSmallImage(String conversationName,
    String senderName, String messageSender, String linkOpenApp) async {
  String url =
      'https://1.bp.blogspot.com/-TUou6-0_AD0/XrP7P1RjyjI/AAAAAAAAkgw/luXEsKHPbzsXnfwJ2haZKJWQL1lmmQ11wCLcBGAsYHQ/s1600/Avatar-Dep-Nu%2B%25283%2529.jpg';

  final imageDir = await getImageBytes(url);

  NotificationMessage message = NotificationMessage.fromPluginTemplate(
      conversationName, conversationName, "${senderName}: ${messageSender}",
      image: imageDir, launch: linkOpenApp);
  winNotifyPlugin.showNotificationPluginTemplate(message);
}

void showWithLargeImage(
    String linkIcon,String conversationName, String senderName, String linkOpenApp) async {
  String url = linkIcon;

  final imageDir = await getImageBytes(url);

  NotificationMessage message = NotificationMessage.fromPluginTemplate(
    'dell biet no la cai gi',
    conversationName,
    "${senderName} đã gửi một nhãn dán",
    largeImage: imageDir,
    launch: linkOpenApp,
  );
  winNotifyPlugin.showNotificationPluginTemplate(message);
}
void showWithLargeImageSendImage(
    String linkIcon, String conversationName,String senderName, String linkOpenApp) async {
  String url = linkIcon;

    final imageDir = await getImageBytes(url);

  NotificationMessage message = NotificationMessage.fromPluginTemplate(
    'dell biet no la cai gi',
    conversationName,
    "${senderName}Đã gửi một nhãn dán",
    largeImage: linkIcon,
    launch: linkOpenApp,
  );
  winNotifyPlugin.showNotificationPluginTemplate(message);
}

// show notification    
