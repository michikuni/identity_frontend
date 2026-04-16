import 'package:dio/dio.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/data/models/contract_model.dart';

abstract class ContractRemoteDataSource {
  Future<ContractModel> getContract();
  Future<ContractModel> createContract(Map<String, dynamic> data);
  Future<ContractModel> updateContract(Map<String, dynamic> data);
  Future<void> deleteContract();
}

class ContractRemoteDataSourceImpl implements ContractRemoteDataSource {
  final Dio _dio;
  const ContractRemoteDataSourceImpl(this._dio);

  @override
  Future<ContractModel> getContract() async {
    try {
      final response = await _dio.get(ApiConstants.contracts);
      return ContractModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ContractModel> createContract(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.contracts, data: data);
      return ContractModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ContractModel> updateContract(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiConstants.contracts, data: data);
      return ContractModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteContract() async {
    try {
      await _dio.delete(ApiConstants.contracts);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}