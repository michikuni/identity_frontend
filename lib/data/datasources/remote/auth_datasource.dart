import 'package:dio/dio.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/data/models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> signIn({required String username, required String password});
  Future<AuthModel> signUp({required String email, required String phone, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  const AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthModel> signIn({required String username, required String password}) async {
    try {
      final response = await _dio.post(
        ApiConstants.signIn,
        data: {'username': username, 'password': password},
      );
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<AuthModel> signUp({required String email, required String phone, required String password}) async {
    try {
      final response = await _dio.post(
        ApiConstants.signUp,
        data: {'email': email, 'phone': phone, 'password': password},
      );
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}