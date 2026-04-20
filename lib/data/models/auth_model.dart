import 'package:identity_frontend/domain/entities/auth_entity.dart';

class AuthModel {
  final String? id;
  final String? email;
  final String? phone;
  final String? role;
  final String token;

  const AuthModel({
    this.id,
    this.email,
    this.phone,
    this.role,
    required this.token,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] as String? ?? '',
      id: json['id'] as String?,
      role: json['role'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  AuthEntity toEntity() => AuthEntity(
        id: id ?? '',
        email: email ?? '',
        phone: phone,
        role: role ?? 'EMPLOYEE',
        token: token,
      );
}