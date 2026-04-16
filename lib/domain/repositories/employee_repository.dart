import 'package:identity_frontend/domain/entities/employee_entity.dart';

abstract class EmployeeRepository {
  Future<EmployeeEntity> getEmployee();
  Future<EmployeeEntity> createEmployee(Map<String, dynamic> data);
  Future<EmployeeEntity> updateEmployee(Map<String, dynamic> data);
}