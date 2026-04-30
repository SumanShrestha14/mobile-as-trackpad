import 'package:flutter/material.dart';

import '../../../shared/models/view_status.dart';

class SettingsState {
  const SettingsState({
    required this.status,
    required this.sensitivity,
    required this.scrollSpeed,
    required this.themeMode,
    this.isLoading = false,
  });

  final ViewStatus status;
  final double sensitivity;
  final double scrollSpeed;
  final ThemeMode themeMode;
  final bool isLoading;

  factory SettingsState.initial() {
    return const SettingsState(
      status: ViewStatus.idle,
      sensitivity: 5,
      scrollSpeed: 5,
      themeMode: ThemeMode.dark,
    );
  }

  SettingsState copyWith({
    ViewStatus? status,
    double? sensitivity,
    double? scrollSpeed,
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return SettingsState(
      status: status ?? this.status,
      sensitivity: sensitivity ?? this.sensitivity,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
