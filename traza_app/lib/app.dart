import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/navigation/shell_navigation_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_service.dart';
import 'core/widgets/report_sheet.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/auth_pages.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/map/presentation/pages/citizen_map_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/report/presentation/bloc/report_bloc.dart';
import 'features/report/presentation/pages/report_history_page.dart';

class TrazaApp extends StatefulWidget {
  const TrazaApp({super.key});

  @override
  State<TrazaApp> createState() => _TrazaAppState();
}

class _TrazaAppState extends State<TrazaApp> {
  late ThemeMode _themeMode;
  late final StreamSubscription<ThemeMode> _themeSub;

  @override
  void initState() {
    super.initState();
    _themeMode = sl<ThemeService>().current;
    _themeSub = sl<ThemeService>().stream.listen((mode) {
      if (mounted) setState(() => _themeMode = mode);
    });
  }

  @override
  void dispose() {
    _themeSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<ReportBloc>()..add(LoadUserReports())),
      ],
      child: MaterialApp(
        title: 'Traza',
        debugShowCheckedModeBanner: false,
        theme: TrazaTheme.light,
        darkTheme: TrazaTheme.dark,
        themeMode: _themeMode,
        initialRoute: '/',
        routes: {
          '/':         (_) => const SplashPage(),
          '/login':    (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/home':     (_) => const CitizenShell(),
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  CITIZEN SHELL
// ═══════════════════════════════════════════════════════════════════════════════

class CitizenShell extends StatefulWidget {
  const CitizenShell({super.key});

  @override
  State<CitizenShell> createState() => _CitizenShellState();
}

class _CitizenShellState extends State<CitizenShell> {
  int _tab = 0;
  late final StreamSubscription<int> _tabSub;

  // Timestamp de la última carga de reportes — evita recargas innecesarias
  DateTime? _lastReportsLoad;
  static const _reportsStaleAfter = Duration(minutes: 2);

  static const _pages = [
    CitizenMapPage(),
    ReportHistoryPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabSub = sl<ShellNavigationService>().tabStream.listen((tab) {
      if (mounted) _handleTabChange(tab);
    });
  }

  @override
  void dispose() {
    _tabSub.cancel();
    super.dispose();
  }

  bool get _reportsAreStale {
    if (_lastReportsLoad == null) return true;
    return DateTime.now().difference(_lastReportsLoad!) > _reportsStaleAfter;
  }

  void _handleTabChange(int tab) {
    setState(() => _tab = tab);
    if (tab == 1 && _reportsAreStale) {
      _loadReports();
    }
  }

  void _loadReports() {
    context.read<ReportBloc>().add(LoadUserReports());
    _lastReportsLoad = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportSubmitSuccess) {
          // Forzar recarga tras enviar un reporte (ignorar caché)
          _lastReportsLoad = null;
          _loadReports();
        }
      },
      child: Scaffold(
        backgroundColor: TrazaThemeTokens.bg(context),
        body: IndexedStack(index: _tab, children: _pages),
        bottomNavigationBar: _BottomNav(
          currentIndex: _tab,
          onTap: _handleTabChange,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  BOTTOM NAV
// ─────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.map_outlined,           Icons.map_rounded,          'Mapa'),
    (Icons.folder_outlined,        Icons.folder_rounded,       'Mis reportes'),
    (Icons.person_outline_rounded, Icons.person_rounded,       'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: TrazaThemeTokens.bg(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: TrazaThemeTokens.borderFaint(context),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: List.generate(
            _items.length,
            (i) => Expanded(
              child: _NavItem(
                iconInactive: _items[i].$1,
                iconActive:   _items[i].$2,
                label:        _items[i].$3,
                active:       currentIndex == i,
                onTap:        () => onTap(i),
              ),
            ),
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
    final color = active
        ? TrazaThemeTokens.brand(context)
        : TrazaThemeTokens.textTertiary(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? TrazaThemeTokens.bgCard(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? iconActive : iconInactive, color: color, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}