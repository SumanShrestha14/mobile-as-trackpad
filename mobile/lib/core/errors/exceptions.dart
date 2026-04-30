class ConnectionException implements Exception {
  final String message;
  ConnectionException([this.message = 'Connection error']);

  @override
  String toString() => 'ConnectionException: $message';
}

class RemoteException implements Exception {
  final String message;
  RemoteException([this.message = 'Remote error']);
  @override
  String toString() => 'RemoteException: $message';
}
