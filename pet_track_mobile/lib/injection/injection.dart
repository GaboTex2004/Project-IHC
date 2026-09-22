import 'package:get_it/get_it.dart';
import '../core/network/token_storage.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/lost_pets/data/datasources/lost_pet_remote_datasource.dart';
import '../features/lost_pets/data/repositories/lost_pet_repository_impl.dart';
import '../features/lost_pets/domain/repositories/lost_pet_repository.dart';
import '../features/lost_pets/domain/usecases/create_report_usecase.dart';
import '../features/lost_pets/domain/usecases/get_report_detail_usecase.dart';
import '../features/lost_pets/domain/usecases/get_my_reports_usecase.dart';
import '../features/lost_pets/domain/usecases/list_reports_usecase.dart';
import '../features/lost_pets/domain/usecases/resolve_report_usecase.dart';
import '../features/lost_pets/presentation/bloc/lost_pet_bloc.dart';
import '../features/chat/data/datasources/chat_remote_datasource.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/domain/usecases/get_conversations_usecase.dart';
import '../features/chat/domain/usecases/get_messages_usecase.dart';
import '../features/chat/domain/usecases/get_or_create_conversation_usecase.dart';
import '../features/chat/domain/usecases/send_message_usecase.dart';
import '../features/chat/presentation/bloc/chat_bloc.dart';
import '../features/sightings/data/datasources/device_location_datasource.dart';
import '../features/sightings/data/datasources/sighting_remote_datasource.dart';
import '../features/sightings/data/repositories/sighting_repository_impl.dart';
import '../features/sightings/domain/repositories/sighting_repository.dart';
import '../features/sightings/domain/usecases/create_sighting_usecase.dart';
import '../features/sightings/domain/usecases/get_current_position_usecase.dart';
import '../features/sightings/domain/usecases/get_report_sightings_usecase.dart';
import '../features/sightings/presentation/bloc/sighting_bloc.dart';
import '../features/lost_pets/domain/usecases/analyze_report_usecase.dart';
import '../features/lost_pets/domain/usecases/find_report_matches_usecase.dart';
final sl = GetIt.instance;

void init() {
  // Core
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(tokenStorage: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(repository: sl()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(repository: sl()),
  );

  // Lost Pets
  sl.registerLazySingleton<LostPetRemoteDataSource>(
    () => LostPetRemoteDataSource(tokenStorage: sl()),
  );
  sl.registerLazySingleton<LostPetRepository>(
    () => LostPetRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CreateReportUseCase>(
    () => CreateReportUseCase(repository: sl()),
  );
  sl.registerLazySingleton<ListReportsUseCase>(
    () => ListReportsUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetReportDetailUseCase>(
    () => GetReportDetailUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetMyReportsUseCase>(
    () => GetMyReportsUseCase(repository: sl()),
  );
  sl.registerLazySingleton<ResolveReportUseCase>(
    () => ResolveReportUseCase(repository: sl()),
  );
  sl.registerLazySingleton<AnalyzeReportUseCase>(
    () => AnalyzeReportUseCase(sl()),
  );
  sl.registerLazySingleton<FindReportMatchesUseCase>(
    () => FindReportMatchesUseCase(sl()),
  );
  sl.registerFactory<LostPetBloc>(
    () => LostPetBloc(
      listReportsUseCase: sl(),
      createReportUseCase: sl(),
      getReportDetailUseCase: sl(),
      getMyReportsUseCase: sl(),
      resolveReportUseCase: sl(),
      analyzeReportUseCase: sl(),
      findReportMatchesUseCase: sl(),
    ),
  );

  // Chat: cada pantalla recibe un BLoC nuevo para no conservar datos entre sesiones.
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(tokenStorage: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetConversationsUseCase(repository: sl()));
  sl.registerLazySingleton(
    () => GetOrCreateConversationUseCase(repository: sl()),
  );
  sl.registerLazySingleton(() => GetMessagesUseCase(repository: sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(repository: sl()));
  sl.registerFactory(
    () => ChatBloc(
      getConversations: sl(),
      getOrCreateConversation: sl(),
      getMessages: sl(),
      sendMessage: sl(),
    ),
  );

  sl.registerLazySingleton(() => DeviceLocationDataSource());
  sl.registerLazySingleton(() => GetCurrentPositionUseCase(dataSource: sl()));
  sl.registerLazySingleton(() => SightingRemoteDataSource(tokenStorage: sl()));
  sl.registerLazySingleton<SightingRepository>(
    () => SightingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => CreateSightingUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetReportSightingsUseCase(repository: sl()));
  sl.registerFactory(
    () => SightingBloc(
      getCurrentPosition: sl(),
      createSighting: sl(),
      getReportSightings: sl(),
    ),
  );
}
