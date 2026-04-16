import 'package:equatable/equatable.dart';
import 'package:identity_frontend/domain/entities/request_entity.dart';

enum RequestStatus { initial, loading, success, failure }

class RequestState extends Equatable {
  final RequestStatus status;
  final List<RequestEntity> requests;
  final List<RequestEntity> subordinateRequests;
  final String? errorMessage;
  final bool actionSuccess;

  const RequestState({
    this.status = RequestStatus.initial,
    this.requests = const [],
    this.subordinateRequests = const [],
    this.errorMessage,
    this.actionSuccess = false,
  });

  RequestState copyWith({
    RequestStatus? status,
    List<RequestEntity>? requests,
    List<RequestEntity>? subordinateRequests,
    String? errorMessage,
    bool? actionSuccess,
  }) =>
      RequestState(
        status: status ?? this.status,
        requests: requests ?? this.requests,
        subordinateRequests: subordinateRequests ?? this.subordinateRequests,
        errorMessage: errorMessage,
        actionSuccess: actionSuccess ?? false,
      );

  @override
  List<Object?> get props => [status, requests, subordinateRequests, errorMessage, actionSuccess];
}
