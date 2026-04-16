import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

class AttendanceFetchToday extends AttendanceEvent {
  const AttendanceFetchToday();
}

class AttendanceCheckIn extends AttendanceEvent {
  final String? location;
  const AttendanceCheckIn({this.location});
  @override
  List<Object?> get props => [location];
}

class AttendanceCheckOut extends AttendanceEvent {
  final String? location;
  const AttendanceCheckOut({this.location});
  @override
  List<Object?> get props => [location];
}

class AttendanceFetchHistory extends AttendanceEvent {
  final int year;
  final int month;
  const AttendanceFetchHistory({required this.year, required this.month});
  @override
  List<Object?> get props => [year, month];
}
