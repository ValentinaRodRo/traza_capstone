import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

class SubmitReportUseCase {
  final ReportRepository repository;
  const SubmitReportUseCase(this.repository);

  Future<Either<Failure, Report>> call(SubmitReportParams params) {
    return repository.submitReport(
      type: params.type,
      location: params.location,
      latitude: params.latitude,
      longitude: params.longitude,
      description: params.description,
      isAnonymous: params.isAnonymous,
    );
  }
}

class SubmitReportParams extends Equatable {
  final ReportType type;
  final String location;
  final double? latitude;
  final double? longitude;
  final String description;
  final bool isAnonymous;

  const SubmitReportParams({
    required this.type,
    required this.location,
    this.latitude,
    this.longitude,
    required this.description,
    required this.isAnonymous,
  });

  @override
  List<Object?> get props => [type, location, latitude, longitude, description, isAnonymous];
}