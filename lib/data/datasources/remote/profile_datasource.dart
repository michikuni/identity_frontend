import 'package:dio/dio.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/data/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> createProfile(Map<String, dynamic> data);
  Future<ProfileModel> updateProfile(Map<String, dynamic> data);
  Future<void> deleteProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;
  const ProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ProfileModel> createProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.profile, data: data);
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiConstants.profile, data: data);
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteProfile() async {
    try {
      await _dio.delete(ApiConstants.profile);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}