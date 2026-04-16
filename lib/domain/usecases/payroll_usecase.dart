import 'package:identity_frontend/domain/entities/payroll_entity.dart';
import 'package:identity_frontend/domain/repositories/payroll_repository.dart';

class PayrollUseCase {
  final PayrollRepository _repository;
  const PayrollUseCase(this._repository);

  Future<PayrollEntity> getPayroll() => _repository.getPayroll();
  Future<PayrollEntity> createPayroll(Map<String, dynamic> data) =>
      _repository.createPayroll(data);
  Future<PayrollEntity> updatePayroll(Map<String, dynamic> data) =>
      _repository.updatePayroll(data);
  Future<void> deletePayroll() => _repository.deletePayroll();
}