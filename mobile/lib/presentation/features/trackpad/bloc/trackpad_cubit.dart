import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/view_status.dart';
import 'trackpad_state.dart';

class TrackpadCubit extends Cubit<TrackpadState> {
  TrackpadCubit() : super(TrackpadState.initial());

  void markInteraction(String label) {
    emit(state.copyWith(status: ViewStatus.idle, feedback: label));
  }

  void toggleKeyboard() {
    final keyboardVisible = !state.keyboardVisible;
    emit(
      state.copyWith(
        status: ViewStatus.idle,
        keyboardVisible: keyboardVisible,
        feedback: keyboardVisible
            ? 'Keyboard placeholder visible.'
            : 'Keyboard placeholder hidden.',
      ),
    );
  }

  void resetSurface() {
    emit(TrackpadState.initial());
  }
}
