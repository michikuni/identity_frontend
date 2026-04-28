import 'package:identity_frontend/domain/entities/attendance_entity.dart';

class AttendanceModel {
  final int? id;
  final String workDate;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String status;
  final String? note;

  const AttendanceModel({
    this.id,
    required this.workDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLocation,
    this.checkOutLocation,
    this.status = 'PRESENT',
    this.note,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => AttendanceModel(
        id: json['id'],
        workDate: _normalizeDate(json['workDate']?.toString()),
        checkInTime: _normalizeDateTime(json['checkInTime']?.toString()),
        checkOutTime: _normalizeDateTime(json['checkOutTime']?.toString()),
        checkInLocation: json['checkInLocation'],
        checkOutLocation: json['checkOutLocation'],
        status: json['status'] ?? 'PRESENT',
        note: json['note'],
      );

  /// Normalize to YYYY-MM-DD (date portion only)
  static String _normalizeDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw.length >= 10 ? raw.substring(0, 10) : raw;
  }

  /// Normalize to full ISO-8601 string; add Z if missing so DateTime.parse works
  static String? _normalizeDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.length == 19) return '${raw}Z';
    return raw;
  }

  AttendanceEntity toEntity() => AttendanceEntity(
        id: id,
        workDate: workDate,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        checkInLocation: checkInLocation,
        checkOutLocation: checkOutLocation,
        status: status,
        note: note,
      );
}
