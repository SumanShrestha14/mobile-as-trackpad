import 'package:flutter/material.dart';

class AppTheme {
  static const Color _darkBackground = Color(0xFF07111F);
  static const Color _darkSurface = Color(0xFF0E1A2D);
  static const Color _darkSurfaceVariant = Color(0xFF14233A);
  static const Color _darkPrimary = Color(0xFF5CC8FF);
  static const Color _darkSecondary = Color(0xFF8C9EFF);
  static const Color _lightBackground = Color(0xFFF4F7FB);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceVariant = Color(0xFFE8EEF7);
  static const Color _lightPrimary = Color(0xFF2563EB);
  static const Color _lightSecondary = Color(0xFF0F766E);

  static ThemeData get darkTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _darkPrimary,
          brightness: Brightness.dark,
          surface: _darkSurface,
        ).copyWith(
          primary: _darkPrimary,
          secondary: _darkSecondary,
          surface: _darkSurface,
          surfaceVariant: _darkSurfaceVariant,
          onPrimary: Colors.black,
          onSurface: Colors.white,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkSurface,
        indicatorColor: _darkPrimary.withOpacity(0.16),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? _darkPrimary : Colors.white70);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? _darkPrimary : Colors.white70,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      sliderTheme: const SliderThemeData(
        showValueIndicator: ShowValueIndicator.always,
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _lightPrimary,
          brightness: Brightness.light,
          surface: _lightSurface,
        ).copyWith(
          primary: _lightPrimary,
          secondary: _lightSecondary,
          surface: _lightSurface,
          surfaceVariant: _lightSurfaceVariant,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _lightSurface,
        indicatorColor: _lightPrimary.withOpacity(0.12),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
