import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/device.dart';
import '../../../../domain/usecases/connect_device.dart';
import '../../../../domain/usecases/disconnect_device.dart';
import '../../../shared/models/view_status.dart';
import 'connection_state.dart';

class ConnectionCubit extends Cubit<ConnectionState> {
  ConnectionCubit({required this.connectDevice, required this.disconnectDevice}) : super(ConnectionState.initial());

  final ConnectDevice connectDevice;
  final DisconnectDevice disconnectDevice;

  void updateIpAddress(String value) {
    emit(state.copyWith(ipAddress: value, status: ViewStatus.idle));
  }

  Future<void> connect() async {
    final ipAddress = state.ipAddress.trim();
    if (ipAddress.isEmpty) {
      emit(
        state.copyWith(
          status: ViewStatus.error,
          message: 'Enter an IP address or add auto-detect later.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ViewStatus.loading, message: 'Connecting to $ipAddress...'));

    try {
      final device = Device(id: ipAddress, name: 'Desktop device', address: ipAddress);
      await connectDevice.call(device);
      emit(state.copyWith(status: ViewStatus.idle, isConnected: true, deviceName: device.name, message: 'Connected to $ipAddress'));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.error, message: 'Failed to connect: ${e.toString()}'));
    }
  }

  Future<void> disconnect() async {
    emit(state.copyWith(status: ViewStatus.loading, message: 'Disconnecting...'));
    try {
      await disconnectDevice.call();
      emit(ConnectionState.initial());
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.error, message: 'Failed to disconnect: ${e.toString()}'));
    }
  }

  void resetError() {
    emit(state.copyWith(status: ViewStatus.idle, message: 'Waiting for a device connection'));
  }
}
