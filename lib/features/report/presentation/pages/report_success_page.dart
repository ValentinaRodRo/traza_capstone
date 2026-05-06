import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/report.dart';
import '../bloc/report_bloc.dart';

class ReportSuccessPage extends StatelessWidget {
  final Report report;
  const ReportSuccessPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrazaColors.surfaceAlt,
      appBar: const TrazaAppBar(title: 'Reporte enviado', showBack: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Success icon
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: TrazaColors.successLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TrazaColors.success.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
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
            const Text('Notificado a la Estación de Policía de Chía',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: TrazaColors.textSecondary)),
            const SizedBox(height: 24),

            // ID card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: TrazaColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TrazaColors.borderLight),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  const Text('Código de seguimiento',
                      style: TextStyle(fontSize: 11, color: TrazaColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(
                    report.id,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: TrazaColors.navyMid,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: TrazaColors.borderLight),
                  const SizedBox(height: 14),

                  // Process tracker
                  const Text('Estado del proceso',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TrazaColors.textPrimary)),
                  const SizedBox(height: 14),
                  ReportStepTracker(report.status),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TrazaColors.infoLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 14, color: TrazaColors.info),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Recibirás actualización en menos de 30 minutos.',
                            style: TextStyle(fontSize: 11, color: TrazaColors.infoText),
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
              onPressed: () {
                // Pop back to main and switch to history tab
                Navigator.of(context).pop();
                // The bottom nav switching is handled by the parent
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: TrazaColors.navyMid),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Volver al mapa',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}