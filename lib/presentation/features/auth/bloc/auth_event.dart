part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SignInSubmitted extends AuthEvent {
  final String username;
  final String password;
  const SignInSubmitted({required this.username, required this.password});
  @override
  List<Object?> get props => [username, password];
}

class SignUpSubmitted extends AuthEvent {
  final String email;
  final String phone;
  final String password;
  const SignUpSubmitted({required this.email, required this.phone, required this.password});
  @override
  List<Object?> get props => [email, phone, password];
}

class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}
