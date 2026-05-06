import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_datasource.dart';
import '../models/report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource localDataSource;
  final _uuid = const Uuid();

  ReportRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, Report>> submitReport({
    required ReportType type,
    required String location,
    double? latitude,
    double? longitude,
    required String description,
    required bool isAnonymous,
  }) async {
    try {
      final num = (847 + DateTime.now().millisecondsSinceEpoch % 100);
      final id = '#CHI-2026-0$num';
      final report = ReportModel(
        id: id,
        type: type,
        location: location,
        latitude: latitude,
        longitude: longitude,
        description: description,
        isAnonymous: isAnonymous,
        status: ReportStatus.received,
        createdAt: DateTime.now(),
        trustLevel: CitizenTrust.noRecord,
        coincidentReports: 0,
      );
      final saved = await localDataSource.saveReport(report);
      return Right(saved);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Report>>> getUserReports() async {
    try {
      final reports = await localDataSource.getUserReports();
      return Right(reports);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Report>>> getAllReports() async {
    try {
      final reports = await localDataSource.getAllReports();
      return Right(reports);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Report>> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? officerNote,
  }) async {
    try {
      final allReports = await localDataSource.getAllReports();
      final report = allReports.firstWhere(
        (r) => r.id == reportId,
        orElse: () => throw const CacheFailure('Reporte no encontrado'),
      );
      final updated = ReportModel.fromEntity(report.copyWith(
        status: status,
        officerNote: officerNote ?? report.officerNote,
      ));
      final saved = await localDataSource.updateReport(updated);
      return Right(saved);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Report>> getReportById(String reportId) async {
    try {
      final all = await localDataSource.getAllReports();
      final report = all.firstWhere(
        (r) => r.id == reportId,
        orElse: () => throw const CacheFailure('Reporte no encontrado'),
      );
      return Right(report);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}