import 'package:identity_frontend/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> createProfile(Map<String, dynamic> data);
  Future<ProfileEntity> updateProfile(Map<String, dynamic> data);
  Future<void> deleteProfile();
}