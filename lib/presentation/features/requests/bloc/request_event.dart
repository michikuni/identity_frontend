import 'package:equatable/equatable.dart';

abstract class RequestEvent extends Equatable {
  const RequestEvent();
  @override
  List<Object?> get props => [];
}

class RequestFetchMine extends RequestEvent { const RequestFetchMine(); }

class RequestCreate extends RequestEvent {
  final Map<String, dynamic> data;
  const RequestCreate(this.data);
  @override
  List<Object?> get props => [data];
}

class RequestApprove extends RequestEvent {
  final int requestId;
  const RequestApprove(this.requestId);
  @override
  List<Object?> get props => [requestId];
}

class RequestReject extends RequestEvent {
  final int requestId;
  final String reason;
  const RequestReject(this.requestId, this.reason);
  @override
  List<Object?> get props => [requestId, reason];
}

class RequestFetchSubordinate extends RequestEvent { const RequestFetchSubordinate(); }
