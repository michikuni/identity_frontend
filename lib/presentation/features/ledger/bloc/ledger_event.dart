part of 'ledger_bloc.dart';

abstract class LedgerEvent extends Equatable {
  const LedgerEvent();
  @override
  List<Object?> get props => [];
}

class LedgerFetchAll extends LedgerEvent {
  const LedgerFetchAll();
}

class LedgerFetchForEmployee extends LedgerEvent {
  final String employeeId;
  const LedgerFetchForEmployee(this.employeeId);
  @override
  List<Object?> get props => [employeeId];
}

class LedgerFetchHistory extends LedgerEvent {
  final String employeeId;
  final String recordType;
  const LedgerFetchHistory({required this.employeeId, required this.recordType});
  @override
  List<Object?> get props => [employeeId, recordType];
}
