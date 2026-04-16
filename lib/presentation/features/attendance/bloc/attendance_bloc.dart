import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/domain/usecases/attendance_usecase.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceUseCase _useCase;

  AttendanceBloc({required AttendanceUseCase useCase})
      : _useCase = useCase,
        super(const AttendanceState()) {
    on<AttendanceFetchToday>(_onFetchToday);
    on<AttendanceCheckIn>(_onCheckIn);
    on<AttendanceCheckOut>(_onCheckOut);
    on<AttendanceFetchHistory>(_onFetchHistory);
  }

  Future<void> _onFetchToday(AttendanceFetchToday _, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(status: AttendanceStatus.loading));
    try {
      final today = await _useCase.getToday();
      emit(state.copyWith(status: AttendanceStatus.success, today: today));
    } catch (e) {
      emit(state.copyWith(status: AttendanceStatus.success, today: null));
    }
  }

  Future<void> _onCheckIn(AttendanceCheckIn event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(status: AttendanceStatus.loading));
    try {
      final today = await _useCase.checkIn(location: event.location);
      emit(state.copyWith(status: AttendanceStatus.success, today: today));
    } catch (e) {
      emit(state.copyWith(status: AttendanceStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onCheckOut(AttendanceCheckOut event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(status: AttendanceStatus.loading));
    try {
      final today = await _useCase.checkOut(location: event.location);
      emit(state.copyWith(status: AttendanceStatus.success, today: today));
    } catch (e) {
      emit(state.copyWith(status: AttendanceStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onFetchHistory(AttendanceFetchHistory event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(status: AttendanceStatus.loading));
    try {
      final history = await _useCase.getHistory(event.year, event.month);
      emit(state.copyWith(status: AttendanceStatus.success, history: history));
    } catch (e) {
      emit(state.copyWith(status: AttendanceStatus.failure, errorMessage: e.toString()));
    }
  }
}
