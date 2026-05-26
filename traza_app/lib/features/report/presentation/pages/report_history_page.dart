import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/report.dart';
import '../bloc/report_bloc.dart';

class ReportHistoryPage extends StatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  State<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(LoadUserReports());
  }

  Future<void> _refresh() async {
    context.read<ReportBloc>().add(LoadUserReports());
    await context.read<ReportBloc>().stream.firstWhere(
          (s) => s is ReportLoaded || s is ReportError,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrazaThemeTokens.bg(context),
      appBar: const TrazaAppBar(title: 'Mis reportes'),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: TrazaThemeTokens.brand(context),
              ),
            );
          }

          if (state is ReportError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 40, color: TrazaThemeTokens.danger(context)),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: TextStyle(
                          color: TrazaThemeTokens.textSecondary(context))),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        context.read<ReportBloc>().add(LoadUserReports()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final reports =
              state is ReportLoaded ? state.reports : <Report>[];

          if (reports.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: TrazaThemeTokens.brand(context),
              child: ListView(
                children: [
                  SizedBox(height: 120),
                  Center(
                    child: TrazaEmptyState(
                      icon: Icons.folder_open_rounded,
                      title: 'No tienes reportes aún',
                      message: 'Tus reportes aparecerán aquí',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: TrazaThemeTokens.brand(context),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, i) => _ReportCard(report: reports[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (report.status) {
      ReportStatus.pending || ReportStatus.received =>
        TrazaThemeTokens.danger(context),
      ReportStatus.inProgress => TrazaThemeTokens.warning(context),
      ReportStatus.resolved => TrazaThemeTokens.success(context),
    };

    final timeAgo = _timeAgo(report.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: TrazaThemeTokens.bgSurface(context),
        borderRadius: BorderRadius.circular(TrazaRadius.lg),
        border: Border.all(color: TrazaThemeTokens.border(context), width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(TrazaRadius.lg),
                  bottomLeft: Radius.circular(TrazaRadius.lg),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TrazaStatusBadge(report.status),
                        const SizedBox(width: 6),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 10,
                            color: TrazaThemeTokens.textTertiary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${report.type.label} — ${report.location}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TrazaThemeTokens.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      report.id,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: TrazaThemeTokens.textTertiary(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TrazaStepTracker(report.status),
                    if (report.officerNote != null &&
                        report.officerNote!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TrazaThemeTokens.successSub(context),
                          borderRadius:
                              BorderRadius.circular(TrazaRadius.sm),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 13,
                              color: TrazaThemeTokens.successText(context),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                report.officerNote!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: TrazaThemeTokens.successText(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return DateFormat('dd MMM', 'es').format(dt);
  }
}