import 'package:equatable/equatable.dart';
import 'package:identity_frontend/domain/entities/attendance_entity.dart';

enum AttendanceStatus { initial, loading, success, failure }

class AttendanceState extends Equatable {
  final AttendanceStatus status;
  final AttendanceEntity? today;
  final List<AttendanceEntity> history;
  final String? errorMessage;

  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.today,
    this.history = const [],
    this.errorMessage,
  });

  AttendanceState copyWith({
    AttendanceStatus? status,
    AttendanceEntity? today,
    List<AttendanceEntity>? history,
    String? errorMessage,
  }) =>
      AttendanceState(
        status: status ?? this.status,
        today: today ?? this.today,
        history: history ?? this.history,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, today, history, errorMessage];
}
