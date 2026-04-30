import '../../../shared/models/view_status.dart';

class TrackpadState {
  const TrackpadState({
    required this.status,
    required this.feedback,
    required this.keyboardVisible,
  });

  final ViewStatus status;
  final String feedback;
  final bool keyboardVisible;

  factory TrackpadState.initial() {
    return const TrackpadState(
      status: ViewStatus.empty,
      feedback: 'Touch the surface to see gesture feedback placeholders.',
      keyboardVisible: false,
    );
  }

  TrackpadState copyWith({
    ViewStatus? status,
    String? feedback,
    bool? keyboardVisible,
  }) {
    return TrackpadState(
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      keyboardVisible: keyboardVisible ?? this.keyboardVisible,
    );
  }
}
