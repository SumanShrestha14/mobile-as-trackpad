import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/gesture.dart' as domain_gesture;
import '../../../../domain/usecases/send_gesture.dart';
import '../../../shared/models/view_status.dart';
import 'trackpad_state.dart';

class TrackpadCubit extends Cubit<TrackpadState> {
  TrackpadCubit({required this.sendGestureUseCase})
    : super(TrackpadState.initial());

  final SendGesture sendGestureUseCase;

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
      if (gesture.type.name == 'move') {
        _throttleMove(gesture);
        return;
      }

      await _flushPendingMove();
      await sendGestureUseCase.call(gesture);
    } catch (e) {
      debugPrint('[TrackpadCubit] Error sending gesture: $e');
      rethrow;
    }
  }

  void _throttleMove(domain_gesture.Gesture gesture) {
    _accumulatedDx += gesture.deltaX;
    _accumulatedDy += gesture.deltaY;

    final now = DateTime.now();
    final elapsed = now.difference(_lastMoveSent).inMilliseconds;

    if (elapsed >= _throttleMs) {
      unawaited(_sendAccumulatedMove(now));
    } else if (_moveFlushTimer == null) {
      final remainingMs = _throttleMs - elapsed;
      _moveFlushTimer = Timer(Duration(milliseconds: remainingMs), () {
        unawaited(_sendAccumulatedMove(DateTime.now()));
      });
    }
  }

  Future<void> _sendAccumulatedMove(DateTime sentTime) async {
    _moveFlushTimer?.cancel();
    _moveFlushTimer = null;

    if (_accumulatedDx.abs() < 0.01 && _accumulatedDy.abs() < 0.01) {
      _lastMoveSent = sentTime;
      return;
    }

    final dx = _accumulatedDx;
    final dy = _accumulatedDy;

    await sendGestureUseCase.call(
      domain_gesture.Gesture(
        type: domain_gesture.GestureType.move,
        deltaX: dx,
        deltaY: dy,
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
      await _sendAccumulatedMove(DateTime.now());
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
