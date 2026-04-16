import 'package:identity_frontend/domain/entities/payroll_entity.dart';

class PayrollModel {
  final String? id;
  final String? employeeId;
  final String? salaryType;
  final double? baseSalary;
  final double? bonusSalary;
  final double? overTimeRate;
  final double? totalIncome;
  final String? currency;
  final String? payDay;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final String? bankName;
  final String? bankBranch;

  const PayrollModel({
    this.id,
    this.employeeId,
    this.salaryType,
    this.baseSalary,
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

  factory PayrollModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final idMap = data['id'] as Map<String, dynamic>?;
    final employee = data['employee'] as Map<String, dynamic>?;
    final empIdMap = employee?['id'] as Map<String, dynamic>?;

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    return PayrollModel(
      id: idMap?['value'] as String?,
      employeeId: empIdMap?['value'] as String?,
      salaryType: data['salaryType'] as String?,
      baseSalary: parseDouble(data['baseSalary']),
      bonusSalary: parseDouble(data['bonusSalary']),
      overTimeRate: parseDouble(data['overTimeRate']),
      totalIncome: parseDouble(data['totalIncome']),
      currency: data['currency'] as String?,
      payDay: data['payDay'] as String?,
      bankAccountNumber: data['bankAccountNumber'] as String?,
      bankAccountName: data['bankAccountName'] as String?,
      bankName: data['bankName'] as String?,
      bankBranch: data['bankBranch'] as String?,
    );
  }

  PayrollEntity toEntity() => PayrollEntity(
        id: id ?? '',
        employeeId: employeeId ?? '',
        salaryType: salaryType ?? 'MONTHLY',
        baseSalary: baseSalary ?? 0,
        bonusSalary: bonusSalary,
        overTimeRate: overTimeRate,
        totalIncome: totalIncome,
        currency: currency,
        payDay: payDay != null ? DateTime.tryParse(payDay!) : null,
        bankAccountNumber: bankAccountNumber,
        bankAccountName: bankAccountName,
        bankName: bankName,
        bankBranch: bankBranch,
      );
}