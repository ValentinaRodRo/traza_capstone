import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/report.dart';

class ReportSuccessPage extends StatelessWidget {
  final Report report;
  const ReportSuccessPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ TrazaColors.bg (era surfaceAlt)
      backgroundColor: TrazaColors.bg,
      appBar: const TrazaAppBar(title: 'Reporte enviado', showBack: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Success icon ───────────────────────────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                // ✅ TrazaColors.successSub (era successLight)
                color: TrazaColors.successSub,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: TrazaColors.success, size: 44),
            ),
            const SizedBox(height: 20),

            const Text('Reporte recibido',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: TrazaColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Notificado a la Estación de Policía de Chía',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: TrazaColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // ── ID card ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                // ✅ TrazaColors.bgSurface (era surface)
                color: TrazaColors.bgSurface,
                borderRadius: TrazaRadius.card,
                // ✅ TrazaColors.border (era borderLight)
                border: Border.all(color: TrazaColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  const Text('Código de seguimiento',
                      style: TextStyle(
                          fontSize: 11, color: TrazaColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(
                    report.id,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      // ✅ TrazaColors.brand (era navyMid)
                      color: TrazaColors.brand,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ✅ TrazaColors.border (era borderLight)
                  const Divider(height: 1, color: TrazaColors.border),
                  const SizedBox(height: 14),

                  // ── Process tracker ──────────────────────────────────────
                  const Text('Estado del proceso',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TrazaColors.textPrimary)),
                  const SizedBox(height: 14),
                  // ✅ TrazaStepTracker (era ReportStepTracker)
                  TrazaStepTracker(report.status),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ✅ TrazaColors.infoSub (era infoLight)
                      color: TrazaColors.infoSub,
                      borderRadius: BorderRadius.circular(TrazaRadius.sm),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 14, color: TrazaColors.info),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Recibirás actualización en menos de 30 minutos.',
                            style: TextStyle(
                                fontSize: 11, color: TrazaColors.infoText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            TrazaPrimaryButton(
              label: 'Ver mis reportes',
              icon: Icons.folder_open_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 10),
            // ✅ TrazaSecondaryButton (era OutlinedButton.icon manual)
            TrazaSecondaryButton(
              label: 'Volver al mapa',
              icon: Icons.map_outlined,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}