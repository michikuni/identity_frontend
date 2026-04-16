import 'package:identity_frontend/domain/entities/request_entity.dart';

class RequestModel {
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

  const RequestModel({
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

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
        id: json['id'],
        requestType: json['requestType'] ?? '',
        status: json['status'] ?? 'PENDING',
        startDate: json['startDate']?.toString() ?? '',
        endDate: json['endDate']?.toString() ?? '',
        session: json['session'],
        reason: json['reason'] ?? '',
        photoUrl: json['photoUrl'],
        approverId: json['approver']?['id'],
        approverName: json['approver']?['profile']?['name'] ?? json['approver']?['auth']?['email'],
        approvedAt: json['approvedAt']?.toString(),
        rejectedReason: json['rejectedReason'],
        createdAt: json['createdAt']?.toString() ?? '',
      );

  RequestEntity toEntity() => RequestEntity(
        id: id,
        requestType: requestType,
        status: status,
        startDate: startDate,
        endDate: endDate,
        session: session,
        reason: reason,
        photoUrl: photoUrl,
        approverId: approverId,
        approverName: approverName,
        approvedAt: approvedAt,
        rejectedReason: rejectedReason,
        createdAt: createdAt,
      );
}
