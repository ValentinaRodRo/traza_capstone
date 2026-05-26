import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_service.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: TrazaScaffold(
        appBar: const TrazaAppBar(
          title: 'Mi perfil',
          subtitle: 'Configuración y preferencias',
          isHome: true,
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _ProfileHeader(),
                const SizedBox(height: 24),

                // ── Apariencia ────────────────────────────────────────────
                TrazaSectionHeader('Apariencia'),
                const SizedBox(height: 10),
                // StreamBuilder para que solo este tile se reconstruya
                // cuando cambia el tema, no toda la página.
                StreamBuilder<ThemeMode>(
                  stream: sl<ThemeService>().stream,
                  initialData: sl<ThemeService>().current,
                  builder: (context, snapshot) {
                    final mode = snapshot.data ?? sl<ThemeService>().current;
                    return _SettingsCard(
                      children: [_ThemeSelector(current: mode)],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ── Notificaciones ────────────────────────────────────────
                TrazaSectionHeader('Notificaciones'),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: [
                    _ToggleTile(
                      icon: Icons.notifications_outlined,
                      iconColor: TrazaThemeTokens.brand(context),
                      iconBg: TrazaThemeTokens.brandSub(context),
                      title: 'Alertas de zona',
                      subtitle: 'Recibe avisos cuando cambia la actividad',
                      value: true,
                      onChanged: (_) {},
                    ),
                    _Divider(),
                    _ToggleTile(
                      icon: Icons.volume_up_outlined,
                      iconColor: TrazaThemeTokens.warning(context),
                      iconBg: TrazaThemeTokens.bgCard(context),
                      title: 'Sonido',
                      subtitle: 'Sonido en alertas importantes',
                      value: false,
                      onChanged: (_) {},
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Privacidad ────────────────────────────────────────────
                TrazaSectionHeader('Privacidad'),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: [
                    _ToggleTile(
                      icon: Icons.shield_outlined,
                      iconColor: TrazaThemeTokens.purple(context),
                      iconBg: TrazaThemeTokens.purpleSub(context),
                      title: 'Reportes anónimos por defecto',
                      subtitle: 'Tu identidad no será visible en nuevos reportes',
                      value: true,
                      onChanged: (_) {},
                    ),
                    _Divider(),
                    _ToggleTile(
                      icon: Icons.location_off_outlined,
                      iconColor: TrazaThemeTokens.textSecondary(context),
                      iconBg: TrazaThemeTokens.bgCard(context),
                      title: 'No compartir ubicación exacta',
                      subtitle: 'Solo muestra la zona, no el punto GPS',
                      value: false,
                      onChanged: (_) {},
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Acerca de ─────────────────────────────────────────────
                TrazaSectionHeader('Acerca de'),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: [
                    _NavTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: TrazaThemeTokens.info(context),
                      iconBg: TrazaThemeTokens.infoSub(context),
                      title: 'Sobre Traza',
                      subtitle: 'Sistema de seguridad ciudadana · Chía',
                      onTap: () {},
                    ),
                    _Divider(),
                    _NavTile(
                      icon: Icons.description_outlined,
                      iconColor: TrazaThemeTokens.textSecondary(context),
                      iconBg: TrazaThemeTokens.bgCard(context),
                      title: 'Términos y privacidad',
                      onTap: () {},
                    ),
                    _Divider(),
                    _NavTile(
                      icon: Icons.code_rounded,
                      iconColor: TrazaThemeTokens.textSecondary(context),
                      iconBg: TrazaThemeTokens.bgCard(context),
                      title: 'Versión',
                      subtitle: '1.0.0',
                      onTap: null,
                      showArrow: false,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Cerrar sesión ─────────────────────────────────────────
                _SettingsCard(
                  children: [
                    _NavTile(
                      icon: Icons.logout_rounded,
                      iconColor: TrazaThemeTokens.danger(context),
                      iconBg: TrazaThemeTokens.dangerSub(context),
                      title: 'Cerrar sesión',
                      titleColor: TrazaThemeTokens.danger(context),
                      onTap: () => _confirmLogout(context),
                      showArrow: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: TrazaThemeTokens.bgOverlay(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: TrazaThemeTokens.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: TrazaThemeTokens.dangerSub(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.logout_rounded,
                  color: TrazaThemeTokens.danger(context), size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              '¿Cerrar sesión?',
              style: TrazaTextStyles.titleMedium.copyWith(
                color: TrazaThemeTokens.textPrimary(context),  // ← context del padre
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tendrás que iniciar sesión de nuevo para acceder a tus reportes.',
              style: TrazaTextStyles.bodyMedium.copyWith(
                color: TrazaThemeTokens.textSecondary(context),  // ← context del padre
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TrazaPrimaryButton(
              label: 'Cerrar sesión',
              backgroundColor: TrazaThemeTokens.danger(context),
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(LogoutEvent());
              },
            ),
            const SizedBox(height: 10),
            TrazaSecondaryButton(
              label: 'Cancelar',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  THEME SELECTOR  (sistema / claro / oscuro)
// ─────────────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  final ThemeMode current;
  const _ThemeSelector({required this.current});

  static const _options = [
    (ThemeMode.system, Icons.brightness_auto_outlined, 'Sistema'),
    (ThemeMode.light,  Icons.light_mode_outlined,      'Claro'),
    (ThemeMode.dark,   Icons.dark_mode_outlined,       'Oscuro'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: TrazaThemeTokens.bgCard(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.contrast_rounded,
                  color: TrazaThemeTokens.textSecondary(context),
                  size: 17,
                ),
              ),
              const SizedBox(width: 12),
              Text('Tema de la app',
                  style: TrazaTextStyles.titleSmall.copyWith(
                    color: TrazaThemeTokens.textPrimary(context),
                  )),
            ],
          ),
          const SizedBox(height: 14),
          // Segmented control de 3 opciones
          Container(
            decoration: BoxDecoration(
              color: TrazaThemeTokens.bgCard(context),
              borderRadius: BorderRadius.circular(TrazaRadius.md),
              border: Border.all(
                color: TrazaThemeTokens.border(context),
                width: 0.5,
              ),
            ),
            child: Row(
              children: _options.map((opt) {
                final (mode, icon, label) = opt;
                final isSelected = current == mode;
                final isLast = opt == _options.last;
                final isFirst = opt == _options.first;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      sl<ThemeService>().setTheme(mode);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TrazaThemeTokens.brand(context)
                            : Colors.transparent,
                        borderRadius: BorderRadius.horizontal(
                          left: isFirst
                              ? const Radius.circular(TrazaRadius.md - 1)
                              : Radius.zero,
                          right: isLast
                              ? const Radius.circular(TrazaRadius.md - 1)
                              : Radius.zero,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : TrazaThemeTokens.textTertiary(context),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : TrazaThemeTokens.textTertiary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PROFILE HEADER
// ─────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TrazaThemeTokens.bgSurface(context),
        borderRadius: TrazaRadius.card,
        border: Border.all(
            color: TrazaThemeTokens.border(context), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: TrazaThemeTokens.brandSub(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: TrazaColors.brand.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(Icons.person_rounded,
                color: TrazaColors.brand, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ciudadano Traza',
                  style: TrazaTextStyles.titleMedium.copyWith(
                    color: TrazaThemeTokens.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 5, height: 5,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: const BoxDecoration(
                        color: TrazaColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      'Chía, Cundinamarca',
                      style: TrazaTextStyles.labelSmall.copyWith(
                        color: TrazaThemeTokens.textTertiary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: TrazaThemeTokens.successSub(context),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'Activo',
              style: TrazaTextStyles.badge
                  .copyWith(color: TrazaThemeTokens.successText(context)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SETTINGS CARD
// ─────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TrazaThemeTokens.bgSurface(context),
        borderRadius: TrazaRadius.card,
        border: Border.all(
            color: TrazaThemeTokens.border(context), width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

// ─────────────────────────────────────────────
//  TOGGLE TILE
// ─────────────────────────────────────────────

class _ToggleTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_ToggleTile> createState() => _ToggleTileState();
}

class _ToggleTileState extends State<_ToggleTile> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: widget.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TrazaTextStyles.titleSmall.copyWith(
                    color: TrazaThemeTokens.textPrimary(context),
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: TrazaTextStyles.labelSmall.copyWith(
                      color: TrazaThemeTokens.textTertiary(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: _value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _value = v);
              widget.onChanged(v);
            },
            activeColor: TrazaColors.brand,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NAV TILE
// ─────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final Color? titleColor;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showArrow;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.titleColor,
    this.subtitle,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TrazaTextStyles.titleSmall.copyWith(
                      color: titleColor ??
                          TrazaThemeTokens.textPrimary(context),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TrazaTextStyles.labelSmall.copyWith(
                        color: TrazaThemeTokens.textTertiary(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right_rounded,
                  size: 18,
                  color: TrazaThemeTokens.textTertiary(context)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DIVIDER INTERNO
// ─────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0.5,
      thickness: 0.5,
      color: TrazaThemeTokens.border(context),
      indent: 62,
    );
  }
}