import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/navigation/shell_navigation_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/report.dart';

class ReportSuccessPage extends StatelessWidget {
  final Report report;
  const ReportSuccessPage({super.key, required this.report});

  void _goToShellTab(BuildContext context, int tab) {
    Navigator.of(context, rootNavigator: true)
        .popUntil((route) => route.settings.name == '/home');
    sl<ShellNavigationService>().goToTab(tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrazaThemeTokens.bg(context),
      appBar: const TrazaAppBar(title: 'Reporte enviado', showBack: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Success icon ─────────────────────────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: TrazaThemeTokens.successSub(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: TrazaThemeTokens.success(context),
                size: 44,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Reporte recibido',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: TrazaThemeTokens.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notificado a la Estación de Policía de Chía',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: TrazaThemeTokens.textSecondary(context),
              ),
            ),
            const SizedBox(height: 24),

            // ── ID card ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: TrazaThemeTokens.bgSurface(context),
                borderRadius: TrazaRadius.card,
                border: Border.all(
                  color: TrazaThemeTokens.border(context),
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Código de seguimiento',
                    style: TextStyle(
                      fontSize: 11,
                      color: TrazaThemeTokens.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.id,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: TrazaThemeTokens.brand(context),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: TrazaThemeTokens.border(context)),
                  const SizedBox(height: 14),
                  Text(
                    'Estado del proceso',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TrazaThemeTokens.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TrazaStepTracker(report.status),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TrazaThemeTokens.infoSub(context),
                      borderRadius: BorderRadius.circular(TrazaRadius.sm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: TrazaThemeTokens.info(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Recibirás actualización en menos de 30 minutos.',
                            style: TextStyle(
                              fontSize: 11,
                              color: TrazaThemeTokens.infoText(context),
                            ),
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
              onPressed: () => _goToShellTab(context, 1),
            ),
            const SizedBox(height: 10),
            TrazaSecondaryButton(
              label: 'Volver al mapa',
              icon: Icons.map_outlined,
              onPressed: () => _goToShellTab(context, 0),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}