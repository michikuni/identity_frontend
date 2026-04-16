import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/domain/entities/contract_entity.dart';
import 'package:identity_frontend/domain/usecases/contract_usecase.dart';

part 'contract_event.dart';
part 'contract_state.dart';

class ContractBloc extends Bloc<ContractEvent, ContractState> {
  final ContractUseCase _contractUseCase;

  ContractBloc({required ContractUseCase contractUseCase})
      : _contractUseCase = contractUseCase,
        super(const ContractState()) {
    on<ContractFetch>(_onFetch);
  }

  Future<void> _onFetch(ContractFetch event, Emitter<ContractState> emit) async {
    emit(state.copyWith(status: ContractStatus.loading));
    try {
      final contract = await _contractUseCase.getContract();
      emit(state.copyWith(status: ContractStatus.success, contract: contract));
    } catch (e) {
      emit(state.copyWith(status: ContractStatus.failure, errorMessage: e.toString()));
    }
  }
}
