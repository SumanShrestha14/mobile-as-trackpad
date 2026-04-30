import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/theme_repository.dart';
import '../features/settings/bloc/settings_cubit.dart';
import '../features/settings/bloc/settings_state.dart';
import 'app_shell.dart';
import 'app_theme.dart';
import 'navigation/navigation_cubit.dart';

class MobileAsTrackpadApp extends StatelessWidget {
  const MobileAsTrackpadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(
          create: (_) => SettingsCubit(themeRepository: ThemeRepository()),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'Mobile as Trackpad',
            debugShowCheckedModeBanner: false,
            themeMode: settingsState.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
