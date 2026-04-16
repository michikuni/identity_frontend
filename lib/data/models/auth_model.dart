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
    // Response wraps data, token is at top level
    final token = json['token'] as String? ?? '';
    final data = json['data'] as Map<String, dynamic>?;

    if (data != null) {
      final idMap = data['id'] as Map<String, dynamic>?;
      return AuthModel(
        id: idMap?['value'] as String?,
        email: data['email'] as String?,
        phone: data['phone'] as String?,
        role: data['role'] as String?,
        token: token,
      );
    }

    return AuthModel(token: token);
  }

  AuthEntity toEntity() => AuthEntity(
        id: id ?? '',
        email: email ?? '',
        phone: phone,
        role: role ?? 'EMPLOYEE',
        token: token,
      );
}