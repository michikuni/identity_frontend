part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object?> get props => [];
}

class OnboardingSubmitted extends OnboardingEvent {
  final String department;
  final String position;
  final String workingType;
  final String createdBy;
  final String? note;

  const OnboardingSubmitted({
    required this.department,
    required this.position,
    required this.workingType,
    required this.createdBy,
    this.note,
  });

  @override
  List<Object?> get props => [department, position, workingType, createdBy, note];
}
