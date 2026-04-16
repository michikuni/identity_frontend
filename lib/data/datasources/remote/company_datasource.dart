import 'package:dio/dio.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/data/models/company_model.dart';

abstract class CompanyRemoteDataSource {
  Future<CompanyModel?> fetchCompany();
  Future<CompanyModel> saveCompany(Map<String, dynamic> data, {bool isNew = false});
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final Dio _dio;
  const CompanyRemoteDataSourceImpl(this._dio);

  @override
  Future<CompanyModel?> fetchCompany() async {
    try {
      final res = await _dio.get(ApiConstants.company);
      final data = res.data['data'];
      return data != null ? CompanyModel.fromJson(data as Map<String, dynamic>) : null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<CompanyModel> saveCompany(Map<String, dynamic> data, {bool isNew = false}) async {
    try {
      final res = isNew
          ? await _dio.post(ApiConstants.company, data: data)
          : await _dio.put(ApiConstants.company, data: data);
      return CompanyModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
