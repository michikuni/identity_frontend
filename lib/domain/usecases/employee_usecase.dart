import 'package:identity_frontend/domain/entities/employee_entity.dart';
import 'package:identity_frontend/domain/repositories/employee_repository.dart';

class EmployeeUseCase {
  final EmployeeRepository _repository;
  const EmployeeUseCase(this._repository);

  Future<EmployeeEntity> getEmployee() => _repository.getEmployee();
  Future<EmployeeEntity> createEmployee(Map<String, dynamic> data) =>
      _repository.createEmployee(data);
  Future<EmployeeEntity> updateEmployee(Map<String, dynamic> data) =>
      _repository.updateEmployee(data);
}