import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/report/domain/entities/report.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  TrazaScaffold
// ─────────────────────────────────────────────

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
    final isDark = TrazaThemeTokens.isDark(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // ✅ overlay style adaptativo
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        // ✅ hereda scaffoldBackgroundColor
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
//  TrazaAppBar
// ─────────────────────────────────────────────

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
    final tt = Theme.of(context);
    return AppBar(
      // ✅ hereda appBarTheme completo
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tt.cardTheme.color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: tt.dividerTheme.color ?? TrazaColors.border,
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                  color: TrazaThemeTokens.textSecondary(context),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      titleSpacing: isHome ? 0 : NavigationToolbar.kMiddleSpacing,
      title: isHome
          ? _HomeTitleContent(subtitle: subtitle)
          : _PageTitleContent(title: title),
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
    final tt         = Theme.of(context);
    final brandColor = TrazaThemeTokens.brand(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [brandColor, TrazaColors.brandDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: TrazaShadows.brand,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                'assets/icons/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Traza', style: tt.textTheme.titleLarge),
              if (subtitle != null)
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: brandColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(subtitle!, style: tt.textTheme.labelSmall),
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
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

// ─────────────────────────────────────────────
//  TrazaBottomNav
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
    final tt = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        // ✅ hereda bottomNavigationBarTheme.backgroundColor
        color: tt.bottomNavigationBarTheme.backgroundColor,
        border: Border(
          top: BorderSide(
            color: TrazaThemeTokens.borderFaint(context),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item   = _items[i];
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
    final tt         = Theme.of(context);
    // ✅ colores del bottomNavigationBarTheme
    final activeColor   = tt.bottomNavigationBarTheme.selectedItemColor!;
    final inactiveColor = tt.bottomNavigationBarTheme.unselectedItemColor!;
    final color         = active ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? tt.cardTheme.color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? iconActive : iconInactive, color: color, size: 20),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TrazaBottomSheet
// ─────────────────────────────────────────────

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
      // ✅ hereda bottomSheetTheme.modalBackgroundColor y shape
      isScrollControlled: true,
      builder: (_) => TrazaBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context);
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
                // ✅ adaptativo
                color: tt.dividerTheme.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
          if (title != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // ✅ textTheme adaptativo
              child: Text(title!, style: tt.textTheme.titleMedium),
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
//  TrazaSectionHeader
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
    final tt         = Theme.of(context);
    final brandColor = TrazaThemeTokens.brand(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ✅ sectionHeader no está en textTheme, pero su color es textPrimary
        //    que sí es adaptativo — usamos copyWith sobre el token
        Text(
          title.toUpperCase(),
          style: TrazaTextStyles.sectionHeader.copyWith(
            color: TrazaThemeTokens.textPrimary(context),
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: tt.textTheme.labelSmall?.copyWith(
                color: brandColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  TrazaFormSectionCard
// ─────────────────────────────────────────────

class TrazaFormSectionCard extends StatelessWidget {
  final String? label;
  final Widget child;

  const TrazaFormSectionCard({super.key, this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context);
    return Container(
      padding: TrazaSpacing.cardPadding,
      decoration: BoxDecoration(
        // ✅ surface adaptativo
        color: tt.colorScheme.surface,
        borderRadius: TrazaRadius.card,
        border: Border.all(
          color: tt.dividerTheme.color ?? TrazaColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label!.toUpperCase(), style: tt.textTheme.labelSmall),
            const SizedBox(height: TrazaSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TrazaStatCard
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
    final tt = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: tt.colorScheme.surface,
        borderRadius: TrazaRadius.card,
        border: Border.all(
          color: tt.dividerTheme.color ?? TrazaColors.border,
          width: 0.5,
        ),
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
              color: valueColor ?? TrazaThemeTokens.textPrimary(context),
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: tt.textTheme.labelSmall),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TrazaZoneCard
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
    final tt = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          // ✅ surface adaptativo
          color: tt.colorScheme.surface,
          borderRadius: TrazaRadius.card,
          border: Border.all(
            color: tt.dividerTheme.color ?? TrazaColors.border,
            width: 0.5,
          ),
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
                            Text(name, style: tt.textTheme.titleSmall),
                            const SizedBox(height: 2),
                            Text('$reports reportes · $timeAgo',
                                style: tt.textTheme.labelSmall),
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
//  TrazaReportCard
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
    final tt = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tt.colorScheme.surface,
          borderRadius: TrazaRadius.card,
          border: Border.all(
            color: tt.dividerTheme.color ?? TrazaColors.border,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: tt.textTheme.titleSmall)),
                TrazaStatusBadge(status),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: TrazaThemeTokens.textTertiary(context),
                ),
                const SizedBox(width: 3),
                Expanded(
                    child: Text(location,
                        style: tt.textTheme.labelSmall,
                        overflow: TextOverflow.ellipsis)),
                Text(timeAgo, style: tt.textTheme.labelSmall),
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
//  TrazaBadge
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
//  TrazaStatusBadge
// ─────────────────────────────────────────────

class TrazaStatusBadge extends StatelessWidget {
  final ReportStatus status;
  const TrazaStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ colores adaptativos via TrazaThemeTokens
    final (label, bg, fg) = switch (status) {
      ReportStatus.pending    => ('Sin atender', TrazaThemeTokens.dangerSub(context),  _dangerText(context)),
      ReportStatus.received   => ('Recibido',    TrazaThemeTokens.infoSub(context),    _infoText(context)),
      ReportStatus.inProgress => ('En proceso',  TrazaThemeTokens.warningSub(context), _warningText(context)),
      ReportStatus.resolved   => ('Resuelto',    TrazaThemeTokens.successSub(context), TrazaThemeTokens.successText(context)),
    };
    return TrazaBadge(label: label, color: fg, bgColor: bg);
  }

  Color _dangerText(BuildContext context) => TrazaThemeTokens.isDark(context)
      ? TrazaColors.dangerText : TrazaColorsLight.dangerText;
  Color _infoText(BuildContext context) => TrazaThemeTokens.isDark(context)
      ? TrazaColors.infoText : TrazaColorsLight.infoText;
  Color _warningText(BuildContext context) => TrazaThemeTokens.isDark(context)
      ? TrazaColors.warningText : TrazaColorsLight.warningText;
}

// ─────────────────────────────────────────────
//  TrazaTrustBadge
// ─────────────────────────────────────────────

class TrazaTrustBadge extends StatelessWidget {
  final CitizenTrust? trust;
  const TrazaTrustBadge(this.trust, {super.key});

  @override
  Widget build(BuildContext context) {
    if (trust == null) return const SizedBox.shrink();
    // ✅ adaptativos
    final (label, bg, fg, icon) = switch (trust!) {
      CitizenTrust.reliable  => ('Ciudadano confiable', TrazaThemeTokens.successSub(context), TrazaThemeTokens.successText(context), '★'),
      CitizenTrust.noRecord  => ('Sin registro',        Theme.of(context).cardTheme.color ?? TrazaThemeTokens.bgCard(context), TrazaThemeTokens.textSecondary(context), '○'),
      CitizenTrust.firstTime => ('Primera vez',         TrazaThemeTokens.purpleSub(context),  _purpleText(context), '◆'),
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

  Color _purpleText(BuildContext context) => TrazaThemeTokens.isDark(context)
      ? TrazaColors.purpleText : TrazaColorsLight.purpleText;
}

// ─────────────────────────────────────────────
//  TrazaRiskBadge
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
//  TrazaPrimaryButton
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
    // ✅ hereda elevatedButtonTheme; solo sobreescribe si se pasa backgroundColor
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: backgroundColor != null
            ? ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: TrazaRadius.button),
                elevation: 0,
                shadowColor: Colors.transparent,
              )
            : null,
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  // ✅ textTheme adaptativo
                  Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TrazaSecondaryButton
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
    // ✅ hereda outlinedButtonTheme completamente
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TrazaTextField
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
      // ✅ hereda style de inputDecorationTheme / textTheme
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        errorText: errorText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18,
                color: TrazaThemeTokens.textTertiary(context))
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TrazaSelectableTile
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
    final tt         = Theme.of(context);
    final brandColor = TrazaThemeTokens.brand(context);
    final brandSub   = TrazaThemeTokens.brandSub(context);

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
          // ✅ adaptativos
          color: isSelected ? brandSub : tt.colorScheme.surface,
          borderRadius: TrazaRadius.input,
          border: Border.all(
            color: isSelected ? brandColor : (tt.dividerTheme.color ?? TrazaColors.border),
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
                    ? brandColor.withOpacity(0.15)
                    : tt.cardTheme.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18,
                  color: isSelected
                      ? brandColor
                      : TrazaThemeTokens.textSecondary(context)),
            ),
            const SizedBox(width: TrazaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? TrazaThemeTokens.textPrimary(context)
                          : TrazaThemeTokens.textSecondary(context),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: tt.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? brandColor
                            : TrazaThemeTokens.textTertiary(context),
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
                color: isSelected ? brandColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? brandColor : (tt.dividerTheme.color ?? TrazaColors.border),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TrazaInfoBanner
// ─────────────────────────────────────────────

class TrazaInfoBanner extends StatelessWidget {
  final Widget child;
  const TrazaInfoBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final infoColor = TrazaThemeTokens.info(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: TrazaSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: TrazaThemeTokens.infoSub(context),
        borderRadius: BorderRadius.circular(TrazaRadius.md),
        border: Border.all(color: infoColor.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 15, color: infoColor),
          const SizedBox(width: TrazaSpacing.sm),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TrazaErrorBanner
// ─────────────────────────────────────────────

class TrazaErrorBanner extends StatelessWidget {
  final String message;
  const TrazaErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final dangerColor = TrazaThemeTokens.danger(context);
    final dangerText  = TrazaThemeTokens.isDark(context)
        ? TrazaColors.dangerText : TrazaColorsLight.dangerText;
    return Container(
      margin: const EdgeInsets.only(bottom: TrazaSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: TrazaSpacing.md, vertical: TrazaSpacing.sm),
      decoration: BoxDecoration(
        color: TrazaThemeTokens.dangerSub(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: dangerColor.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 14, color: dangerText),
          const SizedBox(width: 6),
          Expanded(
            child: Text(message,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: dangerText,
                    )),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TrazaEmptyState
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
    final tt = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: tt.cardTheme.color,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: tt.dividerTheme.color ?? TrazaColors.border,
                width: 0.5,
              ),
            ),
            child: Icon(icon, size: 28,
                color: TrazaThemeTokens.textTertiary(context)),
          ),
          const SizedBox(height: 16),
          Text(title, style: tt.textTheme.titleSmall, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message, style: tt.textTheme.bodyMedium, textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            TrazaPrimaryButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TrazaLoadingSkeleton
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
    // ✅ colores del shimmer adaptativos
    final base = TrazaThemeTokens.bgCard(context);
    final highlight = TrazaThemeTokens.isDark(context)
        ? const Color(0xFF252B3A)
        : const Color(0xFFE5E9F5);

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
            colors: [base, highlight, base],
          ),
        ),
      ),
    );
  }
}

class TrazaReportCardSkeleton extends StatelessWidget {
  const TrazaReportCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tt.colorScheme.surface,
        borderRadius: TrazaRadius.card,
        border: Border.all(
          color: tt.dividerTheme.color ?? TrazaColors.border,
          width: 0.5,
        ),
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
//  TrazaStepTracker
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
    final idx           = _activeIdx;
    final successColor  = TrazaThemeTokens.success(context);
    final warningColor  = TrazaThemeTokens.warning(context);
    final borderColor   = TrazaThemeTokens.border(context);
    final tertiary      = TrazaThemeTokens.textTertiary(context);
    final tt            = Theme.of(context);

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIdx = (i + 1) ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: stepIdx <= idx ? successColor : borderColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }
        final stepIdx  = i ~/ 2;
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
                    ? successColor
                    : isActive
                        ? Colors.transparent
                        : tt.cardTheme.color,
                border: isActive
                    ? Border.all(color: warningColor, width: 2)
                    : null,
              ),
              child: isDone
                  ? const Icon(Icons.check_rounded, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              _steps[stepIdx],
              style: tt.textTheme.labelSmall?.copyWith(
                fontSize: 8,
                color: isActive ? warningColor : isDone ? successColor : tertiary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}