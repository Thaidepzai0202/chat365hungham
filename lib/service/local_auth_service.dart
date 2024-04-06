import 'package:bot_toast/bot_toast.dart';

import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class LocalAuth {
  static final _auth = LocalAuthentication();

  static Future<bool> _canAuthenticate() async =>
      await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

  static Future<bool> authenticate() async {
    List<BiometricType> availableBiometrics =
        await _auth.getAvailableBiometrics();
    try {
      if (!await _canAuthenticate()) return false;
      // Nếu biometric type không có vân tay thì trả về false
      if (!availableBiometrics.contains(BiometricType.fingerprint)) {
        BotToast.showText(text:'Thiết bị của không hỗ trợ chức năng này');
        return false;
      }
      ;
      return await _auth.authenticate(
          authMessages: const <AuthMessages>[
            AndroidAuthMessages(
              signInTitle: 'Sử dụng vân tay hoặc khuôn mặt để mã khóa',
              cancelButton: 'No thanks',
            ),
            IOSAuthMessages(
              cancelButton: 'No thanks',
            ),
          ],
          localizedReason: 'Sử dụng vân tay hoặc khuôn mặt để mã khóa',
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: true,
          ));
    } on PlatformException catch (e) {
      print(e);
      if (e.code == auth_error.notAvailable) {
        // Add handling of no hardware here.
        BotToast.showText(text:
            'Thiết bị không có hỗ trợ phần cứng cho sinh trắc học.');
        return false;
      } else if (e.code == auth_error.notEnrolled) {
        BotToast.showText(text:
            'Người dùng chưa đăng ký bất kỳ sinh trắc học nào trên thiết bị.');
        return false;
      } else if (e.code == auth_error.passcodeNotSet) {
        BotToast.showText(text:
            'Người dùng chưa định cấu hình mật mã (iOS) hoặc PIN/mẫu hình/mật khẩu (Android) trên thiết bị.');
        return false;
      } else if (e.code == auth_error.otherOperatingSystem) {
        BotToast.showText(text:'Hệ điều hành của thiết bị không được hỗ trợ.');
        return false;
      } else if (e.code == auth_error.lockedOut) {
        BotToast.showText(text:'Nhập sai quá nhiều lần');
        return false;
      } else if (e.code == auth_error.permanentlyLockedOut) {
        BotToast.showText(text:'Nhập sai quá nhiều lần vui lòng chờ');
        return false;
      } else if (e.code == auth_error.biometricOnlyNotSupported) {
        BotToast.showText(text:'Tham số biometricOnly không thể đúng trên Windows');
        return false;
      } else {
        BotToast.showText(text:'Lỗi không xác định');
        return false;
      }
    }
  }
}
