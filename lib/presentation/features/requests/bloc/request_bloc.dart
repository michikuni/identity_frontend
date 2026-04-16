import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/domain/usecases/request_usecase.dart';
import 'request_event.dart';
import 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final RequestUseCase _useCase;

  RequestBloc({required RequestUseCase useCase})
      : _useCase = useCase,
        super(const RequestState()) {
    on<RequestFetchMine>(_onFetchMine);
    on<RequestCreate>(_onCreate);
    on<RequestApprove>(_onApprove);
    on<RequestReject>(_onReject);
    on<RequestFetchSubordinate>(_onFetchSubordinate);
  }

  Future<void> _onFetchMine(RequestFetchMine _, Emitter<RequestState> emit) async {
    emit(state.copyWith(status: RequestStatus.loading));
    try {
      final list = await _useCase.getMyRequests();
      emit(state.copyWith(status: RequestStatus.success, requests: list));
    } catch (e) {
      emit(state.copyWith(status: RequestStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreate(RequestCreate event, Emitter<RequestState> emit) async {
    emit(state.copyWith(status: RequestStatus.loading));
    try {
      await _useCase.createRequest(event.data);
      final list = await _useCase.getMyRequests();
      emit(state.copyWith(status: RequestStatus.success, requests: list, actionSuccess: true));
    } catch (e) {
      emit(state.copyWith(status: RequestStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onApprove(RequestApprove event, Emitter<RequestState> emit) async {
    emit(state.copyWith(status: RequestStatus.loading));
    try {
      await _useCase.approve(event.requestId);
      final list = await _useCase.getSubordinateRequests();
      emit(state.copyWith(status: RequestStatus.success, subordinateRequests: list, actionSuccess: true));
    } catch (e) {
      emit(state.copyWith(status: RequestStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onReject(RequestReject event, Emitter<RequestState> emit) async {
    emit(state.copyWith(status: RequestStatus.loading));
    try {
      await _useCase.reject(event.requestId, event.reason);
      final list = await _useCase.getSubordinateRequests();
      emit(state.copyWith(status: RequestStatus.success, subordinateRequests: list, actionSuccess: true));
    } catch (e) {
      emit(state.copyWith(status: RequestStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onFetchSubordinate(RequestFetchSubordinate _, Emitter<RequestState> emit) async {
    emit(state.copyWith(status: RequestStatus.loading));
    try {
      final list = await _useCase.getSubordinateRequests();
      emit(state.copyWith(status: RequestStatus.success, subordinateRequests: list));
    } catch (e) {
      emit(state.copyWith(status: RequestStatus.failure, errorMessage: e.toString()));
    }
  }
}
