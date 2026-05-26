import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/map/data/datasources/zone_datasource.dart';
import '../../features/map/data/repositories_impl/zone_repository_impl.dart';
import '../../features/map/domain/repositories/zone_repository.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';
import '../../features/report/data/datasources/report_local_datasource.dart';
import '../../features/report/data/datasources/report_remote_datasource.dart';
import '../../features/report/data/repositories_impl/report_repository_impl.dart';
import '../../features/report/domain/repositories/report_repository.dart';
import '../../features/report/domain/usecases/report_usecases.dart';
import '../../features/report/domain/usecases/submit_report.dart';
import '../../features/report/presentation/bloc/report_bloc.dart';
import '../navigation/shell_navigation_service.dart';
import '../theme/theme_service.dart';

final sl = GetIt.instance;

final _baseUrl = dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000';
final _wsBaseUrl =
    (dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000').replaceFirst('http', 'ws');

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ── Servicios globales ─────────────────────────────────────────────────────
  sl.registerSingleton<ShellNavigationService>(ShellNavigationService());
  sl.registerSingleton<ThemeService>(ThemeService(prefs));

  // ── HTTP client compartido ─────────────────────────────────────────────────
  sl.registerSingleton<http.Client>(http.Client());

  // ── Auth ───────────────────────────────────────────────────────────────────
  sl.registerSingleton<AuthRemoteDataSource>(AuthRemoteDataSourceImpl(sl()));
  sl.registerSingleton<AuthLocalDataSource>(AuthLocalDataSourceImpl(sl()));
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerSingleton(Login(sl()));
  sl.registerSingleton(Register(sl()));
  sl.registerSingleton(Logout(sl()));
  sl.registerSingleton(GetCurrentUser(sl()));
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
      ));

  // ── Map / Zones ────────────────────────────────────────────────────────────
  sl.registerSingleton<ZoneDataSource>(
    ZoneDataSourceImpl(
      baseUrl: _baseUrl,
      wsBaseUrl: _wsBaseUrl,
      httpClient: sl(),
    ),
  );
  sl.registerSingleton<ZoneRepository>(ZoneRepositoryImpl(sl()));
  sl.registerFactory(() => MapBloc(zoneRepository: sl()));

  // ── Report ─────────────────────────────────────────────────────────────────
  sl.registerSingleton<ReportLocalDataSource>(ReportLocalDataSourceImpl(prefs));
  sl.registerSingleton<ReportRemoteDataSource>(
    ReportRemoteDataSourceImpl(
      httpClient: sl(),
      prefs: prefs,
      baseUrl: _baseUrl,
    ),
  );
  sl.registerSingleton<ReportRepository>(
    ReportRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );
  sl.registerSingleton(SubmitReportUseCase(sl()));
  sl.registerSingleton(GetUserReportsUseCase(sl()));
  sl.registerSingleton(GetAllReportsUseCase(sl()));
  sl.registerSingleton(UpdateReportStatusUseCase(sl()));
  sl.registerFactory(() => ReportBloc(
        submitReportUseCase: sl(),
        getUserReportsUseCase: sl(),
      ));
}