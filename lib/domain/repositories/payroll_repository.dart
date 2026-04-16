import 'package:identity_frontend/domain/entities/payroll_entity.dart';

abstract class PayrollRepository {
  Future<PayrollEntity> getPayroll();
  Future<PayrollEntity> createPayroll(Map<String, dynamic> data);
  Future<PayrollEntity> updatePayroll(Map<String, dynamic> data);
  Future<void> deletePayroll();
}