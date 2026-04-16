import 'package:identity_frontend/domain/entities/directory_entity.dart';

class DirectoryModel {
  final int id;
  final String name;
  final String email;
  final String department;
  final String position;
  final String role;
  final String status;

  const DirectoryModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.role,
    required this.status,
  });

  factory DirectoryModel.fromJson(Map<String, dynamic> json) => DirectoryModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? json['email'] ?? '',
        email: json['email'] ?? '',
        department: json['department'] ?? '',
        position: json['position'] ?? '',
        role: json['role'] ?? 'EMPLOYEE',
        status: json['status'] ?? 'ACTIVE',
      );

  DirectoryEntity toEntity() => DirectoryEntity(
        id: id,
        name: name,
        email: email,
        department: department,
        position: position,
        role: role,
        status: status,
      );
}
