part of 'payroll_bloc.dart';

enum PayrollStatus { initial, loading, success, failure }

class PayrollState extends Equatable {
  final PayrollStatus status;
  final PayrollEntity? payroll;
  final String? errorMessage;

  const PayrollState({
    this.status = PayrollStatus.initial,
    this.payroll,
    this.errorMessage,
  });

  PayrollState copyWith({
    PayrollStatus? status,
    PayrollEntity? payroll,
    String? errorMessage,
  }) {
    return PayrollState(
      status: status ?? this.status,
      payroll: payroll ?? this.payroll,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, payroll, errorMessage];
}
