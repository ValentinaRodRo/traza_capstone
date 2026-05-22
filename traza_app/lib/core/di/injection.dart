import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;                          // ← nuevo
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';   // ← nuevo
import '../../features/auth/data/datasources/auth_remote_datasource.dart';  // ← nuevo
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart'; // ← nuevo
import '../../features/auth/domain/repositories/auth_repository.dart';       // ← nuevo
import '../../features/auth/domain/usecases/get_current_user.dart';          // ← nuevo
import '../../features/auth/domain/usecases/login.dart';                     // ← nuevo
import '../../features/auth/domain/usecases/logout.dart';                    // ← nuevo
import '../../features/auth/domain/usecases/register.dart';                  // ← nuevo
import '../../features/auth/presentation/bloc/auth_bloc.dart';               // ← nuevo
import '../../features/report/data/datasources/report_local_datasource.dart';
import '../../features/report/data/repositories_impl/report_repository_impl.dart';
import '../../features/report/domain/repositories/report_repository.dart';
import '../../features/report/domain/usecases/report_usecases.dart';
import '../../features/report/domain/usecases/submit_report.dart';
import '../../features/report/presentation/bloc/report_bloc.dart';
// ... tus imports de report que ya tienes

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ── Auth (nuevo) ────────────────────────────────────────
  sl.registerSingleton<http.Client>(http.Client());
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

  // ── Report (sin cambios) ────────────────────────────────
  sl.registerSingleton<ReportLocalDataSource>(ReportLocalDataSourceImpl(prefs));
  sl.registerSingleton<ReportRepository>(ReportRepositoryImpl(sl()));
  sl.registerSingleton(SubmitReportUseCase(sl()));
  sl.registerSingleton(GetUserReportsUseCase(sl()));
  sl.registerSingleton(GetAllReportsUseCase(sl()));
  sl.registerSingleton(UpdateReportStatusUseCase(sl()));
  sl.registerFactory(() => ReportBloc(
    submitReportUseCase: sl(),
    getUserReportsUseCase: sl(),
  ));
}