import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const String _themeModeKey = 'app_theme_mode';

  /// Load saved theme mode from local storage.
  /// Returns [ThemeMode.dark] by default if no preference is saved.
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeModeKey);
    
    if (themeModeString == null) {
      return ThemeMode.dark;
    }
    
    try {
      return ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.dark,
      );
    } catch (_) {
      return ThemeMode.dark;
    }
  }

  /// Save theme mode to local storage.
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode.toString());
  }
}
