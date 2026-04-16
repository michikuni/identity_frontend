part of 'contract_bloc.dart';

enum ContractStatus { initial, loading, success, failure }

class ContractState extends Equatable {
  final ContractStatus status;
  final ContractEntity? contract;
  final String? errorMessage;

  const ContractState({
    this.status = ContractStatus.initial,
    this.contract,
    this.errorMessage,
  });

  ContractState copyWith({
    ContractStatus? status,
    ContractEntity? contract,
    String? errorMessage,
  }) {
    return ContractState(
      status: status ?? this.status,
      contract: contract ?? this.contract,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, contract, errorMessage];
}
