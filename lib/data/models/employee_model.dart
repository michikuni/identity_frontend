import 'package:identity_frontend/domain/entities/employee_entity.dart';

class EmployeeModel {
  final String? id;
  final String? authId;
  final String? email;
  final String? phone;
  final String? role;
  final String? department;
  final String? position;
  final String? status;
  final String? workingType;
  final bool? isActive;
  final String? managerAuthId;
  final String? createdBy;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  const EmployeeModel({
    this.id,
    this.authId,
    this.email,
    this.phone,
    this.role,
    this.department,
    this.position,
    this.status,
    this.workingType,
    this.isActive,
    this.managerAuthId,
    this.createdBy,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final idMap = data['id'] as Map<String, dynamic>?;
    final auth = data['auth'] as Map<String, dynamic>?;
    final authIdMap = auth?['id'] as Map<String, dynamic>?;
    final manager = data['manager'] as Map<String, dynamic>?;
    final managerAuthIdMap = manager?['authId'] as Map<String, dynamic>?;

    return EmployeeModel(
      id: idMap?['value'] as String?,
      authId: authIdMap?['value'] as String?,
      email: auth?['email'] as String?,
      phone: auth?['phone'] as String?,
      role: auth?['role'] as String?,
      department: data['department'] as String?,
      position: data['position'] as String?,
      status: data['status'] as String?,
      workingType: data['workingType'] as String?,
      isActive: data['isActive'] as bool?,
      managerAuthId: managerAuthIdMap?['value'] as String?,
      createdBy: data['createdBy'] as String?,
      note: data['note'] as String?,
      createdAt: data['createdAt'] as String?,
      updatedAt: data['updatedAt'] as String?,
    );
  }

  EmployeeEntity toEntity() => EmployeeEntity(
        id: id ?? '',
        authId: authId ?? '',
        email: email ?? '',
        phone: phone,
        role: role ?? 'EMPLOYEE',
        department: department ?? '',
        position: position ?? '',
        status: status ?? 'ACTIVE',
        workingType: workingType ?? 'FULL_TIME',
        isActive: isActive ?? true,
        managerAuthId: managerAuthId,
        createdBy: createdBy,
        note: note,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
        updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
      );
}