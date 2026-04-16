import 'package:identity_frontend/domain/entities/profile_entity.dart';
import 'package:identity_frontend/domain/repositories/profile_repository.dart';

class ProfileUseCase {
  final ProfileRepository _repository;
  const ProfileUseCase(this._repository);

  Future<ProfileEntity> getProfile() => _repository.getProfile();
  Future<ProfileEntity> createProfile(Map<String, dynamic> data) =>
      _repository.createProfile(data);
  Future<ProfileEntity> updateProfile(Map<String, dynamic> data) =>
      _repository.updateProfile(data);
  Future<void> deleteProfile() => _repository.deleteProfile();
}