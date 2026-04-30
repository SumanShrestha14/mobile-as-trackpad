import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/labeled_slider_tile.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/constants.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import '../widgets/settings_switch_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();
          final isDarkTheme = state.themeMode == ThemeMode.dark;

          return ListView(
            padding: const EdgeInsets.all(kSpacingUnit * 2),
            children: [
              const SectionHeader(
                title: 'Settings',
                subtitle: 'Adjust gesture feel and app appearance.',
              ),
              const SizedBox(height: kSpacingUnit * 2),
              LabeledSliderTile(
                title: 'Sensitivity',
                subtitle: 'Controls how quickly gestures respond.',
                valueLabel: state.sensitivity.toStringAsFixed(1),
                value: state.sensitivity,
                min: 1,
                max: 10,
                onChanged: cubit.updateSensitivity,
              ),
              const SizedBox(height: kSpacingUnit),
              LabeledSliderTile(
                title: 'Scroll speed',
                subtitle: 'Placeholder scroll responsiveness control.',
                valueLabel: state.scrollSpeed.toStringAsFixed(1),
                value: state.scrollSpeed,
                min: 1,
                max: 10,
                onChanged: cubit.updateScrollSpeed,
              ),
              const SizedBox(height: kSpacingUnit),
              SettingsSwitchTile(
                title: 'Theme mode',
                subtitle: isDarkTheme
                    ? 'Dark theme enabled'
                    : 'Light theme enabled',
                icon: isDarkTheme
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                value: isDarkTheme,
                onChanged: (isDark) => cubit.toggleThemeMode(isDark),
              ),
              const SizedBox(height: kSpacingUnit * 2),
              Text(
                'This screen is intentionally UI-only and ready to be bound to persistent preferences later.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
