import 'package:identity_frontend/domain/entities/ledger_entity.dart';

abstract class LedgerRepository {
  Future<List<LedgerRecordEntity>> getAllRecordsForEmployee(String employeeId);
  Future<List<LedgerRecordEntity>> getAllRecords();
  Future<LedgerRecordEntity> getRecord(String employeeId, String recordType);
  Future<List<LedgerRecordEntity>> getRecordHistory(String employeeId, String recordType);
  Future<LedgerVerifyEntity> verifyRecord(String employeeId, String recordType, String hash);
}