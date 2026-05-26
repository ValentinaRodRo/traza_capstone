import 'dart:async';

/// Servicio singleton para controlar el tab del CitizenShell
/// desde cualquier punto de la app sin depender del árbol de widgets.
class ShellNavigationService {
  final _tabController = StreamController<int>.broadcast();

  Stream<int> get tabStream => _tabController.stream;

  void goToTab(int tab) => _tabController.add(tab);

  void dispose() => _tabController.close();
}