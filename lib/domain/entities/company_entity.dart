class CompanyEntity {
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

  const CompanyEntity({
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
}
