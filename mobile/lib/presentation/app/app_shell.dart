import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/connection/pages/connection_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../features/trackpad/pages/trackpad_page.dart';
import '../shared/widgets/app_scaffold.dart';
import 'navigation/navigation_cubit.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return AppScaffold(
          title: state.currentTab.title,
          body: IndexedStack(
            index: state.index,
            children: const [ConnectionPage(), TrackpadPage(), SettingsPage()],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: state.index,
            onDestinationSelected: context.read<NavigationCubit>().selectTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.link_rounded),
                label: 'Connection',
              ),
              NavigationDestination(
                icon: Icon(Icons.gesture_rounded),
                label: 'Trackpad',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
