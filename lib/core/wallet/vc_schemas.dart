/// Schema fix cứng — danh sách field cho mỗi loại VC.
///
/// Đồng bộ với `VcIssuerService.kt` ở backend (loại trừ trường `id` chứa DID).
/// Dùng chung cho:
///   - Wallet (popup chọn field khi tạo VC QR có selective disclosure)
///   - Verifier Mode B (render danh sách field theo nhóm VC)
class VcSchema {
  final String type;       // EmploymentCredential | SalaryRangeCredential | PromotionCredential | TerminationCredential
  final String label;      // Hiển thị UI
  final List<String> fields;
  const VcSchema({required this.type, required this.label, required this.fields});
}

const Map<String, VcSchema> kVcSchemas = {
  'EmploymentCredential': VcSchema(
    type: 'EmploymentCredential',
    label: 'Employment Credential',
    fields: ['department', 'position', 'employmentStatus', 'startDate'],
  ),
  'SalaryRangeCredential': VcSchema(
    type: 'SalaryRangeCredential',
    label: 'Salary Range Credential',
    fields: ['salaryBand', 'currency', 'position', 'department', 'issuedAt'],
  ),
  'PromotionCredential': VcSchema(
    type: 'PromotionCredential',
    label: 'Promotion Credential',
    fields: ['department', 'oldPosition', 'newPosition', 'promotionDate', 'promotedBy'],
  ),
  'TerminationCredential': VcSchema(
    type: 'TerminationCredential',
    label: 'Termination Credential',
    fields: [
      'department',
      'position',
      'employmentStatus',
      'terminationDate',
      'terminationReason',
      'revokedBy',
    ],
  ),
};

/// Tra ngược vcType từ một field (lấy VC đầu tiên có chứa field đó).
/// Dùng khi Verifier vừa tick field, cần biết VC type để ràng buộc.
String? findVcTypeByField(String field) {
  for (final entry in kVcSchemas.entries) {
    if (entry.value.fields.contains(field)) return entry.key;
  }
  return null;
}
