import 'package:identity_frontend/domain/entities/ledger_entity.dart';

class LedgerRecordModel {
  final String? recordId;
  final String? employeeId;
  final String? recordType;
  final String? status;
  final String? keyFields;
  final String? dataHash;
  final String? action;
  final String? timestamp;
  final String? updatedBy;

  const LedgerRecordModel({
    this.recordId,
    this.employeeId,
    this.recordType,
    this.status,
    this.keyFields,
    this.dataHash,
    this.action,
    this.timestamp,
    this.updatedBy,
  });

  factory LedgerRecordModel.fromJson(Map<String, dynamic> json) {
    return LedgerRecordModel(
      recordId: json['recordId'] as String?,
      employeeId: json['employeeId'] as String?,
      recordType: json['recordType'] as String?,
      status: json['status'] as String?,
      keyFields: json['keyFields'] as String?,
      dataHash: json['dataHash'] as String?,
      action: json['action'] as String?,
      timestamp: json['timestamp'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  LedgerRecordEntity toEntity() => LedgerRecordEntity(
        recordId: recordId ?? '',
        employeeId: employeeId ?? '',
        recordType: recordType ?? '',
        status: status ?? 'ACTIVE',
        keyFields: keyFields,
        dataHash: dataHash,
        action: action ?? 'CREATE',
        timestamp: timestamp,
        updatedBy: updatedBy,
      );
}

class LedgerVerifyModel {
  final bool valid;
  final String? reason;
  final String? recordId;
  final String? storedHash;
  final String? providedHash;
  final String? timestamp;

  const LedgerVerifyModel({
    required this.valid,
    this.reason,
    this.recordId,
    this.storedHash,
    this.providedHash,
    this.timestamp,
  });

  factory LedgerVerifyModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return LedgerVerifyModel(
      valid: data['valid'] as bool? ?? false,
      reason: data['reason'] as String?,
      recordId: data['recordId'] as String?,
      storedHash: data['storedHash'] as String?,
      providedHash: data['providedHash'] as String?,
      timestamp: data['timestamp'] as String?,
    );
  }

  LedgerVerifyEntity toEntity() => LedgerVerifyEntity(
        valid: valid,
        reason: reason ?? '',
        recordId: recordId ?? '',
        storedHash: storedHash ?? '',
        providedHash: providedHash ?? '',
        timestamp: timestamp,
      );
}