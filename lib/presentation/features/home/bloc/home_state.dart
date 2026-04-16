part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final EmployeeEntity? employee;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.employee,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    EmployeeEntity? employee,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      employee: employee ?? this.employee,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, employee, errorMessage];
}
