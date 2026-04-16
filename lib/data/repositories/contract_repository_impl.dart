import 'package:identity_frontend/data/datasources/remote/contract_datasource.dart';
import 'package:identity_frontend/domain/entities/contract_entity.dart';
import 'package:identity_frontend/domain/repositories/contract_repository.dart';

class ContractRepositoryImpl implements ContractRepository {
  final ContractRemoteDataSource _dataSource;
  const ContractRepositoryImpl(this._dataSource);

  @override
  Future<ContractEntity> getContract() async {
    final model = await _dataSource.getContract();
    return model.toEntity();
  }

  @override
  Future<ContractEntity> createContract(Map<String, dynamic> data) async {
    final model = await _dataSource.createContract(data);
    return model.toEntity();
  }

  @override
  Future<ContractEntity> updateContract(Map<String, dynamic> data) async {
    final model = await _dataSource.updateContract(data);
    return model.toEntity();
  }

  @override
  Future<void> deleteContract() => _dataSource.deleteContract();
}
