import 'package:identity_frontend/data/datasources/remote/ledger_datasource.dart';
import 'package:identity_frontend/domain/entities/ledger_entity.dart';
import 'package:identity_frontend/domain/repositories/ledger_repository.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  final LedgerRemoteDataSource _dataSource;
  const LedgerRepositoryImpl(this._dataSource);

  @override
  Future<List<LedgerRecordEntity>> getAllRecordsForEmployee(String employeeId) async {
    final models = await _dataSource.getAllRecordsForEmployee(employeeId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<LedgerRecordEntity>> getAllRecords() async {
    final models = await _dataSource.getAllRecords();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<LedgerRecordEntity> getRecord(String employeeId, String recordType) async {
    final model = await _dataSource.getRecord(employeeId, recordType);
    return model.toEntity();
  }

  @override
  Future<List<LedgerRecordEntity>> getRecordHistory(String employeeId, String recordType) async {
    final models = await _dataSource.getRecordHistory(employeeId, recordType);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<LedgerVerifyEntity> verifyRecord(String employeeId, String recordType, String hash) async {
    final model = await _dataSource.verifyRecord(employeeId, recordType, hash);
    return model.toEntity();
  }
}
