import 'package:dio/dio.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/data/models/ledger_model.dart';

abstract class LedgerRemoteDataSource {
  Future<List<LedgerRecordModel>> getAllRecordsForEmployee(String employeeId);
  Future<List<LedgerRecordModel>> getAllRecords();
  Future<LedgerRecordModel> getRecord(String employeeId, String recordType);
  Future<List<LedgerRecordModel>> getRecordHistory(String employeeId, String recordType);
  Future<LedgerVerifyModel> verifyRecord(String employeeId, String recordType, String hash);
}

class LedgerRemoteDataSourceImpl implements LedgerRemoteDataSource {
  final Dio _dio;
  const LedgerRemoteDataSourceImpl(this._dio);

  @override
  Future<List<LedgerRecordModel>> getAllRecordsForEmployee(String employeeId) async {
    try {
      final response = await _dio.get('${ApiConstants.ledgerRecords}/$employeeId');
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>? ?? [];
      return data.map((e) => LedgerRecordModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<LedgerRecordModel>> getAllRecords() async {
    try {
      final response = await _dio.get(ApiConstants.ledgerRecords);
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>? ?? [];
      return data.map((e) => LedgerRecordModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<LedgerRecordModel> getRecord(String employeeId, String recordType) async {
    try {
      final response = await _dio.get('${ApiConstants.ledgerRecords}/$employeeId/$recordType');
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return LedgerRecordModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<LedgerRecordModel>> getRecordHistory(String employeeId, String recordType) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.ledgerRecords}/$employeeId/$recordType/history',
      );
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>? ?? [];
      return data.map((e) => LedgerRecordModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<LedgerVerifyModel> verifyRecord(String employeeId, String recordType, String hash) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.ledgerRecords}/$employeeId/$recordType/verify',
        queryParameters: {'hash': hash},
      );
      return LedgerVerifyModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}