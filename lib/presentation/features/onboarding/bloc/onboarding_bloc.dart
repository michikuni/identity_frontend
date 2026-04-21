import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/firebase/repositories/i_analytics_service.dart';
import 'package:identity_frontend/domain/usecases/employee_usecase.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final EmployeeUseCase _employeeUseCase;
  final IAnalyticsService _analytics;

  OnboardingBloc({
    required EmployeeUseCase employeeUseCase,
    IAnalyticsService? analytics,
  })  : _employeeUseCase = employeeUseCase,
        _analytics = analytics ?? sl<IAnalyticsService>(),
        super(const OnboardingState()) {
    on<OnboardingSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(OnboardingSubmitted event, Emitter<OnboardingState> emit) async {
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
      await _analytics.logEvent('onboarding_completed', parameters: {
        'department': event.department,
        'position': event.position,
        'working_type': event.workingType,
      });
      emit(state.copyWith(status: OnboardingStatus.success));
    } catch (e) {
      emit(state.copyWith(status: OnboardingStatus.failure, errorMessage: e.toString()));
    }
  }
}
