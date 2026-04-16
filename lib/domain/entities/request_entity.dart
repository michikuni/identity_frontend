class RequestEntity {
  final int? id;
  final String requestType;
  final String status;
  final String startDate;
  final String endDate;
  final String? session;
  final String reason;
  final String? photoUrl;
  final int? approverId;
  final String? approverName;
  final String? approvedAt;
  final String? rejectedReason;
  final String createdAt;

  const RequestEntity({
    this.id,
    required this.requestType,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.session,
    required this.reason,
    this.photoUrl,
    this.approverId,
    this.approverName,
    this.approvedAt,
    this.rejectedReason,
    required this.createdAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
}
