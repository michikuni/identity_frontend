part of 'payroll_bloc.dart';

abstract class PayrollEvent extends Equatable {
  const PayrollEvent();
  @override
  List<Object?> get props => [];
}

class PayrollFetch extends PayrollEvent {
  const PayrollFetch();
}
