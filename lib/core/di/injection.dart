import 'package:get_it/get_it.dart';
import 'package:identity_frontend/core/network/api_client.dart';
import 'package:identity_frontend/data/datasources/remote/attendance_datasource.dart';
import 'package:identity_frontend/data/datasources/remote/auth_datasource.dart';
import 'package:identity_frontend/data/datasources/remote/company_datasource.dart';
import 'package:identity_frontend/data/datasources/remote/contract_datasource.dart';
import 'package:identity_frontend/data/datasources/remote/directory_datasource.dart';
import 'package:identity_frontend/data/datasources/remote/employee_datasource.dart';
import 'package:identity_frontend/data/datasources/remote/ledger_datasource.dart';
import 'package:identity_frontend/data/datasources/remote/payroll_datasource.dart';
import 'package:identity_frontend/data/datasources/remote/profile_datasource.dart';
import 'package:identity_frontend/data/datasources/remote/request_datasource.dart';
import 'package:identity_frontend/data/repositories/auth_repository_impl.dart';
import 'package:identity_frontend/data/repositories/contract_repository_impl.dart';
import 'package:identity_frontend/data/repositories/employee_repository_impl.dart';
import 'package:identity_frontend/data/repositories/ledger_repository_impl.dart';
import 'package:identity_frontend/data/repositories/payroll_repository_impl.dart';
import 'package:identity_frontend/data/repositories/profile_repository_impl.dart';
import 'package:identity_frontend/domain/repositories/auth_repository.dart';
import 'package:identity_frontend/domain/repositories/contract_repository.dart';
import 'package:identity_frontend/domain/repositories/employee_repository.dart';
import 'package:identity_frontend/domain/repositories/ledger_repository.dart';
import 'package:identity_frontend/domain/repositories/payroll_repository.dart';
import 'package:identity_frontend/domain/repositories/profile_repository.dart';
import 'package:identity_frontend/domain/usecases/attendance_usecase.dart';
import 'package:identity_frontend/domain/usecases/auth/sign_in_usecase.dart';
import 'package:identity_frontend/domain/usecases/auth/sign_up_usecase.dart';
import 'package:identity_frontend/domain/usecases/company_usecase.dart';
import 'package:identity_frontend/domain/usecases/contract_usecase.dart';
import 'package:identity_frontend/domain/usecases/directory_usecase.dart';
import 'package:identity_frontend/domain/usecases/employee_usecase.dart';
import 'package:identity_frontend/domain/usecases/ledger_usecase.dart';
import 'package:identity_frontend/domain/usecases/payroll_usecase.dart';
import 'package:identity_frontend/domain/usecases/profile_usecase.dart';
import 'package:identity_frontend/domain/usecases/request_usecase.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  ApiClient.init();

  // ─── Data Sources ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(ApiClient.instance),
  );
  sl.registerLazySingleton<EmployeeRemoteDataSource>(
    () => EmployeeRemoteDataSourceImpl(ApiClient.instance),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(ApiClient.instance),
  );
  sl.registerLazySingleton<ContractRemoteDataSource>(
    () => ContractRemoteDataSourceImpl(ApiClient.instance),
  );
  sl.registerLazySingleton<PayrollRemoteDataSource>(
    () => PayrollRemoteDataSourceImpl(ApiClient.instance),
  );
  sl.registerLazySingleton<LedgerRemoteDataSource>(
    () => LedgerRemoteDataSourceImpl(ApiClient.instance),
  );
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(ApiClient.instance),
  );
  sl.registerLazySingleton<RequestRemoteDataSource>(
    () => RequestRemoteDataSourceImpl(ApiClient.instance),
  );
  sl.registerLazySingleton<DirectoryRemoteDataSource>(
    () => DirectoryRemoteDataSourceImpl(ApiClient.instance),
  );
  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(ApiClient.instance),
  );

  // ─── Repositories ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ContractRepository>(
    () => ContractRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PayrollRepository>(
    () => PayrollRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<LedgerRepository>(
    () => LedgerRepositoryImpl(sl()),
  );

  // ─── Use Cases ────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => EmployeeUseCase(sl()));
  sl.registerLazySingleton(() => ProfileUseCase(sl()));
  sl.registerLazySingleton(() => ContractUseCase(sl()));
  sl.registerLazySingleton(() => PayrollUseCase(sl()));
  sl.registerLazySingleton(() => LedgerUseCase(sl()));
  sl.registerLazySingleton(() => AttendanceUseCase(sl()));
  sl.registerLazySingleton(() => RequestUseCase(sl()));
  sl.registerLazySingleton(() => DirectoryUseCase(sl()));
  sl.registerLazySingleton(() => CompanyUseCase(sl()));
}