import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/report.dart';
import '../../domain/usecases/report_usecases.dart';
import '../../domain/usecases/submit_report.dart';

// ── Events ──────────────────────────────────────────────────────────────────
abstract class ReportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserReports extends ReportEvent {}

class SubmitReportEvent extends ReportEvent {
  final ReportType type;
  final String location;
  final double? latitude;
  final double? longitude;
  final String description;
  final bool isAnonymous;

  SubmitReportEvent({
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

class ResetReportForm extends ReportEvent {}

// ── States ───────────────────────────────────────────────────────────────────
abstract class ReportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}
class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<Report> reports;
  ReportLoaded(this.reports);
  @override
  List<Object?> get props => [reports];
}

class ReportSubmitting extends ReportState {}

class ReportSubmitSuccess extends ReportState {
  final Report report;
  ReportSubmitSuccess(this.report);
  @override
  List<Object?> get props => [report];
}

class ReportError extends ReportState {
  final String message;
  ReportError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ─────────────────────────────────────────────────────────────────────
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final SubmitReportUseCase submitReportUseCase;
  final GetUserReportsUseCase getUserReportsUseCase;

  ReportBloc({
    required this.submitReportUseCase,
    required this.getUserReportsUseCase,
  }) : super(ReportInitial()) {
    on<LoadUserReports>(_onLoadUserReports);
    on<SubmitReportEvent>(_onSubmitReport);
    on<ResetReportForm>((_, emit) => emit(ReportInitial()));
  }

  Future<void> _onLoadUserReports(
    LoadUserReports event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    final result = await getUserReportsUseCase();
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (reports) => emit(ReportLoaded(reports)),
    );
  }

  Future<void> _onSubmitReport(
    SubmitReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportSubmitting());
    final result = await submitReportUseCase(SubmitReportParams(
      type: event.type,
      location: event.location,
      latitude: event.latitude,
      longitude: event.longitude,
      description: event.description,
      isAnonymous: event.isAnonymous,
    ));
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (report) => emit(ReportSubmitSuccess(report)),
    );
  }
}