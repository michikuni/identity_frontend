import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/domain/entities/payroll_entity.dart';
import 'package:identity_frontend/domain/usecases/payroll_usecase.dart';

part 'payroll_event.dart';
part 'payroll_state.dart';

class PayrollBloc extends Bloc<PayrollEvent, PayrollState> {
  final PayrollUseCase _payrollUseCase;

  PayrollBloc({required PayrollUseCase payrollUseCase})
      : _payrollUseCase = payrollUseCase,
        super(const PayrollState()) {
    on<PayrollFetch>(_onFetch);
  }

  Future<void> _onFetch(PayrollFetch event, Emitter<PayrollState> emit) async {
    emit(state.copyWith(status: PayrollStatus.loading));
    try {
      final payroll = await _payrollUseCase.getPayroll();
      emit(state.copyWith(status: PayrollStatus.success, payroll: payroll));
    } catch (e) {
      emit(state.copyWith(status: PayrollStatus.failure, errorMessage: e.toString()));
    }
  }
}
