import 'package:identity_frontend/domain/entities/auth_entity.dart';
import 'package:identity_frontend/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;
  const SignUpUseCase(this._repository);

  Future<AuthEntity> call({
    required String email,
    required String phone,
    required String password,
  }) {
    return _repository.signUp(email: email, phone: phone, password: password);
  }
}