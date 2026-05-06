import 'package:flutter/material.dart';

import '../../features/report/domain/entities/report.dart';
import '../theme/app_theme.dart';

// ── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final ReportStatus status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      ReportStatus.pending => ('Sin atender', TrazaColors.dangerLight, TrazaColors.dangerText),
      ReportStatus.received => ('Recibido', TrazaColors.infoLight, TrazaColors.infoText),
      ReportStatus.inProgress => ('En proceso', TrazaColors.warningLight, TrazaColors.warningText),
      ReportStatus.resolved => ('Resuelto', TrazaColors.successLight, TrazaColors.successText),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── Trust Badge ───────────────────────────────────────────────────────────────
class TrustBadge extends StatelessWidget {
  final CitizenTrust? trust;
  const TrustBadge(this.trust, {super.key});

  @override
  Widget build(BuildContext context) {
    if (trust == null) return const SizedBox.shrink();
    final (label, bg, fg, icon) = switch (trust!) {
      CitizenTrust.reliable => ('Ciudadano confiable', TrazaColors.successLight, TrazaColors.successText, '★'),
      CitizenTrust.noRecord => ('Sin registro', const Color(0xFFF1EFE8), const Color(0xFF5F5E5A), '○'),
      CitizenTrust.firstTime => ('Primera vez', TrazaColors.purpleLight, TrazaColors.purple, '◆'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: 9, color: fg)),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
        ],
      ),
    );
  }
}

// ── Report Step Tracker ───────────────────────────────────────────────────────
class ReportStepTracker extends StatelessWidget {
  final ReportStatus status;
  const ReportStepTracker(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final steps = ['Enviado', 'Recibido', 'En proceso', 'Resuelto'];
    final activeIdx = switch (status) {
      ReportStatus.pending => 0,
      ReportStatus.received => 1,
      ReportStatus.inProgress => 2,
      ReportStatus.resolved => 3,
    };

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIdx = (i + 1) ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: stepIdx <= activeIdx
                    ? TrazaColors.success
                    : TrazaColors.borderLight,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final isDone = stepIdx < activeIdx;
        final isActive = stepIdx == activeIdx;
        return Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? TrazaColors.success
                    : isActive
                        ? TrazaColors.warning
                        : TrazaColors.surfaceDim,
                border: isActive
                    ? Border.all(color: TrazaColors.warning, width: 2)
                    : null,
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : isActive
                      ? const SizedBox.shrink()
                      : null,
            ),
            const SizedBox(height: 4),
            Text(
              steps[stepIdx],
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? TrazaColors.warning
                    : isDone
                        ? TrazaColors.success
                        : TrazaColors.textTertiary,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: TrazaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TrazaColors.borderLight, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: valueColor ?? TrazaColors.navyMid),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor ?? TrazaColors.navyMid,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: TrazaColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Primary Button ────────────────────────────────────────────────────────────
class TrazaPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final IconData? icon;

  const TrazaPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? TrazaColors.navyMid,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                  Text(label,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: TrazaColors.textPrimary)),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Traza App Bar ─────────────────────────────────────────────────────────────
class TrazaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;
  final Color? backgroundColor;

  const TrazaAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBack = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? TrazaColors.navyMid,
      elevation: 0,
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: subtitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle!,
                    style: const TextStyle(fontSize: 10, color: Colors.white54)),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            )
          : Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


// ── Form Section Card ─────────────────────────────────────────────────────────
// Reemplaza _SectionCard privado de report_form_page.dart
// Úsalo en cualquier formulario de la app: perfil, configuración, etc.
class FormSectionCard extends StatelessWidget {
  final String? label;
  final Widget child;
  const FormSectionCard({super.key, this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: TrazaSpacing.cardPadding,
      decoration: BoxDecoration(
        color: TrazaColors.surface,
        borderRadius: BorderRadius.circular(TrazaRadius.lg),
        border: Border.all(color: TrazaColors.borderLight, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: TrazaColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: TrazaSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}

// ── Inline Error Banner ───────────────────────────────────────────────────────
// Reemplaza _ErrorBanner privado. Usable en cualquier validación de formulario.
class InlineErrorBanner extends StatelessWidget {
  final String message;
  const InlineErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: TrazaSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: TrazaSpacing.md, vertical: TrazaSpacing.sm),
      decoration: BoxDecoration(
        color: TrazaColors.dangerLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 14, color: TrazaColors.dangerText),
          const SizedBox(width: 6),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 11, color: TrazaColors.dangerText)),
          ),
        ],
      ),
    );
  }
}

// ── Selectable Option Tile ────────────────────────────────────────────────────
// Tile de selección con ícono, título y subtítulo.
// Úsalo para cualquier selector de categoría: tipo de incidente, tipo de usuario, etc.
class SelectableOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableOptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(
            horizontal: TrazaSpacing.md, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? TrazaColors.infoLight : TrazaColors.surfaceAlt,
          borderRadius: BorderRadius.circular(TrazaRadius.md),
          border: Border.all(
            color: isSelected ? TrazaColors.info : TrazaColors.border,
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? TrazaColors.info.withOpacity(0.15)
                    : TrazaColors.surfaceDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected
                    ? TrazaColors.info
                    : TrazaColors.textSecondary,
              ),
            ),
            const SizedBox(width: TrazaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? TrazaColors.infoText
                          : TrazaColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? TrazaColors.info
                            : TrazaColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? TrazaColors.info : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? TrazaColors.info : TrazaColors.border,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Hint Banner ──────────────────────────────────────────────────────────
// Para hints contextuales no bloqueantes.
// Úsalo en formularios, pantallas de detalle, onboarding, etc.
class InfoHintBanner extends StatelessWidget {
  final Widget child;
  const InfoHintBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: TrazaSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: TrazaColors.infoLight,
        borderRadius: BorderRadius.circular(TrazaRadius.md),
        border: Border.all(
            color: TrazaColors.info.withOpacity(0.15), width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 15, color: TrazaColors.info),
          const SizedBox(width: TrazaSpacing.sm),
          Expanded(child: child),
        ],
      ),
    );
  }
}

