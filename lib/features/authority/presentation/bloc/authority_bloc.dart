import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../report/domain/entities/report.dart';
import '../../../report/domain/usecases/report_usecases.dart';

// ── Events ──────────────────────────────────────────────────────────────────
abstract class AuthorityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAllReports extends AuthorityEvent {}

class UpdateStatus extends AuthorityEvent {
  final String reportId;
  final ReportStatus status;
  final String? note;
  UpdateStatus({required this.reportId, required this.status, this.note});
  @override
  List<Object?> get props => [reportId, status, note];
}

// ── States ───────────────────────────────────────────────────────────────────
abstract class AuthorityState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthorityInitial extends AuthorityState {}
class AuthorityLoading extends AuthorityState {}

class AuthorityLoaded extends AuthorityState {
  final List<Report> reports;
  AuthorityLoaded(this.reports);
  @override
  List<Object?> get props => [reports];
}

class AuthorityUpdating extends AuthorityState {
  final List<Report> reports;
  AuthorityUpdating(this.reports);
  @override
  List<Object?> get props => [reports];
}

class AuthorityUpdateSuccess extends AuthorityState {
  final List<Report> reports;
  final Report updatedReport;
  AuthorityUpdateSuccess(this.reports, this.updatedReport);
  @override
  List<Object?> get props => [reports, updatedReport];
}

class AuthorityError extends AuthorityState {
  final String message;
  AuthorityError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ─────────────────────────────────────────────────────────────────────
class AuthorityBloc extends Bloc<AuthorityEvent, AuthorityState> {
  final GetAllReportsUseCase getAllReportsUseCase;
  final UpdateReportStatusUseCase updateReportStatusUseCase;

  AuthorityBloc({
    required this.getAllReportsUseCase,
    required this.updateReportStatusUseCase,
  }) : super(AuthorityInitial()) {
    on<LoadAllReports>(_onLoadAll);
    on<UpdateStatus>(_onUpdateStatus);
  }

  Future<void> _onLoadAll(
    LoadAllReports event,
    Emitter<AuthorityState> emit,
  ) async {
    emit(AuthorityLoading());
    final result = await getAllReportsUseCase();
    result.fold(
      (f) => emit(AuthorityError(f.message)),
      (reports) => emit(AuthorityLoaded(reports)),
    );
  }

  Future<void> _onUpdateStatus(
    UpdateStatus event,
    Emitter<AuthorityState> emit,
  ) async {
    final currentReports = state is AuthorityLoaded
        ? (state as AuthorityLoaded).reports
        : (state is AuthorityUpdateSuccess
            ? (state as AuthorityUpdateSuccess).reports
            : <Report>[]);

    emit(AuthorityUpdating(currentReports));

    final result = await updateReportStatusUseCase(
      reportId: event.reportId,
      status: event.status,
      officerNote: event.note,
    );

    result.fold(
      (f) => emit(AuthorityError(f.message)),
      (updated) {
        final newList = currentReports.map((r) => r.id == updated.id ? updated : r).toList();
        emit(AuthorityUpdateSuccess(newList, updated));
      },
    );
  }
}