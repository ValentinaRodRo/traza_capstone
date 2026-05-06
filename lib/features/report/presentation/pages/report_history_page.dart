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
      backgroundColor: TrazaColors.surfaceAlt,
      appBar: const TrazaAppBar(title: 'Mis reportes'),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(
              child: CircularProgressIndicator(color: TrazaColors.navyMid),
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: TrazaColors.surfaceDim,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.folder_open_rounded,
                        size: 36, color: TrazaColors.textTertiary),
                  ),
                  const SizedBox(height: 16),
                  const Text('No tienes reportes aún',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: TrazaColors.textPrimary)),
                  const SizedBox(height: 6),
                  const Text('Tus reportes aparecerán aquí',
                      style: TextStyle(
                          fontSize: 13, color: TrazaColors.textSecondary)),
                ],
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
        color: TrazaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TrazaColors.borderLight, width: 0.8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
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
                        StatusBadge(report.status),
                        const SizedBox(width: 6),
                        Text(timeAgo,
                            style: const TextStyle(
                                fontSize: 10, color: TrazaColors.textTertiary)),
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
                    ReportStepTracker(report.status),
                    if (report.officerNote != null && report.officerNote!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TrazaColors.successLight,
                          borderRadius: BorderRadius.circular(10),
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
                                    fontSize: 11, color: TrazaColors.successText),
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