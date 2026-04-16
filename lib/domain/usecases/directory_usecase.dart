import 'package:identity_frontend/domain/entities/directory_entity.dart';
import 'package:identity_frontend/data/datasources/remote/directory_datasource.dart';

class DirectoryUseCase {
  final DirectoryRemoteDataSource _dataSource;
  const DirectoryUseCase(this._dataSource);

  Future<List<DirectoryEntity>> getAll() async {
    final list = await _dataSource.fetchAll();
    return list.map((m) => m.toEntity()).toList();
  }

  Future<DirectoryEntity> getById(int id) async {
    final model = await _dataSource.fetchById(id);
    return model.toEntity();
  }
}
