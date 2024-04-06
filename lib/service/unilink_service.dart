// import 'dart:async';

// import 'package:flutter/services.dart' show PlatformException;
// import 'package:uni_links/uni_links.dart';

// class uniLinkService {
//   bool _initialUriIsHandled = false;
//   StreamSubscription? sub;
//   void handleIncomingLinks() {
//     {
//       // It will handle app links while the app is already started - be it in
//       // the foreground or in the background.
//       sub = uriLinkStream.listen((Uri? uri) {
//         print('got uri: $uri');
//       }, onError: (Object err) {
//         print('got err: $err');
//       });
//     }
//   }

//   Future<void> handleInitialUri() async {
//     // In this example app this is an almost useless guard, but it is here to
//     // show we are not going to call getInitialUri multiple times, even if this
//     // was a weidget that will be disposed of (ex. a navigation route change).
//     if (!_initialUriIsHandled) {
//       _initialUriIsHandled = true;
//       try {
//         final uri = await getInitialUri();
//         if (uri == null) {
//           print('no initial uri');
//         } else {
//           print('got initial uri: $uri');
//         }
//       } on PlatformException {
//         // Platform messages may fail but we ignore the exception
//         print('falied to get initial uri');
//       } on FormatException {
//         print('malformed initial uri');
//       }
//     }
//   }
// }
