import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/cubit/login_cubit.dart';
import '../../features/auth/data/data_sources/auth_local_data_source.dart';
import '../../features/auth/data/data_sources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/home/cubit/home_cubit.dart';
import '../../features/home/data/data_sources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../config/api_config.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/language_interceptor.dart';
import '../storage/token_storage.dart';

/// The app's service locator.
///
/// It is read in exactly two places: here, and in a `BlocProvider(create: ...)`.
/// Every other class receives what it needs through its constructor.
final GetIt getIt = GetIt.instance;

/// Registers the app's dependencies. Call it once from `main()`, before `runApp`.
///
/// Returns the session [AuthCubit], so `main()` can restore it before the first
/// frame without reaching for the locator itself.
Future<AuthCubit> initInjection({String baseUrl = ApiConfig.baseUrl}) async {
  // Idempotent, so a hot restart (or a test) starts from a clean container.
  if (getIt.isRegistered<Dio>()) {
    await getIt.reset();
  }

  getIt
    // ---- Foundation: network + storage ----
    ..registerLazySingleton<SessionEvents>(SessionEvents.new)
    ..registerLazySingleton<LocaleHolder>(() => LocaleHolder.instance)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<TokenStorage>(() => TokenStorage(storage: getIt()))
    ..registerLazySingleton<Dio>(
      () => buildDioClient(
        tokenStorage: getIt(),
        sessionEvents: getIt(),
        localeHolder: getIt(),
        baseUrl: baseUrl,
      ),
    )
    // ---- Auth feature: data sources, repository, cubits ----
    // Data sources and repositories are singletons (one per app); screen cubits
    // are factories (a fresh one per screen) and the session cubit is a
    // singleton (one session for the whole app).
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(dio: getIt()),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource(tokenStorage: getIt(), storage: getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(remote: getIt(), local: getIt()),
    )
    ..registerLazySingleton<AuthCubit>(
      () => AuthCubit(repository: getIt(), sessionEvents: getIt()),
    )
    ..registerFactory<LoginCubit>(
      () => LoginCubit(repository: getIt(), authCubit: getIt()),
    )
    // ---- Home feature: data source, repository, cubit ----
    // The screen owns its cubit (a factory), so every new session gets a fresh
    // dashboard and never sees the previous user's data.
    ..registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSource(dio: getIt()),
    )
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepository(remote: getIt()),
    )
    ..registerFactory<HomeCubit>(() => HomeCubit(repository: getIt()));

  // A later feature registers its own data sources, repository and cubits here,
  // following the same shapes.
  return getIt<AuthCubit>();
}

/// Tears the container down so a test can start from a clean one.
Future<void> resetInjection() => getIt.reset();

