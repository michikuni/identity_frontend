import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String employeeId;
  final String name;
  final String gender;
  final String identityType;
  final String identityNumber;
  final int? identityIssueDate;
  final String? identityIssuePlace;
  final String email;
  final String phone;
  final String? emergencyName;
  final String? emergencyPhone;
  final String? emergencyRelationship;
  final String? dateOfBirth;
  final String? health;
  final String? married;
  final String? permanentResidence;
  final String? nowResidence;
  final String? avatarUrl;
  final String? educationLevel;
  final String? major;
  final List<String>? certificate;
  final List<String>? skillSet;
  final int? expYears;

  const ProfileEntity({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.gender,
    required this.identityType,
    required this.identityNumber,
    this.identityIssueDate,
    this.identityIssuePlace,
    required this.email,
    required this.phone,
    this.emergencyName,
    this.emergencyPhone,
    this.emergencyRelationship,
    this.dateOfBirth,
    this.health,
    this.married,
    this.permanentResidence,
    this.nowResidence,
    this.avatarUrl,
    this.educationLevel,
    this.major,
    this.certificate,
    this.skillSet,
    this.expYears,
  });

  @override
  List<Object?> get props => [id, employeeId, name, email, phone];
}