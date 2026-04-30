import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const String _themeModeKey = 'app_theme_mode';

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeModeKey);

    if (themeModeString == null) {
      return ThemeMode.dark;
    }

    try {
      return ThemeMode.values.byName(themeModeString);
    } catch (_) {
      return ThemeMode.dark;
    }
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(_themeModeKey, themeMode.name);
    if (!saved) {
      throw Exception('Failed to persist theme mode');
    }
  }
}
