import 'package:get_it/get_it.dart';
import '../core/network/token_storage.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/lost_pets/data/datasources/lost_pet_remote_datasource.dart';
import '../features/lost_pets/data/repositories/lost_pet_repository_impl.dart';
import '../features/lost_pets/domain/repositories/lost_pet_repository.dart';
import '../features/lost_pets/domain/usecases/create_report_usecase.dart';
import '../features/lost_pets/domain/usecases/list_reports_usecase.dart';

final sl = GetIt.instance;

void init() {
  // Core
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(tokenStorage: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(repository: sl()));

  // Lost Pets
  sl.registerLazySingleton<LostPetRemoteDataSource>(() => LostPetRemoteDataSource(tokenStorage: sl()));
  sl.registerLazySingleton<LostPetRepository>(() => LostPetRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<CreateReportUseCase>(() => CreateReportUseCase(repository: sl()));
  sl.registerLazySingleton<ListReportsUseCase>(() => ListReportsUseCase(repository: sl()));
}
