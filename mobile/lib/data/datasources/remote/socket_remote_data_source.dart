import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:mobile/domain/entities/gesture.dart';
import 'package:mobile/data/models/device_model.dart';

class SocketRemoteDataSource {
  Socket? _socket;
  StreamSubscription? _sub;
  Timer? _heartbeatTimer;
  int _messageSeq = 0;

  Future<void> connect(DeviceModel device) async {
    await disconnect();
    try {
      _socket = await Socket.connect(
        device.address,
        8765,
        timeout: const Duration(seconds: 5),
      );

      _sub = _socket!.listen(
        (data) {
          final msg = utf8.decode(data);
          debugPrint('[SocketRemoteDataSource] Received: $msg');
        },
        onDone: () {
          _stopHeartbeat();
          _socket = null;
        },
        onError: (e) {
          _stopHeartbeat();
          _socket = null;
          debugPrint('[SocketRemoteDataSource] Socket error: $e');
        },
      );

      await _sendMessage('HELLO', {});
      _startHeartbeat();
    } catch (e) {
      _stopHeartbeat();
      _socket = null;
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _stopHeartbeat();
    await _sub?.cancel();
    _sub = null;
    try {
      await _socket?.close();
    } catch (_) {}
    _socket = null;
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_socket != null) {
        try {
          await _sendMessage('HEARTBEAT', {});
        } catch (e) {
          _stopHeartbeat();
          _socket = null;
          debugPrint('[SocketRemoteDataSource] Heartbeat failed: $e');
        }
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> sendGesture(Gesture gesture) async {
    if (_socket == null) throw SocketException('Not connected');

    if (gesture.type.name == 'move') {
      await _sendMessage('MOVE', {'dx': gesture.deltaX, 'dy': gesture.deltaY});
    } else if (gesture.type.name == 'tap') {
      final button = gesture.clickButton?.name ?? 'left';
      await _sendMessage('TAP', {
        'button': button,
        'clicks': gesture.clicks ?? 1,
      });
    } else if (gesture.type.name == 'scroll') {
      await _sendMessage('SCROLL', {'amount': gesture.deltaY.toInt()});
    }
  }

  Future<void> _sendMessage(String type, Map<String, dynamic> payload) async {
    final socket = _socket;
    if (socket == null) throw SocketException('Not connected');

    _messageSeq++;
    final msg = {'type': type, 'seq': _messageSeq, 'payload': payload};
    final line = '${json.encode(msg)}\n';
    socket.write(line);
    await socket.flush();
  }

  bool get isConnected => _socket != null;
}
