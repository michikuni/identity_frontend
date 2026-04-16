import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/domain/entities/ledger_entity.dart';
import 'package:identity_frontend/domain/usecases/ledger_usecase.dart';

part 'ledger_event.dart';
part 'ledger_state.dart';

class LedgerBloc extends Bloc<LedgerEvent, LedgerState> {
  final LedgerUseCase _ledgerUseCase;

  LedgerBloc({required LedgerUseCase ledgerUseCase})
      : _ledgerUseCase = ledgerUseCase,
        super(const LedgerState()) {
    on<LedgerFetchAll>(_onFetchAll);
    on<LedgerFetchForEmployee>(_onFetchForEmployee);
    on<LedgerFetchHistory>(_onFetchHistory);
  }

  Future<void> _onFetchAll(LedgerFetchAll event, Emitter<LedgerState> emit) async {
    emit(state.copyWith(status: LedgerStatus.loading));
    try {
      final records = await _ledgerUseCase.getAllRecords();
      emit(state.copyWith(status: LedgerStatus.success, records: records));
    } catch (e) {
      emit(state.copyWith(status: LedgerStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onFetchForEmployee(LedgerFetchForEmployee event, Emitter<LedgerState> emit) async {
    emit(state.copyWith(status: LedgerStatus.loading));
    try {
      final records = await _ledgerUseCase.getAllRecordsForEmployee(event.employeeId);
      emit(state.copyWith(status: LedgerStatus.success, records: records));
    } catch (e) {
      emit(state.copyWith(status: LedgerStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onFetchHistory(LedgerFetchHistory event, Emitter<LedgerState> emit) async {
    emit(state.copyWith(status: LedgerStatus.loading));
    try {
      final history = await _ledgerUseCase.getRecordHistory(event.employeeId, event.recordType);
      emit(state.copyWith(status: LedgerStatus.success, history: history));
    } catch (e) {
      emit(state.copyWith(status: LedgerStatus.failure, errorMessage: e.toString()));
    }
  }
}
