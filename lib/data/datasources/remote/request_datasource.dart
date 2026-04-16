import 'package:dio/dio.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/data/models/request_model.dart';

abstract class RequestRemoteDataSource {
  Future<List<RequestModel>> fetchMyRequests();
  Future<RequestModel> createRequest(Map<String, dynamic> data);
  Future<RequestModel> approve(int requestId);
  Future<RequestModel> reject(int requestId, String reason);
  Future<List<RequestModel>> fetchSubordinateRequests();
}

class RequestRemoteDataSourceImpl implements RequestRemoteDataSource {
  final Dio _dio;
  const RequestRemoteDataSourceImpl(this._dio);

  @override
  Future<List<RequestModel>> fetchMyRequests() async {
    try {
      final res = await _dio.get(ApiConstants.requests);
      final list = res.data['data'] as List? ?? [];
      return list.map((e) => RequestModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<RequestModel> createRequest(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(ApiConstants.requests, data: data);
      return RequestModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<RequestModel> approve(int requestId) async {
    try {
      final res = await _dio.put('${ApiConstants.managerRequests}/$requestId/approve');
      return RequestModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<RequestModel> reject(int requestId, String reason) async {
    try {
      final res = await _dio.put(
        '${ApiConstants.managerRequests}/$requestId/reject',
        data: {'reason': reason},
      );
      return RequestModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<RequestModel>> fetchSubordinateRequests() async {
    try {
      final res = await _dio.get(ApiConstants.managerRequests);
      final list = res.data['data'] as List? ?? [];
      return list.map((e) => RequestModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
