import 'package:identity_frontend/domain/entities/attendance_entity.dart';
import 'package:identity_frontend/data/datasources/remote/attendance_datasource.dart';

class AttendanceUseCase {
  final AttendanceRemoteDataSource _dataSource;
  const AttendanceUseCase(this._dataSource);

  Future<AttendanceEntity?> getToday() async {
    final model = await _dataSource.fetchToday();
    return model?.toEntity();
  }

  Future<AttendanceEntity> checkIn({String? location, String? note}) async {
    final model = await _dataSource.checkIn(location: location, note: note);
    return model.toEntity();
  }

  Future<AttendanceEntity> checkOut({String? location}) async {
    final model = await _dataSource.checkOut(location: location);
    return model.toEntity();
  }

  Future<List<AttendanceEntity>> getHistory(int year, int month) async {
    final list = await _dataSource.fetchHistory(year, month);
    return list.map((m) => m.toEntity()).toList();
  }
}
