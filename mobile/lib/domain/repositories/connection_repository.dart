import '../entities/device.dart';
import '../entities/gesture.dart';

abstract class ConnectionRepository {
  Future<void> connect(Device device);
  Future<void> disconnect();
  Future<bool> get isConnected;
}

abstract class GestureRepository {
  Future<void> sendGesture(Gesture gesture);
}
