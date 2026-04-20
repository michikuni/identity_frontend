import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/domain/usecases/employee_usecase.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final EmployeeUseCase _employeeUseCase;

  OnboardingBloc({required EmployeeUseCase employeeUseCase})
      : _employeeUseCase = employeeUseCase,
        super(const OnboardingState()) {
    on<OnboardingSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    OnboardingSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    try {
      await _employeeUseCase.createEmployee({
        'department': event.department,
        'position': event.position,
        'status': 'ACTIVE',
        'workingType': event.workingType,
        'isActive': true,
        'createdBy': event.createdBy,
        'note': event.note,
        if (event.publicKeyJwk != null) 'publicKeyJwk': event.publicKeyJwk,
      });
      emit(state.copyWith(status: OnboardingStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
