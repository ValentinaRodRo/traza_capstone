import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_datasource.dart';
import '../datasources/report_remote_datasource.dart';
import '../models/report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource localDataSource;
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

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
      final report = await remoteDataSource.submitReport(
        incidentType: type.toBackend(),
        description: description,
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
        anonymous: isAnonymous,
      );
      // guardar en caché local para acceso offline
      await localDataSource.saveReport(report);
      return Right(report);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Report>>> getUserReports() async {
    try {
      final reports = await remoteDataSource.getUserReports();
      return Right(reports);
    } on ServerFailure {
      // sin conexión: devolver caché local
      try {
        final cached = await localDataSource.getUserReports();
        return Right(cached);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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