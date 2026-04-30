import 'package:flutter_bloc/flutter_bloc.dart';

enum AppTab { connection, trackpad, settings }

extension AppTabX on AppTab {
  String get title => switch (this) {
    AppTab.connection => 'Connection',
    AppTab.trackpad => 'Trackpad',
    AppTab.settings => 'Settings',
  };
}

class NavigationState {
  const NavigationState({required this.index});

  final int index;

  AppTab get currentTab => AppTab.values[index];

  NavigationState copyWith({int? index}) {
    return NavigationState(index: index ?? this.index);
  }
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(index: 0));

  void selectTab(int index) {
    if (index == state.index) {
      return;
    }

    emit(state.copyWith(index: index));
  }
}
