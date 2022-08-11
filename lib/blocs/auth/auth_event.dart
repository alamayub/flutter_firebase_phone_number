part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogin extends AuthEvent {
  final String mobile;
  const AuthEventLogin(this.mobile);
}

class AuthEventVerifyOtp extends AuthEvent {
  final String otp;
  const AuthEventVerifyOtp({required this.otp});
}
class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}
