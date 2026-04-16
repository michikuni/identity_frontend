import 'package:dio/dio.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/data/models/employee_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<EmployeeModel> getEmployee();
  Future<EmployeeModel> createEmployee(Map<String, dynamic> data);
  Future<EmployeeModel> updateEmployee(Map<String, dynamic> data);
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final Dio _dio;
  const EmployeeRemoteDataSourceImpl(this._dio);

  @override
  Future<EmployeeModel> getEmployee() async {
    try {
      final response = await _dio.get(ApiConstants.employee);
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<EmployeeModel> createEmployee(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.employee, data: data);
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<EmployeeModel> updateEmployee(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiConstants.employee, data: data);
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}