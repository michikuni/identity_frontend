import 'package:identity_frontend/domain/entities/contract_entity.dart';
import 'package:identity_frontend/domain/repositories/contract_repository.dart';

class ContractUseCase {
  final ContractRepository _repository;
  const ContractUseCase(this._repository);

  Future<ContractEntity> getContract() => _repository.getContract();
  Future<ContractEntity> createContract(Map<String, dynamic> data) =>
      _repository.createContract(data);
  Future<ContractEntity> updateContract(Map<String, dynamic> data) =>
      _repository.updateContract(data);
  Future<void> deleteContract() => _repository.deleteContract();
}