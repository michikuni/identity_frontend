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
        workDate: json['workDate']?.toString() ?? '',
        checkInTime: json['checkInTime']?.toString(),
        checkOutTime: json['checkOutTime']?.toString(),
        checkInLocation: json['checkInLocation'],
        checkOutLocation: json['checkOutLocation'],
        status: json['status'] ?? 'PRESENT',
        note: json['note'],
      );

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
