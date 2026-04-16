import 'package:identity_frontend/data/datasources/remote/payroll_datasource.dart';
import 'package:identity_frontend/domain/entities/payroll_entity.dart';
import 'package:identity_frontend/domain/repositories/payroll_repository.dart';

class PayrollRepositoryImpl implements PayrollRepository {
  final PayrollRemoteDataSource _dataSource;
  const PayrollRepositoryImpl(this._dataSource);

  @override
  Future<PayrollEntity> getPayroll() async {
    final model = await _dataSource.getPayroll();
    return model.toEntity();
  }

  @override
  Future<PayrollEntity> createPayroll(Map<String, dynamic> data) async {
    final model = await _dataSource.createPayroll(data);
    return model.toEntity();
  }

  @override
  Future<PayrollEntity> updatePayroll(Map<String, dynamic> data) async {
    final model = await _dataSource.updatePayroll(data);
    return model.toEntity();
  }

  @override
  Future<void> deletePayroll() => _dataSource.deletePayroll();
}
