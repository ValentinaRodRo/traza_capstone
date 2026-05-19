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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ TrazaColors.bg (era surfaceAlt)
      backgroundColor: TrazaColors.bg,
      appBar: const TrazaAppBar(title: 'Mis reportes'),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(
              // ✅ TrazaColors.brand (era navyMid)
              child: CircularProgressIndicator(color: TrazaColors.brand),
            );
          }

          if (state is ReportError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 40, color: TrazaColors.danger),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: const TextStyle(color: TrazaColors.textSecondary)),
                ],
              ),
            );
          }

          final reports = state is ReportLoaded ? state.reports : <Report>[];

          if (reports.isEmpty) {
            // ✅ TrazaEmptyState — ya existe en shared_widgets, no hace falta
            //    construir el empty state a mano
            return const Center(
              child: TrazaEmptyState(
                icon: Icons.folder_open_rounded,
                title: 'No tienes reportes aún',
                message: 'Tus reportes aparecerán aquí',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) => _ReportCard(report: reports[i]),
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
      ReportStatus.pending || ReportStatus.received => TrazaColors.danger,
      ReportStatus.inProgress => TrazaColors.warning,
      ReportStatus.resolved => TrazaColors.success,
    };

    final timeAgo = _timeAgo(report.createdAt);

    return Container(
      decoration: BoxDecoration(
        // ✅ TrazaColors.bgSurface (era surface)
        color: TrazaColors.bgSurface,
        borderRadius: BorderRadius.circular(TrazaRadius.lg),
        // ✅ TrazaColors.border (era borderLight)
        border: Border.all(color: TrazaColors.border, width: 0.5),
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
                        // ✅ TrazaStatusBadge (era StatusBadge)
                        TrazaStatusBadge(report.status),
                        const SizedBox(width: 6),
                        Text(timeAgo,
                            style: const TextStyle(
                                fontSize: 10,
                                color: TrazaColors.textTertiary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${report.type.label} — ${report.location}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: TrazaColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text(report.id,
                        style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: TrazaColors.textTertiary)),
                    const SizedBox(height: 12),
                    // ✅ TrazaStepTracker (era ReportStepTracker)
                    TrazaStepTracker(report.status),
                    if (report.officerNote != null &&
                        report.officerNote!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          // ✅ TrazaColors.successSub (era successLight)
                          color: TrazaColors.successSub,
                          borderRadius: BorderRadius.circular(TrazaRadius.sm),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined,
                                size: 13, color: TrazaColors.successText),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                report.officerNote!,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: TrazaColors.successText),
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
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return DateFormat('dd MMM', 'es').format(dt);
  }
}