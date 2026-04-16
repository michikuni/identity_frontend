import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String role;
  final String token;

  const AuthEntity({
    required this.id,
    required this.email,
    this.phone,
    required this.role,
    required this.token,
  });

  @override
  List<Object?> get props => [id, email, phone, role, token];
}