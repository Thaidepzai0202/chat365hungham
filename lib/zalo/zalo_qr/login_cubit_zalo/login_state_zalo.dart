part of 'login_cubit_zalo.dart';

abstract class LoginStateZalo extends Equatable {
  const LoginStateZalo();

  @override
  List<Object> get props => [];
}
class LoginLoadingQR extends LoginStateZalo {}

class LoginSuccessQR extends LoginStateZalo {}

class LoginStateZaloInit extends LoginStateZalo {}


class LoginErrorQR extends LoginStateZalo {
  final String error;

  LoginErrorQR(this.error);
}
