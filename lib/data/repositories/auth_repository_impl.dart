import 'package:identity_frontend/data/datasources/remote/auth_datasource.dart';
import 'package:identity_frontend/domain/entities/auth_entity.dart';
import 'package:identity_frontend/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<AuthEntity> signIn({required String username, required String password}) async {
    final model = await _dataSource.signIn(username: username, password: password);
    return model.toEntity();
  }

  @override
  Future<AuthEntity> signUp({required String email, required String phone, required String password}) async {
    final model = await _dataSource.signUp(email: email, phone: phone, password: password);
    return model.toEntity();
  }
}
