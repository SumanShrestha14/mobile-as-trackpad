import '../../../shared/models/view_status.dart';

class ConnectionState {
  const ConnectionState({
    required this.status,
    required this.deviceName,
    required this.ipAddress,
    required this.isConnected,
    required this.message,
  });

  final ViewStatus status;
  final String deviceName;
  final String ipAddress;
  final bool isConnected;
  final String message;

  factory ConnectionState.initial() {
    return const ConnectionState(
      status: ViewStatus.initial,
      deviceName: 'Desktop device',
      ipAddress: '',
      isConnected: false,
      message: 'Waiting for a device connection',
    );
  }

  ConnectionState copyWith({
    ViewStatus? status,
    String? deviceName,
    String? ipAddress,
    bool? isConnected,
    String? message,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      deviceName: deviceName ?? this.deviceName,
      ipAddress: ipAddress ?? this.ipAddress,
      isConnected: isConnected ?? this.isConnected,
      message: message ?? this.message,
    );
  }
}
