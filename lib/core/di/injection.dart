import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/authority/presentation/bloc/authority_bloc.dart';
import '../../features/report/data/datasources/report_local_datasource.dart';
import '../../features/report/data/repositories_impl/report_repository_impl.dart';
import '../../features/report/domain/repositories/report_repository.dart';
import '../../features/report/domain/usecases/report_usecases.dart';
import '../../features/report/domain/usecases/submit_report.dart';
import '../../features/report/presentation/bloc/report_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<ReportLocalDataSource>(ReportLocalDataSourceImpl(prefs));
  sl.registerSingleton<ReportRepository>(ReportRepositoryImpl(sl()));
  sl.registerSingleton(SubmitReportUseCase(sl()));
  sl.registerSingleton(GetUserReportsUseCase(sl()));
  sl.registerSingleton(GetAllReportsUseCase(sl()));
  sl.registerSingleton(UpdateReportStatusUseCase(sl()));
  sl.registerFactory(() => ReportBloc(submitReportUseCase: sl(), getUserReportsUseCase: sl()));
  sl.registerFactory(() => AuthorityBloc(getAllReportsUseCase: sl(), updateReportStatusUseCase: sl()));
}