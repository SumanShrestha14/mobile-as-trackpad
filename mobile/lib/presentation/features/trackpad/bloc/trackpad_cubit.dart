import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/gesture.dart' as domain_gesture;
import '../../../../domain/usecases/send_gesture.dart';
import '../../../shared/models/view_status.dart';
import 'trackpad_state.dart';

class TrackpadCubit extends Cubit<TrackpadState> {
  TrackpadCubit({required this.sendGestureUseCase})
    : super(TrackpadState.initial());

  final SendGesture sendGestureUseCase;

  // Throttling: accumulate deltas and send at fixed rate (60 FPS = 16ms)
  static const int _throttleMs = 16;
  DateTime _lastMoveSent = DateTime.now();
  double _accumulatedDx = 0;
  double _accumulatedDy = 0;
  Timer? _moveFlushTimer;

  void markInteraction(String label) {
    emit(state.copyWith(status: ViewStatus.idle, feedback: label));
  }

  Future<void> sendGesture(domain_gesture.Gesture gesture) async {
    try {
      // For MOVE events, throttle and batch them
      if (gesture.type.name == 'move') {
        _throttleMove(gesture);
        return;
      }

      // For non-move events (TAP, SCROLL), flush pending moves first, then send
      await _flushPendingMove();
      await sendGestureUseCase.call(gesture);
    } catch (e) {
      print('[TrackpadCubit] Error sending gesture: $e');
    }
  }

  void _throttleMove(domain_gesture.Gesture gesture) {
    // Accumulate delta
    _accumulatedDx += gesture.deltaX;
    _accumulatedDy += gesture.deltaY;

    final now = DateTime.now();
    final elapsed = now.difference(_lastMoveSent).inMilliseconds;

    // If enough time has passed, send accumulated movement
    if (elapsed >= _throttleMs) {
      _sendAccumulatedMove(now);
    } else if (_moveFlushTimer == null) {
      // Schedule a flush for the remainder of the throttle window
      final remainingMs = _throttleMs - elapsed;
      _moveFlushTimer = Timer(Duration(milliseconds: remainingMs), () {
        _sendAccumulatedMove(DateTime.now());
      });
    }
  }

  void _sendAccumulatedMove(DateTime sentTime) {
    _moveFlushTimer?.cancel();
    _moveFlushTimer = null;

    if (_accumulatedDx.abs() < 0.01 && _accumulatedDy.abs() < 0.01) {
      // Skip if movement is negligible
      _lastMoveSent = sentTime;
      return;
    }

    sendGestureUseCase.call(
      domain_gesture.Gesture(
        type: domain_gesture.GestureType.move,
        deltaX: _accumulatedDx,
        deltaY: _accumulatedDy,
      ),
    );

    _accumulatedDx = 0;
    _accumulatedDy = 0;
    _lastMoveSent = sentTime;
  }

  Future<void> _flushPendingMove() async {
    _moveFlushTimer?.cancel();
    _moveFlushTimer = null;

    if (_accumulatedDx.abs() > 0.01 || _accumulatedDy.abs() > 0.01) {
      await sendGestureUseCase.call(
        domain_gesture.Gesture(
          type: domain_gesture.GestureType.move,
          deltaX: _accumulatedDx,
          deltaY: _accumulatedDy,
        ),
      );
      _accumulatedDx = 0;
      _accumulatedDy = 0;
    }
  }

  Future<void> sendLeftClick() async {
    await _flushPendingMove();
    await sendGesture(
      domain_gesture.Gesture(
        type: domain_gesture.GestureType.tap,
        clickButton: domain_gesture.ClickButton.left,
        clicks: 1,
      ),
    );
    markInteraction('Left click sent');
  }

  Future<void> sendRightClick() async {
    await _flushPendingMove();
    await sendGesture(
      domain_gesture.Gesture(
        type: domain_gesture.GestureType.tap,
        clickButton: domain_gesture.ClickButton.right,
        clicks: 1,
      ),
    );
    markInteraction('Right click sent');
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
    _moveFlushTimer?.cancel();
    _accumulatedDx = 0;
    _accumulatedDy = 0;
    emit(TrackpadState.initial());
  }

  @override
  Future<void> close() {
    _moveFlushTimer?.cancel();
    return super.close();
  }
}
