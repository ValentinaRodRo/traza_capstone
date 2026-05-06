import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/authority/presentation/bloc/authority_bloc.dart';
import 'features/authority/presentation/pages/authority_panel_page.dart';
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
        BlocProvider(create: (_) => sl<ReportBloc>()..add(LoadUserReports())),
        BlocProvider(create: (_) => sl<AuthorityBloc>()..add(LoadAllReports())),
      ],
      child: MaterialApp(
        title: 'Traza',
        debugShowCheckedModeBanner: false,
        theme: TrazaTheme.light,
        home: const RoleSelectionShell(),
      ),
    );
  }
}

class RoleSelectionShell extends StatefulWidget {
  const RoleSelectionShell({super.key});
  @override
  State<RoleSelectionShell> createState() => _RoleSelectionShellState();
}

class _RoleSelectionShellState extends State<RoleSelectionShell> {
  bool _isCitizen = true;
  int _citizenTab = 0;
  int _authorityTab = 0;

  final _citizenPages = const [CitizenMapPage(), ReportFormPage(), ReportHistoryPage()];
  final _authorityPages = const [AuthorityPanelPage()];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Role switcher header
        Container(
          color: TrazaColors.navyDeep,
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 10),
          child: Row(children: [
            Expanded(child: _RoleTab(label: 'Ciudadano', active: _isCitizen,
                onTap: () => setState(() { _isCitizen = true; _citizenTab = 0; }))),
            const SizedBox(width: 8),
            Expanded(child: _RoleTab(label: 'Autoridad local', active: !_isCitizen,
                onTap: () => setState(() { _isCitizen = false; _authorityTab = 0; }))),
          ]),
        ),
        Expanded(
          child: _isCitizen
              ? Scaffold(
                  body: IndexedStack(index: _citizenTab, children: _citizenPages),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: _citizenTab,
                    onTap: (i) => setState(() => _citizenTab = i),
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map_rounded), label: 'Mapa'),
                      BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_rounded), activeIcon: Icon(Icons.add_circle_rounded), label: 'Reportar'),
                      BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder_rounded), label: 'Mis reportes'),
                    ],
                  ),
                )
              : Scaffold(
                  body: IndexedStack(index: _authorityTab, children: _authorityPages),
                ),
        ),
      ],
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _RoleTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: active ? Border.all(color: Colors.white30) : null,
        ),
        child: Center(child: Text(label,
            style: TextStyle(
                color: active ? Colors.white : Colors.white38,
                fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400))),
      ),
    );
  }
}