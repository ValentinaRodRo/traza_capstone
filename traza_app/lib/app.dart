import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';               // ← nuevo
import 'features/auth/presentation/pages/auth_pages.dart';             // ← nuevo
import 'features/auth/presentation/pages/splash_page.dart';            // ← nuevo
import 'features/map/presentation/pages/citizen_map_page.dart';
import 'features/report/presentation/bloc/report_bloc.dart';
import 'features/report/presentation/pages/report_form_page.dart';
import 'features/report/presentation/pages/report_history_page.dart';

class TrazaApp extends StatelessWidget {
  const TrazaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),                          // ← nuevo
        BlocProvider(create: (_) => sl<ReportBloc>()..add(LoadUserReports())),
      ],
      child: MaterialApp(
        title: 'Traza',
        debugShowCheckedModeBanner: false,
        theme: TrazaTheme.dark,
        initialRoute: '/',                    // ← reemplaza home: CitizenShell()
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

// CitizenShell sin cambios ─────────────────────────────────────────────────────

class CitizenShell extends StatefulWidget {
  const CitizenShell({super.key});
  @override
  State<CitizenShell> createState() => _CitizenShellState();
}

class _CitizenShellState extends State<CitizenShell> {
  int _tab = 0;
  final _pages = const [CitizenMapPage(), ReportFormPage(), ReportHistoryPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined),             activeIcon: Icon(Icons.map_rounded),           label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_rounded),activeIcon: Icon(Icons.add_circle_rounded),    label: 'Reportar'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined),          activeIcon: Icon(Icons.folder_rounded),        label: 'Mis reportes'),
        ],
      ),
    );
  }
}