import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/theme_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({ThemeRepository? themeRepository})
    : _themeRepository = themeRepository ?? ThemeRepository(),
      super(SettingsState.initial()) {
    _initializeTheme();
  }

  final ThemeRepository _themeRepository;

  Future<void> _initializeTheme() async {
    if (isClosed) return;
    try {
      emit(state.copyWith(isLoading: true));
      final savedTheme = await _themeRepository.getThemeMode();
      if (isClosed) return;
      emit(state.copyWith(themeMode: savedTheme, isLoading: false));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false));
    }
  }

  void updateSensitivity(double value) {
    emit(state.copyWith(sensitivity: value));
  }

  void updateScrollSpeed(double value) {
    emit(state.copyWith(scrollSpeed: value));
  }

  Future<void> toggleThemeMode(bool isDark) async {
    final newTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(themeMode: newTheme));

    try {
      await _themeRepository.saveThemeMode(newTheme);
    } catch (_) {
      // Keep UI theme updated, but persistence failure is non-fatal.
    }
  }
}
