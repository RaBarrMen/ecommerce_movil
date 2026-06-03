import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/firebase_constants.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  ThemeProvider({required this.prefs}) {
    _loadTheme();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void _loadTheme() {
    final saved = prefs.getString(FirebaseConstants.themeModeKey);
    if (saved == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (saved == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setString(
      FirebaseConstants.themeModeKey,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await prefs.setString(
        FirebaseConstants.themeModeKey, mode.name);
    notifyListeners();
  }
}