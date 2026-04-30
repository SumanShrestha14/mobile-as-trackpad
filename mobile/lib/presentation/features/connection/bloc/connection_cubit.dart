import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/view_status.dart';
import 'connection_state.dart';

class ConnectionCubit extends Cubit<ConnectionState> {
  ConnectionCubit() : super(ConnectionState.initial());

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

    emit(
      state.copyWith(
        status: ViewStatus.loading,
        message: 'Connecting to $ipAddress...',
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 900));

    emit(
      state.copyWith(
        status: ViewStatus.idle,
        isConnected: true,
        deviceName: 'Desktop device',
        message: 'Connected to $ipAddress',
      ),
    );
  }

  void resetError() {
    emit(
      state.copyWith(
        status: ViewStatus.idle,
        message: 'Waiting for a device connection',
      ),
    );
  }
}
