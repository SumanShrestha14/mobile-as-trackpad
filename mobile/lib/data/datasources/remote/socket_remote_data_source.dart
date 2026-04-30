import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
      print('[SocketRemoteDataSource] Connecting to ${device.address}:8765');
      _socket = await Socket.connect(
        device.address,
        8765,
        timeout: const Duration(seconds: 5),
      );
      print('[SocketRemoteDataSource] ✓ Connected');

      _sub = _socket!.listen(
        (data) {
          final msg = utf8.decode(data);
          print('[SocketRemoteDataSource] Received: $msg');
        },
        onDone: () {
          print('[SocketRemoteDataSource] Server closed connection');
          _stopHeartbeat();
        },
        onError: (e) {
          print('[SocketRemoteDataSource] ✗ Socket error: $e');
          _stopHeartbeat();
        },
      );

      // Send HELLO handshake
      await _sendMessage('HELLO', {});
      print('[SocketRemoteDataSource] Handshake sent');

      // Start heartbeat to keep connection alive
      _startHeartbeat();
    } catch (e) {
      print('[SocketRemoteDataSource] ✗ Connection failed: $e');
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
          print('[SocketRemoteDataSource] Heartbeat failed: $e');
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

    try {
      if (gesture.type.name == 'move') {
        await _sendMessage('MOVE', {
          'dx': gesture.deltaX,
          'dy': gesture.deltaY,
        });
      } else if (gesture.type.name == 'tap') {
        final button = gesture.clickButton?.name ?? 'left';
        await _sendMessage('TAP', {
          'button': button,
          'clicks': gesture.clicks ?? 1,
        });
      } else if (gesture.type.name == 'scroll') {
        await _sendMessage('SCROLL', {'amount': gesture.deltaY.toInt()});
      }
    } catch (e) {
      print('[SocketRemoteDataSource] Error: $e');
      rethrow;
    }
  }

  Future<void> _sendMessage(String type, Map<String, dynamic> payload) async {
    if (_socket == null) throw SocketException('Not connected');
    _messageSeq++;
    final msg = {'type': type, 'seq': _messageSeq, 'payload': payload};
    final line = json.encode(msg) + '\n';
    _socket!.write(line);
    await _socket!.flush();
  }

  bool get isConnected => _socket != null;
}
