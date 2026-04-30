import 'package:get_it/get_it.dart';

import '../data/datasources/remote/socket_remote_data_source.dart';
import '../data/repositories/connection_repository_impl.dart';
import '../domain/repositories/connection_repository.dart';
import '../domain/usecases/connect_device.dart';
import '../domain/usecases/disconnect_device.dart';
import '../domain/usecases/send_gesture.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Data sources
  sl.registerLazySingleton(() => SocketRemoteDataSource());

  // Repositories - register a single implementation instance and expose as both interfaces
  sl.registerLazySingleton<ConnectionRepositoryImpl>(() => ConnectionRepositoryImpl(sl()));
  sl.registerLazySingleton<ConnectionRepository>(() => sl<ConnectionRepositoryImpl>());
  sl.registerLazySingleton<GestureRepository>(() => sl<ConnectionRepositoryImpl>());

  // Use cases
  sl.registerLazySingleton(() => ConnectDevice(sl<ConnectionRepository>()));
  sl.registerLazySingleton(() => DisconnectDevice(sl<ConnectionRepository>()));
  sl.registerLazySingleton(() => SendGesture(sl<GestureRepository>()));
}
