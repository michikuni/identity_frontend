part of 'ledger_bloc.dart';

enum LedgerStatus { initial, loading, success, failure }

class LedgerState extends Equatable {
  final LedgerStatus status;
  final List<LedgerRecordEntity> records;
  final List<LedgerRecordEntity> history;
  final String? errorMessage;

  const LedgerState({
    this.status = LedgerStatus.initial,
    this.records = const [],
    this.history = const [],
    this.errorMessage,
  });

  LedgerState copyWith({
    LedgerStatus? status,
    List<LedgerRecordEntity>? records,
    List<LedgerRecordEntity>? history,
    String? errorMessage,
  }) {
    return LedgerState(
      status: status ?? this.status,
      records: records ?? this.records,
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, records, history, errorMessage];
}
