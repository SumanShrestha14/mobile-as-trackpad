import '../repositories/connection_repository.dart';

class DisconnectDevice {
  final ConnectionRepository repository;
  DisconnectDevice(this.repository);

  Future<void> call() async {
    await repository.disconnect();
  }
}
