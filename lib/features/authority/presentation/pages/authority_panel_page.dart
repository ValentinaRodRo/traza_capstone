import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../report/domain/entities/report.dart';
import '../bloc/authority_bloc.dart';
import 'authority_detail_page.dart';

class AuthorityPanelPage extends StatefulWidget {
  const AuthorityPanelPage({super.key});

  @override
  State<AuthorityPanelPage> createState() => _AuthorityPanelPageState();
}

class _AuthorityPanelPageState extends State<AuthorityPanelPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthorityBloc>().add(LoadAllReports());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrazaColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: TrazaColors.authorityBlue,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Est. Policía Chía',
                style: TextStyle(fontSize: 10, color: Colors.white54)),
            Text('Panel de reportes',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
        actions: [
          BlocBuilder<AuthorityBloc, AuthorityState>(
            builder: (context, state) {
              final pending = _pendingCount(state);
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                  if (pending > 0)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(
                            color: TrazaColors.danger, shape: BoxShape.circle),
                        child: Center(
                          child: Text('$pending',
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthorityBloc, AuthorityState>(
        builder: (context, state) {
          final reports = _getReports(state);

          return RefreshIndicator(
            color: TrazaColors.authorityBlue,
            onRefresh: () async {
              context.read<AuthorityBloc>().add(LoadAllReports());
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Stats
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.8,
                          children: [
                            StatCard(
                              value: reports.where((r) =>
                                r.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 1)))
                              ).length.toString(),
                              label: 'Nuevos hoy',
                              icon: Icons.new_releases_outlined,
                              valueColor: TrazaColors.authorityBlue,
                            ),
                            StatCard(
                              value: _pendingCount(state).toString(),
                              label: 'Sin atender',
                              icon: Icons.pending_actions_outlined,
                              valueColor: TrazaColors.danger,
                            ),
                            StatCard(
                              value: reports.length.toString(),
                              label: 'Este mes',
                              icon: Icons.calendar_today_outlined,
                              valueColor: TrazaColors.authorityBlue,
                            ),
                            const StatCard(
                              value: '68%',
                              label: 'Tasa respuesta',
                              icon: Icons.insights_rounded,
                              valueColor: TrazaColors.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const SectionHeader('Reportes ciudadanos · Anónimos'),
                      ],
                    ),
                  ),
                ),
                if (state is AuthorityLoading)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: TrazaColors.authorityBlue),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _AuthorityReportCard(
                          report: reports[i],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AuthorityBloc>(),
                                child: AuthorityDetailPage(report: reports[i]),
                              ),
                            ),
                          ),
                        ),
                        childCount: reports.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Report> _getReports(AuthorityState state) {
    return switch (state) {
      AuthorityLoaded(reports: final r) => r,
      AuthorityUpdateSuccess(reports: final r) => r,
      AuthorityUpdating(reports: final r) => r,
      _ => [],
    };
  }

  int _pendingCount(AuthorityState state) {
    final reports = _getReports(state);
    return reports.where((r) =>
        r.status == ReportStatus.pending || r.status == ReportStatus.received).length;
  }
}

class _AuthorityReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;

  const _AuthorityReportCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (report.status) {
      ReportStatus.pending || ReportStatus.received => TrazaColors.danger,
      ReportStatus.inProgress => TrazaColors.warning,
      ReportStatus.resolved => TrazaColors.success,
    };

    final timeAgo = _timeAgo(report.createdAt);
    final isPending = report.status == ReportStatus.pending || report.status == ReportStatus.received;

    return GestureDetector(
      onTap: isPending ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
                          if (report.trustLevel != null) TrustBadge(report.trustLevel),
                          const Spacer(),
                          if (isPending)
                            const Text('Ver →',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: TrazaColors.info,
                                    fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${report.type.label} — ${report.location}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: TrazaColors.textPrimary)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(timeAgo,
                              style: const TextStyle(
                                  fontSize: 11, color: TrazaColors.textTertiary)),
                          const Text(' · ',
                              style: TextStyle(color: TrazaColors.textTertiary)),
                          Text(report.id,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: TrazaColors.textTertiary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: TrazaColors.textSecondary),
                      ),
                      if (report.coincidentReports > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: TrazaColors.dangerLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${report.coincidentReports} reportes coincidentes',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: TrazaColors.dangerText),
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