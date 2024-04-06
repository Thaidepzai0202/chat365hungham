// import 'package:app_chat365_pc/router/app_pages.dart';
// import 'package:app_chat365_pc/router/app_route_observer.dart';
// import 'package:app_chat365_pc/router/app_router.dart';
// import 'package:app_chat365_pc/utils/helpers/logger.dart';
// import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// class MapService {
//   static const key = "AIzaSyCmAUhuDeHY3HjgwKLdvm0rpsoyS6JmF9U";

//   // static const apiKey = "AIzaSyCJqpC7oo-YYJJ1pRVZJgf84qExlHZCWSc";
//   static const dirApiKey = "AIzaSyA66KwUrjxcFG5u0exynlJ45CrbrNe3hEc";
//   static const apiKey = "AIzaSyA66KwUrjxcFG5u0exynlJ45CrbrNe3hEc";

//   static MapService? _instance;

//   factory MapService() => _instance ??= MapService._();

//   MapService._() {}

//   Future init() async {
//     _position = await getCurrentLocation();
//   }

//   Future<LatLng?> getCurrentLocation() async {
//     // bool serviceEnabled;
//     LocationPermission permission;

//     // Test if location services are enabled.
//     final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are not enabled don't continue
//       // accessing the position and request users of the
//       // App to enable the location services.
//       // BotToast.showText(text:'Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       // try {
//       //   await _toLocationPermissionPage();
//       //   permission = await Geolocator.checkPermission();
//       // } catch (e, s) {
//       //   logger.logError(e, s);
//       permission = await Geolocator.requestPermission();
//       // }

//       // if (permission == LocationPermission.denied) {
//       //   // Permissions are denied, next time you could try
//       //   // requesting permissions again (this is also where
//       //   // Android's shouldShowRequestPermissionRationale
//       //   // returned true. According to Android guidelines
//       //   // your App should show an explanatory UI now.
//       //   // BotToast.showText(text:'Location permissions are denied');
//       // }
//     }
//     try {
//       return await _onLocationPermissionGranted();
//     } catch (e, s) {
//       logger.logError('Lấy vị trí thất bại');
//       logger.logError(e, s, 'MapServiceGetLocationError');
//     }
//     return null;
//   }

//   /// Cấp quyền truy cập camera
//   // Future<LatLng?> getCurrentCamera() async {
//   //   bool serviceEnabled;
//   //   LocationPermission permission;

//   //   // Test if location services are enabled.
//   //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   //   if (!serviceEnabled) {
//   //     // Location services are not enabled don't continue
//   //     // accessing the position and request users of the
//   //     // App to enable the location services.
//   //     // BotToast.showText(text:'Location services are disabled.');
//   //   }

//   //   permission = await Geolocator.checkPermission();
//   //   if (permission == LocationPermission.denied) {
//   //     try {
//   //       await _toLocationPermissionPage();
//   //       permission = await Geolocator.checkPermission();
//   //     } catch (e, s) {
//   //       logger.logError(e, s);
//   //       permission = await Geolocator.requestPermission();
//   //     }

//   //     if (permission == LocationPermission.denied) {
//   //       // Permissions are denied, next time you could try
//   //       // requesting permissions again (this is also where
//   //       // Android's shouldShowRequestPermissionRationale
//   //       // returned true. According to Android guidelines
//   //       // your App should show an explanatory UI now.
//   //       // BotToast.showText(text:'Location permissions are denied');
//   //     }
//   //   }

//   //   if (permission == LocationPermission.deniedForever) {
//   //     // Permissions are denied forever, handle appropriately.
//   //     try {
//   //       return await _toCameraPermissionPage();
//   //     } catch (e) {
//   //       // BotToast.showText(text:
//   //       //     'Location permissions are permanently denied, we cannot request permissions.');
//   //     }
//   //   }
//   //   try {
//   //     return await _toCameraPermissionPage();
//   //   } catch (e) {}
//   //   return null;
//   // }

//   /// check cấp quyền camera
//   // Future _toCameraPermissionPage() async {
//   //   return await Navigator.of(navigatorKey.currentContext!).push(
//   //     MaterialPageRoute(
//   //       builder: (_) => CameraPermissionPage(
//   //         callBack: _onCameraPermissionGranted,
//   //       ),
//   //     ),
//   //   );
//   // }

//   Future<LatLng> _onLocationPermissionGranted() async {
//     Position p = await GeolocatorPlatform.instance.getCurrentPosition(
//       locationSettings: LocationSettings(
//         accuracy: LocationAccuracy.best,
//         distanceFilter: 5,
//         timeLimit: Duration(seconds: 15),
//       ),
//     );
//     logger.log(p, name: 'CurrentLocation');

//     return LatLng(
//       p.latitude,
//       p.longitude,
//     );
//   }
//   /// lấy vị trí hiện tại của người dùng
//    displayCurrentLocation() async {
//     var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     return LatLng(
//       position.latitude,
//       position.longitude,
//     );
//   }
//   ///Cấp quyền truy cập camera
//   // Future<LatLng> _onCameraPermissionGranted() async {
//   //   var p = await GeolocatorPlatform.instance.getCurrentPosition(
//   //     locationSettings: LocationSettings(
//   //       accuracy: LocationAccuracy.best,
//   //       distanceFilter: 5,
//   //       timeLimit: Duration(seconds: 2),
//   //     ),
//   //   );
//   //   logger.log(p, name: 'CurrentLocation');
//   //   return LatLng(
//   //     p.latitude,
//   //     p.longitude,
//   //   );
//   // }

//   LatLng? _position;

//   LatLng get position {
//     var _defaultLatLng = LatLng(
//       14.0583,
//       108.2772,
//     );
//     return _position ?? _defaultLatLng;
//   }

// }
