import 'package:identity_frontend/domain/entities/request_entity.dart';
import 'package:identity_frontend/data/datasources/remote/request_datasource.dart';

class RequestUseCase {
  final RequestRemoteDataSource _dataSource;
  const RequestUseCase(this._dataSource);

  Future<List<RequestEntity>> getMyRequests() async {
    final list = await _dataSource.fetchMyRequests();
    return list.map((m) => m.toEntity()).toList();
  }

  Future<RequestEntity> createRequest(Map<String, dynamic> data) async {
    final model = await _dataSource.createRequest(data);
    return model.toEntity();
  }

  Future<RequestEntity> approve(int requestId) async {
    final model = await _dataSource.approve(requestId);
    return model.toEntity();
  }

  Future<RequestEntity> reject(int requestId, String reason) async {
    final model = await _dataSource.reject(requestId, reason);
    return model.toEntity();
  }

  Future<List<RequestEntity>> getSubordinateRequests() async {
    final list = await _dataSource.fetchSubordinateRequests();
    return list.map((m) => m.toEntity()).toList();
  }
}
