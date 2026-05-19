import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/report.dart';

abstract class ReportRepository {
  Future<Either<Failure, Report>> submitReport({
    required ReportType type,
    required String location,
    double? latitude,
    double? longitude,
    required String description,
    required bool isAnonymous,
  });

  Future<Either<Failure, List<Report>>> getUserReports();

  Future<Either<Failure, List<Report>>> getAllReports();

  Future<Either<Failure, Report>> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? officerNote,
  });

  Future<Either<Failure, Report>> getReportById(String reportId);
}