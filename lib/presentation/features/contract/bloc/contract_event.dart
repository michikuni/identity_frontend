part of 'contract_bloc.dart';

abstract class ContractEvent extends Equatable {
  const ContractEvent();
  @override
  List<Object?> get props => [];
}

class ContractFetch extends ContractEvent {
  const ContractFetch();
}
