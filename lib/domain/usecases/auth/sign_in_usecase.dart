import 'package:identity_frontend/domain/entities/auth_entity.dart';
import 'package:identity_frontend/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;
  const SignInUseCase(this._repository);

  Future<AuthEntity> call({required String username, required String password}) {
    return _repository.signIn(username: username, password: password);
  }
}