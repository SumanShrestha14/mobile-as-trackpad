import 'dart:io';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/gesture.dart';
import '../../domain/repositories/connection_repository.dart';
import '../datasources/remote/socket_remote_data_source.dart';
import '../models/device_model.dart';

class ConnectionRepositoryImpl
    implements ConnectionRepository, GestureRepository {
  final SocketRemoteDataSource remote;

  ConnectionRepositoryImpl(this.remote);

  @override
  Future<void> connect(Device device) async {
    try {
      final model = DeviceModel.fromEntity(device);
      await remote.connect(model);
    } on SocketException catch (e) {
      throw ConnectionException(e.message);
    } catch (e) {
      throw ConnectionException(e.toString());
    }
  }

  @override
  Future<void> disconnect() async {
    await remote.disconnect();
  }

  @override
  Future<bool> get isConnected async => remote.isConnected;

  @override
  Future<void> sendGesture(Gesture gesture) async {
    try {
      await remote.sendGesture(gesture);
    } on SocketException catch (e) {
      throw RemoteException(e.message);
    } catch (e) {
      throw RemoteException(e.toString());
    }
  }
}
