import 'package:identity_frontend/domain/entities/company_entity.dart';
import 'package:identity_frontend/data/datasources/remote/company_datasource.dart';

class CompanyUseCase {
  final CompanyRemoteDataSource _dataSource;
  const CompanyUseCase(this._dataSource);

  Future<CompanyEntity?> getCompany() async {
    final model = await _dataSource.fetchCompany();
    return model?.toEntity();
  }

  Future<CompanyEntity> saveCompany(Map<String, dynamic> data, {bool isNew = false}) async {
    final model = await _dataSource.saveCompany(data, isNew: isNew);
    return model.toEntity();
  }
}
