import 'package:dio/dio.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/core/network/api_constants.dart';
import 'package:identity_frontend/data/models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel?> fetchToday();
  Future<AttendanceModel> checkIn({String? location, String? note});
  Future<AttendanceModel> checkOut({String? location});
  Future<List<AttendanceModel>> fetchHistory(int year, int month);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio _dio;
  const AttendanceRemoteDataSourceImpl(this._dio);

  @override
  Future<AttendanceModel?> fetchToday() async {
    try {
      final res = await _dio.get(ApiConstants.attendanceToday);
      final data = res.data['data'];
      return data != null ? AttendanceModel.fromJson(data as Map<String, dynamic>) : null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<AttendanceModel> checkIn({String? location, String? note}) async {
    try {
      final res = await _dio.post(ApiConstants.attendanceCheckIn, data: {
        'location': location,
        'note': note,
      });
      return AttendanceModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<AttendanceModel> checkOut({String? location}) async {
    try {
      final res = await _dio.post(ApiConstants.attendanceCheckOut, data: {
        'location': location,
      });
      return AttendanceModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<AttendanceModel>> fetchHistory(int year, int month) async {
    try {
      final res = await _dio.get('${ApiConstants.attendance}?year=$year&month=$month');
      final list = res.data['data'] as List? ?? [];
      return list.map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
