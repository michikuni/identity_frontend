import 'package:identity_frontend/data/datasources/remote/employee_datasource.dart';
import 'package:identity_frontend/domain/entities/employee_entity.dart';
import 'package:identity_frontend/domain/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource _dataSource;
  const EmployeeRepositoryImpl(this._dataSource);

  @override
  Future<EmployeeEntity> getEmployee() async {
    final model = await _dataSource.getEmployee();
    return model.toEntity();
  }

  @override
  Future<EmployeeEntity> createEmployee(Map<String, dynamic> data) async {
    final model = await _dataSource.createEmployee(data);
    return model.toEntity();
  }

  @override
  Future<EmployeeEntity> updateEmployee(Map<String, dynamic> data) async {
    final model = await _dataSource.updateEmployee(data);
    return model.toEntity();
  }
}
