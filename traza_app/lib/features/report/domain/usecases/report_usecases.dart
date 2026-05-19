import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

class GetUserReportsUseCase {
  final ReportRepository repository;
  const GetUserReportsUseCase(this.repository);

  Future<Either<Failure, List<Report>>> call() {
    return repository.getUserReports();
  }
}

class GetAllReportsUseCase {
  final ReportRepository repository;
  const GetAllReportsUseCase(this.repository);

  Future<Either<Failure, List<Report>>> call() {
    return repository.getAllReports();
  }
}

class UpdateReportStatusUseCase {
  final ReportRepository repository;
  const UpdateReportStatusUseCase(this.repository);

  Future<Either<Failure, Report>> call({
    required String reportId,
    required ReportStatus status,
    String? officerNote,
  }) {
    return repository.updateReportStatus(
      reportId: reportId,
      status: status,
      officerNote: officerNote,
    );
  }
}