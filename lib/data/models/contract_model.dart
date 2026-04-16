import 'package:identity_frontend/domain/entities/contract_entity.dart';

class ContractModel {
  final String? id;
  final String? employeeId;
  final String? typeContract;
  final String? startDate;
  final String? endDate;
  final String? contractExpire;
  final String? probationStartDate;
  final String? probationEndDate;
  final String? taxCode;
  final String? socialInsuranceNumber;
  final String? healthInsuranceNumber;

  const ContractModel({
    this.id,
    this.employeeId,
    this.typeContract,
    this.startDate,
    this.endDate,
    this.contractExpire,
    this.probationStartDate,
    this.probationEndDate,
    this.taxCode,
    this.socialInsuranceNumber,
    this.healthInsuranceNumber,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final idMap = data['id'] as Map<String, dynamic>?;
    final employee = data['employee'] as Map<String, dynamic>?;
    final empIdMap = employee?['id'] as Map<String, dynamic>?;

    return ContractModel(
      id: idMap?['value'] as String?,
      employeeId: empIdMap?['value'] as String?,
      typeContract: data['typeContract'] as String?,
      startDate: data['startDate'] as String?,
      endDate: data['endDate'] as String?,
      contractExpire: data['contractExpire'] as String?,
      probationStartDate: data['probationStartDate'] as String?,
      probationEndDate: data['probationEndDate'] as String?,
      taxCode: data['taxCode'] as String?,
      socialInsuranceNumber: data['socialInsuranceNumber'] as String?,
      healthInsuranceNumber: data['healthInsuranceNumber'] as String?,
    );
  }

  ContractEntity toEntity() => ContractEntity(
        id: id ?? '',
        employeeId: employeeId ?? '',
        typeContract: typeContract ?? 'PERMANENT',
        startDate: startDate != null ? DateTime.tryParse(startDate!) : null,
        endDate: endDate != null ? DateTime.tryParse(endDate!) : null,
        contractExpire: contractExpire != null ? DateTime.tryParse(contractExpire!) : null,
        probationStartDate: probationStartDate != null ? DateTime.tryParse(probationStartDate!) : null,
        probationEndDate: probationEndDate != null ? DateTime.tryParse(probationEndDate!) : null,
        taxCode: taxCode,
        socialInsuranceNumber: socialInsuranceNumber,
        healthInsuranceNumber: healthInsuranceNumber,
      );
}