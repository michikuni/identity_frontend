import 'package:equatable/equatable.dart';

class PayrollEntity extends Equatable {
  final String id;
  final String employeeId;
  final String salaryType;
  final double baseSalary;
  final double? bonusSalary;
  final double? overTimeRate;
  final double? totalIncome;
  final String? currency;
  final DateTime? payDay;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final String? bankName;
  final String? bankBranch;

  const PayrollEntity({
    required this.id,
    required this.employeeId,
    required this.salaryType,
    required this.baseSalary,
    this.bonusSalary,
    this.overTimeRate,
    this.totalIncome,
    this.currency,
    this.payDay,
    this.bankAccountNumber,
    this.bankAccountName,
    this.bankName,
    this.bankBranch,
  });

  @override
  List<Object?> get props => [id, employeeId, baseSalary];
}