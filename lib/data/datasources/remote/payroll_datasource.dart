import 'package:dio/dio.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/data/models/payroll_model.dart';

abstract class PayrollRemoteDataSource {
  Future<PayrollModel> getPayroll();
  Future<PayrollModel> createPayroll(Map<String, dynamic> data);
  Future<PayrollModel> updatePayroll(Map<String, dynamic> data);
  Future<void> deletePayroll();
}

class PayrollRemoteDataSourceImpl implements PayrollRemoteDataSource {
  final Dio _dio;
  const PayrollRemoteDataSourceImpl(this._dio);

  @override
  Future<PayrollModel> getPayroll() async {
    try {
      final response = await _dio.get(ApiConstants.payroll);
      return PayrollModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<PayrollModel> createPayroll(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.payroll, data: data);
      return PayrollModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<PayrollModel> updatePayroll(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiConstants.payroll, data: data);
      return PayrollModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deletePayroll() async {
    try {
      await _dio.delete(ApiConstants.payroll);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}