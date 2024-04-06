// import 'dart:io';
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_downloader/image_downloader.dart';
//
// extension ImageDownloaderExt on ImageDownloader{
//   static bool _initialized = false;
//   @override
//   static const MethodChannel _channel = const MethodChannel('plugins.ko2ic.com/image_downloader');
//
//   static Future<Null> initialize({bool debug = true,bool ignoreSsl = false}) async {
//     assert(!_initialized,
//     'initialize() must be called only once!');
//
//     WidgetsFlutterBinding.ensureInitialized();
//
//     final callback = PluginUtilities.getCallbackHandle(callbackDispatcher)!;
//     // await _channel.invokeMethod(
//     //     'initialize', <dynamic>[callback.toRawHandle(), debug ? 1 : 0 ,ignoreSsl? 1:0]);
//     _initialized = true;
//     return null;
//   }
//
//   static registerCallback(Function(List<String>url,int progress) callback) {
//     assert(_initialized, 'initialize() must be called first');
//
//     final callbackHandle = PluginUtilities.getCallbackHandle(callback)!;
//     assert(callbackHandle != null,
//     'callback must be a top-level or a static function');
//     _channel.invokeMethod(
//         'registerCallback', <dynamic>[callbackHandle.toRawHandle()]);
//   }
// }
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   const MethodChannel backgroundChannel =
//   MethodChannel('plugins.ko2ic.com/image_downloader');
//
//   WidgetsFlutterBinding.ensureInitialized();
//
//   backgroundChannel.setMethodCallHandler((MethodCall call) async {
//     final List<dynamic> args = call.arguments;
//     final handle = CallbackHandle.fromRawHandle(args[0]);
//     final Function? callback =
//     PluginUtilities.getCallbackFromHandle(handle);
//
//     if (callback == null) {
//       print('Fatal: could not find callback');
//       exit(-1);
//     }
//
//     final List<String> url = args[1];
//     final int progress = args[2];
//
//     callback(url, progress);
//   });
//
//   backgroundChannel.invokeMethod('didInitializeDispatcher');
// }