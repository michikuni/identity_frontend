import 'package:identity_frontend/domain/entities/profile_entity.dart';

class ProfileModel {
  final String? id;
  final String? employeeId;
  final String? name;
  final String? gender;
  final String? identityType;
  final String? identityNumber;
  final int? identityIssueDate;
  final String? identityIssuePlace;
  final String? email;
  final String? phone;
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

  const ProfileModel({
    this.id,
    this.employeeId,
    this.name,
    this.gender,
    this.identityType,
    this.identityNumber,
    this.identityIssueDate,
    this.identityIssuePlace,
    this.email,
    this.phone,
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

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final idMap = data['id'] as Map<String, dynamic>?;
    final employee = data['employee'] as Map<String, dynamic>?;
    final empIdMap = employee?['id'] as Map<String, dynamic>?;

    List<String>? parseStringList(dynamic val) {
      if (val == null) return null;
      if (val is List) return val.map((e) => e.toString()).toList();
      return null;
    }

    return ProfileModel(
      id: idMap?['value'] as String?,
      employeeId: empIdMap?['value'] as String?,
      name: data['name'] as String?,
      gender: data['gender'] as String?,
      identityType: data['identityType'] as String?,
      identityNumber: data['identityNumber'] as String?,
      identityIssueDate: data['identityIssueDate'] as int?,
      identityIssuePlace: data['identityIssuePlace'] as String?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      emergencyName: data['emergencyName'] as String?,
      emergencyPhone: data['emergencyPhone'] as String?,
      emergencyRelationship: data['emergencyRelationship'] as String?,
      dateOfBirth: data['dateOfBirth'] as String?,
      health: data['health'] as String?,
      married: data['married'] as String?,
      permanentResidence: data['permanentResidence'] as String?,
      nowResidence: data['nowResidence'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      educationLevel: data['educationLevel'] as String?,
      major: data['major'] as String?,
      certificate: parseStringList(data['certificate']),
      skillSet: parseStringList(data['skillSet']),
      expYears: data['expYears'] as int?,
    );
  }

  ProfileEntity toEntity() => ProfileEntity(
        id: id ?? '',
        employeeId: employeeId ?? '',
        name: name ?? '',
        gender: gender ?? 'MALE',
        identityType: identityType ?? 'NATIONAL_ID',
        identityNumber: identityNumber ?? '',
        identityIssueDate: identityIssueDate,
        identityIssuePlace: identityIssuePlace,
        email: email ?? '',
        phone: phone ?? '',
        emergencyName: emergencyName,
        emergencyPhone: emergencyPhone,
        emergencyRelationship: emergencyRelationship,
        dateOfBirth: dateOfBirth,
        health: health,
        married: married,
        permanentResidence: permanentResidence,
        nowResidence: nowResidence,
        avatarUrl: avatarUrl,
        educationLevel: educationLevel,
        major: major,
        certificate: certificate,
        skillSet: skillSet,
        expYears: expYears,
      );
}