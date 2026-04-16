import 'package:identity_frontend/domain/entities/contract_entity.dart';

abstract class ContractRepository {
  Future<ContractEntity> getContract();
  Future<ContractEntity> createContract(Map<String, dynamic> data);
  Future<ContractEntity> updateContract(Map<String, dynamic> data);
  Future<void> deleteContract();
}