import 'package:identity_frontend/data/datasources/remote/profile_datasource.dart';
import 'package:identity_frontend/domain/entities/profile_entity.dart';
import 'package:identity_frontend/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;
  const ProfileRepositoryImpl(this._dataSource);

  @override
  Future<ProfileEntity> getProfile() async {
    final model = await _dataSource.getProfile();
    return model.toEntity();
  }

  @override
  Future<ProfileEntity> createProfile(Map<String, dynamic> data) async {
    final model = await _dataSource.createProfile(data);
    return model.toEntity();
  }

  @override
  Future<ProfileEntity> updateProfile(Map<String, dynamic> data) async {
    final model = await _dataSource.updateProfile(data);
    return model.toEntity();
  }

  @override
  Future<void> deleteProfile() => _dataSource.deleteProfile();
}
