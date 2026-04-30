import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState.initial());

  void updateSensitivity(double value) {
    emit(state.copyWith(sensitivity: value));
  }

  void updateScrollSpeed(double value) {
    emit(state.copyWith(scrollSpeed: value));
  }

  void toggleThemeMode(bool isDark) {
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }
}
