import 'package:equatable/equatable.dart';

class LedgerRecordEntity extends Equatable {
  final String recordId;
  final String employeeId;
  final String recordType;
  final String status;
  final String? keyFields;
  final String? dataHash;
  final String action;
  final String? timestamp;
  final String? updatedBy;

  const LedgerRecordEntity({
    required this.recordId,
    required this.employeeId,
    required this.recordType,
    required this.status,
    this.keyFields,
    this.dataHash,
    required this.action,
    this.timestamp,
    this.updatedBy,
  });

  @override
  List<Object?> get props => [recordId, employeeId, recordType, status];
}

class LedgerVerifyEntity extends Equatable {
  final bool valid;
  final String reason;
  final String recordId;
  final String storedHash;
  final String providedHash;
  final String? timestamp;

  const LedgerVerifyEntity({
    required this.valid,
    required this.reason,
    required this.recordId,
    required this.storedHash,
    required this.providedHash,
    this.timestamp,
  });

  @override
  List<Object?> get props => [valid, recordId];
}