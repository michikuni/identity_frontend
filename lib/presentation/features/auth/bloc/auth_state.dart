part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, signedUp, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? auth;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.auth,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? auth,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      auth: auth ?? this.auth,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, auth, errorMessage];
}
