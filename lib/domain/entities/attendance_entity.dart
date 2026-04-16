class AttendanceEntity {
  final int? id;
  final String workDate;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String status;
  final String? note;

  const AttendanceEntity({
    this.id,
    required this.workDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLocation,
    this.checkOutLocation,
    this.status = 'PRESENT',
    this.note,
  });

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;
}
