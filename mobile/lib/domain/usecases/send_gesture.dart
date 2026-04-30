import '../entities/gesture.dart';
import '../repositories/connection_repository.dart';

class SendGesture {
  final GestureRepository repository;
  SendGesture(this.repository);

  Future<void> call(Gesture gesture) async {
    await repository.sendGesture(gesture);
  }
}
