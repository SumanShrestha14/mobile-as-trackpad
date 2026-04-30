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
  const NavigationState({required this.index})
    : assert(index >= 0 && index < AppTab.values.length);

  final int index;

  AppTab get currentTab => AppTab.values[index];

  NavigationState copyWith({int? index}) {
    return NavigationState(index: index ?? this.index);
  }
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState(index: 0));

  void selectTab(int index) {
    if (index < 0 || index >= AppTab.values.length) {
      return;
    }
    if (index == state.index) {
      return;
    }

    emit(state.copyWith(index: index));
  }
}
