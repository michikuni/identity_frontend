import 'package:identity_frontend/domain/entities/ledger_entity.dart';
import 'package:identity_frontend/domain/repositories/ledger_repository.dart';

class LedgerUseCase {
  final LedgerRepository _repository;
  const LedgerUseCase(this._repository);

  Future<List<LedgerRecordEntity>> getAllRecordsForEmployee(String employeeId) =>
      _repository.getAllRecordsForEmployee(employeeId);

  Future<List<LedgerRecordEntity>> getAllRecords() =>
      _repository.getAllRecords();

  Future<LedgerRecordEntity> getRecord(String employeeId, String recordType) =>
      _repository.getRecord(employeeId, recordType);

  Future<List<LedgerRecordEntity>> getRecordHistory(
          String employeeId, String recordType) =>
      _repository.getRecordHistory(employeeId, recordType);

  Future<LedgerVerifyEntity> verifyRecord(
          String employeeId, String recordType, String hash) =>
      _repository.verifyRecord(employeeId, recordType, hash);
}