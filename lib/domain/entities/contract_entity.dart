import 'package:equatable/equatable.dart';

class ContractEntity extends Equatable {
  final String id;
  final String employeeId;
  final String typeContract;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? contractExpire;
  final DateTime? probationStartDate;
  final DateTime? probationEndDate;
  final String? taxCode;
  final String? socialInsuranceNumber;
  final String? healthInsuranceNumber;

  const ContractEntity({
    required this.id,
    required this.employeeId,
    required this.typeContract,
    this.startDate,
    this.endDate,
    this.contractExpire,
    this.probationStartDate,
    this.probationEndDate,
    this.taxCode,
    this.socialInsuranceNumber,
    this.healthInsuranceNumber,
  });

  @override
  List<Object?> get props => [id, employeeId, typeContract];
}