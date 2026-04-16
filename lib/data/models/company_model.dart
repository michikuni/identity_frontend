import 'package:identity_frontend/domain/entities/company_entity.dart';

class CompanyModel {
  final int? id;
  final String taxCode;
  final String companyName;
  final String legalRepName;
  final String legalRepTitle;
  final String legalRepIdNumber;
  final String address;
  final String phone;
  final String email;
  final String registeredAt;

  const CompanyModel({
    this.id,
    required this.taxCode,
    required this.companyName,
    required this.legalRepName,
    required this.legalRepTitle,
    required this.legalRepIdNumber,
    required this.address,
    required this.phone,
    required this.email,
    required this.registeredAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        id: json['id'],
        taxCode: json['taxCode'] ?? '',
        companyName: json['companyName'] ?? '',
        legalRepName: json['legalRepName'] ?? '',
        legalRepTitle: json['legalRepTitle'] ?? '',
        legalRepIdNumber: json['legalRepIdNumber'] ?? '',
        address: json['address'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        registeredAt: json['registeredAt']?.toString() ?? '',
      );

  CompanyEntity toEntity() => CompanyEntity(
        id: id,
        taxCode: taxCode,
        companyName: companyName,
        legalRepName: legalRepName,
        legalRepTitle: legalRepTitle,
        legalRepIdNumber: legalRepIdNumber,
        address: address,
        phone: phone,
        email: email,
        registeredAt: registeredAt,
      );
}
