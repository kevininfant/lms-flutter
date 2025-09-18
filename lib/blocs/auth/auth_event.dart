import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  RegisterRequested(this.email, this.password);
}

class LogoutRequested extends AuthEvent {}

class ForgetPasswordRequested extends AuthEvent {
  final String email;

  ForgetPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyOTPRequested extends AuthEvent {
  final String otp;

  VerifyOTPRequested(this.otp);

  @override
  List<Object?> get props => [otp];
}
