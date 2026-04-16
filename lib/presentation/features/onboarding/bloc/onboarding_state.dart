part of 'onboarding_bloc.dart';

enum OnboardingStatus { initial, loading, success, failure }

class OnboardingState extends Equatable {
  final OnboardingStatus status;
  final String? errorMessage;

  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.errorMessage,
  });

  OnboardingState copyWith({
    OnboardingStatus? status,
    String? errorMessage,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
