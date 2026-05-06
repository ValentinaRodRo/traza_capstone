import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';

class CitizenMapPage extends StatelessWidget {
  const CitizenMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrazaColors.surfaceAlt,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: TrazaColors.navyMid,
            expandedHeight: 56,
            floating: true,
            pinned: true,
            title: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('T',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Traza', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('Chía, Cundinamarca', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map card
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: TrazaColors.navyMid.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Map background
                          Container(
                            color: const Color(0xFFD0DAE4),
                            child: CustomPaint(
                              painter: _MapPainter(),
                              size: Size.infinite,
                            ),
                          ),
                          // Gradient overlay bottom
                          Positioned(
                            bottom: 0, left: 0, right: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                                ),
                              ),
                            ),
                          ),
                          // Label
                          Positioned(
                            bottom: 12, left: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Zonas de riesgo · últimos 30 días',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                                          color: TrazaColors.textPrimary)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Legend
                  Row(
                    children: [
                      const Text('Bajo', style: TextStyle(fontSize: 10, color: TrazaColors.textTertiary)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: const LinearGradient(
                              colors: [TrazaColors.successLight, TrazaColors.warningLight, TrazaColors.danger],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('Alto', style: TextStyle(fontSize: 10, color: TrazaColors.textTertiary)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stats
                  const SectionHeader('Resumen del mes'),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: const [
                      StatCard(value: '47', label: 'Reportes este mes',
                          icon: Icons.bar_chart_rounded),
                      StatCard(value: '3', label: 'Zonas críticas',
                          icon: Icons.warning_amber_rounded,
                          valueColor: TrazaColors.danger),
                      StatCard(value: '68%', label: 'Tasa de respuesta',
                          icon: Icons.check_circle_outline_rounded,
                          valueColor: TrazaColors.success),
                      StatCard(value: '12 min', label: 'Tiempo resp. prom.',
                          icon: Icons.timer_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Alert zones
                  const SectionHeader('Zonas de alerta activas'),
                  _ZoneCard(
                    name: 'Parque central',
                    level: 'CRÍTICO',
                    reports: 23,
                    color: TrazaColors.danger,
                    bg: TrazaColors.dangerLight,
                  ),
                  _ZoneCard(
                    name: 'Zona comercial',
                    level: 'ALTO',
                    reports: 11,
                    color: TrazaColors.warning,
                    bg: TrazaColors.warningLight,
                  ),
                  _ZoneCard(
                    name: 'La Capilla',
                    level: 'BAJO',
                    reports: 4,
                    color: TrazaColors.success,
                    bg: TrazaColors.successLight,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final String name;
  final String level;
  final int reports;
  final Color color;
  final Color bg;

  const _ZoneCard({
    required this.name,
    required this.level,
    required this.reports,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TrazaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TrazaColors.borderLight, width: 0.8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.location_on_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: TrazaColors.textPrimary)),
                const SizedBox(height: 2),
                Text('$reports reportes',
                    style: const TextStyle(fontSize: 12, color: TrazaColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
            child: Text(level,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFD4DDE8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += size.width / 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += size.height / 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Heat zones
    final spots = [
      (size.width * 0.35, size.height * 0.5, 55.0, const Color(0xFFE24B4A)),
      (size.width * 0.62, size.height * 0.3, 38.0, const Color(0xFFEF9F27)),
      (size.width * 0.75, size.height * 0.72, 26.0, const Color(0xFFEF9F27)),
      (size.width * 0.2, size.height * 0.75, 20.0, const Color(0xFF1D9E75)),
    ];

    for (final (cx, cy, r, color) in spots) {
      for (final (radius, opacity) in [(r, 0.2), (r * 0.6, 0.35), (r * 0.3, 0.55)]) {
        canvas.drawCircle(
          Offset(cx, cy),
          radius,
          Paint()..color = color.withOpacity(opacity),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}