import 'package:identity_frontend/domain/entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> signIn({required String username, required String password});
  Future<AuthEntity> signUp({required String email, required String phone, required String password});
}