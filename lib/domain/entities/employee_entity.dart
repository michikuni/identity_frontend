import 'package:equatable/equatable.dart';

class EmployeeEntity extends Equatable {
  final String id;
  final String authId;
  final String email;
  final String? phone;
  final String role;
  final String department;
  final String position;
  final String status;
  final String workingType;
  final bool isActive;
  final String? managerAuthId;
  final String? createdBy;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EmployeeEntity({
    required this.id,
    required this.authId,
    required this.email,
    this.phone,
    required this.role,
    required this.department,
    required this.position,
    required this.status,
    required this.workingType,
    required this.isActive,
    this.managerAuthId,
    this.createdBy,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        authId,
        email,
        role,
        department,
        position,
        status,
        workingType,
        isActive,
      ];
}