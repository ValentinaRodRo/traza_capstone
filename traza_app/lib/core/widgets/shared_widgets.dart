import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/report/domain/entities/report.dart';
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  TRAZA SHARED WIDGETS — shared_widgets.dart
//
//  Component index:
//    Layout
//      · TrazaScaffold          — base scaffold con nav + FAB opcional
//      · TrazaAppBar            — header estándar con logo o back
//      · TrazaBottomNav         — tab bar global con estado activo
//      · TrazaBottomSheet       — sheet modal reutilizable
//
//    Typography & Structure
//      · TrazaSectionHeader     — título uppercase + link acción
//      · TrazaFormSectionCard   — card contenedor para secciones de formulario
//
//    Data Display
//      · TrazaStatCard          — métrica con icono coloreado
//      · TrazaZoneCard          — zona con accent bar lateral
//      · TrazaReportCard        — card de reporte con estado y tracker
//
//    Badges & Status
//      · TrazaBadge             — pill genérico configurable
//      · TrazaStatusBadge       — badge de estado de reporte
//      · TrazaTrustBadge        — badge de confianza ciudadana
//      · TrazaRiskBadge         — badge de nivel de riesgo (mapa)
//
//    Inputs & Forms
//      · TrazaPrimaryButton     — botón principal con gradiente
//      · TrazaSecondaryButton   — botón outlined
//      · TrazaTextField         — input con estilo Traza
//      · TrazaSelectableTile    — tile de selección animado
//
//    Feedback
//      · TrazaInfoBanner        — banner contextual informativo
//      · TrazaErrorBanner       — banner de error inline
//      · TrazaEmptyState        — estado vacío con icono + mensaje
//      · TrazaLoadingSkeleton   — shimmer genérico configurable
//      · TrazaStepTracker       — tracker de pasos de reporte
// ═══════════════════════════════════════════════════════════════════════════════


// ─────────────────────────────────────────────
//  LAYOUT — TrazaScaffold
// ─────────────────────────────────────────────

/// Scaffold base de la app. Todos los pages usan este widget como raíz.
/// Incluye [TrazaBottomNav] si [showBottomNav] es true, y un FAB opcional.
class TrazaScaffold extends StatelessWidget {
  final Widget body;
  final TrazaAppBar? appBar;
  final bool showBottomNav;
  final int currentNavIndex;
  final ValueChanged<int>? onNavTap;
  final Widget? fab;

  const TrazaScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.showBottomNav = false,
    this.currentNavIndex = 0,
    this.onNavTap,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: TrazaColors.bg,
        appBar: appBar,
        body: body,
        bottomNavigationBar: showBottomNav
            ? TrazaBottomNav(
                currentIndex: currentNavIndex,
                onTap: onNavTap ?? (_) {},
              )
            : null,
        floatingActionButton: fab,
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  LAYOUT — TrazaAppBar
// ─────────────────────────────────────────────

/// AppBar estándar Traza.
/// Modo [isHome]: muestra logo T + nombre app + ubicación.
/// Modo normal: muestra título centrado con back opcional.
class TrazaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool isHome;
  final bool showBack;
  final List<Widget>? actions;

  const TrazaAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.isHome = false,
    this.showBack = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: TrazaColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: TrazaColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TrazaColors.border, width: 0.5),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                  color: TrazaColors.textSecondary,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      titleSpacing: isHome ? 0 : NavigationToolbar.kMiddleSpacing,
      title: isHome ? _HomeTitleContent(subtitle: subtitle) : _PageTitleContent(title: title),
      actions: [
        if (actions != null) ...actions!,
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeTitleContent extends StatelessWidget {
  final String? subtitle;
  const _HomeTitleContent({this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Logo box
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TrazaColors.brand, TrazaColors.brandDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: TrazaShadows.brand,
            ),
            child: const Center(
              child: Text('T',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Traza', style: TrazaTextStyles.titleLarge),
              if (subtitle != null)
                Row(
                  children: [
                    Container(
                      width: 5, height: 5,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: const BoxDecoration(
                        color: TrazaColors.brand,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(subtitle!, style: TrazaTextStyles.labelSmall),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageTitleContent extends StatelessWidget {
  final String title;
  const _PageTitleContent({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TrazaTextStyles.titleLarge);
  }
}


// ─────────────────────────────────────────────
//  LAYOUT — TrazaBottomNav
// ─────────────────────────────────────────────

class TrazaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TrazaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (Icons.map_outlined, Icons.map_rounded, 'Mapa'),
    (Icons.description_outlined, Icons.description_rounded, 'Reportes'),
    (Icons.notifications_outlined, Icons.notifications_rounded, 'Alertas'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TrazaColors.bg,
        border: Border(top: BorderSide(color: TrazaColors.borderFaint, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = i == currentIndex;
              return _NavItem(
                iconInactive: item.$1,
                iconActive: item.$2,
                label: item.$3,
                active: active,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(i);
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData iconInactive;
  final IconData iconActive;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconInactive,
    required this.iconActive,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? TrazaColors.brand : TrazaColors.textTertiary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? TrazaColors.bgCard : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? iconActive : iconInactive, color: color, size: 20),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 9, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  LAYOUT — TrazaBottomSheet
// ─────────────────────────────────────────────

/// Sheet modal reutilizable. Llama con [TrazaBottomSheet.show(context, child)].
class TrazaBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool showHandle;

  const TrazaBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.showHandle = true,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: TrazaColors.bgOverlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (_) => TrazaBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: TrazaColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
          if (title != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(title!, style: TrazaTextStyles.titleMedium),
            ),
          ],
          const SizedBox(height: 16),
          child,
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  STRUCTURE — TrazaSectionHeader
// ─────────────────────────────────────────────

class TrazaSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const TrazaSectionHeader(
    this.title, {
    super.key,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title.toUpperCase(), style: TrazaTextStyles.sectionHeader),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: TrazaTextStyles.labelSmall.copyWith(
                    color: TrazaColors.brand,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
}


// ─────────────────────────────────────────────
//  STRUCTURE — TrazaFormSectionCard
// ─────────────────────────────────────────────

class TrazaFormSectionCard extends StatelessWidget {
  final String? label;
  final Widget child;

  const TrazaFormSectionCard({super.key, this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: TrazaSpacing.cardPadding,
      decoration: BoxDecoration(
        color: TrazaColors.bgSurface,
        borderRadius: TrazaRadius.card,
        border: Border.all(color: TrazaColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label!.toUpperCase(), style: TrazaTextStyles.labelSmall),
            const SizedBox(height: TrazaSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  DATA DISPLAY — TrazaStatCard
// ─────────────────────────────────────────────

class TrazaStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color? valueColor;

  const TrazaStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: TrazaColors.bgSurface,
        borderRadius: TrazaRadius.card,
        border: Border.all(color: TrazaColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TrazaTextStyles.statValue.copyWith(
                color: valueColor ?? TrazaColors.textPrimary),
          ),
          const SizedBox(height: 3),
          Text(label, style: TrazaTextStyles.labelSmall),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  DATA DISPLAY — TrazaZoneCard
// ─────────────────────────────────────────────

class TrazaZoneCard extends StatelessWidget {
  final String name;
  final String riskLevel;
  final int reports;
  final String timeAgo;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback? onTap;

  const TrazaZoneCard({
    super.key,
    required this.name,
    required this.riskLevel,
    required this.reports,
    required this.timeAgo,
    required this.accentColor,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: TrazaColors.bgSurface,
          borderRadius: TrazaRadius.card,
          border: Border.all(color: TrazaColors.border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 3, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(11)),
                        child: Icon(Icons.location_on_rounded,
                            color: accentColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: TrazaTextStyles.titleSmall),
                            const SizedBox(height: 2),
                            Text('$reports reportes · $timeAgo',
                                style: TrazaTextStyles.labelSmall),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TrazaRiskBadge(
                        label: riskLevel,
                        color: accentColor,
                        bgColor: bgColor,
                      ),
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
}


// ─────────────────────────────────────────────
//  DATA DISPLAY — TrazaReportCard
// ─────────────────────────────────────────────

class TrazaReportCard extends StatelessWidget {
  final String title;
  final String location;
  final String timeAgo;
  final ReportStatus status;
  final String category;
  final VoidCallback? onTap;

  const TrazaReportCard({
    super.key,
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.status,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TrazaColors.bgSurface,
          borderRadius: TrazaRadius.card,
          border: Border.all(color: TrazaColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: TrazaTextStyles.titleSmall)),
                TrazaStatusBadge(status),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 12, color: TrazaColors.textTertiary),
                const SizedBox(width: 3),
                Expanded(
                    child: Text(location,
                        style: TrazaTextStyles.labelSmall,
                        overflow: TextOverflow.ellipsis)),
                Text(timeAgo, style: TrazaTextStyles.labelSmall),
              ],
            ),
            const SizedBox(height: 12),
            TrazaStepTracker(status),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  BADGES — TrazaBadge (generic)
// ─────────────────────────────────────────────

class TrazaBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const TrazaBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: TrazaRadius.chip),
      child: Text(label,
          style: TrazaTextStyles.badge.copyWith(color: color)),
    );
  }
}


// ─────────────────────────────────────────────
//  BADGES — TrazaStatusBadge
// ─────────────────────────────────────────────

class TrazaStatusBadge extends StatelessWidget {
  final ReportStatus status;
  const TrazaStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      ReportStatus.pending    => ('Sin atender', TrazaColors.dangerSub,  TrazaColors.dangerText),
      ReportStatus.received   => ('Recibido',    TrazaColors.infoSub,    TrazaColors.infoText),
      ReportStatus.inProgress => ('En proceso',  TrazaColors.warningSub, TrazaColors.warningText),
      ReportStatus.resolved   => ('Resuelto',    TrazaColors.successSub, TrazaColors.successText),
    };
    return TrazaBadge(label: label, color: fg, bgColor: bg);
  }
}


// ─────────────────────────────────────────────
//  BADGES — TrazaTrustBadge
// ─────────────────────────────────────────────

class TrazaTrustBadge extends StatelessWidget {
  final CitizenTrust? trust;
  const TrazaTrustBadge(this.trust, {super.key});

  @override
  Widget build(BuildContext context) {
    if (trust == null) return const SizedBox.shrink();
    final (label, bg, fg, icon) = switch (trust!) {
      CitizenTrust.reliable  => ('Ciudadano confiable', TrazaColors.successSub, TrazaColors.successText, '★'),
      CitizenTrust.noRecord  => ('Sin registro',        TrazaColors.bgCard,     TrazaColors.textSecondary, '○'),
      CitizenTrust.firstTime => ('Primera vez',         TrazaColors.purpleSub,  TrazaColors.purpleText, '◆'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: TrazaRadius.chip),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: 9, color: fg)),
          const SizedBox(width: 3),
          Text(label,
              style: TrazaTextStyles.badge.copyWith(color: fg, fontSize: 10)),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  BADGES — TrazaRiskBadge
// ─────────────────────────────────────────────

class TrazaRiskBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const TrazaRiskBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return TrazaBadge(label: label, color: color, bgColor: bgColor);
  }
}


// ─────────────────────────────────────────────
//  INPUTS — TrazaPrimaryButton
// ─────────────────────────────────────────────

class TrazaPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;

  const TrazaPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? TrazaColors.brand,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: TrazaRadius.button),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white)))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: TrazaTextStyles.labelLarge),
                ],
              ),
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  INPUTS — TrazaSecondaryButton
// ─────────────────────────────────────────────

class TrazaSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const TrazaSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: TrazaColors.brand,
          side: const BorderSide(color: TrazaColors.border, width: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: TrazaRadius.button),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label, style: TrazaTextStyles.labelLarge.copyWith(color: TrazaColors.brand)),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  INPUTS — TrazaTextField
// ─────────────────────────────────────────────

class TrazaTextField extends StatelessWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final int maxLines;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const TrazaTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TrazaTextStyles.bodyMedium.copyWith(color: TrazaColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        errorText: errorText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: TrazaColors.textTertiary)
            : null,
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  INPUTS — TrazaSelectableTile
// ─────────────────────────────────────────────

class TrazaSelectableTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const TrazaSelectableTile({
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
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(
            horizontal: TrazaSpacing.md, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? TrazaColors.brandSub : TrazaColors.bgSurface,
          borderRadius: TrazaRadius.input,
          border: Border.all(
            color: isSelected ? TrazaColors.brand : TrazaColors.border,
            width: isSelected ? 1.5 : 0.5,
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
                    ? TrazaColors.brand.withOpacity(0.15)
                    : TrazaColors.bgCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18,
                  color: isSelected
                      ? TrazaColors.brand
                      : TrazaColors.textSecondary),
            ),
            const SizedBox(width: TrazaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TrazaTextStyles.bodyMedium.copyWith(
                          color: isSelected
                              ? TrazaColors.textPrimary
                              : TrazaColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(subtitle!,
                        style: TrazaTextStyles.labelSmall.copyWith(
                            color: isSelected
                                ? TrazaColors.brand
                                : TrazaColors.textTertiary)),
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
                color:
                    isSelected ? TrazaColors.brand : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? TrazaColors.brand
                      : TrazaColors.border,
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


// ─────────────────────────────────────────────
//  FEEDBACK — TrazaInfoBanner
// ─────────────────────────────────────────────

class TrazaInfoBanner extends StatelessWidget {
  final Widget child;

  const TrazaInfoBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: TrazaSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: TrazaColors.infoSub,
        borderRadius: BorderRadius.circular(TrazaRadius.md),
        border: Border.all(
            color: TrazaColors.info.withOpacity(0.2), width: 0.5),
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


// ─────────────────────────────────────────────
//  FEEDBACK — TrazaErrorBanner
// ─────────────────────────────────────────────

class TrazaErrorBanner extends StatelessWidget {
  final String message;

  const TrazaErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: TrazaSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: TrazaSpacing.md, vertical: TrazaSpacing.sm),
      decoration: BoxDecoration(
        color: TrazaColors.dangerSub,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: TrazaColors.danger.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 14, color: TrazaColors.dangerText),
          const SizedBox(width: 6),
          Expanded(
            child: Text(message,
                style: TrazaTextStyles.labelSmall
                    .copyWith(color: TrazaColors.dangerText)),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  FEEDBACK — TrazaEmptyState
// ─────────────────────────────────────────────

class TrazaEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const TrazaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: TrazaColors.bgCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: TrazaColors.border, width: 0.5),
            ),
            child: Icon(icon, size: 28, color: TrazaColors.textTertiary),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: TrazaTextStyles.titleSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message,
              style: TrazaTextStyles.bodyMedium,
              textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            TrazaPrimaryButton(
              label: actionLabel!,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  FEEDBACK — TrazaLoadingSkeleton
// ─────────────────────────────────────────────

class TrazaLoadingSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const TrazaLoadingSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<TrazaLoadingSkeleton> createState() => _TrazaLoadingSkeletonState();
}

class _TrazaLoadingSkeletonState extends State<TrazaLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_animation.value - 1, 0),
            end: Alignment(_animation.value + 1, 0),
            colors: const [
              Color(0xFF1A1E2A),
              Color(0xFF252B3A),
              Color(0xFF1A1E2A),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper para construir un grupo de skeletons que imitan una card de reporte.
class TrazaReportCardSkeleton extends StatelessWidget {
  const TrazaReportCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TrazaColors.bgSurface,
        borderRadius: TrazaRadius.card,
        border: Border.all(color: TrazaColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: TrazaLoadingSkeleton(height: 14)),
              const SizedBox(width: 12),
              TrazaLoadingSkeleton(width: 72, height: 22, borderRadius: 100),
            ],
          ),
          const SizedBox(height: 8),
          const TrazaLoadingSkeleton(height: 10, width: 160),
          const SizedBox(height: 14),
          const TrazaLoadingSkeleton(height: 6),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  FEEDBACK — TrazaStepTracker
// ─────────────────────────────────────────────

class TrazaStepTracker extends StatelessWidget {
  final ReportStatus status;
  const TrazaStepTracker(this.status, {super.key});

  static const _steps = ['Enviado', 'Recibido', 'En proceso', 'Resuelto'];

  int get _activeIdx => switch (status) {
        ReportStatus.pending    => 0,
        ReportStatus.received   => 1,
        ReportStatus.inProgress => 2,
        ReportStatus.resolved   => 3,
      };

  @override
  Widget build(BuildContext context) {
    final idx = _activeIdx;
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIdx = (i + 1) ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: stepIdx <= idx
                    ? TrazaColors.success
                    : TrazaColors.border,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final isDone   = stepIdx < idx;
        final isActive = stepIdx == idx;
        return Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? TrazaColors.success
                    : isActive
                        ? Colors.transparent
                        : TrazaColors.bgCard,
                border: isActive
                    ? Border.all(color: TrazaColors.warning, width: 2)
                    : null,
              ),
              child: isDone
                  ? const Icon(Icons.check_rounded,
                      size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              _steps[stepIdx],
              style: TrazaTextStyles.labelSmall.copyWith(
                fontSize: 8,
                color: isActive
                    ? TrazaColors.warning
                    : isDone
                        ? TrazaColors.success
                        : TrazaColors.textTertiary,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}