import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  final SharedPreferences _prefs;
  static const _key = 'traza_theme_mode';

  final _controller = StreamController<ThemeMode>.broadcast();
  late ThemeMode _current;

  ThemeService(this._prefs) {
    final stored = _prefs.getString(_key);
    _current = switch (stored) {
      'light'  => ThemeMode.light,
      'dark'   => ThemeMode.dark,
      _        => ThemeMode.system, // default: sistema
    };
  }

  ThemeMode get current => _current;
  Stream<ThemeMode> get stream => _controller.stream;

  Future<void> setTheme(ThemeMode mode) async {
    if (_current == mode) return;
    _current = mode;
    await _prefs.setString(_key, switch (mode) {
      ThemeMode.light  => 'light',
      ThemeMode.dark   => 'dark',
      ThemeMode.system => 'system',
    });
    _controller.add(mode);
  }

  void dispose() => _controller.close();
}