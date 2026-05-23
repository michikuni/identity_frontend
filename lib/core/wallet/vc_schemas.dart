/// Schema fix cứng — danh sách field cho mỗi loại VC.
///
/// Đồng bộ với `VcIssuerService.kt` ở backend (loại trừ trường `id` chứa DID).
/// Dùng chung cho:
///   - Wallet (popup chọn field khi tạo VC QR có selective disclosure)
///   - Verifier Mode B (render danh sách field theo nhóm VC)
class VcSchema {
  final String type;       // EmploymentCredential | SalaryRangeCredential | PromotionCredential | TerminationCredential
  final String label;      // Hiển thị UI (tiếng Việt)
  final List<String> fields;
  const VcSchema({required this.type, required this.label, required this.fields});
}

const Map<String, VcSchema> kVcSchemas = {
  'EmploymentCredential': VcSchema(
    type: 'EmploymentCredential',
    label: 'Chứng chỉ Nhân viên',
    fields: ['department', 'position', 'employmentStatus', 'startDate'],
  ),
  'SalaryRangeCredential': VcSchema(
    type: 'SalaryRangeCredential',
    label: 'Chứng chỉ Mức lương',
    fields: ['salaryBand', 'currency', 'position', 'department', 'issuedAt'],
  ),
  'PromotionCredential': VcSchema(
    type: 'PromotionCredential',
    label: 'Chứng chỉ Thăng chức',
    fields: ['department', 'oldPosition', 'newPosition', 'promotionDate', 'promotedBy'],
  ),
  'TerminationCredential': VcSchema(
    type: 'TerminationCredential',
    label: 'Chứng chỉ Nghỉ việc',
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

/// Nhãn tiếng Việt cho từng field key của credential subject.
const Map<String, String> kFieldLabelsVi = {
  'department': 'Phòng ban',
  'position': 'Chức vụ',
  'employmentStatus': 'Trạng thái công việc',
  'startDate': 'Ngày bắt đầu',
  'salaryBand': 'Mức lương',
  'currency': 'Đơn vị tiền tệ',
  'issuedAt': 'Ngày cấp',
  'oldPosition': 'Chức vụ cũ',
  'newPosition': 'Chức vụ mới',
  'promotionDate': 'Ngày thăng chức',
  'promotedBy': 'Thăng chức bởi',
  'terminationDate': 'Ngày nghỉ việc',
  'terminationReason': 'Lý do nghỉ việc',
  'revokedBy': 'Thu hồi bởi',
  'id': 'Mã định danh (DID)',
  // SD-JWT skill / education fields
  'skillName': 'Tên kỹ năng',
  'proficiencyLevel': 'Cấp độ',
  'degree': 'Bằng cấp',
  'major': 'Chuyên ngành',
  'institution': 'Trường / Tổ chức',
  'graduationYear': 'Năm tốt nghiệp',
  'gpa': 'GPA',
};

/// Trả về nhãn tiếng Việt cho một field key. Nếu không có trong map, trả về key gốc.
String humanizeFieldKey(String key) => kFieldLabelsVi[key] ?? key;

/// Trả về tên tiếng Việt cho một VC type.
String humanizeVcType(String? type) {
  switch (type) {
    case 'EmploymentCredential': return 'Chứng chỉ Nhân viên';
    case 'SalaryRangeCredential': return 'Chứng chỉ Mức lương';
    case 'PromotionCredential': return 'Chứng chỉ Thăng chức';
    case 'TerminationCredential': return 'Chứng chỉ Nghỉ việc';
    case 'SkillCredential': return 'Chứng chỉ Kỹ năng';
    case 'EducationCredential': return 'Chứng chỉ Học vấn';
    default: return 'Chứng chỉ số';
  }
}

/// Tra ngược vcType từ một field (lấy VC đầu tiên có chứa field đó).
/// Dùng khi Verifier vừa tick field, cần biết VC type để ràng buộc.
String? findVcTypeByField(String field) {
  for (final entry in kVcSchemas.entries) {
    if (entry.value.fields.contains(field)) return entry.key;
  }
  return null;
}

/// Chuyển giá trị enum salaryBand thành nhãn tiếng Việt thân thiện.
String humanizeSalaryBandValue(String band) {
  switch (band.toUpperCase()) {
    case 'ENTRY': return 'Mức khởi điểm';
    case 'MID': return 'Mức trung cấp';
    case 'SENIOR': return 'Mức cao cấp';
    case 'EXECUTIVE': return 'Mức điều hành';
    default: return band;
  }
}
