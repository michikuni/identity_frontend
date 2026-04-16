import 'package:dio/dio.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/data/models/directory_model.dart';

abstract class DirectoryRemoteDataSource {
  Future<List<DirectoryModel>> fetchAll();
  Future<DirectoryModel> fetchById(int id);
}

class DirectoryRemoteDataSourceImpl implements DirectoryRemoteDataSource {
  final Dio _dio;
  const DirectoryRemoteDataSourceImpl(this._dio);

  @override
  Future<List<DirectoryModel>> fetchAll() async {
    try {
      final res = await _dio.get(ApiConstants.directory);
      final list = res.data['data'] as List? ?? [];
      return list.map((e) => DirectoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<DirectoryModel> fetchById(int id) async {
    try {
      final res = await _dio.get('${ApiConstants.directory}/$id');
      return DirectoryModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
