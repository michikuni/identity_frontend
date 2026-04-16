import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/domain/entities/employee_entity.dart';
import 'package:identity_frontend/domain/usecases/employee_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final EmployeeUseCase _employeeUseCase;

  HomeBloc({required EmployeeUseCase employeeUseCase})
      : _employeeUseCase = employeeUseCase,
        super(const HomeState()) {
    on<HomeFetchData>(_onFetchData);
  }

  Future<void> _onFetchData(HomeFetchData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final employee = await _employeeUseCase.getEmployee();
      emit(state.copyWith(status: HomeStatus.success, employee: employee));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }
}
